import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                  Icon(Icons.privacy_tip, color: AppTheme.primaryBlue, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy Policy',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Privacy Policy Content
            _buildSection(
              context,
              'Information We Collect',
              [
                'Personal Information: Name, email, phone number, company details',
                'Verification Documents: ID cards, business certificates, photos',
                'Usage Data: App interactions, feature usage, performance metrics',
                'Device Information: Device type, operating system, unique identifiers',
                'Location Data: Only when you grant permission for location-based features',
              ],
            ),
            
            _buildSection(
              context,
              'How We Use Your Information',
              [
                'Account Management: Create and maintain your TrustCard profile',
                'Verification Services: Process and verify your identity and credentials',
                'Communication: Send notifications, updates, and support messages',
                'Service Improvement: Analyze usage patterns to enhance app functionality',
                'Security: Protect against fraud, abuse, and unauthorized access',
                'Legal Compliance: Meet regulatory requirements and legal obligations',
              ],
            ),
            
            _buildSection(
              context,
              'Information Sharing',
              [
                'We do not sell your personal information to third parties',
                'We may share information with verified colleagues for networking purposes',
                'We share data with service providers who assist in app operations',
                'We may disclose information if required by law or to protect our rights',
                'Aggregated, anonymized data may be used for research and analytics',
              ],
            ),
            
            _buildSection(
              context,
              'Data Security',
              [
                'We use industry-standard encryption to protect your data',
                'Access to your information is restricted to authorized personnel only',
                'We regularly audit our security practices and update them as needed',
                'Your data is stored on secure, encrypted servers',
                'We implement multi-factor authentication for administrative access',
              ],
            ),
            
            _buildSection(
              context,
              'Your Rights',
              [
                'Access: Request a copy of your personal information',
                'Correction: Update or correct inaccurate information',
                'Deletion: Request deletion of your account and associated data',
                'Portability: Export your data in a machine-readable format',
                'Opt-out: Unsubscribe from marketing communications',
                'Restriction: Limit how we process your information',
              ],
            ),
            
            _buildSection(
              context,
              'Data Retention',
              [
                'We retain your information as long as your account is active',
                'Inactive accounts may be deleted after 3 years of inactivity',
                'Some information may be retained longer for legal or regulatory purposes',
                'You can request immediate deletion of your account at any time',
              ],
            ),
            
            _buildSection(
              context,
              'Cookies and Tracking',
              [
                'We use cookies to improve your app experience',
                'Analytics cookies help us understand app usage patterns',
                'You can control cookie settings through your device preferences',
                'We do not use cookies for advertising or third-party tracking',
              ],
            ),
            
            _buildSection(
              context,
              'Children\'s Privacy',
              [
                'Our service is not intended for children under 13 years of age',
                'We do not knowingly collect information from children under 13',
                'If we discover we have collected data from a child, we will delete it immediately',
                'Parents can contact us to review or delete their child\'s information',
              ],
            ),
            
            _buildSection(
              context,
              'International Transfers',
              [
                'Your data may be transferred to and processed in countries other than your own',
                'We ensure appropriate safeguards are in place for international transfers',
                'We comply with applicable data protection laws in all jurisdictions',
                'EU users have additional rights under GDPR regulations',
              ],
            ),
            
            _buildSection(
              context,
              'Changes to This Policy',
              [
                'We may update this privacy policy from time to time',
                'We will notify you of significant changes via email or app notification',
                'Continued use of the app after changes constitutes acceptance',
                'We recommend reviewing this policy periodically',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Contact Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_support, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Contact Us',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have questions about this privacy policy or your data rights, please contact us:',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: privacy@trustcard.app\nPhone: +1-800-TRUSTCARD',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 12),
        ...points.map((point) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6, right: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  point,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 24),
      ],
    );
  }
}
