import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../services/game_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();

  int _score = 0;
  int _stars = 0;
  bool _isLoading = false;
  String? _errorMessage;

  int get score => _score;
  int get stars => _stars;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void resetGame() {
    _score = 0;
    _stars = 0;
    _errorMessage = null;
    notifyListeners();
  }

  void addScore(int points) {
    _score += points;

    if (_score >= 90) {
      _stars = 3;
    } else if (_score >= 60) {
      _stars = 2;
    } else if (_score > 0) {
      _stars = 1;
    }

    notifyListeners();
  }

  void computeStars() {
    if (_score >= 90) {
      _stars = 3;
    } else if (_score >= 60) {
      _stars = 2;
    } else if (_score > 0) {
      _stars = 1;
    } else {
      _stars = 0;
    }

    notifyListeners();
  }

  Future<bool> saveResult({
    required String userId,
    required String recipeId,
    required String recipeTitle,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      computeStars();

      final result = GameResultModel(
        id: '',
        userId: userId,
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        score: _score,
        stars: _stars,
        playedAt: DateTime.now(),
      );

      await _gameService.saveGameResult(result);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to save game result.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<GameResultModel>> userGameResultsStream(String userId) {
    return _gameService.getUserGameResults(userId);
  }

  Stream<int> userTotalStarsStream(String userId) {
    return _gameService.getUserTotalStars(userId);
  }
}