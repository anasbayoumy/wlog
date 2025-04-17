import 'package:flutter/material.dart';

class TextFieldContent extends StatelessWidget {
  const TextFieldContent(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.maxlines});

  final String hintText;
  final TextEditingController controller;
  final int? maxlines;

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
    );
  }
}
