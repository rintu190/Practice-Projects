import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'tickets_screen.dart';
import 'chat_screen.dart';
import 'faqs_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & Help'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.confirmation_number), text: 'Tickets'),
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
            Tab(icon: Icon(Icons.help_outline), text: 'FAQs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TicketsScreen(),
          ChatScreen(),
          FAQsScreen(),
        ],
      ),
    );
  }
}
