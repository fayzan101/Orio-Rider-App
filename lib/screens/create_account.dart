import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dashboard.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _obscurePassword = true;
  bool _obscureRePassword = true;
  bool _agreed = false;
  
  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  
  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _rePasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final user = UserModel(
          email: _emailController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        await UserService.saveUser(user);
        
        if (mounted) {
          Get.offAll(() => DashboardScreen());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light, // For iOS
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w400),
                        filled: true,
                        fillColor: Color(0xFFF3F3F3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Full Name field
                    TextFormField(
                      controller: _fullNameController,
                      style: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Full Name',
                        hintStyle: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w400),
                        filled: true,
                        fillColor: Color(0xFFF3F3F3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Phone Number field
                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        hintStyle: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w400),
                        filled: true,
                        fillColor: Color(0xFFF3F3F3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w400),
                        filled: true,
                        fillColor: Color(0xFFF3F3F3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Color(0xFFBDBDBD),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Re-Enter Password field
                    TextFormField(
                      controller: _rePasswordController,
                      style: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Re-Enter Password',
                        hintStyle: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w400),
                        filled: true,
                        fillColor: Color(0xFFF3F3F3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureRePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Color(0xFFBDBDBD),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureRePassword = !_obscureRePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureRePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please re-enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreed,
                          onChanged: (val) {
                            setState(() {
                              _agreed = val ?? false;
                            });
                          },
                          activeColor: Color(0xFF18136E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'I have read and agreed to the Privacy Policy and Terms and Conditions',
                            style: TextStyle(
                              color: Color(0xFF222222),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF18136E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _agreed ? _createAccount : null,
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Color(0xFF7B7B7B),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: Color(0xFF18136E),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
