import 'package:flutter/material.dart';
import 'package:wlog/core/theme/theme_pallet.dart';

class AppTheme {
  static OutlineInputBorder border([Color color = AppPallete.borderColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 4),
        borderRadius: BorderRadius.circular(15),
      );

  static final ThemeData DarkModeTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      // border: border(AppPallete.gradient3),
      focusedBorder: border(AppPallete.gradient3),
      enabledBorder: border(),
    ),
  );
}
