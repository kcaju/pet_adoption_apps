import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from Camera or Gallery, compress it, and return a Base64 data URI string.
  /// Using compressed Base64 allows storing images in Firestore without requiring Firebase Storage Blaze plan.
  static Future<String?> pickAndCompressImage({
    required ImageSource source,
    int maxWidth = 700,
    int maxHeight = 700,
    int quality = 70,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (pickedFile == null) return null;

      final bytes = await pickedFile.readAsBytes();
      if (bytes.isEmpty) return null;

      // Base64 Data URI format (compatible with web, Firestore, and memory decoder)
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Error picking/compressing image: $e');
      return null;
    }
  }

  /// Show a beautiful bottom sheet allowing the user to select between Camera and Gallery
  static void showImageSourceSheet(
    BuildContext context, {
    required ValueChanged<String> onImagePicked,
    String title = 'Upload Photo',
    String subtitle = 'Select image source from your device',
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSourceTile(
                  icon: Icons.photo_library_rounded,
                  iconColor: AppColors.primary,
                  backgroundColor: AppColors.primaryLight,
                  title: 'Choose from Gallery',
                  subtitle: 'Select an existing photo from device',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final result = await pickAndCompressImage(
                      source: ImageSource.gallery,
                    );
                    if (result != null) {
                      onImagePicked(result);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildSourceTile(
                  icon: Icons.camera_alt_rounded,
                  iconColor: AppColors.secondary,
                  backgroundColor: AppColors.secondaryLight,
                  title: 'Take a Photo',
                  subtitle: 'Capture a new picture using camera',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final result = await pickAndCompressImage(
                      source: ImageSource.camera,
                    );
                    if (result != null) {
                      onImagePicked(result);
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSourceTile({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
