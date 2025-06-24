import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseSecrets {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
