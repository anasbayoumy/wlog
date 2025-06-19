import 'package:flutter/material.dart';
import 'package:wlog/core/common/widgets/app_navigation_bar.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Analytics Page - Coming Soon'),
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 1),
    );
  }
}