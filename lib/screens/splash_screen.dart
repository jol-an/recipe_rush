import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    checkUser();
  }

  Future<void> checkUser() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await authProvider.loadCurrentUser();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget foodTile({
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cocoa,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cocoa,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.cocoa,
        size: size * 0.48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 28,
              left: 24,
              child: foodTile(
                icon: Icons.cookie_rounded,
                color: AppColors.peach,
                size: 54,
              ),
            ),

            Positioned(
              top: 54,
              right: 26,
              child: foodTile(
                icon: Icons.local_pizza_rounded,
                color: AppColors.mint,
                size: 58,
              ),
            ),

            Positioned(
              bottom: 86,
              left: 30,
              child: foodTile(
                icon: Icons.icecream_rounded,
                color: AppColors.pink,
                size: 56,
              ),
            ),

            Positioned(
              bottom: 130,
              right: 28,
              child: foodTile(
                icon: Icons.coffee_rounded,
                color: AppColors.butter,
                size: 54,
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: AppStyle.retroBox(AppColors.tomato),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppColors.butter,
                            borderRadius: BorderRadius.circular(34),
                            border: Border.all(
                              color: AppColors.cocoa,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.cocoa,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            color: AppColors.cocoa,
                            size: 64,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        AppText.appName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.cocoa,
                            width: 2.5,
                          ),
                        ),
                        child: const Text(
                          AppText.tagline,
                          style: TextStyle(
                            color: AppColors.cocoa,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Preparing your kitchen...',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          color: AppColors.butter,
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}