import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/community_provider.dart';
import '../utils/avatar_helper.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  State<CreateCommunityPostScreen> createState() =>
      _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  int selectedRating = 5;

  @override
  void dispose() {
    titleController.dispose();
    foodNameController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final communityProvider =
    Provider.of<CommunityProvider>(context, listen: false);

    final user = authProvider.userModel;
    final userId = authProvider.currentUser?.uid ?? '';

    if (user == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.tomato,
          content: Text(
            'Please login first.',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      return;
    }

    final success = await communityProvider.addPost(
      userId: userId,
      userName: user.name,
      userAvatarIcon: user.avatarIcon,
      title: titleController.text,
      foodName: foodNameController.text,
      content: contentController.text,
      rating: selectedRating,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.cocoa,
          content: Text(
            'Post shared successfully!',
            style: TextStyle(
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
            communityProvider.errorMessage ?? 'Something went wrong.',
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
    final authProvider = Provider.of<AuthProvider>(context);
    final communityProvider = Provider.of<CommunityProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Create Post',
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
                      height: 58,
                      width: 58,
                      decoration: BoxDecoration(
                        color: AppColors.peach,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.cocoa,
                          width: 2.3,
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
                        Icons.rate_review_rounded,
                        color: AppColors.cocoa,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Share a Food Review',
                            style: TextStyle(
                              color: AppColors.cocoa,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Post your food thoughts to the community.',
                            style: TextStyle(
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
                padding: const EdgeInsets.all(14),
                decoration: AppStyle.retroBox(AppColors.gameSoftOrange),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.butter,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: AppColors.cocoa,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        AvatarHelper.getAvatarIcon(user?.avatarIcon ?? 'chef'),
                        color: AppColors.cocoa,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Posting as ${user?.name ?? 'Chef'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.cocoa,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
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
                    children: [
                      TextFormField(
                        controller: titleController,
                        validator: (value) =>
                            Validators.validateRequired(value, 'Post title'),
                        decoration: AppStyle.inputDecoration(
                          'Post Title',
                          Icons.title_rounded,
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: foodNameController,
                        validator: (value) =>
                            Validators.validateRequired(value, 'Food name'),
                        decoration: AppStyle.inputDecoration(
                          'Food / Recipe Name',
                          Icons.restaurant_menu_rounded,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Rating',
                          style: const TextStyle(
                            color: AppColors.cocoa,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: List.generate(5, (index) {
                          final rating = index + 1;
                          final isSelected = rating <= selectedRating;

                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: index == 4 ? 0 : 8,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  setState(() {
                                    selectedRating = rating;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.butter
                                        : AppColors.cream,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.cocoa,
                                      width: 1.8,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: AppColors.cocoa,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: contentController,
                        validator: (value) =>
                            Validators.validateRequired(value, 'Review'),
                        maxLines: 6,
                        decoration: AppStyle.inputDecoration(
                          'Write your review or experience',
                          Icons.edit_note_rounded,
                        ),
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: AppStyle.retroButton(AppColors.tomato),
                          onPressed:
                          communityProvider.isLoading ? null : submitPost,
                          icon: const Icon(Icons.send_rounded),
                          label: communityProvider.isLoading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.cocoa,
                              strokeWidth: 3,
                            ),
                          )
                              : const Text('Post Review'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}