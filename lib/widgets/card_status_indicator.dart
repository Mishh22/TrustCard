import 'package:flutter/material.dart';
import '../models/user_card.dart';
import '../utils/app_theme.dart';
import '../services/company_approval_service.dart';

/// Widget to display card verification status with appropriate styling
class CardStatusIndicator extends StatelessWidget {
  final UserCard card;
  final bool showDetails;

  const CardStatusIndicator({
    super.key,
    required this.card,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    // Priority 1: Card is rejected by company admin
    if (!card.isActive && card.rejectedBy != null) {
      return _buildRejectedIndicator();
    }

    // Priority 2: Card is company verified
    if (card.isCompanyVerified) {
      return _buildVerifiedIndicator();
    }

    // Priority 3: Card is pending company approval (CHECK IF APPROVAL REQUEST EXISTS)
    if (card.companyName != null && card.companyName!.isNotEmpty && !card.isCompanyVerified) {
      return _buildPendingCheckWidget();
    }

    // Priority 4: Basic card (no company)
    return _buildBasicIndicator();
  }

  /// Widget that checks if approval request exists before showing pending status
  Widget _buildPendingCheckWidget() {
    return FutureBuilder<bool>(
      future: _hasApprovalRequest(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While checking, show basic indicator
          return _buildBasicIndicator();
        }

        if (snapshot.hasData && snapshot.data == true) {
          // Approval request exists - show pending
          return _buildPendingIndicator();
        }

        // No approval request - show basic
        return _buildBasicIndicator();
      },
    );
  }

  /// Check if approval request exists for this card
  Future<bool> _hasApprovalRequest() async {
    try {
      // Check if there's a pending approval request for this card ID
      final request = await CompanyApprovalService.getApprovalRequestByCardId(card.id);
      return request != null;
    } catch (e) {
      print('Error checking approval request: $e');
      return false;
    }
  }

  Widget _buildRejectedIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Card Rejected',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (showDetails && card.rejectionReason != null) ...[
            const SizedBox(height: 4),
            Text(
              card.rejectionReason!,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
          if (showDetails) ...[
            const SizedBox(height: 4),
            Text(
              'Company admin has rejected this card. You cannot use it.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifiedIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.verifiedGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.verifiedGreen),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, color: AppTheme.verifiedGreen, size: 16),
          const SizedBox(width: 6),
          const Text(
            'Company Verified',
            style: TextStyle(
              color: AppTheme.verifiedGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, color: Colors.orange, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Pending Approval',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (showDetails) ...[
            const SizedBox(height: 4),
            Text(
              'Waiting for company admin to approve',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.phone_android, color: Colors.blue, size: 16),
          const SizedBox(width: 6),
          const Text(
            'Phone Verified',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to show detailed card status with actionable items
class CardStatusBanner extends StatelessWidget {
  final UserCard card;

  const CardStatusBanner({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    // Card is rejected
    if (!card.isActive && card.rejectedBy != null) {
      return _buildRejectedBanner(context);
    }

    // Card is company verified
    if (card.isCompanyVerified) {
      return _buildVerifiedBanner(context);
    }

    // Card is pending approval
    if (card.companyName != null && card.companyName!.isNotEmpty) {
      return _buildPendingBanner(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildRejectedBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Card Rejected',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Company "${card.companyName}" has rejected your card request.',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
          if (card.rejectionReason != null && card.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${card.rejectionReason}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                fontStyle: FontStyle.italic,
            ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'This card is no longer active and cannot be used.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.verifiedGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.verifiedGreen, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: AppTheme.verifiedGreen, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Company Verified',
                  style: TextStyle(
                    color: AppTheme.verifiedGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This card has been approved by "${card.companyName}"',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Colors.orange, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Company Approval',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your card is waiting for approval from "${card.companyName}"',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

