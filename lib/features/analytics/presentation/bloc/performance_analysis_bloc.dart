import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wlog/core/ai/image_analysis_service.dart';
import 'package:wlog/core/ai/trends_scraper_service.dart';
import 'package:wlog/core/ai/performance_analysis_service.dart';

// Events
abstract class PerformanceAnalysisEvent extends Equatable {
  const PerformanceAnalysisEvent();

  @override
  List<Object> get props => [];
}

class StartPerformanceAnalysisEvent extends PerformanceAnalysisEvent {
  final String blogId;
  final String imagePath;
  final String? blogTitle;
  final String? blogContent;

  const StartPerformanceAnalysisEvent({
    required this.blogId,
    required this.imagePath,
    this.blogTitle,
    this.blogContent,
  });

  @override
  List<Object> get props =>
      [blogId, imagePath, blogTitle ?? '', blogContent ?? ''];
}

class RetryPerformanceAnalysisEvent extends PerformanceAnalysisEvent {
  final String blogId;
  final String imagePath;
  final String? blogTitle;
  final String? blogContent;

  const RetryPerformanceAnalysisEvent({
    required this.blogId,
    required this.imagePath,
    this.blogTitle,
    this.blogContent,
  });

  @override
  List<Object> get props =>
      [blogId, imagePath, blogTitle ?? '', blogContent ?? ''];
}

// States
abstract class PerformanceAnalysisState extends Equatable {
  const PerformanceAnalysisState();

  @override
  List<Object> get props => [];
}

class PerformanceAnalysisInitial extends PerformanceAnalysisState {}

class PerformanceAnalysisLoading extends PerformanceAnalysisState {
  final String currentStep;
  final double progress;

  const PerformanceAnalysisLoading({
    required this.currentStep,
    required this.progress,
  });

  @override
  List<Object> get props => [currentStep, progress];
}

class PerformanceAnalysisSuccess extends PerformanceAnalysisState {
  final PerformanceAnalysisResult result;

  const PerformanceAnalysisSuccess({required this.result});

  @override
  List<Object> get props => [result];
}

class PerformanceAnalysisError extends PerformanceAnalysisState {
  final String message;

  const PerformanceAnalysisError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class PerformanceAnalysisBloc
    extends Bloc<PerformanceAnalysisEvent, PerformanceAnalysisState> {
  final ImageAnalysisService _imageAnalysisService;
  final TrendsScraperService _trendsScraperService;
  final PerformanceAnalysisService _performanceAnalysisService;

  PerformanceAnalysisBloc({
    required ImageAnalysisService imageAnalysisService,
    required TrendsScraperService trendsScraperService,
    required PerformanceAnalysisService performanceAnalysisService,
  })  : _imageAnalysisService = imageAnalysisService,
        _trendsScraperService = trendsScraperService,
        _performanceAnalysisService = performanceAnalysisService,
        super(PerformanceAnalysisInitial()) {
    on<StartPerformanceAnalysisEvent>(_onStartPerformanceAnalysis);
    on<RetryPerformanceAnalysisEvent>(_onRetryPerformanceAnalysis);
  }

  Future<void> _onStartPerformanceAnalysis(
    StartPerformanceAnalysisEvent event,
    Emitter<PerformanceAnalysisState> emit,
  ) async {
    await _performAnalysis(event.blogId, event.imagePath, emit,
        blogTitle: event.blogTitle, blogContent: event.blogContent);
  }

  Future<void> _onRetryPerformanceAnalysis(
    RetryPerformanceAnalysisEvent event,
    Emitter<PerformanceAnalysisState> emit,
  ) async {
    await _performAnalysis(event.blogId, event.imagePath, emit,
        blogTitle: event.blogTitle, blogContent: event.blogContent);
  }

  Future<void> _performAnalysis(
    String blogId,
    String imagePath,
    Emitter<PerformanceAnalysisState> emit, {
    String? blogTitle,
    String? blogContent,
  }) async {
    try {
      // Step 1: Analyze image with blog context
      emit(const PerformanceAnalysisLoading(
        currentStep: 'Analyzing image content...',
        progress: 0.25,
      ));

      // Get enhanced image analysis with blog context
      final imageAnalysisImpl =
          _imageAnalysisService as ImageAnalysisServiceImpl;
      final imageAnalysis = await imageAnalysisImpl.analyzeImageWithContext(
        imagePath,
        blogTitle: blogTitle,
        blogContent: blogContent,
      );

      // Step 2: Scrape social media trends
      emit(const PerformanceAnalysisLoading(
        currentStep: 'Scraping social media trends...',
        progress: 0.5,
      ));

      final trends = await _trendsScraperService.scrapeSoftwareTrends();

      // Step 3: Perform performance analysis
      emit(const PerformanceAnalysisLoading(
        currentStep: 'Analyzing performance...',
        progress: 0.75,
      ));

      final performanceResult =
          await _performanceAnalysisService.analyzeBlogPerformance(
        blogId,
        imageAnalysis,
        trends,
      );

      // Step 4: Complete
      emit(const PerformanceAnalysisLoading(
        currentStep: 'Generating recommendations...',
        progress: 1.0,
      ));

      // Small delay to show completion
      await Future.delayed(const Duration(milliseconds: 500));

      emit(PerformanceAnalysisSuccess(result: performanceResult));
    } catch (e) {
      emit(PerformanceAnalysisError(message: e.toString()));
    }
  }
}
