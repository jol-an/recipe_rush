import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarIcon;
  final String title;
  final String foodName;
  final String content;
  final int rating;
  final int likes;
  final List<String> likedBy;
  final DateTime createdAt;

  CommunityPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarIcon,
    required this.title,
    required this.foodName,
    required this.content,
    required this.rating,
    required this.likes,
    required this.likedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatarIcon': userAvatarIcon,
      'title': title,
      'foodName': foodName,
      'content': content,
      'rating': rating,
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommunityPostModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    DateTime parsedDate = DateTime.now();

    if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    }

    return CommunityPostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Chef',
      userAvatarIcon: data['userAvatarIcon'] ?? 'chef',
      title: data['title'] ?? '',
      foodName: data['foodName'] ?? '',
      content: data['content'] ?? '',
      rating: data['rating'] ?? 0,
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: parsedDate,
    );
  }
}