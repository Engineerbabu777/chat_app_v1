import 'dart:developer';

import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository extends BaseRepository {
  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserModel> signUp({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final formattedPhoneNumber = phoneNumber.replaceAll(
        RegExp(r'\+'),
        "".trim(),
      );
      final userCredentials = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredentials.user == null) {
        throw "Failed to create user";
      }

      final user = UserModel(
        uid: userCredentials.user!.uid,
        username: username,
        email: email,
        fullName: fullName,
        phoneNumber: formattedPhoneNumber,
      );

      await saveUserData(user);

      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print("Hello");

      final loggedInUser = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (loggedInUser.user == null) {
        throw "Invalid credentials";
      }

      final userData = await getUserData(loggedInUser.user!.uid);

      print(userData.uid);

      return userData;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> saveUserData(UserModel user) async {
    try {
      await firestore.collection("users").doc(user.uid).set(user.toMap());
    } catch (e) {
      throw "Failed to save user data";
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      throw "Failed to signout";
    }
  }

  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await firestore.collection("users").doc(uid).get();

      if (!doc.exists) {
        throw "User data not found";
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw "Failed to fetch user data";
    }
  }
}
