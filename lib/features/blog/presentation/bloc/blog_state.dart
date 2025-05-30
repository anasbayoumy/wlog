part of 'blog_bloc.dart';

@immutable
sealed class BlogState {}

final class BlogInitial extends BlogState {}

final class BlogLoading extends BlogState {}

final class BlogSuccess extends BlogState {}

class BlogFailure extends BlogState {
  final String message;
  BlogFailure({required this.message});
}
