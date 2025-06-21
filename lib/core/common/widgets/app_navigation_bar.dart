import 'package:flutter/material.dart';
import 'package:wlog/features/blog/presentation/pages/blog_page.dart';
import 'package:wlog/features/blog/presentation/pages/add_new_blog.dart';
import 'package:wlog/features/profile/presentation/pages/profile_page.dart';

class AppNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AppNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0: // Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BlogPage()),
            );
            break;
          case 1: // Analytics
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Analytics page coming soon')),
            );
            break;
          case 2: // Add Blog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AddNewBlogPage()),
            );
            break;
          case 3: // Chat
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chat page coming soon')),
            );
            break;
          case 4: // Profile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'Add',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_outlined),
          selectedIcon: Icon(Icons.chat),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
