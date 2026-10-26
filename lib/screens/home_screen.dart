import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../utils/avatar_helper.dart';
import '../utils/constants.dart';
import 'community_screen.dart';
import 'cooking_game_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'recipe_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<String> pageTitles = [
    AppText.appName,
    'Recipes',
    'Cooking Game',
    'Community',
    'Profile',
  ];

  Future<void> logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.logout();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String userId = authProvider.currentUser?.uid ?? '';

    final pages = [
      DashboardTab(
        userId: userId,
        onOpenGame: () {
          setState(() {
            selectedIndex = 2;
          });
        },
        onOpenCommunity: () {
          setState(() {
            selectedIndex = 3;
          });
        },
      ),
      const RecipesTab(),
      const CookingGameScreen(showAppBar: false),
      const CommunityScreen(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: false,
        title: Text(
          pageTitles[selectedIndex],
          style: const TextStyle(
            color: AppColors.cocoa,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => logout(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.cocoa,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.cocoa,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.cocoa,
              width: 2.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.tomato,
          unselectedItemColor: AppColors.cocoa,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports_rounded),
              label: 'Game',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum_rounded),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
class DashboardTab extends StatelessWidget {
  final String userId;
  final VoidCallback onOpenGame;
  final VoidCallback onOpenCommunity;

  const DashboardTab({
    super.key,
    required this.userId,
    required this.onOpenGame,
    required this.onOpenCommunity,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String name = authProvider.userModel?.name ?? 'Chef';
    final String avatarKey = authProvider.userModel?.avatarIcon ?? 'chef';
    final String level = authProvider.userModel?.cookingLevel ?? 'Beginner Chef';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      child: Column(
        children: [
          HomeHeroCard(
            name: name,
            avatarKey: avatarKey,
          ),

          const SizedBox(height: 16),

          HomeDailyQuestCard(
            onPlay: onOpenGame,
          ),

          const SizedBox(height: 16),

          StreamBuilder<int>(
            stream: Provider.of<GameProvider>(
              context,
              listen: false,
            ).userTotalStarsStream(userId),
            builder: (context, snapshot) {
              final int totalStars = snapshot.data ?? 0;

              return HomeChefProgressCard(
                stars: totalStars,
                level: level,
              );
            },
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: HomeShortcutCard(
                  title: 'Browse',
                  subtitle: 'Find recipes',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.peach,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecipeListScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HomeShortcutCard(
                  title: 'Community',
                  subtitle: 'Food talks',
                  icon: Icons.forum_rounded,
                  color: AppColors.pink,
                  onTap: onOpenCommunity,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const HomeTipCard(),
        ],
      ),
    );
  }
}
class HomeHeroCard extends StatelessWidget {
  final String name;
  final String avatarKey;

  const HomeHeroCard({
    super.key,
    required this.name,
    required this.avatarKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cocoa,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.cocoa,
          width: 2.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColors.peach,
            child: Row(
              children: [
                Container(
                  height: 82,
                  width: 82,
                  decoration: BoxDecoration(
                    color: AppColors.butter,
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
                    AvatarHelper.getAvatarIcon(avatarKey),
                    color: AppColors.cocoa,
                    size: 44,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recipe Rush Journal',
                        style: TextStyle(
                          color: AppColors.cocoa,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hi, $name!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.cocoa,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'What are we cooking today?',
                        style: TextStyle(
                          color: AppColors.cocoa,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.cocoa,
                  width: 2,
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    '🍳',
                    style: TextStyle(fontSize: 30),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Today’s goal: try a recipe, play a challenge, and save your favorites.',
                      style: TextStyle(
                        color: AppColors.cocoa,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class HomeDailyQuestCard extends StatelessWidget {
  final VoidCallback onPlay;

  const HomeDailyQuestCard({
    super.key,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: AppStyle.retroBox(AppColors.gameSoftOrange),
      child: Stack(
        children: [
          Positioned(
            right: 18,
            top: 16,
            child: Text(
              '🥞',
              style: TextStyle(
                fontSize: 58,
                color: AppColors.cocoa.withValues(alpha: 0.15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  height: 78,
                  width: 78,
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
                    Icons.local_fire_department_rounded,
                    color: AppColors.gameCoral,
                    size: 42,
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Quest',
                        style: TextStyle(
                          color: AppColors.cocoa,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Complete Pancake Rush and earn stars for your chef profile.',
                        style: TextStyle(
                          color: AppColors.softBrown,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onPlay,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.gameCoral,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.cocoa,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeChefProgressCard extends StatelessWidget {
  final int stars;
  final String level;

  const HomeChefProgressCard({
    super.key,
    required this.stars,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.retroBox(AppColors.white),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeSectionHeader(
              title: 'Chef Progress',
              icon: Icons.emoji_events_rounded,
              color: AppColors.butter,
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: HomeProgressItem(
                    title: 'Stars',
                    value: stars.toString(),
                    icon: Icons.star_rounded,
                    color: AppColors.butter,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HomeProgressItem(
                    title: 'Level',
                    value: level,
                    icon: Icons.restaurant_menu_rounded,
                    color: AppColors.mint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeProgressItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const HomeProgressItem({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cocoa,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.cocoa,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.softBrown,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeShortcutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HomeShortcutCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        height: 132,
        padding: const EdgeInsets.all(15),
        decoration: AppStyle.retroBox(AppColors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.cocoa,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.cocoa,
                size: 26,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.cocoa,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.softBrown,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTipCard extends StatelessWidget {
  const HomeTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.retroBox(AppColors.white),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            Text(
              '🍳',
              style: TextStyle(fontSize: 36),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tip of the day: Save recipes you like so you can easily find them later.',
                style: TextStyle(
                  color: AppColors.cocoa,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.cocoa,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.cocoa,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.cocoa,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class HomeWelcomeCard extends StatelessWidget {
  final String name;
  final String avatarKey;

  const HomeWelcomeCard({
    super.key,
    required this.name,
    required this.avatarKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppStyle.retroBox(AppColors.white),
      child: Row(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: AppColors.butter,
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
              AvatarHelper.getAvatarIcon(avatarKey),
              color: AppColors.cocoa,
              size: 40,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: AppColors.softBrown,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ready for today’s recipe rush?',
                  style: TextStyle(
                    color: AppColors.softBrown,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeChallengeCard extends StatelessWidget {
  final VoidCallback onPlay;

  const HomeChallengeCard({
    super.key,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.retroBox(AppColors.white),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: BoxDecoration(
                color: AppColors.gamePeach,
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
                Icons.local_fire_department_rounded,
                color: AppColors.gameCoral,
                size: 40,
              ),
            ),

            const SizedBox(width: 16),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today’s Challenge',
                    style: TextStyle(
                      color: AppColors.cocoa,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Play Pancake Rush and earn stars.',
                    style: TextStyle(
                      color: AppColors.softBrown,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onPlay,
              child: Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: AppColors.gameCoral,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.cocoa,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeProgressCard extends StatelessWidget {
  final int totalStars;
  final String level;

  const HomeProgressCard({
    super.key,
    required this.totalStars,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.retroBox(AppColors.white),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeSectionLabel(
              icon: Icons.emoji_events_rounded,
              label: 'Chef Progress',
              color: AppColors.butter,
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: HomeMiniStat(
                    title: 'Stars',
                    value: totalStars.toString(),
                    icon: Icons.star_rounded,
                    color: AppColors.butter,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HomeMiniStat(
                    title: 'Level',
                    value: level,
                    icon: Icons.restaurant_menu_rounded,
                    color: AppColors.mint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeMiniStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const HomeMiniStat({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cocoa,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.cocoa,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.softBrown,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeQuickLinksCard extends StatelessWidget {
  final VoidCallback onOpenRecipes;
  final VoidCallback onOpenCommunity;

  const HomeQuickLinksCard({
    super.key,
    required this.onOpenRecipes,
    required this.onOpenCommunity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.retroBox(AppColors.white),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeSectionLabel(
              icon: Icons.auto_awesome_rounded,
              label: 'Quick Actions',
              color: AppColors.peach,
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: HomeActionButton(
                    title: 'Browse',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.peach,
                    onTap: onOpenRecipes,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HomeActionButton(
                    title: 'Community',
                    icon: Icons.forum_rounded,
                    color: AppColors.pink,
                    onTap: onOpenCommunity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HomeActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.cocoa,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.cocoa,
              size: 30,
            ),
            const SizedBox(height: 6),
            Text(
              title,
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

class HomeSectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const HomeSectionLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.cocoa,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.cocoa,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.cocoa,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class RecipesTab extends StatelessWidget {
  const RecipesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: AppStyle.retroBox(AppColors.butter),
            child: Row(
              children: [
                Container(
                  height: 66,
                  width: 66,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.cocoa,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.cocoa,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recipe Center',
                        style: TextStyle(
                          color: AppColors.cocoa,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Browse, save, and manage your cooking ideas.',
                        style: TextStyle(
                          color: AppColors.softBrown,
                          fontSize: 14,
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

          const SizedBox(height: 20),

          RecipeMenuTile(
            title: 'Browse Recipes',
            subtitle: 'Discover recipe ideas from the community.',
            icon: Icons.search_rounded,
            accentColor: AppColors.peach,
            buttonText: 'Open',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecipeListScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          RecipeMenuTile(
            title: 'My Recipes',
            subtitle: 'Add, edit, and delete your own recipes.',
            icon: Icons.restaurant_menu_rounded,
            accentColor: AppColors.mint,
            buttonText: 'Manage',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecipeListScreen(showOnlyMine: true),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          RecipeMenuTile(
            title: 'Favorite Recipes',
            subtitle: 'View the recipes you saved with the heart button.',
            icon: Icons.favorite_rounded,
            accentColor: AppColors.pink,
            buttonText: 'View',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritesScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: AppStyle.retroBox(AppColors.white),
            child: const Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: AppColors.tomato,
                  size: 34,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Tap the heart icon on any recipe to save it to your favorites.',
                    style: TextStyle(
                      color: AppColors.cocoa,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class RecipeMenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String buttonText;
  final VoidCallback onTap;

  const RecipeMenuTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.retroBox(AppColors.white),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 78,
                width: 78,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.cocoa,
                    width: 2.4,
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
                  size: 38,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.cocoa,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          color: AppColors.cocoa,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.cocoa,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.softBrown,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.cocoa,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.cocoa,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class GameTab extends StatelessWidget {
  const GameTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: AppStyle.retroBox(AppColors.butter),
            child: Row(
              children: [
                Container(
                  height: 66,
                  width: 66,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.cocoa,
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.sports_esports_rounded,
                    color: AppColors.cocoa,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cooking Game',
                        style: TextStyle(
                          color: AppColors.cocoa,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Play recipe challenges and earn cooking stars.',
                        style: TextStyle(
                          color: AppColors.softBrown,
                          fontSize: 14,
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

          const SizedBox(height: 20),

          RecipeMenuTile(
            title: 'Recipe Rush Challenge',
            subtitle: 'Choose ingredients fast, build combos, and cook perfectly.',
            icon: Icons.local_fire_department_rounded,
            accentColor: AppColors.tomato,
            buttonText: 'Play Game',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CookingGameScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          RecipeMenuTile(
            title: 'Earn Stars',
            subtitle: 'Your final score will be saved in your profile history.',
            icon: Icons.star_rounded,
            accentColor: AppColors.butter,
            buttonText: 'Progress',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CookingGameScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: AppStyle.retroBox(AppColors.white),
            child: const Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: AppColors.tomato,
                  size: 34,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Tap the correct ingredients quickly to build combos and get a higher score.',
                    style: TextStyle(
                      color: AppColors.cocoa,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final avatarKey = user?.avatarIcon ?? 'chef';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: AppStyle.retroBox(AppColors.white),
            child: Column(
              children: [
                Container(
                  height: 96,
                  width: 96,
                  decoration: BoxDecoration(
                    color: AppColors.butter,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.cocoa,
                      width: 2.5,
                    ),
                  ),
                  child: Icon(
                    AvatarHelper.getAvatarIcon(avatarKey),
                    color: AppColors.cocoa,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Chef',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.softBrown,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          ProfileInfoCard(
            title: 'Cooking Level',
            value: user?.cookingLevel ?? 'Beginner Chef',
            icon: Icons.emoji_events_rounded,
            color: AppColors.butter,
          ),

          const SizedBox(height: 14),

          ProfileInfoCard(
            title: 'Favorite Cuisine',
            value: user?.favoriteCuisine ?? 'Filipino Food',
            icon: Icons.restaurant_menu_rounded,
            color: AppColors.mint,
          ),

          const SizedBox(height: 14),

          ProfileInfoCard(
            title: 'Dietary Preference',
            value: user?.dietaryPreference ?? 'None',
            icon: Icons.health_and_safety_rounded,
            color: AppColors.peach,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: AppStyle.retroButton(AppColors.tomato),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit Profile & View History'),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderCard extends StatelessWidget {
  final String name;

  const HeaderCard({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: AppStyle.retroBox(AppColors.tomato),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good day,',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$name!',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ready to cook, play, and discover recipes?',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 82,
            width: 82,
            decoration: BoxDecoration(
              color: AppColors.butter,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.cocoa,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.local_dining_rounded,
              color: AppColors.cocoa,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}
class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.cocoa,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.butter,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cocoa,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.cocoa,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.softBrown,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LargeActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String buttonText;
  final VoidCallback onTap;
  final bool isDark;

  const LargeActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.buttonText,
    required this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: AppStyle.retroBox(AppColors.white),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -35,
            child: Container(
              height: 115,
              width: 115,
              decoration: BoxDecoration(
                color: color.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 28,
            bottom: 18,
            child: Icon(
              icon,
              size: 90,
              color: color.withOpacity(0.22),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 76,
                  width: 76,
                  decoration: BoxDecoration(
                    color: color,
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
                    size: 40,
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.softBrown,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppStyle.retroButton(color),
                    onPressed: onTap,
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmallStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SmallStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppStyle.retroBox(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.cocoa,
            size: 34,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppStyle.retroBox(AppColors.white),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.cocoa,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.cocoa,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.softBrown,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
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
          ),
        ],
      ),
    );
  }
}