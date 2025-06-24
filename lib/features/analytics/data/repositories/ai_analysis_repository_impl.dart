import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/ai/performance_analysis_service.dart';
import 'package:wlog/features/analytics/domain/repositories/ai_analysis_repository.dart';

class AIAnalysisRepositoryImpl implements AIAnalysisRepository {
  final SupabaseClient _supabaseClient;

  AIAnalysisRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<Either<Failure, PerformanceAnalysisResult?>> getCachedAnalysis(
      String blogId) async {
    try {
      // Check if analysis exists in cache table
      final response = await _supabaseClient
          .from('cached_performance_analysis')
          .select()
          .eq('blog_id', blogId)
          .maybeSingle();

      if (response == null) {
        return right(null);
      }

      // Convert from database format to PerformanceAnalysisResult
      final result = PerformanceAnalysisResult(
        blogId: response['blog_id'],
        overallScore: (response['overall_score'] ?? 0.0).toDouble(),
        trendAlignmentScore:
            (response['trend_alignment_score'] ?? 0.0).toDouble(),
        engagementPotential:
            (response['engagement_potential'] ?? 0.0).toDouble(),
        competitiveAdvantage:
            (response['competitive_advantage'] ?? 0.0).toDouble(),
        categoryScores:
            Map<String, double>.from(response['category_scores'] ?? {}),
        metrics: _parseMetrics(response['metrics']),
        recommendations: _parseRecommendations(response['recommendations']),
        trendComparisons: _parseTrendComparisons(response['trend_comparisons']),
        analysisTimestamp: DateTime.parse(response['analysis_timestamp']),
      );

      return right(result);
    } catch (e) {
      return left(Failure('Failed to get cached analysis: $e'));
    }
  }

  @override
  Future<Either<Failure, PerformanceAnalysisResult>> saveAnalysis(
      PerformanceAnalysisResult analysis) async {
    try {
      // Save to cache table
      final data = {
        'blog_id': analysis.blogId,
        'overall_score': analysis.overallScore,
        'trend_alignment_score': analysis.trendAlignmentScore,
        'engagement_potential': analysis.engagementPotential,
        'competitive_advantage': analysis.competitiveAdvantage,
        'category_scores': analysis.categoryScores,
        'metrics': _serializeMetrics(analysis.metrics),
        'recommendations': _serializeRecommendations(analysis.recommendations),
        'trend_comparisons':
            _serializeTrendComparisons(analysis.trendComparisons),
        'analysis_timestamp': analysis.analysisTimestamp.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient
          .from('cached_performance_analysis')
          .upsert(data); // Use upsert to handle updates

      return right(analysis);
    } catch (e) {
      return left(Failure('Failed to save analysis: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasAnalysis(String blogId) async {
    try {
      final response = await _supabaseClient
          .from('cached_performance_analysis')
          .select('blog_id')
          .eq('blog_id', blogId)
          .maybeSingle();

      return right(response != null);
    } catch (e) {
      return left(Failure('Failed to check analysis existence: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAnalysis(String blogId) async {
    try {
      await _supabaseClient
          .from('cached_performance_analysis')
          .delete()
          .eq('blog_id', blogId);

      return right(null);
    } catch (e) {
      return left(Failure('Failed to clear analysis: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PerformanceAnalysisResult>>>
      getAllCachedAnalyses() async {
    try {
      final response = await _supabaseClient
          .from('cached_performance_analysis')
          .select()
          .order('analysis_timestamp', ascending: false);

      final analyses = response
          .map((data) => PerformanceAnalysisResult(
                blogId: data['blog_id'],
                overallScore: (data['overall_score'] ?? 0.0).toDouble(),
                trendAlignmentScore:
                    (data['trend_alignment_score'] ?? 0.0).toDouble(),
                engagementPotential:
                    (data['engagement_potential'] ?? 0.0).toDouble(),
                competitiveAdvantage:
                    (data['competitive_advantage'] ?? 0.0).toDouble(),
                categoryScores:
                    Map<String, double>.from(data['category_scores'] ?? {}),
                metrics: _parseMetrics(data['metrics']),
                recommendations: _parseRecommendations(data['recommendations']),
                trendComparisons:
                    _parseTrendComparisons(data['trend_comparisons']),
                analysisTimestamp: DateTime.parse(data['analysis_timestamp']),
              ))
          .toList();

      return right(analyses);
    } catch (e) {
      return left(Failure('Failed to get all cached analyses: $e'));
    }
  }

  // Helper methods for serialization/deserialization
  List<Map<String, dynamic>> _serializeMetrics(
      List<PerformanceMetric> metrics) {
    return metrics
        .map((metric) => {
              'name': metric.name,
              'value': metric.value,
              'maxValue': metric.maxValue,
              'unit': metric.unit,
              'description': metric.description,
              'trend': metric.trend.toString(),
            })
        .toList();
  }

  List<PerformanceMetric> _parseMetrics(dynamic metricsData) {
    if (metricsData == null) return [];

    final List<dynamic> metricsList = metricsData is String
        ? [] // Handle string case
        : metricsData as List<dynamic>;

    return metricsList
        .map((data) => PerformanceMetric(
              name: data['name'] ?? '',
              value: (data['value'] ?? 0.0).toDouble(),
              maxValue: (data['maxValue'] ?? 100.0).toDouble(),
              unit: data['unit'] ?? '%',
              description: data['description'] ?? '',
              trend: MetricTrend.values.firstWhere(
                (t) => t.toString() == data['trend'],
                orElse: () => MetricTrend.stable,
              ),
            ))
        .toList();
  }

  List<Map<String, dynamic>> _serializeRecommendations(
      List<PerformanceRecommendation> recommendations) {
    return recommendations
        .map((rec) => {
              'title': rec.title,
              'description': rec.description,
              'type': rec.type.toString(),
              'impact': rec.impact,
              'actionItem': rec.actionItem,
              'keywords': rec.keywords,
            })
        .toList();
  }

  List<PerformanceRecommendation> _parseRecommendations(
      dynamic recommendationsData) {
    if (recommendationsData == null) return [];

    final List<dynamic> recList = recommendationsData is String
        ? [] // Handle string case
        : recommendationsData as List<dynamic>;

    return recList
        .map((data) => PerformanceRecommendation(
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              type: RecommendationType.values.firstWhere(
                (t) => t.toString() == data['type'],
                orElse: () => RecommendationType.optimization,
              ),
              impact: (data['impact'] ?? 0.0).toDouble(),
              actionItem: data['actionItem'] ?? '',
              keywords: List<String>.from(data['keywords'] ?? []),
            ))
        .toList();
  }

  List<Map<String, dynamic>> _serializeTrendComparisons(
      List<TrendComparison> comparisons) {
    return comparisons
        .map((comp) => {
              'trendKeyword': comp.trendKeyword,
              'alignmentScore': comp.alignmentScore,
              'trendVolume': comp.trendVolume,
              'platform': comp.platform,
              'recommendation': comp.recommendation,
            })
        .toList();
  }

  List<TrendComparison> _parseTrendComparisons(dynamic comparisonsData) {
    if (comparisonsData == null) return [];

    final List<dynamic> compList = comparisonsData is String
        ? [] // Handle string case
        : comparisonsData as List<dynamic>;

    return compList
        .map((data) => TrendComparison(
              trendKeyword: data['trendKeyword'] ?? '',
              alignmentScore: (data['alignmentScore'] ?? 0.0).toDouble(),
              trendVolume: data['trendVolume'] ?? 0,
              platform: data['platform'] ?? '',
              recommendation: data['recommendation'] ?? '',
            ))
        .toList();
  }
}
