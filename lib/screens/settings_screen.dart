import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Preferences Section
            _buildSection(
              context,
              'App Preferences',
              Icons.tune,
              [
                _buildSettingItem(
                  context,
                  'Notifications',
                  'Push notifications and alerts',
                  Icons.notifications,
                  'Enabled',
                  () => _showNotificationSettings(context),
                ),
                _buildSettingItem(
                  context,
                  'Dark Mode',
                  'Appearance and theme',
                  Icons.dark_mode,
                  'System Default',
                  () => _showThemeSettings(context),
                ),
                _buildSettingItem(
                  context,
                  'Language',
                  'App language and region',
                  Icons.language,
                  'English',
                  () => _showLanguageSettings(context),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Privacy & Security Section
            _buildSection(
              context,
              'Privacy & Security',
              Icons.security,
              [
                _buildSettingItem(
                  context,
                  'Data Collection',
                  'What data we collect and why',
                  Icons.data_usage,
                  'Minimal',
                  () => _showDataCollectionInfo(context),
                ),
                _buildSettingItem(
                  context,
                  'Analytics',
                  'Usage analytics and crash reports',
                  Icons.analytics,
                  'Anonymous',
                  () => _showAnalyticsSettings(context),
                ),
                _buildSettingItem(
                  context,
                  'Location Services',
                  'Location access and tracking',
                  Icons.location_on,
                  'Disabled',
                  () => _showLocationSettings(context),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Account Section
            _buildSection(
              context,
              'Account',
              Icons.account_circle,
              [
                _buildSettingItem(
                  context,
                  'Auto-sync',
                  'Automatic data synchronization',
                  Icons.sync,
                  'Enabled',
                  () => _showSyncSettings(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String value,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text('Configure your notification preferences here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showThemeSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Settings'),
        content: const Text('Choose your preferred app theme.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language Settings'),
        content: const Text('Select your preferred language.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataCollectionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Collection'),
        content: const Text('We collect minimal data necessary for app functionality.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics Settings'),
        content: const Text('Help us improve the app by sharing anonymous usage data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLocationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Settings'),
        content: const Text('Location services are currently disabled for privacy.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSyncSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Settings'),
        content: const Text('Automatic synchronization keeps your data up to date.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}