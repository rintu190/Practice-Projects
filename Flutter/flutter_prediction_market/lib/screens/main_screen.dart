import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'portfolio_screen.dart';
import 'wallet_screen.dart';
import 'leaderboard_screen.dart';
import '../theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const PortfolioScreen(),
    const WalletScreen(),
    const LeaderboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              selectedItemColor: AppTheme.accentPurple,
              unselectedItemColor: Colors.grey.shade400,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.home_rounded, size: 26)),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.pie_chart_rounded, size: 26)),
                  label: 'Portfolio',
                ),
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.account_balance_wallet_rounded, size: 26)),
                  label: 'Wallet',
                ),
                BottomNavigationBarItem(
                  icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.leaderboard_rounded, size: 26)),
                  label: 'Leaderboard',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
