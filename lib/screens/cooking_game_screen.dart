import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_model.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class CookingGameScreen extends StatefulWidget {
  final RecipeModel? recipe;
  final bool showAppBar;

  const CookingGameScreen({
    super.key,
    this.recipe,
    this.showAppBar = true,
  });

  @override
  State<CookingGameScreen> createState() => _CookingGameScreenState();
}

class _CookingGameScreenState extends State<CookingGameScreen> {
  final Random random = Random();

  Timer? gameTimer;
  Timer? cookTimer;

  int timeLeft = 45;
  int lives = 3;
  int combo = 0;
  int tasksDone = 0;
  int currentTargetIndex = 0;

  bool gameStarted = false;
  bool gameFinished = false;
  bool finalRound = false;
  bool resultSaved = false;

  double cookProgress = 0.0;

  final List<RushIngredient> ingredients = const [
    RushIngredient(name: 'Egg', emoji: '🥚'),
    RushIngredient(name: 'Flour', emoji: '🌾'),
    RushIngredient(name: 'Milk', emoji: '🥛'),
    RushIngredient(name: 'Butter', emoji: '🧈'),
    RushIngredient(name: 'Candy', emoji: '🍬'),
    RushIngredient(name: 'Pan', emoji: '🍳'),
  ];

  String get recipeTitle {
    return widget.recipe?.title ?? 'Pancake Rush';
  }

  String get recipeId {
    return widget.recipe?.id ?? 'pancake_rush';
  }

