import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'forgot_password.dart';
import 'create_account.dart';
import 'dashboard.dart';
import '../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/Colors/color_resources.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loginError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_resetError);
    _passwordController.addListener(_resetError);
    _passwordController.text = '';
  }

  void _resetError() {
    if (_loginError) {
      setState(() {
        _loginError = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_resetError);
    _passwordController.removeListener(_resetError);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _loginError = false;
      });

      try {
        final isValid = await UserService.validateLoginWithAPI(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (isValid) {
          // Save remember me flag
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('remember_me', _rememberMe);
          await prefs.setInt('loadsheet', 1);
          if (mounted) {
            setState(() {
              _loginError = false;
              _isLoading = false;
            });
            await Future.delayed(const Duration(milliseconds: 800));
            Get.offAll(() => DashboardScreen(showLoginSuccess: true));
          }
        } else {
          if (mounted) {
            setState(() {
              _loginError = true;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid email or password'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing in: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light, // For iOS
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: SafeArea(
            bottom: true,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Center(
                    child: SizedBox(
                      width: 350,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 48),
                          Text(
                            'Sign In',
                            textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "and let's get those orders moving!",
                            textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: GoogleFonts.poppins(
                              color: Color(0xFF888888),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Email field
                          SizedBox(
                            height: 52,
                            child: TextFormField(
                              controller: _emailController,
                              style: GoogleFonts.poppins(color: Color(0xFF222222)),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF222222)),
                                hintText: 'Email',
                                hintStyle: GoogleFonts.poppins(color: Color(0xFF222222)),
                                filled: true,
                                fillColor: Color(0xFFF3F3F3),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _loginError ? Colors.red : Colors.transparent,
                                    width: _loginError ? 2 : 0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red, width: 2),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _loginError ? Colors.red : Color(0xFF007AFF),
                                    width: 2,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _loginError ? Colors.red : Colors.transparent,
                                    width: _loginError ? 2 : 0,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Password field
                          SizedBox(
                            height: 52,
                            child: TextFormField(
                              controller: _passwordController,
                              style: GoogleFonts.poppins(color: Color(0xFF222222)),
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF222222)),
                                hintText: 'Password',
                                hintStyle: GoogleFonts.poppins(color: Color(0xFF222222)),
                                filled: true,
                                fillColor: Color(0xFFF3F3F3),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _loginError ? Colors.red : Colors.transparent,
                                    width: _loginError ? 2 : 0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red, width: 2),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _loginError ? Colors.red : Color(0xFF007AFF),
                                    width: 2,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _loginError ? Colors.red : Colors.transparent,
                                    width: _loginError ? 2 : 0,
                                  ),
                                ),
                                suffixIcon: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF222222).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: Color(0xFF444444),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                // Add minimum password length validation
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: Color(0xFF007AFF),
                                    ),
                                    Text(
                                      'Remember Me',
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: GoogleFonts.poppins(
                                        color: ColorResources.blackColor,
                                        fontSize: mediaQuery.size.width * 0.03,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Get.to(() => const ForgotPasswordScreen());
                                  },
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
                                  child: Text(
                                    'Forgot Password?',
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    style: GoogleFonts.poppins(
                                      color: ColorResources.blackColor,
                                      fontSize: mediaQuery.size.width * 0.03,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF007AFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                              ),
                              onPressed: _isLoading ? null : _signIn,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Sign in',
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}