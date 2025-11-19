import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String fullName;
  final String phoneNumber;
  final bool isOnline;
  final Timestamp lastSeen;
  final Timestamp createdAt;
  final String fcmToken;
  final List<String> blockedUsers;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.isOnline = false,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    required this.fcmToken,
    this.blockedUsers = const [],
  }) : lastSeen = lastSeen ?? Timestamp.now(),
       createdAt = createdAt ?? Timestamp.now();
}
