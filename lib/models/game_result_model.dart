import 'package:cloud_firestore/cloud_firestore.dart';

class GameResultModel {
  final String id;
  final String userId;
  final String recipeId;
  final String recipeTitle;
  final int score;
  final int stars;
  final DateTime playedAt;

  GameResultModel({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.recipeTitle,
    required this.score,
    required this.stars,
    required this.playedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'score': score,
      'stars': stars,
      'playedAt': Timestamp.fromDate(playedAt),
    };
  }

  factory GameResultModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    DateTime parsedPlayedAt = DateTime.now();

    if (data['playedAt'] is Timestamp) {
      parsedPlayedAt = (data['playedAt'] as Timestamp).toDate();
    }

    return GameResultModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      recipeId: data['recipeId'] ?? '',
      recipeTitle: data['recipeTitle'] ?? '',
      score: data['score'] ?? 0,
      stars: data['stars'] ?? 0,
      playedAt: parsedPlayedAt,
    );
  }
}