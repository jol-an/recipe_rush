import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<List<RecipeModel>> get recipesStream {
    return _recipeService.getAllRecipes();
  }

  Stream<List<RecipeModel>> userRecipesStream(String userId) {
    return _recipeService.getUserRecipes(userId);
  }

  Future<bool> addRecipe({
    required String title,
    required String category,
    required String description,
    required String ingredients,
    required String steps,
    required String cookingTime,
    required String difficulty,
    required String estimatedBudget,
    required String createdBy,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final recipe = RecipeModel(
        id: '',
        title: title.trim(),
        category: category.trim(),
        description: description.trim(),
        ingredients: ingredients.trim(),
        steps: steps.trim(),
        cookingTime: cookingTime.trim(),
        difficulty: difficulty.trim(),
        estimatedBudget: estimatedBudget.trim(),
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      await _recipeService.addRecipe(recipe);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('ADD RECIPE ERROR: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRecipe({
    required RecipeModel recipe,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _recipeService.updateRecipe(recipe);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update recipe. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRecipe(String recipeId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _recipeService.deleteRecipe(recipeId);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete recipe. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> addSampleRecipes(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _recipeService.addSampleRecipes(userId);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add sample recipes.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}