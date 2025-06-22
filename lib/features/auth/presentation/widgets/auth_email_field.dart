import 'package:flutter/material.dart';
import 'package:wlog/core/theme/theme.dart';

class AuthEmailField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;

  const AuthEmailField({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  State<AuthEmailField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthEmailField> {
  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your ${widget.hintText}';
    }

    // Check if the email contains @sofindex.com
    if (!value.toLowerCase().endsWith('@sofindex.com')) {
      return 'Only an email with @sofindex.com shall pass';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: AppTheme.border(),
      ),
      validator: _validate,
    );
  }
}
