import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/common/widgets/app_navigation_bar.dart';
import 'package:wlog/features/analytics/presentation/widgets/analytics_header.dart';
import 'package:wlog/features/analytics/presentation/widgets/blog_analytics_card.dart';
import 'package:wlog/features/analytics/presentation/widgets/category_filter.dart';
import 'package:wlog/features/blog/presentation/bloc/blog_bloc.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String selectedCategory = 'All';
  List<String> availableCategories = ['All'];

  @override
  void initState() {
    super.initState();
    // Fetch all blogs for analytics
    context.read<BlogBloc>().add(GetAllBlogsForAnalyticsEvent());
  }

  void _updateCategories(List<String> categories) {
    setState(() {
      availableCategories = ['All', ...categories];
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<BlogBloc, BlogState>(
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BlogAnalyticsSuccess) {
            final allBlogs = state.blogs;

            // Extract unique categories from all blogs
            final Set<String> categoriesSet = {};
            for (final blog in allBlogs) {
              categoriesSet.addAll(blog.topics);
            }
            final categories = categoriesSet.toList()..sort();

            // Update available categories if needed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (categories.isNotEmpty && availableCategories.length == 1) {
                _updateCategories(categories);
              }
            });

            // Filter blogs based on selected category
            final filteredBlogs = selectedCategory == 'All'
                ? allBlogs
                : allBlogs
                    .where((blog) => blog.topics.contains(selectedCategory))
                    .toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<BlogBloc>().add(GetAllBlogsForAnalyticsEvent());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Analytics Header with stats
                    AnalyticsHeader(
                      totalBlogs: allBlogs.length,
                      filteredBlogs: filteredBlogs.length,
                      totalCategories: categories.length,
                    ),
                    const SizedBox(height: 20),

                    // Category Filter
                    CategoryFilter(
                      categories: availableCategories,
                      selectedCategory: selectedCategory,
                      onCategorySelected: _onCategorySelected,
                    ),
                    const SizedBox(height: 20),

                    // Blogs List
                    if (filteredBlogs.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.filter_list_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedCategory == 'All'
                                  ? 'No blogs found'
                                  : 'No blogs found in "$selectedCategory" category',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredBlogs.length,
                        itemBuilder: (context, index) {
                          final blog = filteredBlogs[index];
                          return BlogAnalyticsCard(
                            blog: blog,
                            index: index + 1,
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          } else if (state is BlogFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<BlogBloc>()
                          .add(GetAllBlogsForAnalyticsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Welcome to Analytics!\nPull down to refresh.'),
          );
        },
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 1),
    );
  }
}
