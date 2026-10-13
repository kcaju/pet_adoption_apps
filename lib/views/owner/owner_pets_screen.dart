import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/pet_viewmodel.dart';
import 'add_edit_pet_screen.dart';
import '../common/widgets/app_image.dart';

class OwnerPetsScreen extends StatelessWidget {
  const OwnerPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final petVM = Provider.of<PetViewModel>(context);
    final ownerPets = petVM.ownerPets;
    final uid = authVM.currentUser?.uid;

    if (uid != null && !petVM.hasLoadedOwnerPets && !petVM.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        petVM.listenToOwnerPets(uid);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Pet Listings'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Pet', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          petVM.initAddPetForm(null);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditPetScreen()),
          );
        },
      ),
      body: petVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            )
          : ownerPets.isEmpty
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
                            Icons.pets_rounded,
                            size: 54,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No Pets Listed Yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'List pets currently looking for a loving home so verified adopters can apply.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            petVM.initAddPetForm(null);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddEditPetScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create First Listing'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: ownerPets.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final pet = ownerPets[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: AppImage(
                                imageUrl: pet.imageUrl,
                                fit: BoxFit.cover,
                                fallbackAsset: 'assets/dog.jpg',
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pet.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: pet.isAdopted
                                            ? AppColors.success.withValues(alpha: 0.15)
                                            : AppColors.secondaryLight,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        pet.isAdopted ? 'Adopted' : 'Available',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: pet.isAdopted
                                              ? AppColors.success
                                              : AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${pet.breed} • ${pet.category}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Fee: ${pet.adoptionFee > 0 ? '\$${pet.adoptionFee.toStringAsFixed(0)}' : 'Free'} • ${pet.location}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: AppColors.textSecondary, size: 20),
                                onPressed: () {
                                  petVM.initAddPetForm(pet);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddEditPetScreen(petToEdit: pet),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppColors.error, size: 20),
                                onPressed: () =>
                                    _confirmDelete(context, petVM, pet.id),
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

  void _confirmDelete(BuildContext context, PetViewModel petVM, String petId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Pet Listing'),
        content: const Text(
          'Are you sure you want to remove this pet listing from Pet Haus?',
        ),
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
              final deleted = await petVM.deletePet(petId);
              if (context.mounted) {
                if (deleted) {
                  AppSnackbar.showSuccess(context, 'Pet listing removed.');
                } else {
                  AppSnackbar.showError(
                      context, petVM.errorMessage ?? 'Failed to delete pet.');
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
