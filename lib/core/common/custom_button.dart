import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function()? onPressed;
  final String? text;
  final Widget? child;

  const CustomButton({super.key, this.onPressed, this.text, this.child})
    : assert(
        text != null || child != null,
        'Einter text or child must be provided',
      );

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
