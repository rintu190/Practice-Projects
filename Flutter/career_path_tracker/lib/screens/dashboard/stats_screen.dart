
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/providers/career_provider.dart';
import '../../models/interview.dart';

import '../../widgets/modern_glass_card.dart';
import '../../core/theme/app_theme.dart';
import 'profile_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CareerProvider>(context, listen: false).fetchGoals();
      }
    });
  }

  void _addGoalInDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Daily Goal'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Solve 2 LeetCode problems'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<CareerProvider>(context, listen: false).addGoal(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Consumer<CareerProvider>(
        builder: (context, provider, child) {
          int scheduled = provider.interviews
              .where((i) => i.status == InterviewStatus.scheduled)
              .length;
          int attended = provider.interviews
              .where((i) => i.status == InterviewStatus.attended)
              .length;
          int selected = provider.interviews
              .where((i) => i.status == InterviewStatus.selected)
              .length;
          int rejected = provider.interviews
              .where((i) => i.status == InterviewStatus.rejected)
              .length;

          int total = provider.interviews.length;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    icon: const CircleAvatar(
                       backgroundColor: Colors.white24,
                       child: Icon(Icons.person, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    },
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text("Career Insights", 
                      style: AppTheme.darkTheme.textTheme.headlineMedium),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -50,
                          top: -50,
                          child: Icon(Icons.analytics_outlined, 
                            size: 200, 
                            color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GOALS SECTION
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Today's Focus", style: Theme.of(context).textTheme.titleLarge),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentColor),
                            onPressed: _addGoalInDialog,
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (provider.goals.isEmpty)
                        const Padding(
                           padding: EdgeInsets.symmetric(vertical: 8.0),
                           child: Text("No goals for today. Set one!", style: TextStyle(color: Colors.white54)),
                        )
                      else
                        ...provider.goals.map((goal) => Dismissible(
                          key: Key(goal.id.toString()),
                          onDismissed: (_) {
                             provider.deleteGoal(goal.id!);
                          },
                          child: Card( // We use a simpler card for checklist items
                            margin: const EdgeInsets.only(bottom: 8),
                            color: AppTheme.surfaceColor,
                            child: CheckboxListTile(
                              value: goal.isCompleted,
                              title: Text(goal.title,
                                style: TextStyle(
                                  decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                                  color: goal.isCompleted ? Colors.white38 : null,
                                )
                              ),
                              activeColor: AppTheme.successColor,
                              onChanged: (_) => provider.toggleGoal(goal),
                            ),
                          ),
                        )),

                      const SizedBox(height: 24),
                      
                      _buildSummaryRow(total, scheduled, selected),
                      const SizedBox(height: 24),
                      Text("Interview Performance", 
                        style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      if (total > 0)
                        SizedBox(
                          height: 250,
                          child: ModernGlassCard(
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  _buildPieSection(scheduled, "Pending", AppTheme.infoColor),
                                  _buildPieSection(attended, "Done", AppTheme.warningColor),
                                  _buildPieSection(selected, "Offer", AppTheme.successColor),
                                  _buildPieSection(rejected, "No", AppTheme.errorColor),
                                ],
                                sectionsSpace: 4,
                                centerSpaceRadius: 50,
                                startDegreeOffset: -90,
                              ),
                            ),
                          ),
                        )
                      else 
                        ModernGlassCard(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              "No interviews tracked yet.\nAdd one to see insights!", 
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      Text("Active Courses", 
                        style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      if(provider.courses.isEmpty)
                         ModernGlassCard(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              "Learning is a journey.\nAdd a course to start tracking.", 
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        )
                      else
                        ...provider.courses.map((course) => ModernGlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(course.title, 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  Text("${(course.progress * 100).toInt()}%", 
                                    style: TextStyle(
                                      color: AppTheme.primaryColor, 
                                      fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(course.provider, 
                                style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: course.progress,
                                  backgroundColor: Colors.white10,
                                  color: AppTheme.primaryColor,
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        )),
                      const SizedBox(height: 100), // Spacing for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PieChartSectionData _buildPieSection(int value, String title, Color color) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: value > 0 ? title : '',
      radius: value > 0 ? 60 : 50,
      titleStyle: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      badgeWidget: value > 0 ? _buildBadge(value.toString(), color) : null,
      badgePositionPercentageOffset: 1.2,
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSummaryRow(int total, int upcoming, int success) {
    return Row(
      children: [
        Expanded(child: _buildStatCard("Total", total.toString(), AppTheme.primaryColor)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Pending", upcoming.toString(), AppTheme.infoColor)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Offers", success.toString(), AppTheme.successColor)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return ModernGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, 
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
