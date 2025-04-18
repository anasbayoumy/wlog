import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:wlog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wlog/features/blog/presentation/pages/add_new_blog.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('wlog'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewBlogPage(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          IconButton(
              onPressed: () {
                // context.read<AuthBloc>().add(LogoutEvent());
              },
              icon: const Icon(Icons.logout_outlined)),
        ],
      ),
      body: const Center(
        child: Text('Blog Page'),
      ),
    );
  }
}
