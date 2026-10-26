import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.register(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.tomato,
          content: Text(
            authProvider.errorMessage ?? 'Registration failed.',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.cocoa,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppStyle.retroBox(AppColors.peach),
                child: Column(
                  children: [
                    Container(
                      height: 92,
                      width: 92,
                      decoration: BoxDecoration(
                        color: AppColors.butter,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.cocoa,
                          width: 2.8,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cocoa,
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: AppColors.cocoa,
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Join Recipe Rush',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.cocoa,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Create your chef profile and start your recipe journey.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.cocoa,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppStyle.retroBox(AppColors.butter),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        validator: Validators.validateName,
                        decoration: AppStyle.inputDecoration(
                          'Full Name',
                          Icons.person_rounded,
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: emailController,
                        validator: Validators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: AppStyle.inputDecoration(
                          'Email',
                          Icons.email_rounded,
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: passwordController,
                        validator: Validators.validatePassword,
                        obscureText: isPasswordHidden,
                        decoration: AppStyle.inputDecoration(
                          'Password',
                          Icons.lock_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordHidden = !isPasswordHidden;
                              });
                            },
                            icon: Icon(
                              isPasswordHidden
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.cocoa,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: confirmPasswordController,
                        validator: validateConfirmPassword,
                        obscureText: isConfirmPasswordHidden,
                        decoration: AppStyle.inputDecoration(
                          'Confirm Password',
                          Icons.lock_reset_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isConfirmPasswordHidden =
                                !isConfirmPasswordHidden;
                              });
                            },
                            icon: Icon(
                              isConfirmPasswordHidden
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.cocoa,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: AppStyle.retroButton(AppColors.tomato),
                          onPressed:
                          authProvider.isLoading ? null : registerUser,
                          icon: const Icon(Icons.restaurant_menu_rounded),
                          label: authProvider.isLoading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.cocoa,
                              strokeWidth: 3,
                            ),
                          )
                              : const Text('Create Account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}