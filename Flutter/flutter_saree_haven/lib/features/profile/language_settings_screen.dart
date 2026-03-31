import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English (US)';
  
  final List<Map<String, String>> _languages = [
    {'name': 'English (US)', 'flag': '🇺🇸'},
    {'name': 'Hindi (हिन्दी)', 'flag': '🇮🇳'},
    {'name': 'Bengali (বাংলা)', 'flag': '🇮🇳'},
    {'name': 'Tamil (தமிழ்)', 'flag': '🇮🇳'},
    {'name': 'Telugu (తెలుగు)', 'flag': '🇮🇳'},
    {'name': 'Gujarati (ગુજરાતી)', 'flag': '🇮🇳'},
    {'name': 'Marathi (मराठी)', 'flag': '🇮🇳'},
    {'name': 'Arabic (العربية)', 'flag': '🇸🇦'},
    {'name': 'French (Français)', 'flag': '🇫🇷'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Language Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: _languages.map((lang) => _buildLanguageItem(lang['name']!, lang['flag']!)).toList(),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(String name, String flag) {
    bool isSelected = _selectedLanguage == name;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedLanguage = name),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 20),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary, size: 24)
              else
                Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
