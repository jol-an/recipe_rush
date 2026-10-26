import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_model.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/constants.dart';
import '../utils/recipe_ui_helper.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  final bool showOnlyMine;

  const RecipeListScreen({
    super.key,
    this.showOnlyMine = false,
  });

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String searchQuery = '';

  Future<void> addSampleRecipes(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    final userId = authProvider.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return;
    }

    final success = await recipeProvider.addSampleRecipes(userId);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.cocoa : AppColors.tomato,
        content: Text(
          success
              ? 'Sample recipes added or updated!'
              : recipeProvider.errorMessage ?? 'Failed to add sample recipes.',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    final recipeStream = widget.showOnlyMine
        ? recipeProvider.userRecipesStream(currentUserId)
        : recipeProvider.recipesStream;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: Text(
          widget.showOnlyMine ? 'My Recipes' : 'Browse Recipes',
          style: const TextStyle(
            color: AppColors.cocoa,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (!widget.showOnlyMine)
            IconButton(
              tooltip: 'Add sample recipes',
              onPressed: recipeProvider.isLoading
                  ? null
                  : () => addSampleRecipes(context),
              icon: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.cocoa,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.tomato,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: AppColors.cocoa,
            width: 2.5,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddRecipeScreen(
                openedFromMyRecipes: widget.showOnlyMine,
              ),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            RecipeListHeader(
              showOnlyMine: widget.showOnlyMine,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: AppStyle.inputDecoration(
                  'Search recipe or category',
                  Icons.search_rounded,
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder<List<RecipeModel>>(
                stream: recipeStream,
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
                          'Something went wrong while loading recipes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.cocoa,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  final recipes = snapshot.data ?? [];

                  final filteredRecipes = recipes.where((recipe) {
                    return recipe.title.toLowerCase().contains(searchQuery) ||
                        recipe.category.toLowerCase().contains(searchQuery);
                  }).toList();

                  if (filteredRecipes.isEmpty) {
                    return EmptyRecipeState(
                      showOnlyMine: widget.showOnlyMine,
                      onAddSamples: () => addSampleRecipes(context),
                      isLoading: recipeProvider.isLoading,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 2, 18, 90),
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];

                      return RecipeBookCard(
                        recipe: recipe,
                        currentUserId: currentUserId,
                        isOwner: recipe.createdBy == currentUserId,
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

class RecipeListHeader extends StatelessWidget {
  final bool showOnlyMine;

  const RecipeListHeader({
    super.key,
    required this.showOnlyMine,
  });

  @override
  Widget build(BuildContext context) {
    final Color headerColor =
    showOnlyMine ? AppColors.mint : AppColors.peach;

    final String title =
    showOnlyMine ? 'My Cookbook' : 'Recipe Library';

    final String subtitle = showOnlyMine
        ? 'Your own saved recipes, ready to edit and manage.'
        : 'Find meals, desserts, snacks, and budget ideas.';

    final IconData icon = showOnlyMine
        ? Icons.restaurant_menu_rounded
        : Icons.menu_book_rounded;

    final String chipText =
    showOnlyMine ? 'MY RECIPES' : 'BROWSE RECIPES';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: AppStyle.retroBox(headerColor),
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
              child: Icon(
                icon,
                color: AppColors.cocoa,
                size: 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.cocoa,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      chipText,
                      style: const TextStyle(
                        color: AppColors.cocoa,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.cocoa,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
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

class EmptyRecipeState extends StatelessWidget {
  final bool showOnlyMine;
  final VoidCallback onAddSamples;
  final bool isLoading;

  const EmptyRecipeState({
    super.key,
    required this.showOnlyMine,
    required this.onAddSamples,
    required this.isLoading,
  });

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
                height: 76,
                width: 76,
                decoration: BoxDecoration(
                  color: showOnlyMine ? AppColors.mint : AppColors.butter,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.cocoa,
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  showOnlyMine
                      ? Icons.add_circle_rounded
                      : Icons.auto_awesome_rounded,
                  color: AppColors.cocoa,
                  size: 42,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                showOnlyMine ? 'No personal recipes yet.' : 'No recipes found.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.cocoa,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                showOnlyMine
                    ? 'Tap the + button to add your first recipe.'
                    : 'Tap the button below or the sparkle icon to add sample recipes.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.softBrown,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              if (!showOnlyMine) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppStyle.retroButton(AppColors.tomato),
                    onPressed: isLoading ? null : onAddSamples,
                    child: isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.cocoa,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text('Add Sample Recipes'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeBookCard extends StatelessWidget {
  final RecipeModel recipe;
  final String currentUserId;
  final bool isOwner;

  const RecipeBookCard({
    super.key,
    required this.recipe,
    required this.currentUserId,
    required this.isOwner,
  });

  Future<void> toggleFavorite(BuildContext context, bool isFavorite) async {
    final favoriteProvider =
    Provider.of<FavoriteProvider>(context, listen: false);

    final success = await favoriteProvider.toggleFavorite(
      userId: currentUserId,
      recipe: recipe,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.cocoa,
          content: Text(
            isFavorite ? 'Removed from favorites.' : 'Added to favorites!',
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
                        RecipeCategoryChip(
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
                            RecipeInfoPill(
                              icon: Icons.timer_rounded,
                              text: recipe.cookingTime,
                            ),
                            RecipeInfoPill(
                              icon: Icons.local_fire_department_rounded,
                              text: recipe.difficulty,
                            ),
                            RecipeInfoPill(
                              icon: Icons.payments_rounded,
                              text: recipe.estimatedBudget,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    children: [
                      StreamBuilder<bool>(
                        stream: Provider.of<FavoriteProvider>(
                          context,
                          listen: false,
                        ).isFavoriteStream(
                          userId: currentUserId,
                          recipeId: recipe.id,
                        ),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;

                          return IconButton(
                            onPressed: currentUserId.isEmpty
                                ? null
                                : () => toggleFavorite(context, isFavorite),
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? AppColors.tomato
                                  : AppColors.cocoa,
                              size: 28,
                            ),
                          );
                        },
                      ),
                      if (isOwner)
                        const Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.cocoa,
                          size: 27,
                        ),
                    ],
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

class RecipeCategoryChip extends StatelessWidget {
  final String text;
  final Color color;

  const RecipeCategoryChip({
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

class RecipeInfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const RecipeInfoPill({
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