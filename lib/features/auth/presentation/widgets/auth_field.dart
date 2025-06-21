import 'package:flutter/material.dart';
import 'package:wlog/core/theme/theme.dart';

class AuthField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;

  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Initialize obscureText based on whether it's a password field.
    _obscureText = widget.isPassword;
  }

  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your ${widget.hintText}';
    }
    // If the field hint contains "email", perform email validation.
    if (widget.hintText.toLowerCase().contains('email')) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    }
    // If the field hint contains "password", enforce a minimum length.
    if (widget.hintText.toLowerCase().contains('password')) {
      if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: AppTheme.border(),
        // Show a toggle icon only if this is a password field.
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      validator: _validate,
    );
  }
}
