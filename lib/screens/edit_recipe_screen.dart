import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class EditRecipeScreen extends StatefulWidget {
  final RecipeModel recipe;

  const EditRecipeScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
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
  void initState() {
    super.initState();

    titleController.text = widget.recipe.title;
    descriptionController.text = widget.recipe.description;
    ingredientsController.text = widget.recipe.ingredients;
    stepsController.text = widget.recipe.steps;
    cookingTimeController.text = widget.recipe.cookingTime;
    budgetController.text = widget.recipe.estimatedBudget;

    selectedCategory = categories.contains(widget.recipe.category)
        ? widget.recipe.category
        : 'Other';

    selectedDifficulty = difficulties.contains(widget.recipe.difficulty)
        ? widget.recipe.difficulty
        : 'Easy';
  }

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

  Future<void> updateRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    final updatedRecipe = widget.recipe.copyWith(
      title: titleController.text.trim(),
      category: selectedCategory,
      description: descriptionController.text.trim(),
      ingredients: ingredientsController.text.trim(),
      steps: stepsController.text.trim(),
      cookingTime: cookingTimeController.text.trim(),
      difficulty: selectedDifficulty,
      estimatedBudget: budgetController.text.trim(),
    );

    final success = await recipeProvider.updateRecipe(recipe: updatedRecipe);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.cocoa,
          content: Text(
            'Recipe updated successfully!',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      Navigator.pop(context);
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
        title: const Text('Edit Recipe'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppStyle.retroBox(AppColors.mint),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.cocoa,
                    size: 62,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Update Recipe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.cocoa,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
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
                      onPressed:
                      recipeProvider.isLoading ? null : updateRecipe,
                      child: recipeProvider.isLoading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.cocoa,
                          strokeWidth: 3,
                        ),
                      )
                          : const Text('Update Recipe'),
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