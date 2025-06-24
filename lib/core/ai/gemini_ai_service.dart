import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wlog/core/ai/image_analysis_service.dart';
import 'package:wlog/core/ai/trends_scraper_service.dart';

/// Real AI service implementation using Google Gemini API
class GeminiAIService {
  // Changed to static to match the rest of the class
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// Analyze image using Gemini Vision with optional blog context
  static Future<ImageAnalysisResult> analyzeImage(
    String imageUrl, {
    String? blogTitle,
    String? blogContent,
  }) async {
    try {
      final contextInfo = blogTitle != null || blogContent != null
          ? '''
BLOG CONTEXT:
Title: ${blogTitle ?? 'Not provided'}
Content: ${blogContent ?? 'Not provided'}

Use this context to provide more accurate analysis of the image content.
'''
          : '';

      final prompt = '''
$contextInfo
Analyze this image and provide a detailed analysis in JSON format with the following structure:
{
  "extractedText": "any text visible in the image",
  "themes": ["theme1", "theme2", "theme3"],
  "keywords": ["keyword1", "keyword2", "keyword3"],
  "contentDescription": "detailed description of the image content",
  "confidence": 0.85,
  "metadata": {
    "imageType": "screenshot/photo/graphic",
    "primaryColors": ["color1", "color2"],
    "technicalContent": true,
    "programmingLanguage": "if code is visible",
    "softwareTools": ["tool1", "tool2"]
  }
}

Focus on identifying:
- Any text, code, or technical content in the image
- Software development themes (programming, AI, web dev, mobile dev, etc.)
- Relevant keywords for social media trends
- Technical tools, frameworks, or languages visible
- Overall content quality and professional level
- Color scheme and visual design elements

Provide accurate and detailed analysis for content optimization.
''';

      final response = await _callGeminiVision(prompt, imageUrl);
      final jsonResponse = _extractJsonFromResponse(response);

      return ImageAnalysisResult(
        extractedText: jsonResponse['extractedText'] ?? '',
        themes: List<String>.from(jsonResponse['themes'] ?? []),
        keywords: List<String>.from(jsonResponse['keywords'] ?? []),
        contentDescription: jsonResponse['contentDescription'] ?? '',
        confidence: (jsonResponse['confidence'] ?? 0.8).toDouble(),
        metadata: Map<String, dynamic>.from(jsonResponse['metadata'] ?? {}),
      );
    } catch (e) {
      print('Gemini image analysis error: $e');
      // Return fallback analysis
      return _getFallbackImageAnalysis();
    }
  }

  /// Generate social media trends using Gemini
  static Future<List<TrendData>> generateSoftwareTrends() async {
    try {
      const prompt = '''
Generate current software development trends data in JSON format. Create realistic trending topics for social media platforms based on actual current trends in 2024-2025:

{
  "trends": [
    {
      "platform": "Twitter",
      "content": "trend description",
      "hashtags": ["#hashtag1", "#hashtag2"],
      "keywords": ["keyword1", "keyword2"],
      "engagementCount": 1250,
      "shareCount": 340,
      "likeCount": 890,
      "category": "software",
      "trendScore": 0.85,
      "hoursAgo": 2
    }
  ]
}

Include current trending topics for:
- AI and Machine Learning (ChatGPT, Claude, Gemini, LLMs)
- Web Development (React, Next.js, Vue, Angular, TypeScript)
- Mobile Development (Flutter, React Native, Swift, Kotlin)
- DevOps and Cloud (Docker, Kubernetes, AWS, Azure, GCP)
- Programming Languages (Python, JavaScript, Rust, Go, Java)
- Software Architecture (Microservices, Serverless, Edge Computing)
- Developer Tools (GitHub Copilot, VS Code, IDEs)
- Emerging Technologies (WebAssembly, Blockchain, IoT)

Generate 15-20 realistic trending topics across Twitter, LinkedIn, Reddit, GitHub, and Product Hunt.
Make the engagement numbers realistic and vary the trend scores based on actual popularity.
''';

      final response = await _callGeminiText(prompt);
      final jsonResponse = _extractJsonFromResponse(response);

      final trendsData = jsonResponse['trends'] as List? ?? [];

      return trendsData
          .map((trend) => TrendData(
                platform: trend['platform'] ?? 'Unknown',
                content: trend['content'] ?? '',
                hashtags: List<String>.from(trend['hashtags'] ?? []),
                keywords: List<String>.from(trend['keywords'] ?? []),
                engagementCount: trend['engagementCount'] ?? 0,
                shareCount: trend['shareCount'] ?? 0,
                likeCount: trend['likeCount'] ?? 0,
                timestamp: DateTime.now()
                    .subtract(Duration(hours: trend['hoursAgo'] ?? 2)),
                category: trend['category'] ?? 'software',
                trendScore: (trend['trendScore'] ?? 0.5).toDouble(),
              ))
          .toList();
    } catch (e) {
      print('Gemini trends generation error: $e');
      // Return fallback trends
      return _getFallbackTrends();
    }
  }

