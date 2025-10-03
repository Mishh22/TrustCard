import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/language_service.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load current theme and language settings
    final themeMode = Theme.of(context).brightness;
    _isDarkMode = themeMode == Brightness.dark;
    
    final languageService = Provider.of<LanguageService>(context, listen: false);
    _selectedLanguage = languageService.getLanguageName(languageService.currentLanguageCode);
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Provider.of<LanguageService>(context).getLocalizedString('settings'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          _buildSectionHeader(
            context,
            Provider.of<LanguageService>(context).getLocalizedString('theme'),
            Icons.palette,
          ),
          _buildThemeToggle(context),
          const SizedBox(height: 24),
          
          // Language Section
          _buildSectionHeader(
            context,
            Provider.of<LanguageService>(context).getLocalizedString('language'),
            Icons.language,
          ),
          _buildLanguageSelector(context),
          const SizedBox(height: 24),
          
          // Account Section
          _buildSectionHeader(
            context,
            'Account',
            Icons.account_circle,
          ),
          _buildAccountOptions(context),
          const SizedBox(height: 24),
          
          // Privacy Section
          _buildSectionHeader(
            context,
            'Privacy & Security',
            Icons.security,
          ),
          _buildPrivacyOptions(context),
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader(
            context,
            'About',
            Icons.info,
          ),
          _buildAboutOptions(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(
          Provider.of<LanguageService>(context).getLocalizedString('dark_mode'),
        ),
        subtitle: Text(
          Provider.of<LanguageService>(context).getLocalizedString('dark_mode_subtitle'),
        ),
        value: _isDarkMode,
        onChanged: (value) {
          setState(() {
            _isDarkMode = value;
          });
          // TODO: Implement theme switching
          _showSnackBar(context, 'Theme switching will be implemented');
        },
        activeColor: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final supportedLanguages = languageService.getSupportedLanguageNames();
    
    return Card(
      child: ListTile(
        title: Text(
          Provider.of<LanguageService>(context).getLocalizedString('select_language'),
        ),
        subtitle: Text(_selectedLanguage),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showLanguageDialog(context, supportedLanguages),
      ),
    );
  }

  Widget _buildAccountOptions(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.edit, color: AppTheme.primaryBlue),
            title: Text(
              Provider.of<LanguageService>(context).getLocalizedString('edit_profile'),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to edit profile
              _showSnackBar(context, 'Edit profile will be implemented');
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.contacts, color: AppTheme.primaryBlue),
            title: const Text('Upload Contacts'),
            subtitle: const Text('Help build your professional network'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                _showSnackBar(context, 'Contacts upload will be implemented');
              },
              activeColor: AppTheme.primaryBlue,
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              Provider.of<LanguageService>(context).getLocalizedString('sign_out'),
            ),
            onTap: () => _showSignOutDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyOptions(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.visibility, color: AppTheme.primaryBlue),
            title: const Text('Public Profile Visibility'),
            subtitle: const Text('Control what others can see'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showSnackBar(context, 'Privacy settings will be implemented');
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.data_usage, color: AppTheme.primaryBlue),
            title: const Text('Data Usage'),
            subtitle: const Text('Manage your data and cache'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showSnackBar(context, 'Data management will be implemented');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAboutOptions(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.help, color: AppTheme.primaryBlue),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showSnackBar(context, 'Help & Support will be implemented');
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppTheme.primaryBlue),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showSnackBar(context, 'Privacy Policy will be implemented');
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.description, color: AppTheme.primaryBlue),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showSnackBar(context, 'Terms of Service will be implemented');
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info, color: AppTheme.primaryBlue),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            onTap: () {
              _showSnackBar(context, 'Version 1.0.0 - Beta Release');
            },
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, List<String> languages) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Provider.of<LanguageService>(context).getLocalizedString('select_language'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                _changeLanguage(context, language);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context, String language) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final languageCode = languageService.supportedLanguages[language]?.languageCode ?? 'en';
    languageService.changeLanguage(languageCode);
    _showSnackBar(context, 'Language changed to $language');
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Provider.of<LanguageService>(context).getLocalizedString('sign_out'),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/auth');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }
}
