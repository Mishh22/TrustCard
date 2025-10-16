import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user_card.dart';
import '../utils/app_theme.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(
              child: Text('Please login to view verification status'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Status
                _buildCurrentStatus(user),
                
                const SizedBox(height: 24),
                
                // Verification Levels
                _buildVerificationLevels(),
                
                const SizedBox(height: 24),
                
                // Trust Score
                _buildTrustScore(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStatus(UserCard user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: AppTheme.getVerificationColor(
                    user.verificationLevel,
                    user.isCompanyVerified,
                  ),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.verificationBadgeText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.getVerificationColor(
                            user.verificationLevel,
                            user.isCompanyVerified,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.getVerificationColor(
                      user.verificationLevel,
                      user.isCompanyVerified,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${user.trustScore.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _getStatusDescription(user),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationLevels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Levels',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildVerificationLevelCard(
          'Basic Verification',
          'Phone number verified',
          Icons.phone_android,
          AppTheme.verifiedYellow,
          VerificationLevel.basic,
          'Your phone number is verified via OTP',
        ),
        
        _buildVerificationLevelCard(
          'Document Verification',
          'Documents uploaded and verified',
          Icons.description,
          AppTheme.verifiedGreen,
          VerificationLevel.document,
          'Upload company ID, offer letter, or salary slip',
        ),
        
        _buildPeerVerificationCard(),
        
        _buildVerificationLevelCard(
          'Company Verification',
          'Officially verified by company',
          Icons.business,
          AppTheme.verifiedGold,
          VerificationLevel.company,
          'Company admin verifies your employment',
        ),
      ],
    );
  }

  Widget _buildVerificationLevelCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VerificationLevel level,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: () => _handleVerificationLevelTap(level),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        level.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: color,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustScore(UserCard user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trust Score',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.trustScore.toInt()}%',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.getTrustScoreColor(user.trustScore),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: user.trustScore / 100.0,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.getTrustScoreColor(user.trustScore),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getTrustScoreColor(user.trustScore).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTrustScoreIcon(user.trustScore),
                    color: AppTheme.getTrustScoreColor(user.trustScore),
                    size: 32,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _getTrustScoreDescription(user.trustScore),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeerVerificationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: () => context.push('/colleague-verification'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.verifiedBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.people, color: AppTheme.verifiedBlue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peer Verification',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verified by colleagues',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Get verified by 2+ colleagues from same company',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.verifiedBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PEER',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.verifiedBlue,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleVerificationLevelTap(VerificationLevel level) {
    switch (level) {
      case VerificationLevel.basic:
        // Basic verification is already complete - no action needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Basic verification is already complete!'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      
      case VerificationLevel.document:
        // Navigate to document upload for document verification
        context.push('/document-upload');
        break;
      
      case VerificationLevel.peer:
        // Navigate to colleague verification for peer verification
        context.push('/colleague-verification');
        break;
      
      case VerificationLevel.company:
        // Navigate to card verification request screen
        context.push('/card-verification-request');
        break;
    }
  }

  String _getStatusDescription(UserCard user) {
    if (user.isCompanyVerified) {
      return 'Your identity is officially verified by your company. This is the highest level of verification.';
    }
    
    switch (user.verificationLevel) {
      case VerificationLevel.basic:
        return 'You have basic verification with phone number. Upload documents to increase your trust level.';
      case VerificationLevel.document:
        return 'Your documents are verified. Get colleague endorsements to reach the next level.';
      case VerificationLevel.peer:
        return 'You are verified by your colleagues. Contact your company to get official verification.';
      case VerificationLevel.company:
        return 'You are officially verified by your company.';
    }
  }

  String _getTrustScoreDescription(double score) {
    if (score >= 80) {
      return 'Excellent! You have a high trust score. Customers will trust your identity.';
    } else if (score >= 60) {
      return 'Good trust score. Consider uploading more documents to increase it further.';
    } else if (score >= 40) {
      return 'Fair trust score. Upload documents and get colleague verification to improve.';
    } else {
      return 'Low trust score. Start by uploading documents to build trust.';
    }
  }

  IconData _getTrustScoreIcon(double score) {
    if (score >= 80) return Icons.star;
    if (score >= 60) return Icons.thumb_up;
    if (score >= 40) return Icons.check_circle;
    return Icons.warning;
  }
}
