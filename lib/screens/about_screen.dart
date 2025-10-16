import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.verified_user,
                      size: 64,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TrustCard',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _packageInfo?.version ?? '1.0.0',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Digital Identity Verification Platform',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App Description
            _buildSection(
              context,
              'About TrustCard',
              Icons.info_outline,
              [
                const Text(
                  'TrustCard is a revolutionary digital identity verification platform designed for workers, service providers, and customers. Our app enables secure, verified interactions through digital ID cards, QR code scanning, and a comprehensive trust scoring system.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Features
            _buildSection(
              context,
              'Key Features',
              Icons.star,
              [
                _buildFeatureItem(
                  context,
                  'Digital ID Cards',
                  'Create and manage multiple digital identity cards',
                  Icons.credit_card,
                ),
                _buildFeatureItem(
                  context,
                  'QR Code Scanning',
                  'Scan and verify other users\' identity cards',
                  Icons.qr_code_scanner,
                ),
                _buildFeatureItem(
                  context,
                  'Multi-Level Verification',
                  'Basic, Peer, Document, and Company verification levels',
                  Icons.verified_user,
                ),
                _buildFeatureItem(
                  context,
                  'Trust Scoring System',
                  'Build and maintain your trust score through verified interactions',
                  Icons.trending_up,
                ),
                _buildFeatureItem(
                  context,
                  'Real-time Notifications',
                  'Stay updated with verification requests and updates',
                  Icons.notifications,
                ),
                _buildFeatureItem(
                  context,
                  'Secure Cloud Storage',
                  'Your data is safely stored and synchronized across devices',
                  Icons.cloud_done,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // App Information
            _buildSection(
              context,
              'App Information',
              Icons.phone_android,
              [
                _buildInfoItem(
                  context,
                  'Version',
                  _packageInfo?.version ?? '1.0.0',
                  Icons.info,
                ),
                _buildInfoItem(
                  context,
                  'Build Number',
                  _packageInfo?.buildNumber ?? '1',
                  Icons.build,
                ),
                _buildInfoItem(
                  context,
                  'Package Name',
                  _packageInfo?.packageName ?? 'com.trustcard.app',
                  Icons.inventory,
                ),
                _buildInfoItem(
                  context,
                  'Last Updated',
                  'December 2024',
                  Icons.update,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Development Team
            _buildSection(
              context,
              'Development Team',
              Icons.people,
              [
                _buildTeamMember(
                  context,
                  'Development Team',
                  'TrustCard Development Team',
                  Icons.code,
                ),
                _buildTeamMember(
                  context,
                  'Design Team',
                  'UI/UX Design Specialists',
                  Icons.design_services,
                ),
                _buildTeamMember(
                  context,
                  'Security Team',
                  'Cybersecurity Experts',
                  Icons.security,
                ),
                _buildTeamMember(
                  context,
                  'Support Team',
                  'Customer Support Specialists',
                  Icons.support_agent,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Legal Information
            _buildSection(
              context,
              'Legal Information',
              Icons.gavel,
              [
                _buildLegalItem(
                  context,
                  'Privacy Policy',
                  'How we protect your data',
                  Icons.privacy_tip,
                  () => _showPrivacyPolicy(context),
                ),
                _buildLegalItem(
                  context,
                  'Terms of Service',
                  'App usage terms and conditions',
                  Icons.description,
                  () => _showTermsOfService(context),
                ),
                _buildLegalItem(
                  context,
                  'Open Source Licenses',
                  'Third-party library licenses',
                  Icons.code,
                  () => _showOpenSourceLicenses(context),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Contact Information
            _buildSection(
              context,
              'Contact Us',
              Icons.contact_mail,
              [
                _buildContactItem(
                  context,
                  'Email',
                  'support@trustcard.app',
                  Icons.email,
                ),
                _buildContactItem(
                  context,
                  'Phone',
                  '+1-800-TRUSTCARD',
                  Icons.phone,
                ),
                _buildContactItem(
                  context,
                  'Website',
                  'www.trustcard.app',
                  Icons.web,
                ),
                _buildContactItem(
                  context,
                  'Support Hours',
                  'Monday - Friday, 9 AM - 6 PM EST',
                  Icons.schedule,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Copyright
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    '© 2024 TrustCard. All rights reserved.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Made with ❤️ for secure digital interactions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
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
        ...children,
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(label),
        trailing: Text(
          value,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember(BuildContext context, String role, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(role),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildLegalItem(BuildContext context, String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Our privacy policy outlines how we collect, use, and protect your personal information. We are committed to maintaining the highest standards of data protection and privacy.\n\nKey points:\n• We collect minimal data necessary for app functionality\n• Your data is encrypted and securely stored\n• We never sell your personal information\n• You have full control over your data\n\nFor the complete privacy policy, please visit our website.',
          ),
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

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using TrustCard, you agree to our terms of service. These terms govern your use of the app and our services.\n\nKey terms:\n• You must be at least 18 years old to use the app\n• You are responsible for the accuracy of your information\n• Misuse of the app may result in account termination\n• We reserve the right to update these terms\n\nFor the complete terms of service, please visit our website.',
          ),
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

  void _showOpenSourceLicenses(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Source Licenses'),
        content: const SingleChildScrollView(
          child: Text(
            'TrustCard uses several open source libraries and frameworks. We are grateful to the open source community for their contributions.\n\nNotable libraries:\n• Flutter - UI framework\n• Firebase - Backend services\n• Provider - State management\n• GoRouter - Navigation\n• Image Picker - Photo selection\n\nFor a complete list of licenses, please visit our GitHub repository.',
          ),
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
