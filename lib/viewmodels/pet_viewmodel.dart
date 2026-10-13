import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/utils/image_helper.dart';
import '../data/models/pet_model.dart';
import '../data/models/user_model.dart';
import '../data/services/pet_service.dart';

class PetViewModel extends ChangeNotifier {
  final PetService _petService;

  PetViewModel({PetService? petService})
    : _petService = petService ?? PetService();

  List<PetModel> _pets = [];
  List<PetModel> _ownerPets = [];
  final Set<String> _favoriteIds = {};

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Navigation state for Main Screens
  int _adopterNavIndex = 0;
  int _ownerNavIndex = 0;

  int get adopterNavIndex => _adopterNavIndex;
  int get ownerNavIndex => _ownerNavIndex;

  void setAdopterNavIndex(int index) {
    _adopterNavIndex = index;
    notifyListeners();
  }

  void setOwnerNavIndex(int index) {
    _ownerNavIndex = index;
    notifyListeners();
  }

  // Search Controller
  final TextEditingController searchController = TextEditingController();

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    notifyListeners();
  }

  // Add / Edit Pet Form Controllers & State
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController petBreedController = TextEditingController();
  final TextEditingController petAgeController = TextEditingController();
  final TextEditingController petLocationController = TextEditingController();
  final TextEditingController petFeeController = TextEditingController();
  final TextEditingController petDescriptionController =
      TextEditingController();
  final TextEditingController petImageUrlController = TextEditingController();

  String _petCategory = 'Dog';
  String _petGender = 'Male';
  String _petSize = 'Medium';

  String get petCategory => _petCategory;
  String get petGender => _petGender;
  String get petSize => _petSize;

  final List<String> availableCategories = [
    'Dog',
    'Cat',
    'Rabbit',
    'Bird',
    'Other',
  ];
  final List<String> availableGenders = ['Male', 'Female'];
  final List<String> availableSizes = ['Small', 'Medium', 'Large'];

  List<String> _petImages = [];
  List<String> get petImages => _petImages;

  void addPetImage(String base64Image) {
    if (_petImages.length < 4) {
      _petImages.add(base64Image);
      petImageUrlController.text = _petImages.first;
      notifyListeners();
    }
  }

  void removePetImage(int index) {
    if (index >= 0 && index < _petImages.length) {
      _petImages.removeAt(index);
      petImageUrlController.text = _petImages.isNotEmpty ? _petImages.first : '';
      notifyListeners();
    }
  }

  void setPetImages(List<String> images) {
    _petImages = List<String>.from(images.take(4));
    petImageUrlController.text = _petImages.isNotEmpty ? _petImages.first : '';
    notifyListeners();
  }

  void initAddPetForm(PetModel? pet) {
    if (pet != null) {
      petNameController.text = pet.name;
      petBreedController.text = pet.breed;
      petAgeController.text = pet.age;
      petLocationController.text = pet.location;
      petFeeController.text = pet.adoptionFee.toStringAsFixed(0);
      petDescriptionController.text = pet.description;
      _petCategory = pet.category;
      _petGender = pet.gender;
      _petSize = pet.size;
      if (pet.images.isNotEmpty) {
        _petImages = List<String>.from(pet.images.take(4));
      } else if (pet.imageUrl.isNotEmpty) {
        _petImages = [pet.imageUrl];
      } else {
        _petImages = [];
      }
      petImageUrlController.text = _petImages.isNotEmpty ? _petImages.first : '';
    } else {
      petNameController.clear();
      petBreedController.clear();
      petAgeController.text = '1 year';
      petLocationController.text = 'Downtown';
      petFeeController.text = '0';
      petDescriptionController.clear();
      petImageUrlController.clear();
      _petImages = [];
      _petCategory = 'Dog';
      _petGender = 'Male';
      _petSize = 'Medium';
    }
    notifyListeners();
  }

  void setPetCategory(String cat) {
    _petCategory = cat;
    notifyListeners();
  }

  void setPetGender(String gender) {
    _petGender = gender;
    notifyListeners();
  }

  void setPetSize(String size) {
    _petSize = size;
    notifyListeners();
  }

  bool _isUploadingImage = false;
  bool get isUploadingImage => _isUploadingImage;

  void setPetImageUrl(String url) {
    petImageUrlController.text = url;
    if (url.isNotEmpty && !_petImages.contains(url)) {
      if (_petImages.length < 4) {
        _petImages.add(url);
      } else {
        _petImages[0] = url;
      }
    }
    notifyListeners();
  }

  Future<bool> pickPetImageFromSource(ImageSource source) async {
    if (_petImages.length >= 4) return false;
    _isUploadingImage = true;
    notifyListeners();
    try {
      final base64Image = await ImageHelper.pickAndCompressImage(
        source: source,
      );
      if (base64Image != null) {
        addPetImage(base64Image);
        return true;
      }
      return false;
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  StreamSubscription<List<PetModel>>? _allPetsSubscription;
  StreamSubscription<List<PetModel>>? _ownerPetsSubscription;

  List<PetModel> get pets => _pets;
  List<PetModel> get ownerPets => _ownerPets;
  Set<String> get favoriteIds => _favoriteIds;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  /// Filtered list based on category and search query
  List<PetModel> get filteredPets {
    return _pets.where((pet) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          pet.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesSearch =
          _searchQuery.isEmpty ||
          pet.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pet.breed.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pet.location.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// List of favorite pets
  List<PetModel> get favoritePets {
    return _pets.where((pet) => _favoriteIds.contains(pet.id)).toList();
  }

  bool _hasLoadedAllPets = false;
  bool _hasLoadedOwnerPets = false;
  String? _listeningOwnerId;

  bool get hasLoadedAllPets => _hasLoadedAllPets;
  bool get hasLoadedOwnerPets => _hasLoadedOwnerPets;

  void resetLoadedStates() {
    _hasLoadedAllPets = false;
    _hasLoadedOwnerPets = false;
    _listeningOwnerId = null;
  }

  /// Listen to all available pets
  void listenToAllPets({bool force = false}) {
    if (!force && _hasLoadedAllPets && _allPetsSubscription != null) {
      return;
    }
    _isLoading = true;
    notifyListeners();

    _allPetsSubscription?.cancel();
    _allPetsSubscription = _petService.getAllPetsStream().listen(
      (petList) {
        _pets = petList;
        _isLoading = false;
        _hasLoadedAllPets = true;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        _hasLoadedAllPets = true;
        notifyListeners();
      },
    );
  }

  /// Listen to pets owned by current owner
  void listenToOwnerPets(String ownerId, {bool force = false}) {
    if (!force &&
        _hasLoadedOwnerPets &&
        _listeningOwnerId == ownerId &&
        _ownerPetsSubscription != null) {
      return;
    }
    _listeningOwnerId = ownerId;
    _isLoading = true;
    notifyListeners();

    _ownerPetsSubscription?.cancel();
    _ownerPetsSubscription = _petService
        .getOwnerPetsStream(ownerId)
        .listen(
          (petList) {
            _ownerPets = petList;
            _isLoading = false;
            _hasLoadedOwnerPets = true;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            _isLoading = false;
            _hasLoadedOwnerPets = true;
            notifyListeners();
          },
        );
  }

  /// Set selected pet category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Set search query filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Toggle favorite status for a pet
  void toggleFavorite(String petId) {
    if (_favoriteIds.contains(petId)) {
      _favoriteIds.remove(petId);
    } else {
      _favoriteIds.add(petId);
    }
    notifyListeners();
  }

  bool isFavorite(String petId) => _favoriteIds.contains(petId);

  /// Add a new pet listing
  Future<bool> addPet(PetModel pet) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _petService.addPet(pet);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update an existing pet
  Future<bool> updatePet(PetModel pet) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _petService.updatePet(pet);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Save Pet from form
  Future<bool> savePetForm({
    required UserModel? user,
    PetModel? petToEdit,
  }) async {
    final fee = double.tryParse(petFeeController.text.trim()) ?? 0.0;
    final images = List<String>.from(_petImages);
    final primaryImage = images.isNotEmpty
        ? images.first
        : petImageUrlController.text.trim();

    if (images.isEmpty && primaryImage.isEmpty) {
      _errorMessage = 'Please upload at least 1 photo for the pet';
      notifyListeners();
      return false;
    }

    final pet = PetModel(
      id: petToEdit?.id ?? '',
      name: petNameController.text.trim(),
      breed: petBreedController.text.trim(),
      category: _petCategory,
      age: petAgeController.text.trim(),
      gender: _petGender,
      size: _petSize,
      location: petLocationController.text.trim(),
      adoptionFee: fee,
      description: petDescriptionController.text.trim(),
      imageUrl: primaryImage,
      images: images.isNotEmpty
          ? images
          : (primaryImage.isNotEmpty ? [primaryImage] : []),
      ownerId: user?.uid ?? 'guest_owner',
      ownerName: user?.name.isNotEmpty == true ? user!.name : 'Pet Shelter',
      ownerPhone: user?.phone ?? '',
      isAdopted: petToEdit?.isAdopted ?? false,
    );

    if (petToEdit != null) {
      return await updatePet(pet);
    } else {
      return await addPet(pet);
    }
  }

  /// Delete a pet
  Future<bool> deletePet(String petId) async {
    try {
      await _petService.deletePet(petId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Seed initial database data
  Future<void> seedInitialData() async {
    await _petService.seedInitialPets();
  }

  @override
  void dispose() {
    searchController.dispose();
    petNameController.dispose();
    petBreedController.dispose();
    petAgeController.dispose();
    petLocationController.dispose();
    petFeeController.dispose();
    petDescriptionController.dispose();
    petImageUrlController.dispose();
    _allPetsSubscription?.cancel();
    _ownerPetsSubscription?.cancel();
    super.dispose();
  }
}
