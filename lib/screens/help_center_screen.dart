import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: AppTheme.primaryBlue, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Help & Support',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get help, report issues, and learn about our policies',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Support Options
            _buildSection(
              context,
              'Support Options',
              Icons.support_agent,
              [
                _buildSupportItem(
                  context,
                  'Email Support',
                  'Get help via email',
                  Icons.email,
                  'support@trustcard.app',
                  () => _showEmailSupport(context),
                ),
                _buildSupportItem(
                  context,
                  'Report a Bug',
                  'Help us improve the app',
                  Icons.bug_report,
                  'Report issues and bugs',
                  () => context.push('/report-issue'),
                ),
                _buildSupportItem(
                  context,
                  'Privacy Policy',
                  'How we protect your data',
                  Icons.privacy_tip,
                  'View privacy policy',
                  () => context.push('/privacy-policy'),
                ),
                _buildSupportItem(
                  context,
                  'Terms & Conditions',
                  'App terms and conditions',
                  Icons.description,
                  'View terms and conditions',
                  () => context.push('/terms-conditions'),
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

  Widget _buildSupportItem(
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showEmailSupport(BuildContext context) {
    _showInfoDialog(
      context,
      'Email Support',
      'Send us an email at support@trustcard.app\n\nWe typically respond within 24 hours. Please include:\n• Your account details\n• Description of the issue\n• Screenshots if applicable',
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
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
