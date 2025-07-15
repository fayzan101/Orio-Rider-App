import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'profile_screen.dart';

class SidebarScreen extends StatelessWidget {
  final String userName;
  final VoidCallback onProfile;
  final VoidCallback onResetPassword;
  final VoidCallback onLogout;

  const SidebarScreen({
    Key? key,
    required this.userName,
    required this.onProfile,
    required this.onResetPassword,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF18136E);
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
          automaticallyImplyLeading: false,
          title: const SizedBox.shrink(),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.person, color: darkBlue, size: 32),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            userName.isEmpty || userName == 'Loading...'
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Loading...', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: darkBlue)),
                                  ],
                                )
                              : Text(
                                  'Hi, $userName',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: darkBlue,
                                  ),
                                ),
                            const SizedBox(height: 2),
                            Text(
                              'Good Morning',
                              style: GoogleFonts.poppins(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.person, color: darkBlue),
                      title: Text('Profile', style: GoogleFonts.poppins(color: darkBlue, fontSize: 16)),
                      onTap: onProfile,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: darkBlue),
                      title: Text('Reset Password', style: GoogleFonts.poppins(color: darkBlue, fontSize: 16)),
                      onTap: onResetPassword,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.logout, color: darkBlue),
                      title: Text('Logout', style: GoogleFonts.poppins(color: darkBlue, fontSize: 16)),
                      onTap: onLogout,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
                // Bottom app version text
                SafeArea(
                  top: false,
                  left: false,
                  right: false,
                  bottom: true,
                  child: Center(
                    child: Text(
                      'App Version - V2.00',
                      style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
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