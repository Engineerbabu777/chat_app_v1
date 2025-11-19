import 'package:chat_app/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactRepository extends BaseRepository {
  String get currentUserId => FirebaseAuth.instance.currentUser!.uid ?? "";

  Future<bool> requestContactsPermission() async {
    return await FlutterContacts.requestPermission();
  }
}
