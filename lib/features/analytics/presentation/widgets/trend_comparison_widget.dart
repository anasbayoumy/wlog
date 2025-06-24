import 'package:flutter/material.dart';
import 'package:wlog/core/ai/performance_analysis_service.dart';

class TrendComparisonWidget extends StatefulWidget {
  final List<TrendComparison> comparisons;

  const TrendComparisonWidget({
    super.key,
    required this.comparisons,
  });

  @override
  State<TrendComparisonWidget> createState() => _TrendComparisonWidgetState();
}

class _TrendComparisonWidgetState extends State<TrendComparisonWidget>
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
            'Trend Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How your content compares to current social media trends',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Trend Comparison Cards
          if (widget.comparisons.isEmpty)
            _buildEmptyState()
          else
            ...widget.comparisons.asMap().entries.map((entry) {
              final index = entry.key;
              final comparison = entry.value;
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _buildTrendCard(comparison),
                    ),
                  );
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTrendCard(TrendComparison comparison) {
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
          // Header with platform badge
          Row(
            children: [
              Expanded(
                child: Text(
                  comparison.trendKeyword,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildPlatformBadge(comparison.platform),
            ],
          ),

          const SizedBox(height: 16),

          // Alignment Score
          Row(
            children: [
              const Text(
                'Alignment Score: ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                '${comparison.alignmentScore.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getScoreColor(comparison.alignmentScore),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress Bar
          LinearProgressIndicator(
            value: comparison.alignmentScore / 100,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getScoreColor(comparison.alignmentScore),
            ),
            minHeight: 4,
          ),

          const SizedBox(height: 16),

          // Trend Volume
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Colors.blue,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Trend Volume: ${_formatNumber(comparison.trendVolume)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Recommendation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    comparison.recommendation,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBadge(String platform) {
    Color color;
    IconData icon;

    switch (platform.toLowerCase()) {
      case 'twitter':
        color = Colors.blue;
        icon = Icons.alternate_email;
        break;
      case 'linkedin':
        color = Colors.indigo;
        icon = Icons.business;
        break;
      case 'reddit':
        color = Colors.orange;
        icon = Icons.forum;
        break;
      case 'github':
        color = Colors.grey;
        icon = Icons.code;
        break;
      default:
        color = Colors.purple;
        icon = Icons.public;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            platform,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
              Icons.trending_neutral,
              color: Colors.grey[600],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No Trend Data Available',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to fetch current social media trends for comparison',
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

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.orange;
    } else if (score >= 40) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
