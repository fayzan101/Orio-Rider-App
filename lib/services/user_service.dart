import 'dart:convert';
import 'dart:convert' show base64Encode, utf8;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import '../models/user_model.dart';
import '../config/api_config.dart';
import '../Network/network.dart';

class UserService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _apiKeyKey = 'api_key';
  static const String _baseUrl = 'https://thegoexpress.com';
  static const String _loginEndpoint = '/api/app_login';
  static const String _empCodeKey = 'emp_code';
  static const String _empNameKey = 'emp_name';
  static const String _stationNameKey = 'station_name';
  static const String _userInfoKey = 'user_info';
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';
  
  

  // Save user data to SharedPreferences
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Save API key to SharedPreferences
  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  // Get API key from SharedPreferences
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  // Get user data from SharedPreferences
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  // Get credentials for API calls
  static Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey)?.trim();
    final password = prefs.getString(_passwordKey)?.trim();
    return {
      'email': email,
      'password': password,
    };
  }

  // Get authorization header for API calls
  static Future<String?> getAuthorizationHeader() async {
    final credentials = await getCredentials();
    final email = credentials['email'];
    final password = credentials['password'];
    
    if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
      return '$email:$password';
    }
    return null;
  }

  // Validate login credentials with API
  static Future<bool> validateLoginWithAPI(String email, String password) async {
    final url = 'https://thegoexpress.com/api/app_login';
    try {
      // Trim email and password
      final trimmedEmail = email.trim();
      final trimmedPassword = password.trim();
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': '$trimmedEmail:$trimmedPassword',
      };
      final data = jsonEncode({
        'email': trimmedEmail,
        'password': trimmedPassword,
      });
      
      final responseData = await Network.postApi(url, data, headers);
      final json = responseData is String ? jsonDecode(responseData) : responseData;
      
      // Temporary debugging for correct credentials
      print('=== DEBUG LOGIN ===');
      print('Email provided: $trimmedEmail');
      print('Password provided: $trimmedPassword');
      print('API Response: $json');
      
      // Check if response is null or invalid
      if (json == null) {
        print('Login failed: Null response from server');
        return false;
      }
      
      // Check if status is 0 (failed)
      if (json['status'] == 0) {
        print('Login failed: ${json['message'] ?? 'Invalid credentials'}');
        return false;
      }
      
      // Check if status is 1 (success) and data exists
      if (json['status'] == 1 && json['data'] != null) {
        final data = json['data'];
        
        // Check if response code is 200
        if (data['response'] != 200) {
          print('Login failed: API response code ${data['response']}');
          return false;
        }
        
        // Check if body exists and is a list with data
        if (data['body'] == null || data['body'] is! List || data['body'].isEmpty) {
          print('Login failed: No user data returned');
          return false;
        }
        
        final user = data['body'][0];
        print('User data returned: $user');
        
        // Validate required user fields
        final empCode = user['emp_code']?.toString() ?? '';
        final empName = user['emp_name']?.toString() ?? '';
        final stationName = user['station_name']?.toString() ?? '';
        final returnedEmail = user['email']?.toString() ?? '';
        
        print('Emp Code: "$empCode"');
        print('Emp Name: "$empName"');
        print('Station Name: "$stationName"');
        print('Returned Email: "$returnedEmail"');
        
        // Check if essential user data is present
        if (empCode.isEmpty || empName.isEmpty) {
          print('Login failed: Missing essential user data');
          return false;
        }
        
        // For now, let's be more lenient with email validation
        // Only check email if it's actually returned by the API
        if (returnedEmail.isNotEmpty && returnedEmail.toLowerCase() != trimmedEmail.toLowerCase()) {
          print('Login failed: Email mismatch - API returned different user');
          print('Provided: $trimmedEmail, Returned: $returnedEmail');
          return false;
        }
        
        // If all validations pass, save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('emp_code', empCode);
        await prefs.setString('emp_name', empName);
        await prefs.setString('station_name', stationName);
        await prefs.setString('user_info', jsonEncode(user));
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('logged_in_name', empName);
        await prefs.setString('logged_in_password', trimmedPassword);
        await prefs.setString('arrival', user['arrival']?.toString() ?? '0');
        // Save email for future API calls
        await prefs.setString(_emailKey, trimmedEmail);
        await prefs.setString(_passwordKey, trimmedPassword);
        
        print('Login successful for user: $empName ($empCode)');
        return true;
      } else {
        print('Login failed: Invalid response structure');
        return false;
      }
    } catch (e) {
      print('Exception during login: $e');
      return false;
    }
  }

  // Get user info from SharedPreferences
  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'emp_code': prefs.getString(_empCodeKey),
      'emp_name': prefs.getString(_empNameKey),
      'station_name': prefs.getString(_stationNameKey),
      'arrival': prefs.getString('arrival'),
    };
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('remember_me', false);
  }



} 