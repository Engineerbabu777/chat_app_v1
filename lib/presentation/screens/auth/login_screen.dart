import 'package:chat_app/core/common/custom_text_field.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordCOntroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Text(
                  "Welcome Back",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Sign in to continue",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.grey),
                ),
                SizedBox(height: 30),

                CustomTextField(
                  controller: emailController,
                  hintText: "Email",
                  prefxIcon: Icon(Icons.email_outlined),
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller: passwordCOntroller,
                  hintText: "Password",
                  obscureText: true,
                  prefxIcon: Icon(Icons.lock_outline),
                  suffixIcon: Icon(Icons.visibility),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
