import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String ingredients;
  final String steps;
  final String cookingTime;
  final String difficulty;
  final String estimatedBudget;
  final String createdBy;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.cookingTime,
    required this.difficulty,
    required this.estimatedBudget,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'cookingTime': cookingTime,
      'difficulty': difficulty,
      'estimatedBudget': estimatedBudget,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RecipeModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    DateTime parsedCreatedAt = DateTime.now();

    if (data['createdAt'] is Timestamp) {
      parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
    }

    return RecipeModel(
      id: doc.id,
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
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? ingredients,
    String? steps,
    String? cookingTime,
    String? difficulty,
    String? estimatedBudget,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      cookingTime: cookingTime ?? this.cookingTime,
      difficulty: difficulty ?? this.difficulty,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}