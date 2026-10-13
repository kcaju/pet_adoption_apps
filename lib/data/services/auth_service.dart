import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  static const String _prefRoleKey = 'pet_haus_user_role';
  static const String _prefNameKey = 'pet_haus_user_name';

  /// Sign up with email, password, name, and role ('adopter' or 'owner')
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String phone = '',
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw Exception('User creation failed.');
      }

      await user.updateDisplayName(name);

      final UserModel userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        role: role.toLowerCase(),
        phone: phone.trim(),
        createdAt: DateTime.now(),
      );

      // Save user to Firestore
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
      } catch (e) {
        // Fallback in case Firestore rules or network delay occurs
        // ignore: avoid_print
        print('Firestore user write note: $e');
      }

      // Cache locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefRoleKey, role.toLowerCase());
      await prefs.setString(_prefNameKey, name.trim());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw Exception('Sign in failed.');
      }

      // Try fetching role from Firestore
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final model = UserModel.fromMap(doc.data()!, uid: user.uid);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefRoleKey, model.role);
          await prefs.setString(_prefNameKey, model.name);
          return model;
        }
      } catch (e) {
        // ignore: avoid_print
        print('Firestore fetch note: $e');
      }

      // Fallback to locally cached role or default to 'adopter'
      final prefs = await SharedPreferences.getInstance();
      final cachedRole = prefs.getString(_prefRoleKey) ?? 'adopter';
      final cachedName = prefs.getString(_prefNameKey) ?? (user.displayName ?? 'Pet Lover');

      return UserModel(
        uid: user.uid,
        name: cachedName,
        email: user.email ?? email,
        role: cachedRole,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid: user.uid);
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final cachedRole = prefs.getString(_prefRoleKey) ?? 'adopter';
    final cachedName = prefs.getString(_prefNameKey) ?? (user.displayName ?? 'Pet Lover');

    return UserModel(
      uid: user.uid,
      name: cachedName,
      email: user.email ?? '',
      role: cachedRole,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefRoleKey);
    await prefs.remove(_prefNameKey);
  }

  /// Password reset
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user profile photo in Firestore (stores Base64 data string without requiring Firebase Storage Blaze plan)
  Future<void> updateUserProfilePhoto({
    required String uid,
    required String photoUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'photoUrl': photoUrl,
      });
    } catch (e) {
      throw Exception('Failed to update profile photo: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
