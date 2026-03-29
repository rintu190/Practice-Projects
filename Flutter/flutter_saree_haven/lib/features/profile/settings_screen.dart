import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _promotionsEnabled = false;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('Preferences'),
          _buildToggleSwitch('Push Notifications', 'Receive order updates and alerts', _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
          _buildToggleSwitch('Promotional Emails', 'Receive exclusive offers and news', _promotionsEnabled, (v) => setState(() => _promotionsEnabled = v)),
          _buildToggleSwitch('Dark Mode', 'Switch to a darker app theme', _darkModeEnabled, (v) => setState(() => _darkModeEnabled = v)),
          
          const SizedBox(height: 32),
          _buildSectionHeader('Account'),
          _buildListTile('Change Password', Icons.lock_outline),
          _buildListTile('Privacy Policy', Icons.privacy_tip_outlined),
          _buildListTile('Terms of Service', Icons.description_outlined),
          
          const SizedBox(height: 32),
          _buildSectionHeader('Danger Zone'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            ),
            title: Text('Delete Account', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.redAccent)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {},
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }

  Widget _buildToggleSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () {},
    );
  }
}
