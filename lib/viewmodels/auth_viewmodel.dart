import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel({AuthService? authService})
      : _authService = authService ?? AuthService();

  UserModel? _currentUser;
  String _selectedRole = 'adopter'; // 'adopter' or 'owner'
  bool _isLoading = false;
  String? _errorMessage;

  // Form Controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPhoneController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController registerConfirmPasswordController = TextEditingController();

  // Password Visibility States
  bool _isLoginPasswordHidden = true;
  bool _isRegisterPasswordHidden = true;
  bool _isRegisterConfirmPasswordHidden = true;

  UserModel? get currentUser => _currentUser;
  String get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isOwner => _currentUser?.isOwner ?? (_selectedRole == 'owner');
  bool get isAdopter => _currentUser?.isAdopter ?? (_selectedRole == 'adopter');

  bool get isLoginPasswordHidden => _isLoginPasswordHidden;
  bool get isRegisterPasswordHidden => _isRegisterPasswordHidden;
  bool get isRegisterConfirmPasswordHidden => _isRegisterConfirmPasswordHidden;

  void toggleLoginPasswordVisibility() {
    _isLoginPasswordHidden = !_isLoginPasswordHidden;
    notifyListeners();
  }

  void toggleRegisterPasswordVisibility() {
    _isRegisterPasswordHidden = !_isRegisterPasswordHidden;
    notifyListeners();
  }

  void toggleRegisterConfirmPasswordVisibility() {
    _isRegisterConfirmPasswordHidden = !_isRegisterConfirmPasswordHidden;
    notifyListeners();
  }

  void setSelectedRole(String role) {
    _selectedRole = role.toLowerCase();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearAuthControllers() {
    loginEmailController.clear();
    loginPasswordController.clear();
    registerNameController.clear();
    registerEmailController.clear();
    registerPhoneController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
  }

  /// Initialize and check persistent auth state
  Future<bool> checkAuthStatus() async {
    _isLoading = true;

    try {
      final user = await _authService.getCurrentUserProfile();
      _currentUser = user;
      if (user != null) {
        _selectedRole = user.role;
      }
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign In with Email & Password
  Future<bool> login({
    String? email,
    String? password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final effEmail = email ?? loginEmailController.text;
    final effPassword = password ?? loginPasswordController.text;

    try {
      final user = await _authService.signIn(
        email: effEmail,
        password: effPassword,
      );
      _currentUser = user;
      _selectedRole = user.role;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Register new user with Email, Password, Name, Role
  Future<bool> register({
    String? email,
    String? password,
    String? name,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final effEmail = email ?? registerEmailController.text;
    final effPassword = password ?? registerPasswordController.text;
    final effName = name ?? registerNameController.text;
    final effPhone = phone ?? registerPhoneController.text;

    try {
      final user = await _authService.signUp(
        email: effEmail,
        password: effPassword,
        name: effName,
        role: _selectedRole,
        phone: effPhone,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Send password reset
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordReset(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update user profile photo
  Future<bool> updateProfilePhoto(String base64Image) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateUserProfilePhoto(
        uid: _currentUser!.uid,
        photoUrl: base64Image,
      );
      _currentUser = _currentUser!.copyWith(photoUrl: base64Image);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _currentUser = null;
    clearAuthControllers();
    _isLoading = false;
    notifyListeners();
  }

  /// Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPhoneController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    super.dispose();
  }
}
