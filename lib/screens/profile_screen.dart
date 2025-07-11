import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = '';
  String password = '';
  bool _obscurePassword = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedName = prefs.getString('logged_in_name') ?? '';
    final loadedPassword = prefs.getString('logged_in_password') ?? '';
    setState(() {
      fullName = loadedName;
      password = loadedPassword;
      _nameController.text = loadedName;
      _passwordController.text = loadedPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text('Profile Page', style: GoogleFonts.poppins(color: Colors.black)),
        ),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Name', style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  enabled: false,
                  controller: _nameController,
                  style: GoogleFonts.poppins(),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F3F3),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Designation', style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  enabled: false,
                  initialValue: 'Driver',
                  style: GoogleFonts.poppins(),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F3F3),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
                const SizedBox(height: 16),
                Text('City', style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  enabled: false,
                  initialValue: 'KHI',
                  style: GoogleFonts.poppins(),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F3F3),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Station', style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  enabled: false,
                  initialValue: 'Karachi',
                  style: GoogleFonts.poppins(),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F3F3),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Password', style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(height: 4),
                TextFormField(
                  readOnly: true,
                  controller: _passwordController,
                  style: GoogleFonts.poppins(),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF3F3F3),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 