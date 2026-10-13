import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// A universal image rendering widget that seamlessly handles:
/// 1. Base64 encoded images (stored in Firestore to avoid Firebase Storage Blaze plan)
/// 2. Remote HTTP/HTTPS network URLs
/// 3. Local asset images
/// 4. Graceful fallback placeholder
class AppImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final String fallbackAsset;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.fallbackAsset = 'assets/dog.jpg',
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImageContent();

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildImageContent() {
    final cleanUrl = imageUrl.trim();

    if (cleanUrl.isEmpty) {
      return _buildFallback();
    }

    // 1. Base64 Data URI or raw Base64 string
    final bool isBase64 = cleanUrl.startsWith('data:image') ||
        cleanUrl.startsWith('data:') ||
        (!cleanUrl.startsWith('http') &&
            !cleanUrl.startsWith('assets/') &&
            cleanUrl.length > 80);

    if (isBase64) {
      try {
        final base64Payload = cleanUrl.contains(',')
            ? cleanUrl.split(',').last.trim()
            : cleanUrl;
        final Uint8List bytes = base64Decode(base64Payload);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } catch (e) {
        return _buildFallback();
      }
    }

    // 2. HTTP / HTTPS Network image
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return Image.network(
        cleanUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.surfaceMuted,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // 3. Local Asset image
    return Image.asset(
      cleanUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Image.asset(
      fallbackAsset,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: AppColors.surfaceMuted,
          child: const Center(
            child: Icon(
              Icons.pets_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
        );
      },
    );
  }
}
