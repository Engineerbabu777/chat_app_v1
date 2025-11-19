import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/services/base_repository.dart';

class AuthRepository extends BaseRepository {
  Future<UserModel> signUp({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
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
        phoneNumber: phoneNumber,
      );

      await saveUserData(user);

      return user;
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
}
