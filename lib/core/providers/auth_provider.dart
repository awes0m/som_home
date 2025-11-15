import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_service.dart';
import '../storage/hive_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastMergedUid; // Track which UID we've already merged for

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((user) async {
      _currentUser = user;

      // If a user just signed in and we haven't merged for this UID yet,
      // run the best-effort local/cloud merge and then notify listeners.
      try {
        if (user != null && user.uid.isNotEmpty && _lastMergedUid != user.uid) {
          await HiveService.mergeLocalAndCloudOnSignIn();
          _lastMergedUid = user.uid;
        }
      } catch (_) {
        // Best-effort merge: ignore errors here to avoid blocking auth flow
      }

      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (!email.contains('@')) {
        throw Exception('Please enter a valid email');
      }

      await _authService.signUp(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!email.contains('@')) {
        throw Exception('Please enter a valid email');
      }

      await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!email.contains('@')) {
        throw Exception('Please enter a valid email');
      }

      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _lastMergedUid = null; // Reset merge tracking on sign-out
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
