import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../adopter/adopter_main_screen.dart';
import '../owner/owner_main_screen.dart';
import '../common/widgets/custom_button.dart';
import '../common/widgets/custom_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final String? initialRole;

  const LoginScreen({super.key, this.initialRole});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.login();

    if (!context.mounted) return;

    if (success) {
      AppSnackbar.showSuccess(context, 'Welcome back to Pet Haus!');
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
        authVM.errorMessage ?? 'Login failed. Please check your credentials.',
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final emailController = TextEditingController(
      text: authVM.loginEmailController.text,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address to receive password reset instructions.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(ctx);
                final sent = await authVM.sendPasswordReset(email);
                if (context.mounted) {
                  if (sent) {
                    AppSnackbar.showSuccess(
                      context,
                      'Password reset link sent to your email.',
                    );
                  } else {
                    AppSnackbar.showError(
                      context,
                      authVM.errorMessage ?? 'Failed to send reset email.',
                    );
                  }
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final isOwner = authVM.isOwner;

    return Scaffold(
      backgroundColor: const Color(
        0xFFEAF2F8,
      ), // Soft sky blue matching prompt image
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // 1. The White Login Card Positioned Below the Dog Image
              Container(
                margin: const EdgeInsets.only(top: 152),
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 46, 22, 28),
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
                      // Role indicator banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isOwner
                              ? AppColors.secondaryLight
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isOwner
                                ? AppColors.secondary.withValues(alpha: 0.3)
                                : AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isOwner
                                  ? Icons.home_work_rounded
                                  : Icons.volunteer_activism_rounded,
                              color: isOwner
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isOwner
                                    ? 'Logging in as Owner / Shelter'
                                    : 'Logging in as Pet Adopter',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isOwner
                                      ? AppColors.secondary
                                      : AppColors.primaryDark,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                authVM.setSelectedRole(
                                  isOwner ? 'adopter' : 'owner',
                                );
                              },
                              child: Text(
                                'Switch',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isOwner
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      const Text(
                        'Welcome Back! 🐾',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to your account with Firebase credentials.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Email Field
                      CustomTextField(
                        controller: authVM.loginEmailController,
                        label: 'Email Address',
                        hint: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      CustomTextField(
                        controller: authVM.loginPasswordController,
                        label: 'Password',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: authVM.isLoginPasswordHidden,
                        suffixIcon: IconButton(
                          icon: Icon(
                            authVM.isLoginPasswordHidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () =>
                              authVM.toggleLoginPasswordVisibility(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPasswordDialog(context),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Sign In Button
                      CustomButton(
                        text: 'Sign In',
                        icon: Icons.login_rounded,
                        isLoading: authVM.isLoading,
                        onPressed: () => _handleLogin(context),
                      ),
                      const SizedBox(height: 18),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: AppColors.primary,
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

              // 2. The Peeking Dog Image positioned on top of the card
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    height: 230,
                    child: Image.asset(
                      'assets/logindog.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset('assets/dog.jpg', height: 150),
                    ),
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
