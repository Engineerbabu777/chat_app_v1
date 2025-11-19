import 'package:chat_app/config/theme/app_theme.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/auth/auth_cubit.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              getIt<AuthCubit>().signOut();
            },
            child: Icon(Icons.logout),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 20),
        title: Text("Chats"),
      ),
      body: Center(
        child: Text(
          "User is AUTHENTICATED",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.brown),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
