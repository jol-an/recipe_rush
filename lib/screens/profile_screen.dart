import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_result_model.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../utils/avatar_helper.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  String selectedLevel = 'Beginner Chef';
  String selectedCuisine = 'Filipino Food';
  String selectedDiet = 'None';
  String selectedAvatar = 'chef';

  final List<String> levels = [
    'Beginner Chef',
    'Home Cook',
    'Recipe Explorer',
    'Kitchen Master',
  ];

  final List<String> cuisines = [
    'Filipino Food',
    'Desserts',
    'Healthy Meals',
    'Budget Meals',
    'Quick Meals',
    'Snacks',
    'Other',
  ];

  final List<String> diets = [
    'None',
    'Vegetarian',
    'Low Sugar',
    'Low Salt',
    'High Protein',
  ];

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;

    nameController.text = user?.name ?? '';

    selectedLevel = user != null && levels.contains(user.cookingLevel)
        ? user.cookingLevel
        : 'Beginner Chef';

    selectedCuisine = user != null && cuisines.contains(user.favoriteCuisine)
        ? user.favoriteCuisine
        : 'Filipino Food';

    selectedDiet = user != null && diets.contains(user.dietaryPreference)
        ? user.dietaryPreference
        : 'None';

    selectedAvatar = user?.avatarIcon ?? 'chef';
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateProfile(
      name: nameController.text,
      cookingLevel: selectedLevel,
      favoriteCuisine: selectedCuisine,
      dietaryPreference: selectedDiet,
      avatarIcon: selectedAvatar,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.cocoa : AppColors.tomato,
        content: Text(
          success
              ? 'Profile updated successfully!'
              : authProvider.errorMessage ?? 'Failed to update profile.',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);

    final user = authProvider.userModel;
    final userId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.cocoa,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppStyle.retroBox(AppColors.white),
                child: Row(
                  children: [
                    Container(
                      height: 66,
                      width: 66,
                      decoration: BoxDecoration(
                        color: AppColors.butter,
                        borderRadius: BorderRadius.circular(22),
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
                        AvatarHelper.getAvatarIcon(selectedAvatar),
                        color: AppColors.cocoa,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Chef',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.cocoa,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.softBrown,
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

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: AppStyle.retroBox(AppColors.white),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProfileSectionTitle(
                        icon: Icons.face_rounded,
                        title: 'Choose Avatar',
                        color: AppColors.peach,
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AvatarHelper.avatarKeys.map((avatarKey) {
                          final isSelected = selectedAvatar == avatarKey;

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              setState(() {
                                selectedAvatar = avatarKey;
                              });
                            },
                            child: Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.butter
                                    : AppColors.cream,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.cocoa,
                                  width: isSelected ? 2.8 : 1.8,
                                ),
                              ),
                              child: Icon(
                                AvatarHelper.getAvatarIcon(avatarKey),
                                color: AppColors.cocoa,
                                size: 29,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      const ProfileSectionTitle(
                        icon: Icons.edit_rounded,
                        title: 'Profile Details',
                        color: AppColors.mint,
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: nameController,
                        validator: Validators.validateName,
                        decoration: AppStyle.inputDecoration(
                          'Full Name',
                          Icons.person_rounded,
                        ),
                      ),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        value: selectedLevel,
                        decoration: AppStyle.inputDecoration(
                          'Cooking Level',
                          Icons.emoji_events_rounded,
                        ),
                        items: levels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedLevel = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        value: selectedCuisine,
                        decoration: AppStyle.inputDecoration(
                          'Favorite Cuisine',
                          Icons.restaurant_menu_rounded,
                        ),
                        items: cuisines.map((cuisine) {
                          return DropdownMenuItem(
                            value: cuisine,
                            child: Text(cuisine),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCuisine = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        value: selectedDiet,
                        decoration: AppStyle.inputDecoration(
                          'Dietary Preference',
                          Icons.health_and_safety_rounded,
                        ),
                        items: diets.map((diet) {
                          return DropdownMenuItem(
                            value: diet,
                            child: Text(diet),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDiet = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: AppStyle.retroButton(AppColors.tomato),
                          onPressed:
                          authProvider.isLoading ? null : saveProfile,
                          icon: const Icon(Icons.save_rounded),
                          label: authProvider.isLoading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.cocoa,
                              strokeWidth: 3,
                            ),
                          )
                              : const Text('Save Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: AppStyle.retroBox(AppColors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfileSectionTitle(
                      icon: Icons.history_rounded,
                      title: 'Game History',
                      color: AppColors.butter,
                    ),

                    const SizedBox(height: 14),

                    StreamBuilder<List<GameResultModel>>(
                      stream: gameProvider.userGameResultsStream(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(18),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.tomato,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Text(
                            'Unable to load game history.',
                            style: TextStyle(
                              color: AppColors.cocoa,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }

                        final results = snapshot.data ?? [];

                        if (results.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.cocoa,
                                width: 1.7,
                              ),
                            ),
                            child: const Text(
                              'No cooking challenges played yet.',
                              style: TextStyle(
                                color: AppColors.softBrown,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: results.take(5).map((result) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.cocoa,
                                  width: 1.7,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 42,
                                    width: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.gameHoney,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: AppColors.cocoa,
                                        width: 1.7,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.sports_esports_rounded,
                                      color: AppColors.cocoa,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          result.recipeTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.cocoa,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          'Score: ${result.score} • Stars: ${'★' * result.stars}',
                                          style: const TextStyle(
                                            color: AppColors.softBrown,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatDate(result.playedAt),
                                    style: const TextStyle(
                                      color: AppColors.softBrown,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const ProfileSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.cocoa,
              width: 1.8,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.cocoa,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.cocoa,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}