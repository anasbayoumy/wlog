import 'package:flutter/material.dart';
import 'package:wlog/core/ai/performance_analysis_service.dart';

class PerformanceMetricsWidget extends StatefulWidget {
  final List<PerformanceMetric> metrics;

  const PerformanceMetricsWidget({
    super.key,
    required this.metrics,
  });

  @override
  State<PerformanceMetricsWidget> createState() =>
      _PerformanceMetricsWidgetState();
}

class _PerformanceMetricsWidgetState extends State<PerformanceMetricsWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      widget.metrics.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1000 + (index * 200)),
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    // Start animations with staggered delay
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _animationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Detailed breakdown of your content performance',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),

        // Metrics List
        ...widget.metrics.asMap().entries.map((entry) {
          final index = entry.key;
          final metric = entry.value;
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - _animations[index].value)),
                child: Opacity(
                  opacity: _animations[index].value,
                  child: _buildMetricCard(metric, index),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildMetricCard(PerformanceMetric metric, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metric.description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Trend Indicator
              _buildTrendIndicator(metric.trend),
            ],
          ),

          const SizedBox(height: 16),

          // Value and Progress
          Row(
            children: [
              Text(
                '${metric.value.toStringAsFixed(1)}${metric.unit}',
                style: TextStyle(
                  color: _getMetricColor(metric.percentage),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${metric.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return LinearProgressIndicator(
                value: (metric.percentage / 100) * _animations[index].value,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getMetricColor(metric.percentage),
                ),
                minHeight: 6,
              );
            },
          ),

          const SizedBox(height: 8),

          // Performance Level
          _buildPerformanceLevel(metric.percentage),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(MetricTrend trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case MetricTrend.increasing:
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case MetricTrend.decreasing:
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      case MetricTrend.stable:
        icon = Icons.trending_flat;
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildPerformanceLevel(double percentage) {
    String level;
    Color color;

    if (percentage >= 80) {
      level = 'Excellent';
      color = Colors.green;
    } else if (percentage >= 60) {
      level = 'Good';
      color = Colors.orange;
    } else if (percentage >= 40) {
      level = 'Average';
      color = Colors.yellow;
    } else {
      level = 'Poor';
      color = Colors.red;
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          level,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getMetricColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else if (percentage >= 40) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
