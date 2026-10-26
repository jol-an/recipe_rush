import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _favorites =>
      _firestore.collection('favorites');

  String _favoriteDocId(String userId, String recipeId) {
    return '${userId}_$recipeId';
  }

  Stream<bool> isFavoriteStream({
    required String userId,
    required String recipeId,
  }) {
    return _favorites.doc(_favoriteDocId(userId, recipeId)).snapshots().map(
          (doc) => doc.exists,
    );
  }

  Stream<List<RecipeModel>> getFavoriteRecipes(String userId) {
    return _favorites.where('userId', isEqualTo: userId).snapshots().map(
          (snapshot) {
        final favorites = snapshot.docs.map((doc) {
          final data = doc.data();

          DateTime parsedCreatedAt = DateTime.now();

          if (data['createdAt'] is Timestamp) {
            parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
          }

          return RecipeModel(
            id: data['recipeId'] ?? '',
            title: data['title'] ?? '',
            category: data['category'] ?? '',
            description: data['description'] ?? '',
            ingredients: data['ingredients'] ?? '',
            steps: data['steps'] ?? '',
            cookingTime: data['cookingTime'] ?? '',
            difficulty: data['difficulty'] ?? '',
            estimatedBudget: data['estimatedBudget'] ?? '',
            createdBy: data['createdBy'] ?? '',
            createdAt: parsedCreatedAt,
          );
        }).toList();

        return favorites;
      },
    );
  }

  Future<void> addFavorite({
    required String userId,
    required RecipeModel recipe,
  }) async {
    await _favorites.doc(_favoriteDocId(userId, recipe.id)).set({
      'userId': userId,
      'recipeId': recipe.id,
      'title': recipe.title,
      'category': recipe.category,
      'description': recipe.description,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps,
      'cookingTime': recipe.cookingTime,
      'difficulty': recipe.difficulty,
      'estimatedBudget': recipe.estimatedBudget,
      'createdBy': recipe.createdBy,
      'createdAt': Timestamp.fromDate(recipe.createdAt),
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite({
    required String userId,
    required String recipeId,
  }) async {
    await _favorites.doc(_favoriteDocId(userId, recipeId)).delete();
  }

  Future<void> toggleFavorite({
    required String userId,
    required RecipeModel recipe,
  }) async {
    final favoriteDoc = _favorites.doc(_favoriteDocId(userId, recipe.id));
    final doc = await favoriteDoc.get();

    if (doc.exists) {
      await favoriteDoc.delete();
    } else {
      await addFavorite(
        userId: userId,
        recipe: recipe,
      );
    }
  }
}