import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../utils/constants.dart';
import '../utils/recipe_ui_helper.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> removeFavorite({
    required BuildContext context,
    required RecipeModel recipe,
    required String userId,
  }) async {
    final favoriteProvider =
    Provider.of<FavoriteProvider>(context, listen: false);

    final success = await favoriteProvider.toggleFavorite(
      userId: userId,
      recipe: recipe,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.cocoa,
          content: Text(
            'Removed from favorites.',
            style: TextStyle(
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    final String userId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Favorite Recipes',
          style: TextStyle(
            color: AppColors.cocoa,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const FavoriteHeader(),

            Expanded(
              child: StreamBuilder<List<RecipeModel>>(
                stream: favoriteProvider.favoriteRecipesStream(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.tomato,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Something went wrong while loading favorites.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.cocoa,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  final favoriteRecipes = snapshot.data ?? [];

                  if (favoriteRecipes.isEmpty) {
                    return const EmptyFavoritesState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    itemCount: favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = favoriteRecipes[index];

                      return FavoriteCookbookCard(
                        recipe: recipe,
                        onRemove: () {
                          removeFavorite(
                            context: context,
                            recipe: recipe,
                            userId: userId,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class FavoriteHeader extends StatelessWidget {
  const FavoriteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: AppStyle.retroBox(AppColors.pink),
        child: Row(
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.cocoa,
                  width: 2.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cocoa,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.cocoa,
                size: 36,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FavoriteHeaderChip(),
                  SizedBox(height: 10),
                  Text(
                    'Saved Cookbook',
                    style: TextStyle(
                      color: AppColors.cocoa,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Recipes you saved for later cooking.',
                    style: TextStyle(
                      color: AppColors.cocoa,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteHeaderChip extends StatelessWidget {
  const _FavoriteHeaderChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cocoa,
          width: 1.5,
        ),
      ),
      child: const Text(
        'FAVORITES',
        style: TextStyle(
          color: AppColors.cocoa,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
class EmptyFavoritesState extends StatelessWidget {
  const EmptyFavoritesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: AppStyle.retroBox(AppColors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 78,
                width: 78,
                decoration: BoxDecoration(
                  color: AppColors.pink,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.cocoa,
                    width: 2.5,
                  ),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.cocoa,
                  size: 42,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'No favorites yet!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cocoa,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the heart icon on a recipe to save it here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.softBrown,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteCookbookCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onRemove;

  const FavoriteCookbookCard({
    super.key,
    required this.recipe,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = RecipeUiHelper.getRecipeColor(recipe.category);
    final recipeIcon = RecipeUiHelper.getRecipeIcon(recipe.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: AppStyle.retroBox(AppColors.white),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 82,
                    width: 82,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: AppColors.cocoa,
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cocoa,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      recipeIcon,
                      color: AppColors.cocoa,
                      size: 42,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FavoriteCategoryChip(
                          text: recipe.category,
                          color: accentColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.cocoa,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          recipe.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.softBrown,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 7,
                          children: [
                            FavoriteInfoPill(
                              icon: Icons.timer_rounded,
                              text: recipe.cookingTime,
                            ),
                            FavoriteInfoPill(
                              icon: Icons.payments_rounded,
                              text: recipe.estimatedBudget,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.tomato,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteCategoryChip extends StatelessWidget {
  final String text;
  final Color color;

  const FavoriteCategoryChip({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cocoa,
          width: 1.6,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.cocoa,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class FavoriteInfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const FavoriteInfoPill({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.cocoa,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.cocoa,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}