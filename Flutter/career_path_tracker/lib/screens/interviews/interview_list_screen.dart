import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/providers/career_provider.dart';
import '../../models/interview.dart';
import 'interview_detail_screen.dart';

import 'add_interview_screen.dart';
import '../../widgets/interview_card.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class InterviewListScreen extends StatefulWidget {
  const InterviewListScreen({super.key});

  @override
  State<InterviewListScreen> createState() => _InterviewListScreenState();
}

class _InterviewListScreenState extends State<InterviewListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CareerProvider>(context, listen: false).fetchInterviews();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppConstants.fabBottomPadding),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddInterviewScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text("New Interview"),
          backgroundColor: AppTheme.primaryColor,
        ),
      ),
      body: Consumer<CareerProvider>(
        builder: (context, provider, child) {
          if (provider.interviews.isEmpty) {
            return _buildEmptyState();
          }

          final productBased = provider.interviews.where((i) => i.companyType == CompanyType.product).toList();
          final serviceBased = provider.interviews.where((i) => i.companyType == CompanyType.service).toList();

          return CustomScrollView(
            slivers: [
              const SliverAppBar(
                title: Text('My Schedule'),
                backgroundColor: Colors.transparent,
                pinned: true,
                centerTitle: false,
              ),
              if (productBased.isNotEmpty) ...[
                _buildSectionHeader("Product Based Companies"),
                _buildSliverList(productBased, 0),
              ],
              if (serviceBased.isNotEmpty) ...[
                _buildSectionHeader("Service Based Companies"),
                _buildSliverList(serviceBased, productBased.length),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_rounded, size: 80, color: Colors.white10),
          const SizedBox(height: 24),
          Text(
            'Your schedule is empty.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Time to start applying!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverList(List<Interview> interviews, int startOffset) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: AnimationLimiter(
        child: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final interview = interviews[index];
              return AnimationConfiguration.staggeredList(
                position: startOffset + index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InterviewDetailScreen(interview: interview),
                          ),
                        ),
                        child: InterviewCard(interview: interview),
                      ),
                    ),
                  ),
                ),
              );
            },
            childCount: interviews.length,
          ),
        ),
      ),
    );
  }
}
