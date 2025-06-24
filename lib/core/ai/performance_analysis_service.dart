import 'image_analysis_service.dart';
import 'trends_scraper_service.dart';
import 'gemini_ai_service.dart';

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
      // Calculate real alignment score based on actual keywords
      final alignmentScore = await calculateAlignmentScore(
        imageAnalysis.keywords,
        trends,
      );

      // Generate real performance metrics based on actual analysis
      final metrics = _generateRealPerformanceMetrics(
          imageAnalysis, trends, alignmentScore);

      // Calculate real scores based on actual content
      final engagementPotential =
          _calculateRealEngagementPotential(imageAnalysis, trends);
      final competitiveAdvantage =
          _calculateRealCompetitiveAdvantage(imageAnalysis, trends);
      final categoryScores =
          _calculateRealCategoryScores(imageAnalysis, trends, alignmentScore);
      final overallScore = _calculateRealOverallScore(alignmentScore,
          engagementPotential, competitiveAdvantage, categoryScores);

      // Get real AI recommendations
      final recommendations = await getRecommendations(
        imageAnalysis,
        TrendAnalysis(
          topKeywords: trends.expand((t) => t.keywords).toSet().toList(),
          emergingTrends: _extractEmergingTrends(trends),
          keywordPerformance:
              _calculateKeywordPerformance(imageAnalysis.keywords, trends),
          platformDistribution: _calculatePlatformDistribution(trends),
          overallTrendScore: trends.isEmpty
              ? 0.0
              : trends.map((t) => t.trendScore).reduce((a, b) => a + b) /
                  trends.length,
          recommendations: [],
        ),
      );

      return PerformanceAnalysisResult(
        blogId: blogId,
        overallScore: overallScore,
        trendAlignmentScore: alignmentScore * 100, // Convert to percentage
        engagementPotential: engagementPotential,
        competitiveAdvantage: competitiveAdvantage,
        categoryScores: categoryScores,
        metrics: metrics,
        recommendations: recommendations,
        trendComparisons: _generateRealTrendComparisons(imageAnalysis, trends),
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
    try {
      // Use Gemini AI to generate personalized recommendations
      final trends = trendAnalysis.topKeywords
          .asMap()
          .entries
          .map((entry) => TrendData(
                platform: 'Mixed',
                content: 'Trending topic: ${entry.value}',
                hashtags: ['#${entry.value}'],
                keywords: [entry.value],
                engagementCount: 1000 - (entry.key * 100),
                shareCount: 200 - (entry.key * 20),
                likeCount: 500 - (entry.key * 50),
                timestamp:
                    DateTime.now().subtract(Duration(hours: entry.key + 1)),
                category: 'software',
                trendScore: 0.9 - (entry.key * 0.1),
              ))
          .toList();

      final aiRecommendations = await GeminiAIService.generateRecommendations(
        imageAnalysis,
        trends,
      );

      return aiRecommendations.asMap().entries.map((entry) {
        final index = entry.key;
        final recommendation = entry.value;

        return PerformanceRecommendation(
          title: 'AI Recommendation ${index + 1}',
          description: recommendation,
          type: _getRecommendationType(recommendation),
          impact: 0.9 - (index * 0.1), // Vary impact scores
          actionItem: recommendation,
          keywords: imageAnalysis.keywords,
        );
      }).toList();
    } catch (e) {
      print('Gemini recommendations failed, using fallback: $e');
      // Fallback recommendations
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

  /// Helper method to determine recommendation type based on content
  RecommendationType _getRecommendationType(String recommendation) {
    final lowerRec = recommendation.toLowerCase();
    if (lowerRec.contains('trending') ||
        lowerRec.contains('hashtag') ||
        lowerRec.contains('keyword')) {
      return RecommendationType.trending;
    } else if (lowerRec.contains('engagement') ||
        lowerRec.contains('interaction') ||
        lowerRec.contains('comment')) {
      return RecommendationType.engagement;
    } else if (lowerRec.contains('competitor') ||
        lowerRec.contains('advantage') ||
        lowerRec.contains('outperform')) {
      return RecommendationType.competitive;
    } else {
      return RecommendationType.optimization;
    }
  }

  /// Generate real performance metrics based on actual analysis
  List<PerformanceMetric> _generateRealPerformanceMetrics(
    ImageAnalysisResult imageAnalysis,
    List<TrendData> trends,
    double alignmentScore,
  ) {
    // Calculate keyword relevance based on actual keywords found
    final keywordRelevance = imageAnalysis.keywords.isEmpty
        ? 20.0
        : (imageAnalysis.keywords.length * 15.0).clamp(0.0, 100.0);

    // Calculate content quality based on confidence and extracted text
    final contentQuality = (imageAnalysis.confidence * 100).clamp(0.0, 100.0);

    // Calculate trend alignment percentage
    final trendAlignment = (alignmentScore * 100).clamp(0.0, 100.0);

    // Calculate engagement potential based on themes and technical content
    final engagementPotential =
        _calculateRealEngagementPotential(imageAnalysis, trends);

    // Calculate SEO optimization based on keywords and themes
    final seoOptimization = imageAnalysis.keywords.isEmpty
        ? 30.0
        : ((imageAnalysis.keywords.length * 12.0) +
                (imageAnalysis.themes.length * 8.0))
            .clamp(0.0, 100.0);

    return [
      PerformanceMetric(
        name: 'Content Quality',
        value: contentQuality,
        maxValue: 100,
        unit: '%',
        description: 'Quality of content based on AI analysis confidence',
        trend:
            contentQuality > 70 ? MetricTrend.increasing : MetricTrend.stable,
      ),
      PerformanceMetric(
        name: 'Keyword Relevance',
        value: keywordRelevance,
        maxValue: 100,
        unit: '%',
        description: 'Relevance of detected keywords to target audience',
        trend: keywordRelevance > 60
            ? MetricTrend.increasing
            : MetricTrend.decreasing,
      ),
      PerformanceMetric(
        name: 'Trend Alignment',
        value: trendAlignment,
        maxValue: 100,
        unit: '%',
        description: 'How well content aligns with current social media trends',
        trend:
            trendAlignment > 50 ? MetricTrend.increasing : MetricTrend.stable,
      ),
      PerformanceMetric(
        name: 'Engagement Potential',
        value: engagementPotential,
        maxValue: 100,
        unit: '%',
        description: 'Predicted engagement based on content analysis',
        trend: engagementPotential > 65
            ? MetricTrend.increasing
            : MetricTrend.stable,
      ),
      PerformanceMetric(
        name: 'SEO Optimization',
        value: seoOptimization,
        maxValue: 100,
        unit: '%',
        description: 'Search engine optimization potential',
        trend: seoOptimization > 55
            ? MetricTrend.increasing
            : MetricTrend.decreasing,
      ),
    ];
  }

  /// Calculate real engagement potential based on actual content
  double _calculateRealEngagementPotential(
    ImageAnalysisResult imageAnalysis,
    List<TrendData> trends,
  ) {
    double score = 0.0;

    // Base score from AI confidence
    score += imageAnalysis.confidence * 30;

    // Bonus for technical content
    if (imageAnalysis.metadata['technicalContent'] == true) {
      score += 20;
    }

    // Bonus for extracted text (indicates informative content)
    if (imageAnalysis.extractedText.isNotEmpty) {
      score += 15;
    }

    // Bonus for number of themes (indicates rich content)
    score += imageAnalysis.themes.length * 5;

    // Bonus for keyword alignment with trends
    final alignedKeywords = imageAnalysis.keywords
        .where((keyword) => trends
            .any((trend) => trend.keywords.contains(keyword.toLowerCase())))
        .length;
    score += alignedKeywords * 8;

    return score.clamp(0.0, 100.0);
  }

  /// Calculate real competitive advantage based on content uniqueness
  double _calculateRealCompetitiveAdvantage(
    ImageAnalysisResult imageAnalysis,
    List<TrendData> trends,
  ) {
    double score = 0.0;

    // Base score from content quality
    score += imageAnalysis.confidence * 25;

    // Bonus for unique themes not commonly found in trends
    final uniqueThemes = imageAnalysis.themes
        .where((theme) => !trends
            .any((trend) => trend.keywords.contains(theme.toLowerCase())))
        .length;
    score += uniqueThemes * 10;

    // Bonus for technical depth
    if (imageAnalysis.metadata['programmingLanguage'] != null) {
      score += 15;
    }

    // Bonus for visual quality (inferred from metadata)
    if (imageAnalysis.metadata['imageType'] == 'screenshot' ||
        imageAnalysis.metadata['imageType'] == 'graphic') {
      score += 10;
    }

    // Bonus for comprehensive content
    if (imageAnalysis.keywords.length > 5) {
      score += 15;
    }

    return score.clamp(0.0, 100.0);
  }

  /// Calculate real category scores based on actual analysis
  Map<String, double> _calculateRealCategoryScores(
    ImageAnalysisResult imageAnalysis,
    List<TrendData> trends,
    double alignmentScore,
  ) {
    return {
      'Content Quality': (imageAnalysis.confidence * 100).clamp(0.0, 100.0),
      'Trend Relevance': (alignmentScore * 100).clamp(0.0, 100.0),
      'Technical Depth':
          imageAnalysis.metadata['technicalContent'] == true ? 85.0 : 45.0,
      'Visual Appeal': imageAnalysis.extractedText.isNotEmpty ? 75.0 : 60.0,
      'SEO Potential': (imageAnalysis.keywords.length * 12.0).clamp(0.0, 100.0),
      'Social Media Readiness':
          _calculateSocialMediaReadiness(imageAnalysis, trends),
    };
  }

  /// Calculate overall score based on all factors
  double _calculateRealOverallScore(
    double alignmentScore,
    double engagementPotential,
    double competitiveAdvantage,
    Map<String, double> categoryScores,
  ) {
    // Weighted average of all scores
    final weights = {
      'alignment': 0.25,
      'engagement': 0.25,
      'competitive': 0.20,
      'categories': 0.30,
    };

    final categoryAverage =
        categoryScores.values.reduce((a, b) => a + b) / categoryScores.length;

    final weightedScore = (alignmentScore * 100 * weights['alignment']!) +
        (engagementPotential * weights['engagement']!) +
        (competitiveAdvantage * weights['competitive']!) +
        (categoryAverage * weights['categories']!);

    return weightedScore.clamp(0.0, 100.0);
  }

  /// Calculate social media readiness score
  double _calculateSocialMediaReadiness(
    ImageAnalysisResult imageAnalysis,
    List<TrendData> trends,
  ) {
    double score = 0.0;

    // Visual content bonus
    if (imageAnalysis.metadata['imageType'] != null) {
      score += 30;
    }

    // Hashtag potential (based on themes)
    score += imageAnalysis.themes.length * 8;

    // Trending keyword alignment
    final trendingKeywords = imageAnalysis.keywords
        .where((keyword) => trends
            .any((trend) => trend.keywords.contains(keyword.toLowerCase())))
        .length;
    score += trendingKeywords * 12;

    // Technical content appeal
    if (imageAnalysis.metadata['technicalContent'] == true) {
      score += 20;
    }

    return score.clamp(0.0, 100.0);
  }

  /// Extract emerging trends from trend data
  List<String> _extractEmergingTrends(List<TrendData> trends) {
    return trends
        .where((trend) => trend.trendScore > 0.7)
        .map((trend) => trend.keywords.first)
        .take(5)
        .toList();
  }

  /// Calculate keyword performance mapping
  Map<String, double> _calculateKeywordPerformance(
    List<String> contentKeywords,
    List<TrendData> trends,
  ) {
    final performance = <String, double>{};

    for (final keyword in contentKeywords) {
      final matchingTrends = trends
          .where((trend) => trend.keywords.contains(keyword.toLowerCase()));

      if (matchingTrends.isNotEmpty) {
        performance[keyword] =
            matchingTrends.map((t) => t.trendScore).reduce((a, b) => a + b) /
                matchingTrends.length;
      } else {
        performance[keyword] =
            0.3; // Default low score for non-trending keywords
      }
    }

    return performance;
  }

  /// Calculate platform distribution from trends
  Map<String, int> _calculatePlatformDistribution(List<TrendData> trends) {
    final distribution = <String, int>{};

    for (final trend in trends) {
      distribution[trend.platform] = (distribution[trend.platform] ?? 0) + 1;
    }

    return distribution;
  }

  /// Generate real trend comparisons based on actual data
  List<TrendComparison> _generateRealTrendComparisons(
    ImageAnalysisResult imageAnalysis,
    List<TrendData> trends,
  ) {
    final comparisons = <TrendComparison>[];

    for (final trend in trends.take(5)) {
      // Calculate real alignment score for this specific trend
      final alignmentScore =
          _calculateTrendSpecificAlignment(imageAnalysis, trend);

      comparisons.add(TrendComparison(
        trendKeyword:
            trend.keywords.isNotEmpty ? trend.keywords.first : 'Unknown',
        alignmentScore: alignmentScore,
        trendVolume: trend.engagementCount,
        platform: trend.platform,
        recommendation: _generateTrendRecommendation(alignmentScore, trend),
      ));
    }

    return comparisons;
  }

  /// Calculate alignment score for a specific trend
  double _calculateTrendSpecificAlignment(
    ImageAnalysisResult imageAnalysis,
    TrendData trend,
  ) {
    double score = 0.0;

    // Check keyword overlap
    final keywordOverlap = imageAnalysis.keywords
        .where((keyword) => trend.keywords.contains(keyword.toLowerCase()))
        .length;
    score += keywordOverlap * 20.0;

    // Check theme overlap
    final themeOverlap = imageAnalysis.themes
        .where((theme) =>
            trend.keywords.contains(theme.toLowerCase()) ||
            trend.content.toLowerCase().contains(theme.toLowerCase()))
        .length;
    score += themeOverlap * 15.0;

    // Bonus for high-performing trends
    score += trend.trendScore * 30;

    return score.clamp(0.0, 100.0);
  }

  /// Generate specific recommendation for a trend
  String _generateTrendRecommendation(double alignmentScore, TrendData trend) {
    if (alignmentScore > 70) {
      return 'Excellent alignment! Leverage this trend with hashtags: ${trend.hashtags.take(2).join(", ")}';
    } else if (alignmentScore > 40) {
      return 'Good potential. Consider incorporating keywords: ${trend.keywords.take(2).join(", ")}';
    } else {
      return 'Low alignment. Monitor this trend for future content opportunities';
    }
  }
}

/// Exception for performance analysis errors
class PerformanceAnalysisException implements Exception {
  final String message;
  PerformanceAnalysisException(this.message);

  @override
  String toString() => 'PerformanceAnalysisException: $message';
}
