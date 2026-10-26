import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<bool> isFavoriteStream({
    required String userId,
    required String recipeId,
  }) {
    return _favoriteService.isFavoriteStream(
      userId: userId,
      recipeId: recipeId,
    );
  }

  Stream<List<RecipeModel>> favoriteRecipesStream(String userId) {
    return _favoriteService.getFavoriteRecipes(userId);
  }

  Future<bool> toggleFavorite({
    required String userId,
    required RecipeModel recipe,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _favoriteService.toggleFavorite(
        userId: userId,
        recipe: recipe,
      );

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update favorites. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}