  /// Generate performance recommendations using Gemini
  static Future<List<String>> generateRecommendations(
    ImageAnalysisResult imageAnalysis,
    List<TrendData> trends,
  ) async {
    try {
      final trendSummary = trends
          .take(5)
          .map((t) =>
              '- ${t.platform}: ${t.content} (Keywords: ${t.keywords.join(", ")}) [Score: ${t.trendScore}]')
          .join('\n');

      final prompt = '''
Based on the following content analysis and current social media trends, provide 6-8 specific, actionable recommendations to improve content performance and social media engagement:

CONTENT ANALYSIS:
- Extracted Text: "${imageAnalysis.extractedText}"
- Themes: ${imageAnalysis.themes.join(', ')}
- Keywords: ${imageAnalysis.keywords.join(', ')}
- Description: ${imageAnalysis.contentDescription}
- Technical Content: ${imageAnalysis.metadata['technicalContent'] ?? false}
- Programming Language: ${imageAnalysis.metadata['programmingLanguage'] ?? 'None detected'}
- Software Tools: ${imageAnalysis.metadata['softwareTools'] ?? []}

CURRENT TRENDING TOPICS:
$trendSummary

Provide recommendations in JSON format:
{
  "recommendations": [
    "Specific actionable recommendation 1",
    "Specific actionable recommendation 2",
    ...
  ]
}

Focus on:
1. Trending keywords to incorporate in posts
2. Platform-specific content strategies
3. Hashtag optimization for better reach
4. Content timing and posting strategies
5. Visual content improvements
6. Engagement tactics (polls, questions, CTAs)
7. Cross-platform promotion strategies
8. Technical content presentation tips

Make recommendations specific, actionable, and based on current trends.
''';

      final response = await _callGeminiText(prompt);
      final jsonResponse = _extractJsonFromResponse(response);

      return List<String>.from(jsonResponse['recommendations'] ?? []);
    } catch (e) {
      print('Gemini recommendations error: $e');
      return _getFallbackRecommendations();
    }
  }

  /// Call Gemini Vision API for image analysis
  static Future<String> _callGeminiVision(
      String prompt, String imageUrl) async {
    // Removed const and using string interpolation with _apiKey
    final url =
        '$_baseUrl/models/gemini-1.5-flash:generateContent?key=${_apiKey}';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': await _getImageBase64(imageUrl),
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      }
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception(
          'Gemini Vision API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Call Gemini Text API for text generation
  static Future<String> _callGeminiText(String prompt) async {
    // Removed const and using string interpolation with _apiKey
    final url =
        '$_baseUrl/models/gemini-1.5-flash:generateContent?key=${_apiKey}';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.8,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 4096,
      }
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception(
          'Gemini Text API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get image as base64 string
  static Future<String> _getImageBase64(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return base64Encode(response.bodyBytes);
      } else {
        throw Exception('Failed to fetch image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching image: $e');
      // Return a placeholder base64 image or throw error
      throw Exception('Failed to fetch image for analysis');
    }
  }

  /// Extract JSON from AI response
  static Map<String, dynamic> _extractJsonFromResponse(String response) {
    try {
      // Try to find JSON in the response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        return json.decode(jsonString);
      }

      // If no JSON found, return empty map
      print('No JSON found in response: $response');
      return {};
    } catch (e) {
      print('JSON parsing error: $e');
      print('Response was: $response');
      return {};
    }
  }

  /// Fallback image analysis
  static ImageAnalysisResult _getFallbackImageAnalysis() {
    return ImageAnalysisResult(
      extractedText: 'Unable to analyze image - using fallback analysis',
      themes: ['technology', 'software', 'development'],
      keywords: ['tech', 'code', 'programming', 'software'],
      contentDescription:
          'Technical content detected - detailed analysis unavailable',
      confidence: 0.6,
      metadata: {
        'fallback': true,
        'imageType': 'unknown',
        'technicalContent': true,
      },
    );
  }

  /// Fallback trends
  static List<TrendData> _getFallbackTrends() {
    return [
      TrendData(
        platform: 'Twitter',
        content:
            'AI development tools revolutionizing software engineering workflows',
        hashtags: ['#AI', '#SoftwareDevelopment', '#Programming', '#DevTools'],
        keywords: ['AI', 'development', 'tools', 'software', 'engineering'],
        engagementCount: 1250,
        shareCount: 340,
        likeCount: 890,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        category: 'software',
        trendScore: 0.85,
      ),
      TrendData(
        platform: 'LinkedIn',
        content:
            'Low-code platforms changing how enterprises build applications',
        hashtags: ['#LowCode', '#NoCode', '#Development', '#Enterprise'],
        keywords: ['low-code', 'no-code', 'applications', 'enterprise'],
        engagementCount: 980,
        shareCount: 220,
        likeCount: 650,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        category: 'software',
        trendScore: 0.72,
      ),
      TrendData(
        platform: 'GitHub',
        content: 'Open source AI libraries trending this week',
        hashtags: ['#OpenSource', '#AI', '#MachineLearning', '#Libraries'],
        keywords: ['open source', 'AI', 'machine learning', 'libraries'],
        engagementCount: 890,
        shareCount: 290,
        likeCount: 610,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        category: 'software',
        trendScore: 0.78,
      ),
    ];
  }

  /// Fallback recommendations
  static List<String> _getFallbackRecommendations() {
    return [
      'Incorporate trending AI and machine learning keywords in your content',
      'Use platform-specific hashtags: #AI #SoftwareDevelopment #Programming',
      'Post during peak engagement hours (9-11 AM and 2-4 PM)',
      'Include visual code snippets or screenshots for better engagement',
      'Add call-to-action questions to encourage comments and discussions',
      'Cross-post content across multiple platforms with platform-specific adaptations',
      'Engage with trending topics in your niche to increase visibility',
    ];
  }
}
