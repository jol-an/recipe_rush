import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/community_post_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('community_posts');

  Stream<List<CommunityPostModel>> getPosts() {
    return _posts.snapshots().map((snapshot) {
      final posts = snapshot.docs.map((doc) {
        return CommunityPostModel.fromDocument(doc);
      }).toList();

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return posts;
    });
  }

  Future<void> addPost(CommunityPostModel post) async {
    await _posts.add(post.toMap());
  }

  Future<void> deletePost(String postId) async {
    await _posts.doc(postId).delete();
  }

  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final postRef = _posts.doc(postId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);

      if (!snapshot.exists) return;

      final data = snapshot.data() ?? {};

      final List<String> likedBy = List<String>.from(data['likedBy'] ?? []);
      int likes = data['likes'] ?? 0;

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        likes = likes > 0 ? likes - 1 : 0;
      } else {
        likedBy.add(userId);
        likes++;
      }

      transaction.update(postRef, {
        'likedBy': likedBy,
        'likes': likes,
      });
    });
  }
  Future<void> addSamplePosts() async {
    final snapshot = await _posts.limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final List<Map<String, dynamic>> samplePosts = [
      {
        'userId': 'sample_user_ana',
        'userName': 'Ana Bakes',
        'userAvatarIcon': 'cake',
        'title': 'Mango Graham Float is still the easiest dessert!',
        'foodName': 'Mango Graham Float',
        'content':
        'I tried making mango graham float last weekend and it was super easy. I recommend chilling it overnight because the texture becomes softer and creamier.',
        'rating': 5,
        'likes': 12,
        'likedBy': [],
        'createdAt': Timestamp.now(),
        'isSample': true,
      },
      {
        'userId': 'sample_user_mico',
        'userName': 'Mico Eats',
        'userAvatarIcon': 'pizza',
        'title': 'Budget tuna rice bowl saved my lunch',
        'foodName': 'Tuna Rice Bowl',
        'content':
        'This is a good student meal. I added egg and a little soy sauce. It is cheap, fast, and filling. Perfect kapag nagtitipid.',
        'rating': 4,
        'likes': 8,
        'likedBy': [],
        'createdAt': Timestamp.now(),
        'isSample': true,
      },
      {
        'userId': 'sample_user_lia',
        'userName': 'Lia Cooks',
        'userAvatarIcon': 'ramen',
        'title': 'Chicken adobo tip: let it simmer longer',
        'foodName': 'Chicken Adobo',
        'content':
        'For better flavor, I let the chicken simmer longer until the sauce becomes thicker. Mas masarap siya kapag slightly reduced yung sauce.',
        'rating': 5,
        'likes': 15,
        'likedBy': [],
        'createdAt': Timestamp.now(),
        'isSample': true,
      },
      {
        'userId': 'sample_user_ren',
        'userName': 'Ren Coffee',
        'userAvatarIcon': 'coffee',
        'title': 'Garlic fried rice is best with leftover rice',
        'foodName': 'Garlic Fried Rice',
        'content':
        'Fresh rice can be sticky, so leftover rice works better. I also toast the garlic first para mas mabango.',
        'rating': 4,
        'likes': 6,
        'likedBy': [],
        'createdAt': Timestamp.now(),
        'isSample': true,
      },
      {
        'userId': 'sample_user_sam',
        'userName': 'Sam Sweet Tooth',
        'userAvatarIcon': 'icecream',
        'title': 'Pancakes are better with butter and honey',
        'foodName': 'Classic Pancakes',
        'content':
        'I tried the pancake recipe and added honey on top. The texture was fluffy, but do not overmix the batter para hindi matigas.',
        'rating': 5,
        'likes': 10,
        'likedBy': [],
        'createdAt': Timestamp.now(),
        'isSample': true,
      },
    ];

    for (final post in samplePosts) {
      await _posts.add(post);
    }
  }
}