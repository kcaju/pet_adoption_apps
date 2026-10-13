import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/image_helper.dart';
import '../../data/models/pet_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/pet_viewmodel.dart';
import '../common/widgets/app_image.dart';
import '../common/widgets/custom_button.dart';
import '../common/widgets/custom_text_field.dart';

class AddEditPetScreen extends StatefulWidget {
  final PetModel? petToEdit;

  const AddEditPetScreen({super.key, this.petToEdit});

  @override
  State<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends State<AddEditPetScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSave(BuildContext context) async {
    final petVM = Provider.of<PetViewModel>(context, listen: false);

    if (petVM.petImages.isEmpty) {
      AppSnackbar.showError(
        context,
        'Please upload at least 1 photo for your pet.',
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    final success = await petVM.savePetForm(
      user: authVM.currentUser,
      petToEdit: widget.petToEdit,
    );

    if (!context.mounted) return;

    if (success) {
      AppSnackbar.showSuccess(
        context,
        widget.petToEdit != null
            ? 'Pet updated successfully!'
            : 'Pet listing created successfully!',
      );
      Navigator.pop(context);
    } else {
      AppSnackbar.showError(
        context,
        petVM.errorMessage ?? 'Failed to save pet listing.',
      );
    }
  }

  void _pickPhoto(BuildContext context, PetViewModel petVM) {
    if (petVM.petImages.length >= 4) {
      AppSnackbar.showError(
        context,
        'You can upload a maximum of 4 photos per pet.',
      );
      return;
    }
    ImageHelper.showImageSourceSheet(
      context,
      title: 'Upload Pet Photo',
      subtitle: 'Pick pet photo from Camera or Gallery',
      onImagePicked: (base64) => petVM.addPetImage(base64),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petVM = Provider.of<PetViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.petToEdit != null ? 'Edit Pet' : 'Add New Pet'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Photos Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.photo_library_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pet Photos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Upload up to 4 photos from device',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: petVM.petImages.length >= 4
                            ? AppColors.secondaryLight
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: petVM.petImages.length >= 4
                              ? AppColors.secondary
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        '${petVM.petImages.length}/4',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: petVM.petImages.length >= 4
                              ? AppColors.secondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Upload Prompt or Photo Strip
                if (petVM.petImages.isEmpty) ...[
                  GestureDetector(
                    onTap: () => _pickPhoto(context, petVM),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_a_photo_rounded,
                              color: AppColors.secondary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Upload Pet Photos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Select up to 4 photos from camera or gallery',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: petVM.petImages.length < 4
                          ? petVM.petImages.length + 1
                          : petVM.petImages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index < petVM.petImages.length) {
                          final img = petVM.petImages[index];
                          final isCover = index == 0;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 120,
                                height: 130,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isCover
                                        ? AppColors.primary
                                        : AppColors.cardBorder,
                                    width: isCover ? 2.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: AppImage(
                                    imageUrl: img,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (isCover)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Cover',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: GestureDetector(
                                  onTap: () => petVM.removePetImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Add Photo slot
                          return GestureDetector(
                            onTap: () => _pickPhoto(context, petVM),
                            child: Container(
                              width: 110,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      color: AppColors.secondary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Add Photo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  Text(
                                    '${4 - petVM.petImages.length} left',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  if (petVM.petImages.length < 4) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickPhoto(context, petVM),
                        icon: const Icon(
                          Icons.add_a_photo_rounded,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        label: Text(
                          'Upload Another Photo (${petVM.petImages.length}/4)',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.secondary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 20),

                CustomTextField(
                  controller: petVM.petNameController,
                  label: 'Pet Name',
                  hint: 'e.g. Bella, Max, Luna',
                  prefixIcon: Icons.pets_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the pet name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: petVM.petBreedController,
                  label: 'Breed',
                  hint: 'e.g. Golden Retriever, Persian, Dutch',
                  prefixIcon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the pet breed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category & Gender dropdowns
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: petVM.petCategory,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.cardBorder,
                                ),
                              ),
                            ),
                            items: petVM.availableCategories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) petVM.setPetCategory(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: petVM.petGender,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.cardBorder,
                                ),
                              ),
                            ),
                            items: petVM.availableGenders.map((g) {
                              return DropdownMenuItem(value: g, child: Text(g));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) petVM.setPetGender(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Age & Size
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: petVM.petAgeController,
                        label: 'Age',
                        hint: 'e.g. 2 years, 6 months',
                        prefixIcon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Size',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: petVM.petSize,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.cardBorder,
                                ),
                              ),
                            ),
                            items: petVM.availableSizes.map((s) {
                              return DropdownMenuItem(value: s, child: Text(s));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) petVM.setPetSize(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location & Adoption Fee
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: petVM.petLocationController,
                        label: 'Location',
                        hint: 'City, Area',
                        prefixIcon: Icons.location_on_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter location';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CustomTextField(
                        controller: petVM.petFeeController,
                        label: 'Adoption Fee (\$)',
                        hint: '0 for free',
                        prefixIcon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: petVM.petDescriptionController,
                  label: 'Description & Personality',
                  hint:
                      'Describe vaccination status, personality traits, and requirements for the pet home...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a short description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                CustomButton(
                  text: widget.petToEdit != null
                      ? 'Update Listing'
                      : 'Publish Pet Listing',
                  icon: Icons.check_circle_rounded,
                  isLoading: petVM.isSubmitting,
                  backgroundColor: AppColors.secondary,
                  onPressed: () => _handleSave(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
