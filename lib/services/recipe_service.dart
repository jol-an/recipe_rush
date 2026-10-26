import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _recipes =>
      _firestore.collection('recipes');

  Stream<List<RecipeModel>> getAllRecipes() {
    return _recipes.snapshots().map((snapshot) {
      final recipes = snapshot.docs.map((doc) {
        return RecipeModel.fromDocument(doc);
      }).toList();

      recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return recipes;
    });
  }

  Stream<List<RecipeModel>> getUserRecipes(String userId) {
    return _recipes.where('createdBy', isEqualTo: userId).snapshots().map(
          (snapshot) {
        final recipes = snapshot.docs.map((doc) {
          return RecipeModel.fromDocument(doc);
        }).toList();

        recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return recipes;
      },
    );
  }

  Future<void> addRecipe(RecipeModel recipe) async {
    await _recipes.add(recipe.toMap());
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    await _recipes.doc(recipe.id).update(recipe.toMap());
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _recipes.doc(recipeId).delete();
  }

  Future<void> addSampleRecipes(String userId) async {
    final existingSnapshot = await _recipes.get();

    final existingTitles = existingSnapshot.docs.map((doc) {
      final data = doc.data();
      return (data['title'] ?? '').toString().toLowerCase();
    }).toSet();

    final List<Map<String, dynamic>> sampleRecipes = [
      {
        'title': 'Classic Pancakes',
        'category': 'Breakfast',
        'description': 'Soft and fluffy pancakes perfect for a quick breakfast.',
        'ingredients':
        '1 cup flour\n1 egg\n1 cup milk\n2 tbsp sugar\n1 tsp baking powder\nButter',
        'steps':
        '1. Mix flour, sugar, and baking powder.\n2. Add egg and milk.\n3. Stir until smooth.\n4. Cook on a pan until golden brown.\n5. Serve with butter or syrup.',
        'cookingTime': '20 mins',
        'difficulty': 'Easy',
        'estimatedBudget': '₱120',
        'createdBy': userId,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Chicken Adobo',
        'category': 'Filipino Food',
        'description':
        'A classic Filipino dish made with soy sauce, vinegar, garlic, and chicken.',
        'ingredients':
        'Chicken\nSoy sauce\nVinegar\nGarlic\nBay leaves\nPepper\nWater',
        'steps':
        '1. Marinate chicken in soy sauce and garlic.\n2. Add vinegar, bay leaves, and pepper.\n3. Simmer until chicken is tender.\n4. Reduce sauce.\n5. Serve with rice.',
        'cookingTime': '45 mins',
        'difficulty': 'Medium',
        'estimatedBudget': '₱250',
        'createdBy': userId,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Tuna Rice Bowl',
        'category': 'Budget Meal',
        'description':
        'A simple student-friendly meal using canned tuna and rice.',
        'ingredients':
        'Cooked rice\nCanned tuna\nEgg\nSoy sauce\nSpring onions\nPepper',
        'steps':
        '1. Heat tuna in a pan.\n2. Fry or scramble the egg.\n3. Place rice in a bowl.\n4. Add tuna and egg on top.\n5. Season with soy sauce and pepper.',
        'cookingTime': '15 mins',
        'difficulty': 'Easy',
        'estimatedBudget': '₱90',
        'createdBy': userId,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Creamy Carbonara',
        'category': 'Lunch',
        'description': 'A creamy pasta dish with bacon, cheese, and sauce.',
        'ingredients':
        'Pasta\nCream\nCheese\nBacon\nGarlic\nOnion\nSalt and pepper',
        'steps':
        '1. Boil pasta until cooked.\n2. Sauté garlic, onion, and bacon.\n3. Add cream and cheese.\n4. Mix pasta with sauce.\n5. Serve warm.',
        'cookingTime': '30 mins',
        'difficulty': 'Medium',
        'estimatedBudget': '₱220',
        'createdBy': userId,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Mango Graham Float',
        'category': 'Dessert',
        'description':
        'A no-bake Filipino dessert made with mangoes, cream, and graham crackers.',
        'ingredients':
        'Graham crackers\nMangoes\nAll-purpose cream\nCondensed milk',
        'steps':
        '1. Mix cream and condensed milk.\n2. Layer graham crackers in a container.\n3. Add cream mixture and mango slices.\n4. Repeat layers.\n5. Chill before serving.',
        'cookingTime': '25 mins',
        'difficulty': 'Easy',
        'estimatedBudget': '₱180',
        'createdBy': userId,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Garlic Fried Rice',
        'category': 'Breakfast',
        'description': 'A quick Filipino-style fried rice with garlic flavor.',
        'ingredients': 'Cooked rice\nGarlic\nOil\nSalt\nEgg optional',
        'steps':
        '1. Sauté garlic until golden.\n2. Add cooked rice.\n3. Mix well.\n4. Season with salt.\n5. Serve with egg or hotdog.',
        'cookingTime': '10 mins',
        'difficulty': 'Easy',
        'estimatedBudget': '₱60',
        'createdBy': userId,
        'createdAt': Timestamp.now(),
      },

      {
        'title': 'Chicken Tinola',
        'category': 'Filipino Food',
        'description':
        'A warm Filipino soup with chicken, ginger, green papaya, and leafy vegetables.',
        'ingredients':
        'Chicken\nGinger\nGarlic\nOnion\nGreen papaya\nMalunggay or sili leaves\nFish sauce\nWater',
        'steps':
        '1. Sauté garlic, onion, and ginger.\n2. Add chicken and cook until lightly browned.\n3. Add water and simmer.\n4. Add green papaya.\n5. Add leaves and season with fish sauce.',
        'cookingTime': '40 mins',
        'difficulty': 'Medium',
        'estimatedBudget': '₱230',
        'createdBy': userId,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Banana Oat Smoothie',
        'category': 'Healthy',
        'description':
        'A quick and healthy drink made with banana, oats, milk, and honey.',
        'ingredients':
        'Banana\nRolled oats\nMilk\nHoney\nIce cubes',
        'steps':
        '1. Slice the banana.\n2. Add banana, oats, milk, honey, and ice to a blender.\n3. Blend until smooth.\n4. Pour into a glass and serve cold.',
        'cookingTime': '5 mins',
        'difficulty': 'Easy',
        'estimatedBudget': '₱80',
        'createdBy': userId,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Cheesy Egg Toast',
        'category': 'Snack',
        'description':
        'A simple toasted bread snack topped with egg and melted cheese.',
        'ingredients':
        'Bread slices\nEgg\nCheese\nButter\nSalt and pepper',
        'steps':
        '1. Toast the bread lightly.\n2. Cook the egg in a pan.\n3. Place egg and cheese on top of the bread.\n4. Heat until cheese melts.\n5. Serve warm.',
        'cookingTime': '12 mins',
        'difficulty': 'Easy',
        'estimatedBudget': '₱70',
        'createdBy': userId,
        'createdAt': Timestamp.now(),
      },
    ];

    for (final recipe in sampleRecipes) {
      final title = (recipe['title'] ?? '').toString().toLowerCase();

      if (!existingTitles.contains(title)) {
        await _recipes.add(recipe);
      }
    }
  }
}