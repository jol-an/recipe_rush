import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential userCredential =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    User? user = userCredential.user;

    if (user != null) {
      UserModel newUser = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc =
    await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  Future<void> updateUserProfile(UserModel userModel) async {
    await _firestore
        .collection('users')
        .doc(userModel.uid)
        .update(userModel.toMap());
  }
}