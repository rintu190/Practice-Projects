import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../auth/auth_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'language_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<AuthService>(
        builder: (context, auth, _) {
          final settings = auth.userSettings;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionHeader('Preferences'),
              _buildToggleSwitch(
                'Push Notifications',
                'Receive order updates and alerts',
                settings?.pushNotifications ?? true,
                (v) => auth.updateUserSettings(pushNotifications: v),
              ),
              _buildToggleSwitch(
                'Promotional Emails',
                'Receive exclusive offers and news',
                settings?.promotionalEmails ?? false,
                (v) => auth.updateUserSettings(promotionalEmails: v),
              ),
              _buildToggleSwitch(
                'Dark Mode',
                'Switch to a darker app theme',
                settings?.darkMode ?? false,
                (v) => auth.updateUserSettings(darkMode: v),
              ),
              
              const SizedBox(height: 32),
              _buildSectionHeader('Account'),
              _buildListTile('Personal Details', Icons.person_outline, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
              }),
              _buildListTile('Change Password', Icons.lock_outline, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
              }),
              _buildListTile('Language Settings', Icons.translate_outlined, onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageSettingsScreen()));
              }),
              
              _buildSectionHeader('Danger Zone'),
              _buildDangerTile('Delete Account', Icons.delete_outline, onTap: () {}),
              
              const SizedBox(height: 60),
              Center(
                child: Text(
                  'Saree Bazaar v1.0.2',
                   style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: AppColors.primary,
          letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDangerTile(String title, IconData icon, {required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(icon, color: Colors.redAccent, size: 20),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.redAccent)),
        trailing: const Icon(Icons.chevron_right, color: Colors.redAccent, size: 20),
        onTap: onTap,
      ),
    );
  }
}
