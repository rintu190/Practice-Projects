import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../interviews/interview_list_screen.dart';
import '../courses/course_list_screen.dart';
import 'stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StatsScreen(), // Home is now Stats/Dashboard
    const InterviewListScreen(),
    const CourseListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Key for floating effect
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: NavigationBar(
            height: 70,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent, // Let container color show
            indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Cleaner look
            destinations: const [
               NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryColor),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                label: 'Interviews',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school, color: AppTheme.primaryColor),
                label: 'Courses',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
