import 'package:flutter/material.dart';
import 'package:wlog/core/theme/theme_pallet.dart';

class AuthGradientbtn extends StatelessWidget {
  final String text;
  const AuthGradientbtn({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const RadialGradient(
              colors: [AppPallete.gradient1, AppPallete.gradient2])),
      child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPallete.transparentColor,
            shadowColor: AppPallete.transparentColor,
            maximumSize: const Size(600, 50),
          ),
          child: Text(text,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1))),
    );
  }
}
