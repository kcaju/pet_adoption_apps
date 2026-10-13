import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/image_helper.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../role_selection/role_selection_screen.dart';
import 'widgets/app_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar & Name Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with Camera Edit Badge
                  GestureDetector(
                    onTap: () => _handleProfilePhotoUpload(context, authVM),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: authVM.isOwner
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: user?.photoUrl != null &&
                                    user!.photoUrl!.isNotEmpty
                                ? AppImage(
                                    imageUrl: user.photoUrl!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    fallbackAsset: 'assets/dog.jpg',
                                  )
                                : Container(
                                    color: AppColors.primaryLight,
                                    alignment: Alignment.center,
                                    child: Text(
                                      user?.name.isNotEmpty == true
                                          ? user!.name.substring(0, 1).toUpperCase()
                                          : 'P',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: authVM.isOwner
                                            ? AppColors.secondary
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        // Loading overlay while saving photo
                        if (authVM.isLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Camera Edit Badge
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: authVM.isOwner
                                  ? AppColors.secondary
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _handleProfilePhotoUpload(context, authVM),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 14),
                    label: const Text(
                      'Change Profile Photo',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name.isNotEmpty == true ? user!.name : 'Pet Lover',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'No email',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: authVM.isOwner
                          ? AppColors.secondaryLight
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          authVM.isOwner
                              ? Icons.home_work_rounded
                              : Icons.pets_rounded,
                          size: 16,
                          color: authVM.isOwner
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          authVM.isOwner
                              ? 'Pet Owner / Shelter'
                              : 'Pet Adopter',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: authVM.isOwner
                                ? AppColors.secondary
                                : AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings & Actions
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Switch App Mode',
                    subtitle: 'Switch between Adopter & Owner views',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectionScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildListTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy & Security',
                    subtitle: 'Firebase Protected Account',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildListTile(
                    icon: Icons.help_outline_rounded,
                    title: 'About Pet Haus',
                    subtitle: 'Version 1.0.0 • MVVM Architecture',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Pet Haus',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'Crafted with Flutter & Firebase',
                        children: const [
                          SizedBox(height: 12),
                          Text(
                            'Pet Haus is your premier destination to connect loving pet adopters with pet shelters and caring owners.',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context, authVM),
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  void _handleProfilePhotoUpload(BuildContext context, AuthViewModel authVM) {
    ImageHelper.showImageSourceSheet(
      context,
      title: 'Update Profile Photo',
      subtitle: 'Pick a photo from your device to save to your profile',
      onImagePicked: (base64Image) async {
        final success = await authVM.updateProfilePhoto(base64Image);
        if (context.mounted) {
          if (success) {
            AppSnackbar.showSuccess(
              context,
              'Profile picture updated successfully!',
            );
          } else {
            AppSnackbar.showError(
              context,
              authVM.errorMessage ?? 'Failed to update profile picture.',
            );
          }
        }
      },
    );
  }

  void _confirmSignOut(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out of Pet Haus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await authVM.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
