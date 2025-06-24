import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:wlog/core/common/cubits/theme/theme_cubit.dart';
import 'package:wlog/core/theme/theme.dart';
import 'package:wlog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wlog/features/auth/presentation/pages/loginpage.dart';
import 'package:wlog/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:wlog/features/blog/presentation/pages/blog_page.dart';
import 'package:wlog/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:wlog/features/analytics/presentation/bloc/performance_analysis_bloc.dart';
import 'package:wlog/initDependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  final authBloc = serviceLocator<AuthBloc>();
  final appUserCubit = serviceLocator<AppUserCubit>();
  final blogBloc = serviceLocator<BlogBloc>();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => serviceLocator<AuthBloc>(),
      ),
      BlocProvider(
        create: (context) => serviceLocator<AppUserCubit>(),
      ),
      BlocProvider(
        create: (context) => serviceLocator<BlogBloc>(),
      ),
      BlocProvider(
        create: (context) => serviceLocator<ThemeCubit>(),
      ),
      BlocProvider(
        create: (context) => serviceLocator<ChatBloc>(),
      ),
      BlocProvider(
        create: (context) => serviceLocator<PerformanceAnalysisBloc>(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(IsUserLoggedInEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'WLOG',
          theme:
              themeState.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: BlocSelector<AppUserCubit, AppUserState, bool>(
            selector: (state) => state is IsLoggedIn,
            builder: (context, isLoggedIn) {
              return isLoggedIn ? const BlogPage() : const LoginPage();
            },
          ),
        );
      },
    );
  }
}
