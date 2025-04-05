import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/secrets/supabase_secrets.dart';
import 'package:wlog/features/auth/data/datasouces/auth_remote_data_source.dart';
import 'package:wlog/features/auth/data/repo/auth_repo_imp.dart';
import 'package:wlog/features/auth/domain/repo/auth_repo.dart';
import 'package:wlog/features/auth/domain/usecases/user_signUp.dart';
import 'package:wlog/features/auth/presentation/bloc/auth_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  final supabase = await Supabase.initialize(
    url: SupabaseSecrets.url,
    anonKey: SupabaseSecrets.anonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);
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

  serviceLocator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      userSignup: serviceLocator(),
    ),
  );
}
