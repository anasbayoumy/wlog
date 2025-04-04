import 'package:flutter/material.dart';
import 'package:wlog/core/secrets/supabase_secrets.dart';
import 'package:wlog/core/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/pages/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseSecrets.url,
    anonKey: SupabaseSecrets.anonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WLOG',
      theme: AppTheme.DarkModeTheme,
      debugShowCheckedModeBanner: false,
      home: const SignUpPage(),
    );
  }
}
