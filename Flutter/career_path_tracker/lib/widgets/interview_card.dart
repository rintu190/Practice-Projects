
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/interview.dart';
import 'modern_glass_card.dart';
import '../core/theme/app_theme.dart';

class InterviewCard extends StatelessWidget {
  final Interview interview;

  const InterviewCard({super.key, required this.interview});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (interview.status) {
      case InterviewStatus.scheduled:
        statusColor = AppTheme.infoColor; // Blue
        statusIcon = Icons.access_time_rounded;
        break;
      case InterviewStatus.attended:
        statusColor = AppTheme.warningColor; // Amber
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case InterviewStatus.selected:
        statusColor = AppTheme.successColor; // Emerald
        statusIcon = Icons.emoji_events_outlined;
        break;
      case InterviewStatus.rejected:
        statusColor = AppTheme.errorColor; // Red
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return ModernGlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // Header with Color bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: statusColor, width: 4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interview.companyName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        interview.jobRole,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTypeBadge(interview.companyType),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        interview.status.name.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildInfoChip(context, Icons.calendar_today_rounded, 
                    DateFormat('MMM d • h:mm a').format(interview.date)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoChip(context, Icons.location_on_outlined, 
                      interview.location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey[300]),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(CompanyType type) {
    final isProduct = type == CompanyType.product;
    final color = isProduct ? Colors.amber : Colors.cyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isProduct ? "PRODUCT" : "SERVICE",
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
