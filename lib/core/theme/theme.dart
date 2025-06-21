import 'package:flutter/material.dart';
import 'package:wlog/core/theme/theme_pallet.dart';

class AppTheme {
  static OutlineInputBorder border([Color color = AppPallete.borderColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 4),
        borderRadius: BorderRadius.circular(15),
      );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: border(AppPallete.gradient3),
      enabledBorder: border(),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.backgroundColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppPallete.greyColor.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: border(AppPallete.gradient3),
      enabledBorder: border(Colors.grey),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
    ),
    cardTheme: CardTheme(
      color: Colors.grey[100],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // Keep backward compatibility
  static ThemeData get DarkModeTheme => darkTheme;
}
