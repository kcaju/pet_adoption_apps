import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../adopter/adopter_main_screen.dart';
import '../owner/owner_main_screen.dart';
import '../common/widgets/custom_button.dart';
import '../common/widgets/custom_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  final String? initialRole;

  const RegisterScreen({super.key, this.initialRole});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleRegister(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    if (authVM.registerPasswordController.text !=
        authVM.registerConfirmPasswordController.text) {
      AppSnackbar.showError(context, 'Passwords do not match');
      return;
    }

    final success = await authVM.register();

    if (!context.mounted) return;

    if (success) {
      AppSnackbar.showSuccess(
        context,
        'Welcome to Pet Haus as a ${authVM.isOwner ? 'Pet Owner / Shelter' : 'Pet Adopter'}!',
      );
      if (authVM.isOwner) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OwnerMainScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdopterMainScreen()),
          (route) => false,
        );
      }
    } else {
      AppSnackbar.showError(
        context,
        authVM.errorMessage ?? 'Registration failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final isOwner = authVM.isOwner;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2F8),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Background Cat Logo Lottie positioned at the bottom of the screen
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: SizedBox(
                    height: 150,
                    child: Lottie.asset(
                      'assets/catlogo.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Foreground Scrollable Registration Content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFD6E4EE),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Text(
                            'Join Pet Haus 🐾',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Select your account type and start connecting.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Role Toggle Selector Tabs
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        authVM.setSelectedRole('adopter'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: !isOwner
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: !isOwner
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.05),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.volunteer_activism_rounded,
                                            size: 18,
                                            color: !isOwner
                                                ? AppColors.primary
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Adopter',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: !isOwner
                                                  ? AppColors.primary
                                                  : AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        authVM.setSelectedRole('owner'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isOwner
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: isOwner
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.05),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.home_work_rounded,
                                            size: 18,
                                            color: isOwner
                                                ? AppColors.secondary
                                                : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Owner / Shelter',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isOwner
                                                  ? AppColors.secondary
                                                  : AppColors.textMuted,
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
                          const SizedBox(height: 24),

                          // Full Name
                          CustomTextField(
                            controller: authVM.registerNameController,
                            label: isOwner
                                ? 'Organization / Owner Name'
                                : 'Full Name',
                            hint: isOwner
                                ? 'e.g. Happy Paws Shelter'
                                : 'e.g. Alex Taylor',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email
                          CustomTextField(
                            controller: authVM.registerEmailController,
                            label: 'Email Address',
                            hint: 'name@example.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          CustomTextField(
                            controller: authVM.registerPhoneController,
                            label: 'Phone Number (Optional)',
                            hint: '+1 (555) 000-0000',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          CustomTextField(
                            controller: authVM.registerPasswordController,
                            label: 'Password',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: authVM.isRegisterPasswordHidden,
                            suffixIcon: IconButton(
                              icon: Icon(
                                authVM.isRegisterPasswordHidden
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () =>
                                  authVM.toggleRegisterPasswordVisibility(),
                            ),
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
                          const SizedBox(height: 16),

                          // Confirm Password
                          CustomTextField(
                            controller:
                                authVM.registerConfirmPasswordController,
                            label: 'Confirm Password',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: authVM.isRegisterConfirmPasswordHidden,
                            suffixIcon: IconButton(
                              icon: Icon(
                                authVM.isRegisterConfirmPasswordHidden
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () => authVM
                                  .toggleRegisterConfirmPasswordVisibility(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Create Account Button
                          CustomButton(
                            text: 'Register Account',
                            icon: Icons.person_add_rounded,
                            isLoading: authVM.isLoading,
                            backgroundColor: isOwner
                                ? AppColors.secondary
                                : AppColors.primary,
                            onPressed: () => _handleRegister(context),
                          ),
                          const SizedBox(height: 20),

                          // Back to Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: isOwner
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom space that reveals the animated cat Lottie below the card and account text
                  const SizedBox(height: 220),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
