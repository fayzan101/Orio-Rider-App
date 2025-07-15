import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'forgot_password.dart';
import 'login_screen.dart';
import '../services/user_service.dart';
import 'Pickup.dart';
import 'arrival.dart';
import 'profile_screen.dart';
import 'sidebar_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../Utils/Colors/color_resources.dart';
import '../Utils/custom_snackbar.dart';
import 'dart:async';
import '../controllers/dashboard_card_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/poppins_text.dart';
import 'report_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool showLoginSuccess;
  DashboardScreen({Key? key, this.showLoginSuccess = false}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardCardController cardController = Get.put(DashboardCardController());
  String userName = 'User';
  bool _loginSnackbarShown = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
   
    // Show login success snackbar only once, after first frame
    if (widget.showLoginSuccess && !_loginSnackbarShown) {
      _loginSnackbarShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        customSnackBar('Success', 'Login successful!');
      });
    }
  }

  void _loadUserName() async {
    final userInfo = await UserService.getUserInfo();
    if (userInfo['emp_name'] != null && userInfo['emp_name']!.isNotEmpty) {
      setState(() {
        userName = userInfo['emp_name']!;
      });
    } else {
      final user = await UserService.getUser();
      if (user != null) {
        setState(() {
          userName = user.fullName;
        });
      }
    }
  }

  void _showMenuModal(BuildContext context) {
    Get.to(() => SidebarScreen(
      userName: userName,
      onLogout: () => _showLogoutDialog(context),
      onResetPassword: () {
        Get.back();
        Get.to(() => const ForgotPasswordScreen());
      },
      onProfile: () {
        Get.back();
        Get.to(() => const ProfileScreen());
      },
    ));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 0),
            child: Material(
              color: Colors.transparent,
              child: _LogoutDialog(
                onNo: () => Navigator.of(context).pop(),
                onYes: () async {
                  Navigator.of(context).pop();
                  await UserService.logout();
                  Get.delete<DashboardCardController>();
                  Get.offAll(() => const LoginScreen());
                },
              ),
            ),
          ),
        );
      },
    );
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
          elevation: 1,
          surfaceTintColor: Colors.white,
          scrolledUnderElevation: 1,
          automaticallyImplyLeading: false,
          title: const SafeArea(child: _FlyCourierBranding()),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 28),
              onPressed: () => _showMenuModal(context),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: Text(
                      'Dashboard',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Here is the list of operational process',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF7B7B7B),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 16.0, top: 8.0, bottom: 8.0),
                    child: Obx(() => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.15,
                      children: [
                        if (cardController.showPickup.value)
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const PickupScreen());
                            },
                            child: _DashboardCard(icon: Icons.local_shipping, label: 'Loadsheet'),
                          ),
                        if (cardController.showArrival.value)
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const ArrivalScreen());
                            },
                            child: _DashboardCard(icon: Icons.inventory_2, label: 'Arrival'),
                          ),
                        if (cardController.showManifest.value)
                          _DashboardCard(icon: Icons.list_alt, label: 'Manifest'),
                        if (cardController.showDeManifest.value)
                          _DashboardCard(icon: Icons.assignment_return, label: 'De Manifest'),
                        if (cardController.showCreateSheet.value)
                          _DashboardCard(icon: Icons.create, label: 'Create Sheet'),
                        if (cardController.showDelivery.value)
                          _DashboardCard(icon: Icons.delivery_dining, label: 'Delivery'),
                        if (cardController.showTracking.value)
                          _DashboardCard(icon: Icons.track_changes, label: 'Tracking'),
                        // Always show Report card
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const ReportScreen());
                          },
                          child: _DashboardCard(icon: Icons.bar_chart, label: 'Report'),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  final VoidCallback onNo;
  final VoidCallback onYes;
  const _LogoutDialog({required this.onNo, required this.onYes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.fromLTRB(24, 32, 24, 24 + MediaQuery.of(context).viewPadding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F3FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout, color: Color(0xFF007AFF), size: 48),
          ),
          const SizedBox(height: 24),
          const Text(
            'Are you Sure',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You want to logout',
            style: TextStyle(
              color: Color(0xFF7B7B7B),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F3F3),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onNo,
                  child: const Text('No', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onYes,
                  child: const Text('Yes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlyCourierBranding extends StatelessWidget {
  const _FlyCourierBranding();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: SvgPicture.asset(
        'assets/Frame.svg',
        height: 25,
        colorFilter: const ColorFilter.mode(
          Color(0xFF007AFF),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DashboardCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF007AFF)),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
