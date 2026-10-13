import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/adoption_request_model.dart';
import '../data/services/pet_service.dart';

class AdoptionViewModel extends ChangeNotifier {
  final PetService _petService;

  AdoptionViewModel({PetService? petService})
      : _petService = petService ?? PetService();

  List<AdoptionRequestModel> _adopterRequests = [];
  List<AdoptionRequestModel> _ownerRequests = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  final TextEditingController adopterPhoneController = TextEditingController();
  final TextEditingController adopterMessageController = TextEditingController();

  void initAdoptionForm({required String petName, String defaultPhone = ''}) {
    adopterPhoneController.text = defaultPhone;
    adopterMessageController.text =
        "Hi! I would love to adopt $petName. I have a safe, loving home ready for them and look forward to hearing from you!";
    notifyListeners();
  }

  StreamSubscription<List<AdoptionRequestModel>>? _adopterSubscription;
  StreamSubscription<List<AdoptionRequestModel>>? _ownerSubscription;

  bool _hasLoadedAdopterRequests = false;
  bool _hasLoadedOwnerRequests = false;
  String? _listeningAdopterId;
  String? _listeningOwnerId;

  List<AdoptionRequestModel> get adopterRequests => _adopterRequests;
  List<AdoptionRequestModel> get ownerRequests => _ownerRequests;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  bool get hasLoadedAdopterRequests => _hasLoadedAdopterRequests;
  bool get hasLoadedOwnerRequests => _hasLoadedOwnerRequests;

  void resetLoadedStates() {
    _hasLoadedAdopterRequests = false;
    _hasLoadedOwnerRequests = false;
    _listeningAdopterId = null;
    _listeningOwnerId = null;
  }

  /// Listen to requests made by adopter
  void listenToAdopterRequests(String adopterId, {bool force = false}) {
    if (!force &&
        _hasLoadedAdopterRequests &&
        _listeningAdopterId == adopterId &&
        _adopterSubscription != null) {
      return;
    }
    _listeningAdopterId = adopterId;
    _isLoading = true;
    notifyListeners();

    _adopterSubscription?.cancel();
    _adopterSubscription = _petService
        .getAdopterRequestsStream(adopterId)
        .listen((requests) {
      _adopterRequests = requests;
      _isLoading = false;
      _hasLoadedAdopterRequests = true;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      _hasLoadedAdopterRequests = true;
      notifyListeners();
    });
  }

  /// Listen to requests received by owner
  void listenToOwnerRequests(String ownerId, {bool force = false}) {
    if (!force &&
        _hasLoadedOwnerRequests &&
        _listeningOwnerId == ownerId &&
        _ownerSubscription != null) {
      return;
    }
    _listeningOwnerId = ownerId;
    _isLoading = true;
    notifyListeners();

    _ownerSubscription?.cancel();
    _ownerSubscription = _petService
        .getOwnerRequestsStream(ownerId)
        .listen((requests) {
      _ownerRequests = requests;
      _isLoading = false;
      _hasLoadedOwnerRequests = true;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      _hasLoadedOwnerRequests = true;
      notifyListeners();
    });
  }

  /// Submit adoption request
  Future<bool> submitRequest(AdoptionRequestModel request) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _petService.submitAdoptionRequest(request);
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

  /// Update request status ('approved' or 'rejected')
  Future<bool> updateRequestStatus({
    required String requestId,
    required String petId,
    required String status,
  }) async {
    try {
      await _petService.updateRequestStatus(
        requestId: requestId,
        petId: petId,
        status: status,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    adopterPhoneController.dispose();
    adopterMessageController.dispose();
    _adopterSubscription?.cancel();
    _ownerSubscription?.cancel();
    super.dispose();
  }
}
