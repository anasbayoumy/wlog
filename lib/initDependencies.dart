import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:wlog/core/common/cubits/theme/theme_cubit.dart';
import 'package:wlog/core/secrets/supabase_secrets.dart';
import 'package:wlog/features/auth/data/datasouces/auth_remote_data_source.dart';
import 'package:wlog/features/auth/data/repo/auth_repo_imp.dart';
import 'package:wlog/features/auth/domain/repo/auth_repo.dart';
import 'package:wlog/features/auth/domain/usecases/current_user.dart';
import 'package:wlog/features/auth/domain/usecases/use_login.dart';
import 'package:wlog/features/auth/domain/usecases/user_signUp.dart';
import 'package:wlog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wlog/features/blog/data/datasource/blog_remote_data_source.dart';
import 'package:wlog/features/blog/data/repos/blog_repo_imp.dart';
import 'package:wlog/features/blog/domain/repos/blog_repo.dart';
import 'package:wlog/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:wlog/features/blog/domain/usecases/get_all_blogs_for_analytics.dart';
import 'package:wlog/features/blog/domain/usecases/upload_blog.dart';
import 'package:wlog/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:wlog/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:wlog/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:wlog/features/chat/domain/repositories/chat_repository.dart';
import 'package:wlog/features/chat/domain/usecases/get_chat_groups.dart';
import 'package:wlog/features/chat/domain/usecases/get_messages.dart';
import 'package:wlog/features/chat/domain/usecases/send_message.dart';
import 'package:wlog/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:wlog/core/ai/image_analysis_service.dart';
import 'package:wlog/core/ai/trends_scraper_service.dart';
import 'package:wlog/core/ai/performance_analysis_service.dart';
import 'package:wlog/features/analytics/presentation/bloc/performance_analysis_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  _initAI();
  final supabase = await Supabase.initialize(
    url: SupabaseSecrets.url,
    anonKey: SupabaseSecrets.anonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);

  serviceLocator.registerLazySingleton<AppUserCubit>(
    () => AppUserCubit(),
  );

  serviceLocator.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(),
  );

  _initChat();
}

void _initChat() {
  // Data sources
  serviceLocator.registerFactory<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      supabaseClient: serviceLocator(),
    ),
  );

  // Repository
  serviceLocator.registerFactory<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: serviceLocator(),
    ),
  );

  // Use cases
  serviceLocator.registerFactory<GetChatGroups>(
    () => GetChatGroups(serviceLocator()),
  );

  serviceLocator.registerFactory<GetMessages>(
    () => GetMessages(serviceLocator()),
  );

  serviceLocator.registerFactory<SendMessage>(
    () => SendMessage(serviceLocator()),
  );

  // Bloc
  serviceLocator.registerLazySingleton<ChatBloc>(
    () => ChatBloc(
      getChatGroups: serviceLocator(),
      getMessages: serviceLocator(),
      sendMessage: serviceLocator(),
      chatRepository: serviceLocator(),
    ),
  );
}

void _initAuth() {
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImp(
      supabaseClient: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AuthRepo>(
    () => AuthRepoImp(
      remoteDataSource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserSignup>(
    () => UserSignup(
      authRepo: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory<UserLogin>(
    () => UserLogin(
      authRepo: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory<CurrentUserUseCase>(
    () => CurrentUserUseCase(
      authRepo: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      userSignup: serviceLocator(),
      userLogin: serviceLocator(),
      currentUserUseCase: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );
}

void _initBlog() {
  serviceLocator.registerFactory<BlogRemoteDataSource>(
    () => BlogRemoteDataSourceImpl(
      supabaseClient: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<BlogRepo>(
    () => BlogRepoImpl(
      serviceLocator(),
      supabaseClient: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UploadBlogUseCase>(
    () => UploadBlogUseCase(
      blogRepo: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetAllBlogs>(
    () => GetAllBlogs(
      serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetAllBlogsForAnalytics>(
    () => GetAllBlogsForAnalytics(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<BlogBloc>(
    () => BlogBloc(
      uploadBlogUseCase: serviceLocator(),
      blogRepo: serviceLocator(),
      getAllBlogs: serviceLocator(),
      getAllBlogsForAnalytics: serviceLocator(),
    ),
  );
}

void _initAI() {
  // AI Services
  serviceLocator.registerLazySingleton<ImageAnalysisService>(
    () => ImageAnalysisServiceImpl(),
  );

  serviceLocator.registerLazySingleton<TrendsScraperService>(
    () => TrendsScraperServiceImpl(),
  );

  serviceLocator.registerLazySingleton<PerformanceAnalysisService>(
    () => PerformanceAnalysisServiceImpl(),
  );

  // Performance Analysis BLoC
  serviceLocator.registerFactory<PerformanceAnalysisBloc>(
    () => PerformanceAnalysisBloc(
      imageAnalysisService: serviceLocator(),
      trendsScraperService: serviceLocator(),
      performanceAnalysisService: serviceLocator(),
    ),
  );
}
