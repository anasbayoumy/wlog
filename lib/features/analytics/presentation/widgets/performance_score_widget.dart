import 'package:flutter/material.dart';
import 'package:wlog/core/ai/performance_analysis_service.dart';
import 'dart:math' as math;

class PerformanceScoreWidget extends StatefulWidget {
  final PerformanceAnalysisResult result;

  const PerformanceScoreWidget({
    super.key,
    required this.result,
  });

  @override
  State<PerformanceScoreWidget> createState() => _PerformanceScoreWidgetState();
}

class _PerformanceScoreWidgetState extends State<PerformanceScoreWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.result.overallScore / 100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900.withOpacity(0.3),
            Colors.purple.shade900.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          const Text(
            'Overall Performance Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Circular Progress Indicator
          SizedBox(
            width: 150,
            height: 150,
            child: AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CircularScorePainter(
                    progress: _scoreAnimation.value,
                    score: widget.result.overallScore,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(widget.result.overallScore * _scoreAnimation.value).toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Score',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Score Interpretation
          _buildScoreInterpretation(),
          
          const SizedBox(height: 16),
          
          // Analysis Date
          Text(
            'Analyzed on ${_formatDate(widget.result.analysisTimestamp)}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInterpretation() {
    final score = widget.result.overallScore;
    String interpretation;
    Color color;
    IconData icon;

    if (score >= 80) {
      interpretation = 'Excellent Performance';
      color = Colors.green;
      icon = Icons.emoji_events;
    } else if (score >= 60) {
      interpretation = 'Good Performance';
      color = Colors.orange;
      icon = Icons.thumb_up;
    } else if (score >= 40) {
      interpretation = 'Average Performance';
      color = Colors.yellow;
      icon = Icons.trending_flat;
    } else {
      interpretation = 'Needs Improvement';
      color = Colors.red;
      icon = Icons.trending_down;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            interpretation,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class CircularScorePainter extends CustomPainter {
  final double progress;
  final double score;

  CircularScorePainter({
    required this.progress,
    required this.score,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Gradient colors based on score
    if (score >= 80) {
      progressPaint.color = Colors.green;
    } else if (score >= 60) {
      progressPaint.color = Colors.orange;
    } else if (score >= 40) {
      progressPaint.color = Colors.yellow;
    } else {
      progressPaint.color = Colors.red;
    }

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow effect
    if (progress > 0.5) {
      final glowPaint = Paint()
        ..color = progressPaint.color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularScorePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.score != score;
  }
}
