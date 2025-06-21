part of 'theme_cubit.dart';

@immutable
class ThemeState {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState && other.isDarkMode == isDarkMode;
  }

  @override
  int get hashCode => isDarkMode.hashCode;
}
