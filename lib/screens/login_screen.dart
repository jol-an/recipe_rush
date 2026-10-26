import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    if (authProvider.errorMessage == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.tomato,
          content: Text(
            authProvider.errorMessage!,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: AppStyle.retroBox(AppColors.butter),
                child: const Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu_rounded,
                      size: 76,
                      color: AppColors.cocoa,
                    ),
                    SizedBox(height: 12),
                    Text(
                      AppText.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.cocoa,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      AppText.tagline,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cocoa,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: AppStyle.retroBox(AppColors.peach),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back, chef!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cocoa,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Log in and continue your tasty recipe adventure.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.cocoa,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 24),

                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                        decoration: AppStyle.inputDecoration(
                          'Email',
                          Icons.email_rounded,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        validator: Validators.validatePassword,
                        decoration: AppStyle.inputDecoration(
                          'Password',
                          Icons.lock_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: AppColors.cocoa,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: AppStyle.retroButton(AppColors.tomato),
                          onPressed:
                          authProvider.isLoading ? null : loginUser,
                          child: authProvider.isLoading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColors.cocoa,
                            ),
                          )
                              : const Text('Login'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'No account yet? Create one',
                            style: TextStyle(
                              color: AppColors.cocoa,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  MiniFoodIcon(icon: Icons.local_pizza_rounded),
                  SizedBox(width: 10),
                  MiniFoodIcon(icon: Icons.icecream_rounded),
                  SizedBox(width: 10),
                  MiniFoodIcon(icon: Icons.coffee_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniFoodIcon extends StatelessWidget {
  final IconData icon;

  const MiniFoodIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cocoa,
          width: 2.5,
        ),
      ),
      child: Icon(
        icon,
        color: AppColors.cocoa,
        size: 24,
      ),
    );
  }
}