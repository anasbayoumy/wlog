import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:wlog/core/common/widgets/app_navigation_bar.dart';
import 'package:wlog/features/blog/presentation/pages/add_new_blog.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // Sign out from Supabase
      await Supabase.instance.client.auth.signOut();

      // Update the app user state to logged out
      // The main app's BlocSelector will automatically handle navigation
      if (context.mounted) {
        context.read<AppUserCubit>().updateUser(null);
      }
    } catch (e) {
      // Show error message if logout fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('wlog'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await _logout(context);
              },
              icon: const Icon(Icons.logout_outlined)),
        ],
      ),
      body: const Center(
        child: Text('Blog Page'),
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 0),
    );
  }
}
