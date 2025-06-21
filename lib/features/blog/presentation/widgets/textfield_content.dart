import 'package:flutter/material.dart';

class TextFieldContent extends StatelessWidget {
  const TextFieldContent({
    super.key,
    required this.hintText,
    required this.controller,
    required this.maxlines,
    this.validatorText = 'This field cannot be empty',
  });

  final String hintText;
  final TextEditingController controller;
  final int? maxlines;
  final String validatorText;

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
      maxLines: maxlines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
    );
  }
}
