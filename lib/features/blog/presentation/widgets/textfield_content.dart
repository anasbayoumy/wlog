import 'package:flutter/material.dart';

class TextFieldContent extends StatelessWidget {
  const TextFieldContent(
      {super.key, required this.hintText, required this.controller});

  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      controller: controller,
    );
  }
}
