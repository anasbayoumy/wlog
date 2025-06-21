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
import 'package:wlog/features/blog/domain/usecases/upload_blog.dart';
import 'package:wlog/features/blog/presentation/bloc/blog_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
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

  serviceLocator.registerLazySingleton<BlogBloc>(
    () => BlogBloc(
      uploadBlogUseCase: serviceLocator(),
      blogRepo: serviceLocator(),
      getAllBlogs: serviceLocator(),
    ),
  );
}
