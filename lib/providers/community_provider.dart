import 'package:flutter/material.dart';

import '../models/community_post_model.dart';
import '../services/community_service.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityService _communityService = CommunityService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<List<CommunityPostModel>> get postsStream {
    return _communityService.getPosts();
  }

  Future<bool> addPost({
    required String userId,
    required String userName,
    required String userAvatarIcon,
    required String title,
    required String foodName,
    required String content,
    required int rating,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final post = CommunityPostModel(
        id: '',
        userId: userId,
        userName: userName.trim(),
        userAvatarIcon: userAvatarIcon,
        title: title.trim(),
        foodName: foodName.trim(),
        content: content.trim(),
        rating: rating,
        likes: 0,
        likedBy: [],
        createdAt: DateTime.now(),
      );

      await _communityService.addPost(post);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create post.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _communityService.deletePost(postId);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete post.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      await _communityService.toggleLike(
        postId: postId,
        userId: userId,
      );

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update like.';
      notifyListeners();
      return false;
    }
  }
  Future<bool> addSamplePosts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _communityService.addSamplePosts();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add sample community posts.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}