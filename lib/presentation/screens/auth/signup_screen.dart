import 'package:chat_app/core/common/custom_button.dart';
import 'package:chat_app/core/common/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController paswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    paswordController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Account",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Create an account to continue",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.grey),
                ),
                SizedBox(height: 30),

                CustomTextField(
                  controller: nameController,
                  hintText: "Full Name",
                  prefxIcon: Icon(Icons.person_outline),
                ),
                SizedBox(height: 16),

                CustomTextField(
                  controller: nameController,
                  hintText: "Username",
                  prefxIcon: Icon(Icons.alternate_email),
                ),
                SizedBox(height: 16),

                CustomTextField(
                  controller: nameController,
                  hintText: "Email",
                  prefxIcon: Icon(Icons.email_outlined),
                ),
                SizedBox(height: 16),

                CustomTextField(
                  controller: nameController,
                  hintText: "Password",
                  prefxIcon: Icon(Icons.lock_outline),
                  suffixIcon: Icon(Icons.visibility),
                ),
                SizedBox(height: 16),

                CustomTextField(
                  controller: nameController,
                  hintText: "Phone Number",
                  prefxIcon: Icon(Icons.phone_outlined),
                ),
                SizedBox(height: 30),

                CustomButton(onPressed: () {}, text: "Create Account"),

                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account?  ",
                      style: TextStyle(color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
