import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/pet_viewmodel.dart';
import '../onboarding/onboarding_screen.dart';
import '../role_selection/role_selection_screen.dart';
import '../adopter/adopter_main_screen.dart';
import '../owner/owner_main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _handleNavigation(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final petVM = Provider.of<PetViewModel>(context, listen: false);

      petVM.seedInitialData();

      final results = await Future.wait([
        Future.delayed(const Duration(milliseconds: 2200)),
        authVM.checkAuthStatus(),
        authVM.hasSeenOnboarding(),
      ]);

      if (!context.mounted) return;

      final isAuthenticated = results[1] as bool;
      final hasSeenOnboarding = results[2] as bool;

      if (isAuthenticated && authVM.currentUser != null) {
        if (authVM.isOwner) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OwnerMainScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdopterMainScreen()),
          );
        }
      } else {
        if (!hasSeenOnboarding) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _handleNavigation(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3ED), Color(0xFFFFECE5), Color(0xFFFFDFD3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App Icon Image Card
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/appicon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(22),
                      child: Image.asset(
                        'assets/paws.png',
                        errorBuilder: (ctx, err, st) => const Icon(
                          Icons.pets_rounded,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // App Name
              const Text(
                'Pet Haus',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              // Tagline
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 2,
                    width: 24,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Where Hearts Find Homes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    width: 24,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ],
              ),
              const Spacer(),
              // Bottom Progress Indicator
              Column(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Connecting paws & people...',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
