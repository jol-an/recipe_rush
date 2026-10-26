import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class AddRecipeScreen extends StatefulWidget {
  final bool openedFromMyRecipes;

  const AddRecipeScreen({
    super.key,
    this.openedFromMyRecipes = false,
  });

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController cookingTimeController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  String selectedCategory = 'Breakfast';
  String selectedDifficulty = 'Easy';

  final List<String> categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Filipino Food',
    'Budget Meal',
    'Healthy',
    'Other',
  ];

  final List<String> difficulties = [
    'Easy',
    'Medium',
    'Hard',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    ingredientsController.dispose();
    stepsController.dispose();
    cookingTimeController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  Future<void> saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    final userId = authProvider.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.tomato,
          content: Text(
            'You must be logged in to add a recipe.',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      return;
    }

    final success = await recipeProvider.addRecipe(
      title: titleController.text,
      category: selectedCategory,
      description: descriptionController.text,
      ingredients: ingredientsController.text,
      steps: stepsController.text,
      cookingTime: cookingTimeController.text,
      difficulty: selectedDifficulty,
      estimatedBudget: budgetController.text,
      createdBy: userId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.cocoa,
          content: Text(
            widget.openedFromMyRecipes
                ? 'Recipe added to My Recipes!'
                : 'Recipe added successfully! You can also find it in My Recipes.',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.tomato,
          content: Text(
            recipeProvider.errorMessage ?? 'Something went wrong.',
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
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Add Recipe',
          style: TextStyle(
            color: AppColors.cocoa,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppStyle.retroBox(AppColors.peach),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_rounded,
                    color: AppColors.cocoa,
                    size: 62,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Create a New Recipe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.cocoa,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.openedFromMyRecipes
                        ? 'This will be saved under My Recipes.'
                        : 'This will be visible in Browse Recipes and My Recipes.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.cocoa,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: titleController,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Recipe name'),
                    decoration: AppStyle.inputDecoration(
                      'Recipe Name',
                      Icons.restaurant_menu_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: AppStyle.inputDecoration(
                      'Category',
                      Icons.category_rounded,
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: descriptionController,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Description'),
                    maxLines: 2,
                    decoration: AppStyle.inputDecoration(
                      'Short Description',
                      Icons.notes_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: ingredientsController,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Ingredients'),
                    maxLines: 4,
                    decoration: AppStyle.inputDecoration(
                      'Ingredients',
                      Icons.shopping_basket_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: stepsController,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Steps'),
                    maxLines: 5,
                    decoration: AppStyle.inputDecoration(
                      'Cooking Steps',
                      Icons.format_list_numbered_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cookingTimeController,
                          validator: (value) => Validators.validateRequired(
                            value,
                            'Cooking time',
                          ),
                          decoration: AppStyle.inputDecoration(
                            'Time',
                            Icons.timer_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: budgetController,
                          validator: (value) => Validators.validateRequired(
                            value,
                            'Budget',
                          ),
                          decoration: AppStyle.inputDecoration(
                            'Budget',
                            Icons.payments_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: selectedDifficulty,
                    decoration: AppStyle.inputDecoration(
                      'Difficulty',
                      Icons.local_fire_department_rounded,
                    ),
                    items: difficulties.map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDifficulty = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppStyle.retroButton(AppColors.tomato),
                      onPressed: recipeProvider.isLoading ? null : saveRecipe,
                      child: recipeProvider.isLoading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.cocoa,
                          strokeWidth: 3,
                        ),
                      )
                          : const Text('Save Recipe'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}