import 'package:fpdart/fpdart.dart';
import 'package:wlog/core/error/failures.dart';
import 'package:wlog/core/ai/performance_analysis_service.dart';

abstract class AIAnalysisRepository {
  /// Get cached performance analysis for a blog
  Future<Either<Failure, PerformanceAnalysisResult?>> getCachedAnalysis(String blogId);
  
  /// Save performance analysis to cache/database
  Future<Either<Failure, PerformanceAnalysisResult>> saveAnalysis(PerformanceAnalysisResult analysis);
  
  /// Check if analysis exists for a blog
  Future<Either<Failure, bool>> hasAnalysis(String blogId);
  
  /// Clear cached analysis for a blog (force re-analysis)
  Future<Either<Failure, void>> clearAnalysis(String blogId);
  
  /// Get all cached analyses for analytics dashboard
  Future<Either<Failure, List<PerformanceAnalysisResult>>> getAllCachedAnalyses();
}
