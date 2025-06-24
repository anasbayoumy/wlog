import 'image_analysis_service.dart';
import 'trends_scraper_service.dart';

/// Service for analyzing content performance against social media trends
abstract class PerformanceAnalysisService {
  /// Analyze blog performance against current trends
  Future<PerformanceAnalysisResult> analyzeBlogPerformance(
    String blogId,
    ImageAnalysisResult imageAnalysis,
    List<TrendData> trends,
  );

  /// Get performance recommendations
  Future<List<PerformanceRecommendation>> getRecommendations(
    ImageAnalysisResult imageAnalysis,
    TrendAnalysis trendAnalysis,
  );

  /// Calculate content alignment score
  Future<double> calculateAlignmentScore(
    List<String> contentKeywords,
    List<TrendData> trends,
  );
}

/// Result of performance analysis
class PerformanceAnalysisResult {
  final String blogId;
  final double overallScore;
  final double trendAlignmentScore;
  final double engagementPotential;
  final double competitiveAdvantage;
  final Map<String, double> categoryScores;
  final List<PerformanceMetric> metrics;
  final List<PerformanceRecommendation> recommendations;
  final List<TrendComparison> trendComparisons;
  final DateTime analysisTimestamp;

  PerformanceAnalysisResult({
    required this.blogId,
    required this.overallScore,
    required this.trendAlignmentScore,
    required this.engagementPotential,
    required this.competitiveAdvantage,
    required this.categoryScores,
    required this.metrics,
    required this.recommendations,
    required this.trendComparisons,
    required this.analysisTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'blogId': blogId,
      'overallScore': overallScore,
      'trendAlignmentScore': trendAlignmentScore,
      'engagementPotential': engagementPotential,
      'competitiveAdvantage': competitiveAdvantage,
      'categoryScores': categoryScores,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'trendComparisons': trendComparisons.map((t) => t.toJson()).toList(),
      'analysisTimestamp': analysisTimestamp.toIso8601String(),
    };
  }

  factory PerformanceAnalysisResult.fromJson(Map<String, dynamic> json) {
    return PerformanceAnalysisResult(
      blogId: json['blogId'] ?? '',
      overallScore: (json['overallScore'] ?? 0.0).toDouble(),
      trendAlignmentScore: (json['trendAlignmentScore'] ?? 0.0).toDouble(),
      engagementPotential: (json['engagementPotential'] ?? 0.0).toDouble(),
      competitiveAdvantage: (json['competitiveAdvantage'] ?? 0.0).toDouble(),
      categoryScores: Map<String, double>.from(json['categoryScores'] ?? {}),
      metrics: (json['metrics'] as List? ?? [])
          .map((m) => PerformanceMetric.fromJson(m))
          .toList(),
      recommendations: (json['recommendations'] as List? ?? [])
          .map((r) => PerformanceRecommendation.fromJson(r))
          .toList(),
      trendComparisons: (json['trendComparisons'] as List? ?? [])
          .map((t) => TrendComparison.fromJson(t))
          .toList(),
      analysisTimestamp: DateTime.parse(json['analysisTimestamp']),
    );
  }
}

/// Individual performance metric
class PerformanceMetric {
  final String name;
  final double value;
  final double maxValue;
  final String unit;
  final String description;
  final MetricTrend trend;

  PerformanceMetric({
    required this.name,
    required this.value,
    required this.maxValue,
    required this.unit,
    required this.description,
    required this.trend,
  });

  double get percentage => (value / maxValue) * 100;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'maxValue': maxValue,
      'unit': unit,
      'description': description,
      'trend': trend.toString(),
    };
  }

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      name: json['name'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
      maxValue: (json['maxValue'] ?? 100.0).toDouble(),
      unit: json['unit'] ?? '',
      description: json['description'] ?? '',
      trend: MetricTrend.values.firstWhere(
        (t) => t.toString() == json['trend'],
        orElse: () => MetricTrend.stable,
      ),
    );
  }
}

/// Performance recommendation
class PerformanceRecommendation {
  final String title;
  final String description;
  final RecommendationType type;
  final double impact;
  final String actionItem;
  final List<String> keywords;

  PerformanceRecommendation({
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
    required this.actionItem,
    required this.keywords,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.toString(),
      'impact': impact,
      'actionItem': actionItem,
      'keywords': keywords,
    };
  }