  RushIngredient get currentTarget {
    return ingredients[currentTargetIndex];
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).resetGame();
    });

    generateNewTarget();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    cookTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    Provider.of<GameProvider>(context, listen: false).resetGame();

    setState(() {
      timeLeft = 45;
      lives = 3;
      combo = 0;
      tasksDone = 0;
      gameStarted = true;
      gameFinished = false;
      finalRound = false;
      resultSaved = false;
      cookProgress = 0.0;
    });

    generateNewTarget();

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        timeLeft--;
      });

      if (timeLeft <= 0 || lives <= 0) {
        timer.cancel();
        startFinalRound();
      }
    });
  }

  void generateNewTarget() {
    currentTargetIndex = random.nextInt(ingredients.length);
  }

  void chooseIngredient(RushIngredient selected) {
    if (!gameStarted || gameFinished || finalRound) return;

    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (selected.name == currentTarget.name) {
      combo++;
      tasksDone++;

      int points = 10;

      if (combo >= 3) {
        points += 5;
      }

      if (combo >= 6) {
        points += 10;
      }

      gameProvider.addScore(points);

      showMiniMessage('Nice! +$points', AppColors.gameMint);

      if (tasksDone >= 10) {
        startFinalRound();
        return;
      }

      setState(() {
        generateNewTarget();
      });
    } else {
      combo = 0;
      lives--;

      showMiniMessage('Oops! Wrong ingredient', AppColors.gameCoral);

      setState(() {});

      if (lives <= 0) {
        startFinalRound();
      }
    }
  }

  void showMiniMessage(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 650),
        backgroundColor: color,
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.cocoa,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  void startFinalRound() {
    if (finalRound || gameFinished) return;

    gameTimer?.cancel();

    setState(() {
      finalRound = true;
      cookProgress = 0.0;
    });
  }

  void startCookingHold() {
    if (!finalRound || gameFinished) return;

    cookTimer?.cancel();

    cookTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) return;

      setState(() {
        cookProgress += 0.035;

        if (cookProgress >= 1.0) {
          cookProgress = 1.0;
          timer.cancel();
          finishFinalRound();
        }
      });
    });
  }

  void stopCookingHold() {
    if (!finalRound || gameFinished) return;

    cookTimer?.cancel();
    finishFinalRound();
  }

  Future<void> finishFinalRound() async {
    if (gameFinished) return;

    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (cookProgress >= 0.62 && cookProgress <= 0.86) {
      gameProvider.addScore(40);
      showMiniMessage('Perfect cook! +40', AppColors.gameMint);
    } else if (cookProgress >= 0.45 && cookProgress < 0.62) {
      gameProvider.addScore(20);
      showMiniMessage('Good cook! +20', AppColors.gameHoney);
    } else {
      gameProvider.addScore(8);
      showMiniMessage('A little burnt! +8', AppColors.gamePink);
    }

    await Future.delayed(const Duration(milliseconds: 700));

    await finishGame();
  }

  Future<void> finishGame() async {
    if (resultSaved) return;

    gameTimer?.cancel();
    cookTimer?.cancel();

    setState(() {
      gameFinished = true;
      gameStarted = false;
      finalRound = false;
      resultSaved = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    final userId = authProvider.currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      await gameProvider.saveResult(
        userId: userId,
        recipeId: recipeId,
        recipeTitle: recipeTitle,
      );
    }
  }

  void restartGame() {
    gameTimer?.cancel();
    cookTimer?.cancel();

    Provider.of<GameProvider>(context, listen: false).resetGame();

    setState(() {
      timeLeft = 45;
      lives = 3;
      combo = 0;
      tasksDone = 0;
      gameStarted = false;
      gameFinished = false;
      finalRound = false;
      resultSaved = false;
      cookProgress = 0.0;
    });

    generateNewTarget();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    final gameContent = SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          buildHeader(),
          const SizedBox(height: 16),
          buildStats(gameProvider),
          const SizedBox(height: 18),
          if (!gameStarted && !gameFinished && !finalRound) buildStartCard(),
          if (gameStarted && !gameFinished && !finalRound) buildRushRound(),
          if (finalRound && !gameFinished) buildFinalRound(),
          if (gameFinished) buildResultCard(gameProvider),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return gameContent;
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Cooking Game',
          style: TextStyle(
            color: AppColors.cocoa,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: gameContent,
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: AppStyle.retroBox(AppColors.gameCream),
      child: Column(
        children: [
          Container(
            height: 92,
            width: 92,
            decoration: BoxDecoration(
              color: AppColors.gameHoney,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.cocoa,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.sports_esports_rounded,
              color: AppColors.cocoa,
              size: 50,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            recipeTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Fast hands, quick choices, perfect cooking!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cocoa,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStats(GameProvider gameProvider) {
    return Row(
      children: [
        Expanded(
          child: GameInfoCard(
            title: 'Time',
            value: '${timeLeft}s',
            icon: Icons.timer_rounded,
            color: AppColors.gameHoney,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GameInfoCard(
            title: 'Score',
            value: gameProvider.score.toString(),
            icon: Icons.star_rounded,
            color: AppColors.gamePeach,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GameInfoCard(
            title: 'Lives',
            value: '❤️' * lives,
            icon: Icons.favorite_rounded,
            color: AppColors.gamePink,
          ),
        ),
      ],
    );
  }

  Widget buildStartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: AppStyle.retroBox(AppColors.gameSoftOrange),
      child: Column(
        children: [
          Container(
            height: 82,
            width: 82,
            decoration: BoxDecoration(
              color: AppColors.gameCream,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.cocoa,
                width: 2.5,
              ),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.gameCoral,
              size: 44,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Recipe Rush Challenge',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cocoa,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap the correct ingredient before time runs out.\n'
                'Build combos, avoid mistakes, then finish with the perfect cooking round!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cocoa,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: AppStyle.retroButton(AppColors.gameCoral),
              onPressed: startGame,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Rush'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRushRound() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppStyle.retroBox(AppColors.gameCream),
      child: Column(
        children: [
          const Text(
            'Find this ingredient!',
            style: TextStyle(
              color: AppColors.cocoa,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: AppStyle.retroBox(AppColors.gameHoney),
            child: Column(
              children: [
                Text(
                  currentTarget.emoji,
                  style: const TextStyle(fontSize: 58),
                ),
                Text(
                  currentTarget.name,
                  style: const TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MiniGameBadge(
                  label: 'Combo',
                  value: 'x$combo',
                  color: AppColors.gamePeach,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MiniGameBadge(
                  label: 'Tasks',
                  value: '$tasksDone/10',
                  color: AppColors.gameMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];

              return IngredientRushButton(
                ingredient: ingredient,
                onTap: () => chooseIngredient(ingredient),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildFinalRound() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: AppStyle.retroBox(AppColors.gameSoftOrange),
      child: Column(
        children: [
          Container(
            height: 82,
            width: 82,
            decoration: BoxDecoration(
              color: AppColors.gameCream,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.cocoa,
                width: 2.5,
              ),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.gameCoral,
              size: 44,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Final Cooking Round!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cocoa,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hold the button and release near the perfect cooking zone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cocoa,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: LinearProgressIndicator(
                  value: cookProgress,
                  minHeight: 30,
                  backgroundColor: AppColors.gameCream,
                  color: AppColors.gameCoral,
                ),
              ),
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerRight,
                  widthFactor: 0.30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gameMint.withOpacity(0.7),
                      border: Border.all(
                        color: AppColors.cocoa,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Perfect zone: around 62% to 86%',
            style: TextStyle(
              color: AppColors.cocoa,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTapDown: (_) => startCookingHold(),
            onTapUp: (_) => stopCookingHold(),
            onTapCancel: stopCookingHold,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: AppStyle.retroBox(AppColors.gameCoral),
              child: const Text(
                'Hold to Cook',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResultCard(GameProvider gameProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: AppStyle.retroBox(AppColors.gameCream),
      child: Column(
        children: [
          Container(
            height: 84,
            width: 84,
            decoration: BoxDecoration(
              color: AppColors.gameHoney,
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
              Icons.emoji_events_rounded,
              color: AppColors.cocoa,
              size: 46,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Dish Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cocoa,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gameSoftOrange,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.cocoa,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Final Score: ${gameProvider.score}',
                  style: const TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  gameProvider.stars == 0
                      ? 'Stars: No stars yet'
                      : 'Stars: ${'★' * gameProvider.stars}',
                  style: const TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            getResultMessage(gameProvider.score),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppStyle.retroButton(AppColors.gameCoral),
              onPressed: restartGame,
              child: const Text('Play Again'),
            ),
          ),
        ],
      ),
    );
  }

  String getResultMessage(int score) {
    if (score >= 140) {
      return 'Amazing! You cooked like a kitchen master!';
    } else if (score >= 90) {
      return 'Great job! Your dish turned out delicious.';
    } else if (score >= 50) {
      return 'Nice try! A little more practice and you will improve.';
    } else {
      return 'Oops! The kitchen got messy, but you can try again.';
    }
  }
}

class RushIngredient {
  final String name;
  final String emoji;

  const RushIngredient({
    required this.name,
    required this.emoji,
  });
}
class IngredientRushButton extends StatelessWidget {
  final RushIngredient ingredient;
  final VoidCallback onTap;

  const IngredientRushButton({
    super.key,
    required this.ingredient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: AppStyle.retroBox(AppColors.gameCream),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ingredient.emoji,
              style: const TextStyle(fontSize: 34),
            ),
            const SizedBox(height: 6),
            Text(
              ingredient.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.cocoa,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MiniGameBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const MiniGameBadge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppStyle.retroBox(color),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class GameInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const GameInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: AppStyle.retroBox(color),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.cocoa,
            size: 25,
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? '0' : value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}