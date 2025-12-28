import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/career_provider.dart';
import '../../models/course.dart';

import 'add_course_screen.dart';
import 'course_detail_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/modern_glass_card.dart';

import '../../core/constants/app_constants.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CareerProvider>(context, listen: false).fetchCourses();
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
              MaterialPageRoute(builder: (_) => const AddCourseScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text("New Course"),
          backgroundColor: AppTheme.accentColor,
        ),
      ),
      body: Consumer<CareerProvider>(
        builder: (context, provider, child) {
          if (provider.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.school_outlined, size: 80, color: Colors.white10),
                  const SizedBox(height: 24),
                  Text("No courses yet.",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text("Add a course to track your growth.",
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              const SliverAppBar(
                title: Text('Learning Path'),
                backgroundColor: Colors.transparent,
                pinned: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = provider.courses[index];
                      final isCompleted = course.status == CourseStatus.completed;
                      final opacity = isCompleted ? 0.5 : 1.0;
                      
                      return ModernGlassCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetailScreen(course: course),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isCompleted 
                                    ? Colors.grey.withValues(alpha: 0.2) 
                                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCompleted 
                                    ? Colors.grey.withValues(alpha: 0.3) 
                                    : AppTheme.primaryColor.withValues(alpha: 0.3)
                                ),
                              ),
                              child: Icon(
                                isCompleted ? Icons.check : Icons.menu_book_rounded, 
                                color: isCompleted ? Colors.grey : AppTheme.primaryColor
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Opacity(
                                opacity: opacity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(course.title,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontSize: 18,
                                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                                        )),
                                    const SizedBox(height: 4),
                                    Text(course.provider,
                                      style: TextStyle(color: Colors.blueGrey[300])),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: course.progress,
                                        backgroundColor: Colors.white10,
                                        color: isCompleted ? Colors.grey : AppTheme.accentColor,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                isCompleted ? Icons.undo : Icons.check_circle_outline,
                                color: isCompleted ? Colors.white54 : AppTheme.successColor,
                              ),
                              onPressed: () {
                                final newStatus = isCompleted 
                                    ? CourseStatus.inProgress 
                                    : CourseStatus.completed;
                                final newProgress = isCompleted ? 0.0 : 1.0;
                                final updated = Course(
                                  id: course.id,
                                  title: course.title,
                                  provider: course.provider,
                                  status: newStatus,
                                  progress: newProgress,
                                );
                                provider.updateCourse(updated);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: provider.courses.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
