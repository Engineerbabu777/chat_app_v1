import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefxIcon;
  final FocusNode? focusNode;

  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefxIcon,
    this.focusNode,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
