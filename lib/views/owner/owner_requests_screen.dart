import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/adoption_viewmodel.dart';
import '../common/widgets/app_image.dart';

class OwnerRequestsScreen extends StatelessWidget {
  const OwnerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final adoptionVM = Provider.of<AdoptionViewModel>(context);
    final requests = adoptionVM.ownerRequests;
    final uid = authVM.currentUser?.uid;

    if (uid != null && !adoptionVM.hasLoadedOwnerRequests && !adoptionVM.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        adoptionVM.listenToOwnerRequests(uid);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Adoption Applications'),
        automaticallyImplyLeading: false,
      ),
      body: adoptionVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            )
          : requests.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inbox_rounded,
                            size: 54,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No Applications Yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'When adopters send requests for your pets, they will appear here for you to review and approve.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pet Info Header
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: AppImage(
                                    imageUrl: req.petImageUrl,
                                    fit: BoxFit.cover,
                                    fallbackAsset: 'assets/dog.jpg',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Applying for ${req.petName}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (req.petBreed.isNotEmpty)
                                      Text(
                                        req.petBreed,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              _buildStatusBadge(req.status),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Applicant Details
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person_rounded,
                                        size: 16, color: AppColors.secondary),
                                    const SizedBox(width: 6),
                                    Text(
                                      req.adopterName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined,
                                        size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      req.adopterEmail,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    if (req.adopterPhone.isNotEmpty) ...[
                                      const SizedBox(width: 12),
                                      const Icon(Icons.phone_outlined,
                                          size: 14, color: AppColors.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        req.adopterPhone,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Message
                          const Text(
                            'Applicant Message:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${req.message}"',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Action Buttons (if pending)
                          if (req.isPending)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final success = await adoptionVM
                                          .updateRequestStatus(
                                        requestId: req.id,
                                        petId: req.petId,
                                        status: 'rejected',
                                      );
                                      if (context.mounted && success) {
                                        AppSnackbar.showInfo(
                                            context, 'Application declined.');
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(
                                          color: AppColors.error),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final success = await adoptionVM
                                          .updateRequestStatus(
                                        requestId: req.id,
                                        petId: req.petId,
                                        status: 'approved',
                                      );
                                      if (context.mounted && success) {
                                        AppSnackbar.showSuccess(
                                          context,
                                          'Application approved! Pet marked as adopted.',
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: const Text('Approve'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
        bg = const Color(0xFFD1FAE5);
        fg = AppColors.success;
        label = 'Approved';
        break;
      case 'rejected':
        bg = const Color(0xFFFEE2E2);
        fg = AppColors.error;
        label = 'Declined';
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = 'Pending Review';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
