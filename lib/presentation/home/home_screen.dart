import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "User is AUTHENTICATED",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.brown),
        ),
      ),
    );
  }
}
