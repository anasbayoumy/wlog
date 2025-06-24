import 'package:flutter/material.dart';
import 'package:wlog/core/ai/performance_analysis_service.dart';

class PerformanceRecommendationsWidget extends StatefulWidget {
  final List<PerformanceRecommendation> recommendations;

  const PerformanceRecommendationsWidget({
    super.key,
    required this.recommendations,
  });

  @override
  State<PerformanceRecommendationsWidget> createState() => _PerformanceRecommendationsWidgetState();
}

class _PerformanceRecommendationsWidgetState extends State<PerformanceRecommendationsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Recommendations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Actionable insights to improve your content performance',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          
          // Recommendations List
          if (widget.recommendations.isEmpty)
            _buildEmptyState()
          else
            ...widget.recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 150)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildRecommendationCard(recommendation, index),
                    ),
                  );
                },
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(PerformanceRecommendation recommendation, int index) {
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
          // Header with type badge and impact
          Row(
            children: [
              Expanded(
                child: Text(
                  recommendation.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTypeBadge(recommendation.type),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Text(
            recommendation.description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Impact Score
          Row(
            children: [
              const Text(
                'Impact: ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getImpactColor(recommendation.impact).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(recommendation.impact * 100).toInt()}%',
                  style: TextStyle(
                    color: _getImpactColor(recommendation.impact),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              // Priority indicator
              _buildPriorityIndicator(recommendation.impact),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Item
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.assignment_turned_in,
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Action Item',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation.actionItem,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Keywords (if any)
          if (recommendation.keywords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: recommendation.keywords.map((keyword) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Text(
                    keyword,
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 10,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeBadge(RecommendationType type) {
    Color color;
    IconData icon;
    String label;
    
    switch (type) {
      case RecommendationType.trending:
        color = Colors.orange;
        icon = Icons.trending_up;
        label = 'Trending';
        break;
      case RecommendationType.engagement:
        color = Colors.pink;
        icon = Icons.favorite;
        label = 'Engagement';
        break;
      case RecommendationType.competitive:
        color = Colors.green;
        icon = Icons.emoji_events;
        label = 'Competitive';
        break;
      case RecommendationType.optimization:
        color = Colors.blue;
        icon = Icons.tune;
        label = 'Optimization';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityIndicator(double impact) {
    String priority;
    Color color;
    
    if (impact >= 0.8) {
      priority = 'High';
      color = Colors.red;
    } else if (impact >= 0.6) {
      priority = 'Medium';
      color = Colors.orange;
    } else {
      priority = 'Low';
      color = Colors.green;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          priority,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Colors.grey[600],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No Recommendations Available',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your content is performing well! Check back later for new insights.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getImpactColor(double impact) {
    if (impact >= 0.8) {
      return Colors.red;
    } else if (impact >= 0.6) {
      return Colors.orange;
    } else if (impact >= 0.4) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }
}
