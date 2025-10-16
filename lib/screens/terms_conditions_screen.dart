import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
                  Icon(Icons.description, color: AppTheme.primaryBlue, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms & Conditions',
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
            
            // Terms Content
            _buildSection(
              context,
              'Acceptance of Terms',
              [
                'By using TrustCard, you agree to be bound by these Terms and Conditions',
                'If you do not agree to these terms, please do not use our service',
                'We reserve the right to modify these terms at any time',
                'Continued use of the service after changes constitutes acceptance',
                'You are responsible for reviewing these terms periodically',
              ],
            ),
            
            _buildSection(
              context,
              'Service Description',
              [
                'TrustCard is a digital identity verification and professional networking platform',
                'We provide tools for creating, sharing, and verifying digital business cards',
                'Our service includes identity verification, trust scoring, and networking features',
                'We facilitate professional connections through verified user profiles',
                'The service is available through mobile applications and web platforms',
              ],
            ),
            
            _buildSection(
              context,
              'User Responsibilities',
              [
                'Provide accurate and truthful information in your profile',
                'Maintain the security of your account credentials',
                'Use the service only for lawful and professional purposes',
                'Respect other users and maintain professional conduct',
                'Report any suspicious or inappropriate behavior',
                'Comply with all applicable laws and regulations',
                'Do not share false, misleading, or fraudulent information',
              ],
            ),
            
            _buildSection(
              context,
              'Account Security',
              [
                'You are responsible for maintaining the confidentiality of your account',
                'You must notify us immediately of any unauthorized access',
                'We are not liable for losses resulting from unauthorized account use',
                'You must use strong passwords and enable security features',
                'We may suspend accounts that show signs of compromise',
              ],
            ),
            
            _buildSection(
              context,
              'Prohibited Activities',
              [
                'Creating fake or fraudulent profiles or documents',
                'Impersonating other individuals or organizations',
                'Sharing inappropriate, offensive, or illegal content',
                'Attempting to hack, disrupt, or damage our systems',
                'Using automated tools to access our service',
                'Violating intellectual property rights of others',
                'Engaging in harassment, discrimination, or abuse',
                'Selling or transferring your account to others',
              ],
            ),
            
            _buildSection(
              context,
              'Content and Intellectual Property',
              [
                'You retain ownership of content you create and share',
                'You grant us a license to use your content to provide our service',
                'You represent that you have the right to share all content',
                'We respect intellectual property rights and expect you to do the same',
                'Report any copyright or trademark violations to us',
                'We may remove content that violates these terms',
              ],
            ),
            
            _buildSection(
              context,
              'Privacy and Data Protection',
              [
                'Your privacy is important to us - see our Privacy Policy for details',
                'We collect and process data as described in our Privacy Policy',
                'You have rights regarding your personal information',
                'We implement security measures to protect your data',
                'We may share information as described in our Privacy Policy',
              ],
            ),
            
            _buildSection(
              context,
              'Service Availability',
              [
                'We strive to provide reliable service but cannot guarantee 100% uptime',
                'We may perform maintenance that temporarily affects service',
                'We reserve the right to modify or discontinue features',
                'We will provide reasonable notice of significant changes',
                'Service may be unavailable due to factors beyond our control',
              ],
            ),
            
            _buildSection(
              context,
              'Limitation of Liability',
              [
                'Our service is provided "as is" without warranties of any kind',
                'We are not liable for indirect, incidental, or consequential damages',
                'Our total liability is limited to the amount you paid for the service',
                'We are not responsible for third-party content or services',
                'Some jurisdictions may not allow limitation of liability',
              ],
            ),
            
            _buildSection(
              context,
              'Termination',
              [
                'You may terminate your account at any time',
                'We may suspend or terminate accounts that violate these terms',
                'We will provide notice before terminating accounts when possible',
                'Termination does not relieve you of obligations incurred before termination',
                'We may retain certain information after account termination',
              ],
            ),
            
            _buildSection(
              context,
              'Dispute Resolution',
              [
                'These terms are governed by the laws of [Jurisdiction]',
                'Disputes will be resolved through binding arbitration',
                'You waive the right to participate in class action lawsuits',
                'We encourage resolving disputes through direct communication first',
                'Arbitration will be conducted by a neutral third party',
              ],
            ),
            
            _buildSection(
              context,
              'Changes to Terms',
              [
                'We may update these terms from time to time',
                'We will notify you of material changes via email or app notification',
                'Your continued use after changes constitutes acceptance',
                'We recommend reviewing these terms periodically',
                'Previous versions of terms are available upon request',
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
                        'Questions About These Terms?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have questions about these terms and conditions, please contact us:',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: legal@trustcard.app\nPhone: +1-800-TRUSTCARD',
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
