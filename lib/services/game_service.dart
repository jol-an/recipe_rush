import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game_result_model.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _gameResults =>
      _firestore.collection('game_results');

  Future<void> saveGameResult(GameResultModel result) async {
    await _gameResults.add(result.toMap());
  }

  Stream<List<GameResultModel>> getUserGameResults(String userId) {
    return _gameResults.where('userId', isEqualTo: userId).snapshots().map(
          (snapshot) {
        final results = snapshot.docs.map((doc) {
          return GameResultModel.fromDocument(doc);
        }).toList();

        results.sort((a, b) => b.playedAt.compareTo(a.playedAt));

        return results;
      },
    );
  }

  Stream<int> getUserTotalStars(String userId) {
    return _gameResults.where('userId', isEqualTo: userId).snapshots().map(
          (snapshot) {
        int totalStars = 0;

        for (final doc in snapshot.docs) {
          final data = doc.data();
          totalStars += (data['stars'] ?? 0) as int;
        }

        return totalStars;
      },
    );
  }
}