  factory PerformanceRecommendation.fromJson(Map<String, dynamic> json) {
    return PerformanceRecommendation(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: RecommendationType.values.firstWhere(
        (t) => t.toString() == json['type'],
        orElse: () => RecommendationType.optimization,
      ),
      impact: (json['impact'] ?? 0.0).toDouble(),
      actionItem: json['actionItem'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }
}

/// Trend comparison data
class TrendComparison {
  final String trendKeyword;
  final double alignmentScore;
  final int trendVolume;
  final String platform;
  final String recommendation;

  TrendComparison({
    required this.trendKeyword,
    required this.alignmentScore,
    required this.trendVolume,
    required this.platform,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'trendKeyword': trendKeyword,
      'alignmentScore': alignmentScore,
      'trendVolume': trendVolume,
      'platform': platform,
      'recommendation': recommendation,
    };
  }

  factory TrendComparison.fromJson(Map<String, dynamic> json) {
    return TrendComparison(
      trendKeyword: json['trendKeyword'] ?? '',
      alignmentScore: (json['alignmentScore'] ?? 0.0).toDouble(),
      trendVolume: json['trendVolume'] ?? 0,
      platform: json['platform'] ?? '',
      recommendation: json['recommendation'] ?? '',
    );
  }
}

/// Enums for categorization
enum MetricTrend { increasing, decreasing, stable }

enum RecommendationType { optimization, trending, competitive, engagement }

/// Implementation of Performance Analysis Service
class PerformanceAnalysisServiceImpl implements PerformanceAnalysisService {
  @override
  Future<PerformanceAnalysisResult> analyzeBlogPerformance(
    String blogId,
    ImageAnalysisResult imageAnalysis,
    List<TrendData> trends,
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate analysis

      final alignmentScore = await calculateAlignmentScore(
        imageAnalysis.keywords,
        trends,
      );

      final metrics = _generatePerformanceMetrics(imageAnalysis, trends);
      final recommendations = await getRecommendations(
        imageAnalysis,
        TrendAnalysis(
          topKeywords: trends.expand((t) => t.keywords).toList(),
          emergingTrends: ['AI', 'automation', 'cloud'],
          keywordPerformance: {},
          platformDistribution: {},
          overallTrendScore: 0.75,
          recommendations: [],
        ),
      );

      return PerformanceAnalysisResult(
        blogId: blogId,
        overallScore: _calculateOverallScore(alignmentScore, metrics),
        trendAlignmentScore: alignmentScore,
        engagementPotential:
            _calculateEngagementPotential(imageAnalysis, trends),
        competitiveAdvantage:
            _calculateCompetitiveAdvantage(imageAnalysis, trends),
        categoryScores: _calculateCategoryScores(imageAnalysis, trends),
        metrics: metrics,
        recommendations: recommendations,
        trendComparisons: _generateTrendComparisons(imageAnalysis, trends),
        analysisTimestamp: DateTime.now(),
      );
    } catch (e) {
      throw PerformanceAnalysisException(
          'Failed to analyze blog performance: $e');
    }
  }

  @override
  Future<List<PerformanceRecommendation>> getRecommendations(
    ImageAnalysisResult imageAnalysis,
    TrendAnalysis trendAnalysis,
  ) async {
    return [
      PerformanceRecommendation(
        title: 'Leverage Trending Keywords',
        description:
            'Incorporate high-performing keywords to increase visibility',
        type: RecommendationType.trending,
        impact: 0.85,
        actionItem: 'Add trending hashtags: #AI, #MachineLearning',
        keywords: trendAnalysis.topKeywords,
      ),
      PerformanceRecommendation(
        title: 'Optimize for Engagement',
        description: 'Adjust content structure for better user engagement',
        type: RecommendationType.engagement,
        impact: 0.72,
        actionItem: 'Add interactive elements and call-to-actions',
        keywords: imageAnalysis.keywords,
      ),
    ];
  }

  @override
  Future<double> calculateAlignmentScore(
    List<String> contentKeywords,
    List<TrendData> trends,
  ) async {
    if (contentKeywords.isEmpty || trends.isEmpty) return 0.0;

    final trendKeywords = trends.expand((t) => t.keywords).toSet();
    final matchingKeywords = contentKeywords
        .where(
          (keyword) => trendKeywords.contains(keyword.toLowerCase()),
        )
        .length;

    return (matchingKeywords / contentKeywords.length).clamp(0.0, 1.0);
  }

  List<PerformanceMetric> _generatePerformanceMetrics(
    ImageAnalysisResult imageAnalysis,
    List<TrendData> trends,
  ) {
    return [
      PerformanceMetric(
        name: 'Trend Alignment',
        value: 75,
        maxValue: 100,
        unit: '%',
        description: 'How well content aligns with current trends',
        trend: MetricTrend.increasing,
      ),
      PerformanceMetric(
        name: 'Keyword Relevance',
        value: 68,
        maxValue: 100,
        unit: '%',
        description: 'Relevance of keywords to target audience',
        trend: MetricTrend.stable,
      ),
      PerformanceMetric(
        name: 'Engagement Potential',
        value: 82,
        maxValue: 100,
        unit: '%',
        description: 'Predicted engagement based on content analysis',
        trend: MetricTrend.increasing,
      ),
    ];
  }

  double _calculateOverallScore(
      double alignmentScore, List<PerformanceMetric> metrics) {
    final avgMetricScore =
        metrics.map((m) => m.value / m.maxValue).reduce((a, b) => a + b) /
            metrics.length;
    return ((alignmentScore + avgMetricScore) / 2 * 100).clamp(0.0, 100.0);
  }

  double _calculateEngagementPotential(
      ImageAnalysisResult imageAnalysis, List<TrendData> trends) {
    return (imageAnalysis.confidence * 0.6 + 0.4) * 100;
  }

  double _calculateCompetitiveAdvantage(
      ImageAnalysisResult imageAnalysis, List<TrendData> trends) {
    return (imageAnalysis.themes.length / 10.0).clamp(0.0, 1.0) * 100;
  }

  Map<String, double> _calculateCategoryScores(
      ImageAnalysisResult imageAnalysis, List<TrendData> trends) {
    return {
      'Content Quality': 78.5,
      'Trend Relevance': 82.3,
      'SEO Optimization': 65.7,
      'Social Media Potential': 89.2,
    };
  }

  List<TrendComparison> _generateTrendComparisons(
      ImageAnalysisResult imageAnalysis, List<TrendData> trends) {
    return trends
        .take(5)
        .map((trend) => TrendComparison(
              trendKeyword: trend.keywords.first,
              alignmentScore: (trend.trendScore * 100),
              trendVolume: trend.engagementCount,
              platform: trend.platform,
              recommendation: 'Consider incorporating this trending topic',
            ))
        .toList();
  }
}

/// Exception for performance analysis errors
class PerformanceAnalysisException implements Exception {
  final String message;
  PerformanceAnalysisException(this.message);

  @override
  String toString() => 'PerformanceAnalysisException: $message';
}
