import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authService.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.registerUser(
        name: name,
        email: email,
        password: password,
      );

      if (_authService.currentUser != null) {
        _userModel =
        await _authService.getUserData(_authService.currentUser!.uid);
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.loginUser(
        email: email,
        password: password,
      );

      if (_authService.currentUser != null) {
        _userModel =
        await _authService.getUserData(_authService.currentUser!.uid);
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentUser() async {
    if (_authService.currentUser != null) {
      _userModel =
      await _authService.getUserData(_authService.currentUser!.uid);
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String cookingLevel,
    required String favoriteCuisine,
    required String dietaryPreference,
    required String avatarIcon,
  }) async {
    try {
      if (_userModel == null) {
        _errorMessage = 'User data not found.';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedUser = _userModel!.copyWith(
        name: name.trim(),
        cookingLevel: cookingLevel,
        favoriteCuisine: favoriteCuisine,
        dietaryPreference: dietaryPreference,
        avatarIcon: avatarIcon,
      );

      await _authService.updateUserProfile(updatedUser);

      _userModel = updatedUser;

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logoutUser();
    _userModel = null;
    notifyListeners();
  }
}