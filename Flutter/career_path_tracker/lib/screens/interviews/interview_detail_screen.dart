
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/interview.dart';
import '../../core/providers/career_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/modern_glass_card.dart';
import 'add_interview_screen.dart';

class InterviewDetailScreen extends StatelessWidget {
  final Interview interview;

  const InterviewDetailScreen({super.key, required this.interview});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddInterviewScreen(interview: interview),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Interview?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true), 
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              
              if (confirm == true && context.mounted) {
                await Provider.of<CareerProvider>(context, listen: false).deleteInterview(interview.id!);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Consumer<CareerProvider>(
          builder: (context, provider, child) {
            // Find the updated interview object from the provider list
            final currentInterview = provider.interviews.firstWhere(
              (i) => i.id == interview.id,
              orElse: () => interview,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, currentInterview),
                  const SizedBox(height: 24),
                  _buildStatusStepper(context, currentInterview),
                  const SizedBox(height: 24),
                  _buildDetailsCard(context, currentInterview),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Interview interview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                interview.companyName,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(height: 1.1),
              ),
            ),
            _buildCompanyTypeBadge(interview.companyType),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          interview.jobRole,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyTypeBadge(CompanyType type) {
    final isProduct = type == CompanyType.product;
    final color = isProduct ? Colors.amber : Colors.cyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        isProduct ? "PRODUCT" : "SERVICE",
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildStatusStepper(BuildContext context, Interview interview) {
    return ModernGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Application Status", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          // Custom Stepper UI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepNode(context, interview, InterviewStatus.scheduled, Icons.schedule),
              _buildConnector(context, interview, InterviewStatus.scheduled),
              _buildStepNode(context, interview, InterviewStatus.attended, Icons.check), 
              _buildConnector(context, interview, InterviewStatus.attended),
              // Final node is split (Selected or Rejected)
               _buildFinalStepNode(context, interview),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButtons(context, interview),
        ],
      ),
    );
  }

  Widget _buildStepNode(BuildContext context, Interview interview, InterviewStatus stepStatus, IconData icon) {
    final isActive = interview.status.index >= stepStatus.index && interview.status != InterviewStatus.rejected;
    // Reject is a special case branch, so if rejected, scheduled and attended might still be visually 'past', 
    // but usually rejection happens after attended. 
    // Simplified logic: If status is rejected, scheduled and attended are 'past'.
    final isPast = interview.status == InterviewStatus.rejected ? (stepStatus.index <= 1) : isActive;

    final color = isPast ? AppTheme.primaryColor : Colors.white24;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isPast ? 0.2 : 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(stepStatus.name.capitalize(), 
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFinalStepNode(BuildContext context, Interview interview) {
    final isSelected = interview.status == InterviewStatus.selected;
    final isRejected = interview.status == InterviewStatus.rejected;
    
    IconData icon = Icons.question_mark;
    Color color = Colors.white24;
    String label = "Result";

    if (isSelected) {
      icon = Icons.emoji_events;
      color = AppTheme.successColor;
      label = "Selected";
    } else if (isRejected) {
      icon = Icons.cancel;
      color = AppTheme.errorColor;
      label = "Rejected";
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: (isSelected || isRejected) ? 0.2 : 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, 
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildConnector(BuildContext context, Interview interview, InterviewStatus prevStatus) {
    // If the next status is reached, connector is active
    bool active = false;
    if (interview.status == InterviewStatus.rejected) {
       // If rejected, we assume we went through previous steps (simplification)
       active = true; 
    } else {
       active = interview.status.index > prevStatus.index;
    }

    return Expanded(
      child: Container(
        height: 2,
        color: active ? AppTheme.primaryColor : Colors.white10,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Interview interview) {
    if (interview.status == InterviewStatus.scheduled) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text("Mark as Attended"),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningColor),
          onPressed: () => _updateStatus(context, interview, InterviewStatus.attended),
        ),
      );
    } else if (interview.status == InterviewStatus.attended) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.thumb_up),
              label: const Text("Selected"),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
              onPressed: () => _updateStatus(context, interview, InterviewStatus.selected),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.thumb_down),
              label: const Text("Rejected"),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
              onPressed: () => _updateStatus(context, interview, InterviewStatus.rejected),
            ),
          ),
        ],
      );
    }
    return Center(
      child: Text(
        "Interview Process Completed.", 
        style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, Interview interview, InterviewStatus newStatus) async {
    final updated = interview.copyWith(status: newStatus);
    await Provider.of<CareerProvider>(context, listen: false).updateInterview(updated);
  }

  Widget _buildDetailsCard(BuildContext context, Interview interview) {
    return ModernGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.calendar_today, DateFormat('EEEE, MMMM d, yyyy').format(interview.date)),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.access_time, DateFormat('h:mm a').format(interview.date)),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.location_on, interview.location),
          if (interview.notes.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.white10),
            ),
            Text("Notes", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(interview.notes, style: const TextStyle(color: Colors.white60, height: 1.5)),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey[200]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1)}";
    }
}
