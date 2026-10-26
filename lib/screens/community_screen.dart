import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/community_post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/community_provider.dart';
import '../utils/avatar_helper.dart';
import '../utils/constants.dart';
import 'create_community_post_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  String formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> deletePost({
    required BuildContext context,
    required String postId,
  }) async {
    final communityProvider =
    Provider.of<CommunityProvider>(context, listen: false);

    final success = await communityProvider.deletePost(postId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.cocoa,
          content: Text(
            'Post deleted.',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  Future<void> addSamplePosts(BuildContext context) async {
    final communityProvider =
    Provider.of<CommunityProvider>(context, listen: false);

    final success = await communityProvider.addSamplePosts();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.cocoa : AppColors.tomato,
        content: Text(
          success
              ? 'Sample community posts added!'
              : communityProvider.errorMessage ?? 'Failed to add sample posts.',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final currentUserId = authProvider.currentUser?.uid ?? '';
    final currentUser = authProvider.userModel;

    return StreamBuilder<List<CommunityPostModel>>(
      stream: communityProvider.postsStream,
      builder: (context, snapshot) {
        final posts = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: [
            CompactCommunityHeader(
              userName: currentUser?.name ?? 'Chef',
              avatarKey: currentUser?.avatarIcon ?? 'chef',
            ),

            const SizedBox(height: 14),

            CompactWriteReviewCard(
              userName: currentUser?.name ?? 'Chef',
              avatarKey: currentUser?.avatarIcon ?? 'chef',
            ),

            const SizedBox(height: 14),

            const CommunityTopicsRow(),

            const SizedBox(height: 16),

            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.tomato,
                  ),
                ),
              )
            else if (snapshot.hasError)
              const CommunityErrorCard()
            else if (posts.isEmpty)
                EmptyCommunityState(
                  isLoading: communityProvider.isLoading,
                  onAddSamples: () => addSamplePosts(context),
                )
              else
                ...posts.map((post) {
                  final isOwner = post.userId == currentUserId;
                  final isLiked = post.likedBy.contains(currentUserId);

                  return CommunityFeedCard(
                    post: post,
                    isOwner: isOwner,
                    isLiked: isLiked,
                    currentUserId: currentUserId,
                    dateText: formatDate(post.createdAt),
                    onLike: () {
                      communityProvider.toggleLike(
                        postId: post.id,
                        userId: currentUserId,
                      );
                    },
                    onDelete: () {
                      deletePost(
                        context: context,
                        postId: post.id,
                      );
                    },
                  );
                }),
          ],
        );
      },
    );
  }
}

class CompactCommunityHeader extends StatelessWidget {
  final String userName;
  final String avatarKey;

  const CompactCommunityHeader({
    super.key,
    required this.userName,
    required this.avatarKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.retroBox(AppColors.white),
      padding: const EdgeInsets.all(16),
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
              Icons.groups_rounded,
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
                  'Food Community',
                  style: TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Food reviews, tips, and stories.',
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
    );
  }
}

class CompactWriteReviewCard extends StatelessWidget {
  final String userName;
  final String avatarKey;

  const CompactWriteReviewCard({
    super.key,
    required this.userName,
    required this.avatarKey,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateCommunityPostScreen(),
          ),
        );
      },
      child: Container(
        decoration: AppStyle.retroBox(AppColors.gameSoftOrange),
        padding: const EdgeInsets.all(14),
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
                AvatarHelper.getAvatarIcon(avatarKey),
                color: AppColors.cocoa,
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Write a food review, $userName...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.cocoa,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.tomato,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.cocoa,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityTopicsRow extends StatelessWidget {
  const CommunityTopicsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CommunityTopicChip(
            label: 'Reviews',
            icon: Icons.star_rounded,
            color: AppColors.butter,
          ),
          SizedBox(width: 8),
          CommunityTopicChip(
            label: 'Tips',
            icon: Icons.tips_and_updates_rounded,
            color: AppColors.mint,
          ),
          SizedBox(width: 8),
          CommunityTopicChip(
            label: 'Budget Meals',
            icon: Icons.payments_rounded,
            color: AppColors.peach,
          ),
          SizedBox(width: 8),
          CommunityTopicChip(
            label: 'Desserts',
            icon: Icons.cake_rounded,
            color: AppColors.pink,
          ),
        ],
      ),
    );
  }
}

class CommunityTopicChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const CommunityTopicChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cocoa,
          width: 1.7,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.cocoa,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityErrorCard extends StatelessWidget {
  const CommunityErrorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.retroBox(AppColors.white),
      padding: const EdgeInsets.all(22),
      child: const Text(
        'Something went wrong while loading posts.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.cocoa,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class EmptyCommunityState extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onAddSamples;

  const EmptyCommunityState({
    super.key,
    required this.isLoading,
    required this.onAddSamples,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.retroBox(AppColors.white),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppColors.peach,
              borderRadius: BorderRadius.circular(23),
              border: Border.all(
                color: AppColors.cocoa,
                width: 2.5,
              ),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: AppColors.cocoa,
              size: 39,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No community posts yet!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cocoa,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add demo posts or create your own food review.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.softBrown,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: AppStyle.retroButton(AppColors.tomato),
              onPressed: isLoading ? null : onAddSamples,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: isLoading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: AppColors.cocoa,
                  strokeWidth: 3,
                ),
              )
                  : const Text('Add Sample Posts'),
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityFeedCard extends StatelessWidget {
  final CommunityPostModel post;
  final bool isOwner;
  final bool isLiked;
  final String currentUserId;
  final String dateText;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  const CommunityFeedCard({
    super.key,
    required this.post,
    required this.isOwner,
    required this.isLiked,
    required this.currentUserId,
    required this.dateText,
    required this.onLike,
    required this.onDelete,
  });

  Color getRatingColor() {
    if (post.rating >= 5) {
      return AppColors.butter;
    } else if (post.rating >= 4) {
      return AppColors.mint;
    } else {
      return AppColors.peach;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingColor = getRatingColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppStyle.retroBox(AppColors.white),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.butter,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: AppColors.cocoa,
                    width: 2.2,
                  ),
                ),
                child: Icon(
                  AvatarHelper.getAvatarIcon(post.userAvatarIcon),
                  color: AppColors.cocoa,
                  size: 27,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.cocoa,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'posted on $dateText',
                      style: const TextStyle(
                        color: AppColors.softBrown,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: AppColors.tomato,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            post.title,
            style: const TextStyle(
              color: AppColors.cocoa,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CommunityFoodTag(
                label: post.foodName,
                icon: Icons.restaurant_menu_rounded,
                color: AppColors.peach,
              ),
              CommunityFoodTag(
                label: '${post.rating}/5',
                icon: Icons.star_rounded,
                color: ratingColor,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.cocoa,
                width: 1.7,
              ),
            ),
            child: Text(
              post.content,
              style: const TextStyle(
                color: AppColors.cocoa,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              CommunityActionButton(
                icon: isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: '${post.likes}',
                color: isLiked ? AppColors.tomato : AppColors.cocoa,
                onTap: currentUserId.isEmpty ? null : onLike,
              ),
              const SizedBox(width: 10),
              CommunityActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Discuss',
                color: AppColors.cocoa,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.cocoa,
                      content: Text(
                        'Discussion feature can be added next!',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.cocoa,
                    width: 1.5,
                  ),
                ),
                child: const Text(
                  'Review',
                  style: TextStyle(
                    color: AppColors.cocoa,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommunityFoodTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const CommunityFoodTag({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cocoa,
          width: 1.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.cocoa,
            size: 16,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.cocoa,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const CommunityActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cocoa,
            width: 1.7,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 19,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.cocoa,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}