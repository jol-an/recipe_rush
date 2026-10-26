import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/constants.dart';
import '../utils/recipe_ui_helper.dart';
import 'cooking_game_screen.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  Map<String, dynamic> getRecipeMap() {
    try {
      return Map<String, dynamic>.from((recipe as dynamic).toMap());
    } catch (_) {
      return {};
    }
  }

  String getTextFromRecipeMap(List<String> keys) {
    final data = getRecipeMap();

    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }

  Future<void> deleteRecipe(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text(
            'Delete Recipe?',
            style: TextStyle(
              color: AppColors.cocoa,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this recipe? This action cannot be undone.',
            style: TextStyle(
              color: AppColors.softBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.softBrown,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tomato,
                foregroundColor: AppColors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    final success = await recipeProvider.deleteRecipe(recipe.id);

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.tomato,
          content: Text(
            'Recipe deleted successfully.',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.tomato,
          content: Text(
            recipeProvider.errorMessage ?? 'Failed to delete recipe.',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    final currentUserId = authProvider.currentUser?.uid ?? '';
    final isOwner = recipe.createdBy == currentUserId;

    final accentColor = RecipeUiHelper.getRecipeColor(recipe.category);
    final recipeIcon = RecipeUiHelper.getRecipeIcon(recipe.category);

    final ingredientList = recipe.ingredients
        .split(RegExp(r'\r?\n|,'))
        .map((ingredient) => ingredient.trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();

    final instructionsText = getTextFromRecipeMap([
      'instructions',
      'instruction',
      'steps',
      'procedure',
      'directions',
    ]);

    final creatorName = getTextFromRecipeMap([
      'createdByName',
      'authorName',
      'userName',
      'ownerName',
      'creatorName',
    ]);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Recipe Details',
          style: TextStyle(
            color: AppColors.cocoa,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (currentUserId.isNotEmpty)
            StreamBuilder<bool>(
              stream: favoriteProvider.isFavoriteStream(
                userId: currentUserId,
                recipeId: recipe.id,
              ),
              builder: (context, snapshot) {
                final isFavorite = snapshot.data ?? false;

                return IconButton(
                  onPressed: () async {
                    await favoriteProvider.toggleFavorite(
                      userId: currentUserId,
                      recipe: recipe,
                    );
                  },
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: AppColors.tomato,
                  ),
                );
              },
            ),
          if (isOwner)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditRecipeScreen(recipe: recipe),
                  ),
                );
              },
              icon: const Icon(
                Icons.edit_rounded,
                color: AppColors.cocoa,
              ),
            ),
          if (isOwner)
            IconButton(
              onPressed: () => deleteRecipe(context),
              icon: const Icon(
                Icons.delete_rounded,
                color: AppColors.tomato,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: AppStyle.retroBox(accentColor),
              child: Column(
                children: [
                  Container(
                    height: 98,
                    width: 98,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.cocoa,
                        width: 2.8,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cocoa,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      recipeIcon,
                      color: AppColors.cocoa,
                      size: 52,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    recipe.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.cocoa,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    recipe.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.cocoa,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      DetailChip(
                        icon: Icons.category_rounded,
                        label: recipe.category,
                      ),
                      DetailChip(
                        icon: Icons.timer_rounded,
                        label: '${recipe.cookingTime} mins',
                      ),
                      DetailChip(
                        icon: Icons.signal_cellular_alt_rounded,
                        label: recipe.difficulty,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppStyle.retroBox(AppColors.white),
              child: Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: AppColors.butter,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.cocoa,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.cocoa,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shared by',
                          style: TextStyle(
                            color: AppColors.softBrown,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          creatorName.isEmpty ? 'Recipe Creator' : creatorName,
                          style: const TextStyle(
                            color: AppColors.cocoa,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            DetailSectionCard(
              title: 'Ingredients',
              icon: Icons.shopping_basket_rounded,
              color: AppColors.gameSoftOrange,
              child: ingredientList.isEmpty
                  ? const Text(
                'No ingredients added.',
                style: TextStyle(
                  color: AppColors.softBrown,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              )
                  : Column(
                children: ingredientList.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.cocoa,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.cocoa,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: const TextStyle(
                              color: AppColors.cocoa,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 18),

            DetailSectionCard(
              title: 'Cooking Instructions',
              icon: Icons.menu_book_rounded,
              color: AppColors.peach,
              child: Text(
                instructionsText.isEmpty
                    ? 'No cooking instructions were added.'
                    : instructionsText,
                style: const TextStyle(
                  color: AppColors.cocoa,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: AppStyle.retroButton(AppColors.tomato),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CookingGameScreen(recipe: recipe),
                    ),
                  );
                },
                icon: const Icon(Icons.sports_esports_rounded),
                label: const Text('Play Cooking Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const DetailChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cocoa,
          width: 1.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.cocoa,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const DetailSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppStyle.retroBox(AppColors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.cocoa,
                width: 1.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: AppColors.cocoa,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}