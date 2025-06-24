import 'dart:io';
import 'dart:typed_data';
import 'gemini_ai_service.dart';

/// Service for analyzing images and extracting text/content information
abstract class ImageAnalysisService {
  /// Analyze an image and extract text content
  Future<ImageAnalysisResult> analyzeImage(String imagePath);

  /// Analyze image from bytes
  Future<ImageAnalysisResult> analyzeImageFromBytes(Uint8List imageBytes);

  /// Extract key themes and topics from image
  Future<List<String>> extractThemes(String imagePath);

  /// Get content description from image
  Future<String> getContentDescription(String imagePath);
}

/// Result of image analysis
class ImageAnalysisResult {
  final String extractedText;
  final List<String> themes;
  final List<String> keywords;
  final String contentDescription;
  final double confidence;
  final Map<String, dynamic> metadata;

  ImageAnalysisResult({
    required this.extractedText,
    required this.themes,
    required this.keywords,
    required this.contentDescription,
    required this.confidence,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'extractedText': extractedText,
      'themes': themes,
      'keywords': keywords,
      'contentDescription': contentDescription,
      'confidence': confidence,
      'metadata': metadata,
    };
  }

  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ImageAnalysisResult(
      extractedText: json['extractedText'] ?? '',
      themes: List<String>.from(json['themes'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      contentDescription: json['contentDescription'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      metadata: json['metadata'] ?? {},
    );
  }
}

/// Implementation of Image Analysis Service
class ImageAnalysisServiceImpl implements ImageAnalysisService {
  // This would integrate with services like:
  // - Google Vision API
  // - AWS Rekognition
  // - Azure Computer Vision
  // - OpenAI GPT-4 Vision

  @override
  Future<ImageAnalysisResult> analyzeImage(String imagePath) async {
    try {
      // Use Gemini AI for real image analysis
      return await GeminiAIService.analyzeImage(imagePath);
    } catch (e) {
      print('Gemini analysis failed, using fallback: $e');
      // Fallback to mock analysis if Gemini fails
      return ImageAnalysisResult(
        extractedText: 'Fallback analysis - Gemini API unavailable',
        themes: ['technology', 'software', 'development'],
        keywords: ['tech', 'code', 'programming', 'software'],
        contentDescription:
            'Technical content detected - detailed analysis unavailable',
        confidence: 0.6,
        metadata: {
          'fallback': true,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  /// Analyze image with blog context for more accurate results
  Future<ImageAnalysisResult> analyzeImageWithContext(
    String imagePath, {
    String? blogTitle,
    String? blogContent,
  }) async {
    try {
      // Use Gemini AI with blog context for enhanced analysis
      return await GeminiAIService.analyzeImage(
        imagePath,
        blogTitle: blogTitle,
        blogContent: blogContent,
      );
    } catch (e) {
      print('Gemini contextual analysis failed, using fallback: $e');
      // Enhanced fallback with context
      return ImageAnalysisResult(
        extractedText: 'Contextual analysis unavailable - using fallback',
        themes: _extractThemesFromContext(blogTitle, blogContent),
        keywords: _extractKeywordsFromContext(blogTitle, blogContent),
        contentDescription:
            'Content analysis based on blog context: ${blogTitle ?? 'Untitled'}',
        confidence: 0.7, // Higher confidence with context
        metadata: {
          'fallback': true,
          'hasContext': blogTitle != null || blogContent != null,
          'blogTitle': blogTitle,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  /// Extract themes from blog context
  List<String> _extractThemesFromContext(String? title, String? content) {
    final themes = <String>[];
    final text = '${title ?? ''} ${content ?? ''}'.toLowerCase();

    // Common tech themes
    if (text.contains('ai') || text.contains('artificial intelligence')) {
      themes.add('artificial intelligence');
    }
    if (text.contains('machine learning') || text.contains('ml')) {
      themes.add('machine learning');
    }
    if (text.contains('web') ||
        text.contains('frontend') ||
        text.contains('backend')) themes.add('web development');
    if (text.contains('mobile') ||
        text.contains('app') ||
        text.contains('flutter') ||
        text.contains('react native')) themes.add('mobile development');
    if (text.contains('data') ||
        text.contains('database') ||
        text.contains('analytics')) themes.add('data science');
    if (text.contains('cloud') ||
        text.contains('aws') ||
        text.contains('azure') ||
        text.contains('gcp')) themes.add('cloud computing');
    if (text.contains('devops') ||
        text.contains('docker') ||
        text.contains('kubernetes')) themes.add('devops');
    if (text.contains('security') || text.contains('cybersecurity')) {
      themes.add('cybersecurity');
    }
    if (text.contains('blockchain') || text.contains('crypto')) {
      themes.add('blockchain');
    }
    if (text.contains('iot') || text.contains('internet of things')) {
      themes.add('internet of things');
    }

    return themes.isEmpty ? ['technology', 'software', 'development'] : themes;
  }

  /// Extract keywords from blog context
  List<String> _extractKeywordsFromContext(String? title, String? content) {
    final keywords = <String>[];
    final text = '${title ?? ''} ${content ?? ''}'.toLowerCase();

    // Programming languages
    final languages = [
      'python',
      'javascript',
      'java',
      'c++',
      'c#',
      'go',
      'rust',
      'swift',
      'kotlin',
      'dart',
      'flutter'
    ];
    for (final lang in languages) {
      if (text.contains(lang)) keywords.add(lang);
    }

    // Frameworks and tools
    final frameworks = [
      'react',
      'angular',
      'vue',
      'node',
      'express',
      'django',
      'spring',
      'tensorflow',
      'pytorch'
    ];
    for (final framework in frameworks) {
      if (text.contains(framework)) keywords.add(framework);
    }

    // General tech keywords
    final techKeywords = [
      'api',
      'database',
      'algorithm',
      'architecture',
      'performance',
      'optimization',
      'testing',
      'deployment'
    ];
    for (final keyword in techKeywords) {
      if (text.contains(keyword)) keywords.add(keyword);
    }

    return keywords.isEmpty
        ? ['technology', 'programming', 'software']
        : keywords.take(10).toList();
  }

  @override
  Future<ImageAnalysisResult> analyzeImageFromBytes(
      Uint8List imageBytes) async {
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      return ImageAnalysisResult(
        extractedText: 'Sample extracted text from image analysis',
        themes: ['technology', 'software', 'development', 'innovation'],
        keywords: [
          'AI',
          'machine learning',
          'software development',
          'tech trends'
        ],
        contentDescription:
            'This image appears to contain technology-related content with focus on software development and AI trends.',
        confidence: 0.85,
        metadata: {
          'processingTime': 2000,
          'imageSize': imageBytes.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw ImageAnalysisException('Failed to analyze image bytes: $e');
    }
  }

  @override
  Future<List<String>> extractThemes(String imagePath) async {
    final result = await analyzeImage(imagePath);
    return result.themes;
  }

  @override
  Future<String> getContentDescription(String imagePath) async {
    final result = await analyzeImage(imagePath);
    return result.contentDescription;
  }
}

/// Exception for image analysis errors
class ImageAnalysisException implements Exception {
  final String message;
  ImageAnalysisException(this.message);

  @override
  String toString() => 'ImageAnalysisException: $message';
}
