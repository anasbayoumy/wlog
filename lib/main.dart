import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/secrets/supabase_secrets.dart';
import 'package:wlog/core/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/features/auth/domain/usecases/user_signUp.dart';
import 'package:wlog/features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/datasouces/auth_remote_data_source.dart';
import 'features/auth/data/repo/auth_repo_imp.dart';
import 'features/auth/presentation/pages/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supabase = await Supabase.initialize(
    url: SupabaseSecrets.url,
    anonKey: SupabaseSecrets.anonKey,
  );
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => (_) =>AuthBloc(userSignup: UserSignup(AuthRepoImp(AuthRemoteDataSourceImp(supabase.client))),
      ),
      // BlocProvider(
      //   create: (context) => SubjectBloc(),
      // ),
    ],
    child: const MyApp(),
  )
  
);
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
