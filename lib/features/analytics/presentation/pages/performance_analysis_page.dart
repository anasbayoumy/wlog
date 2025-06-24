import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wlog/core/ai/performance_analysis_service.dart';
import 'package:wlog/features/analytics/presentation/bloc/performance_analysis_bloc.dart';
import 'package:wlog/features/analytics/presentation/widgets/performance_metrics_widget.dart';
import 'package:wlog/features/analytics/presentation/widgets/performance_recommendations_widget.dart';
import 'package:wlog/features/analytics/presentation/widgets/trend_comparison_widget.dart';
import 'package:wlog/features/analytics/presentation/widgets/performance_score_widget.dart';

class PerformanceAnalysisPage extends StatefulWidget {
  final String blogId;
  final String blogTitle;
  final String blogImage;

  const PerformanceAnalysisPage({
    super.key,
    required this.blogId,
    required this.blogTitle,
    required this.blogImage,
  });

  @override
  State<PerformanceAnalysisPage> createState() =>
      _PerformanceAnalysisPageState();
}

class _PerformanceAnalysisPageState extends State<PerformanceAnalysisPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start analysis when page loads
    context.read<PerformanceAnalysisBloc>().add(
          StartPerformanceAnalysisEvent(
            blogId: widget.blogId,
            imagePath: widget.blogImage,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.blogTitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Metrics'),
            Tab(text: 'Trends'),
            Tab(text: 'Recommendations'),
          ],
        ),
      ),
      body: BlocBuilder<PerformanceAnalysisBloc, PerformanceAnalysisState>(
        builder: (context, state) {
          if (state is PerformanceAnalysisLoading) {
            return _buildLoadingView();
          } else if (state is PerformanceAnalysisSuccess) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(state.result),
                  _buildMetricsTab(state.result),
                  _buildTrendsTab(state.result),
                  _buildRecommendationsTab(state.result),
                ],
              ),
            );
          } else if (state is PerformanceAnalysisError) {
            return _buildErrorView(state.message);
          }
          return _buildInitialView();
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AI Analysis Animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
            ),
            child: const Icon(
              Icons.psychology,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'Analyzing your content...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI is examining your image and comparing with social media trends',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Progress Steps
          _buildAnalysisSteps(),
        ],
      ),
    );
  }

  Widget _buildAnalysisSteps() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _buildStepItem('🔍', 'Analyzing image content', true),
          _buildStepItem('📊', 'Scraping social media trends', true),
          _buildStepItem('🤖', 'AI performance comparison', false),
          _buildStepItem('📈', 'Generating recommendations', false),
        ],
      ),
    );
  }

  Widget _buildStepItem(String icon, String text, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: completed ? Colors.green : Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          if (completed)
            const Icon(Icons.check_circle, color: Colors.green, size: 20)
          else
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(PerformanceAnalysisResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Score Card
          PerformanceScoreWidget(result: result),
          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStats(result),
          const SizedBox(height: 24),

          // Blog Image Preview
          _buildImagePreview(),
          const SizedBox(height: 24),

          // Category Scores
          _buildCategoryScores(result),
        ],
      ),
    );
  }

  Widget _buildMetricsTab(PerformanceAnalysisResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PerformanceMetricsWidget(metrics: result.metrics),
    );
  }

  Widget _buildTrendsTab(PerformanceAnalysisResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TrendComparisonWidget(comparisons: result.trendComparisons),
    );
  }

  Widget _buildRecommendationsTab(PerformanceAnalysisResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PerformanceRecommendationsWidget(
          recommendations: result.recommendations),
    );
  }

  Widget _buildQuickStats(PerformanceAnalysisResult result) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Trend Alignment',
            '${result.trendAlignmentScore.toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Engagement',
            '${result.engagementPotential.toStringAsFixed(1)}%',
            Icons.favorite,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Competitive',
            '${result.competitiveAdvantage.toStringAsFixed(1)}%',
            Icons.emoji_events,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.blogImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[900],
              child: const Center(
                child: Icon(Icons.image, color: Colors.grey, size: 48),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryScores(PerformanceAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Performance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...result.categoryScores.entries
            .map((entry) => _buildCategoryScoreBar(entry.key, entry.value))
            .toList(),
      ],
    );
  }

  Widget _buildCategoryScoreBar(String category, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '${score.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              score > 80
                  ? Colors.green
                  : score > 60
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<PerformanceAnalysisBloc>().add(
                      StartPerformanceAnalysisEvent(
                        blogId: widget.blogId,
                        imagePath: widget.blogImage,
                      ),
                    );
              },
              child: const Text('Retry Analysis'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'Ready to analyze',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
