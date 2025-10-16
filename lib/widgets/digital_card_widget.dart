import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../models/user_card.dart';
import '../utils/app_theme.dart';
import '../providers/card_provider.dart';

class DigitalCardWidget extends StatelessWidget {
  final UserCard card;
  final bool showQR;
  final bool isCompact;

  const DigitalCardWidget({
    Key? key,
    required this.card,
    this.showQR = false,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _getCardGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: CardPatternPainter(),
                ),
              ),
            ),
            
            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Verification Badge
                  _buildHeader(context),
                  
                  const SizedBox(height: 20),
                  
                  // Profile Section
                  _buildProfileSection(context),
                  
                  if (!isCompact) ...[
                    const SizedBox(height: 20),
                    
                    // Company Info
                    if (card.companyName != null) _buildCompanyInfo(context),
                    
                    const SizedBox(height: 16),
                    
                    // Trust Indicators
                    _buildTrustIndicators(context),
                    
                    const SizedBox(height: 20),
                    
                    // QR Code Section
                    if (showQR) _buildQRSection(context),
                    
                    const SizedBox(height: 16),
                    
                    // Footer with ID
                    _buildFooter(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App Logo/Branding
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.verified_user,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'TrustCard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        // Verification Badge
        _buildVerificationBadge(),
      ],
    );
  }

  Widget _buildVerificationBadge() {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    if (card.isCompanyVerified) {
      badgeColor = AppTheme.verifiedGold;
      badgeIcon = Icons.verified;
      badgeText = 'VERIFIED';
    } else if (card.verificationLevel == VerificationLevel.document) {
      badgeColor = AppTheme.verifiedGreen;
      badgeIcon = Icons.check_circle;
      badgeText = 'DOCUMENT';
    } else if (card.verificationLevel == VerificationLevel.peer) {
      badgeColor = AppTheme.verifiedBlue;
      badgeIcon = Icons.people;
      badgeText = 'PEER';
    } else {
      badgeColor = AppTheme.verifiedYellow;
      badgeIcon = Icons.phone_android;
      badgeText = 'BASIC';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(badgeIcon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Row(
      children: [
        // Profile Photo
        Container(
          width: isCompact ? 60 : 80,
          height: isCompact ? 60 : 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: card.profilePhotoUrl != null
                ? Image.network(
                    card.profilePhotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultAvatar(),
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Name and Basic Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.fullName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (card.designation != null) ...[
                const SizedBox(height: 4),
                Text(
                  card.designation!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              
              if (!isCompact) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      card.phoneNumber, // Show full phone number
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.white.withOpacity(0.3),
      child: Icon(
        Icons.person,
        size: isCompact ? 30 : 40,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildCompanyInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                size: 18,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  card.companyName!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          if (card.companyId != null) ...[
            const SizedBox(height: 8),
            Text(
              'ID: ${card.companyId}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ],
          
          if (card.companyPhone != null) ...[
            const SizedBox(height: 4),
            Text(
              'Phone: ${card.companyPhone}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrustIndicators(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // Customer Rating
        if (card.customerRating != null && card.totalRatings != null)
          _buildTrustChip(
            Icons.star,
            '${card.customerRating!.toStringAsFixed(1)}/5',
            '(${card.totalRatings} ratings)',
            AppTheme.verifiedYellow,
          ),
        
        // Peer Verification
        if (card.verifiedByColleagues.isNotEmpty)
          _buildTrustChip(
            Icons.people,
            'Verified by',
            '${card.verifiedByColleagues.length} colleagues',
            AppTheme.verifiedBlue,
          ),
        
        // Document Verification
        if (card.verificationLevel == VerificationLevel.document ||
            card.verificationLevel == VerificationLevel.company)
          _buildTrustChip(
            Icons.description,
            'Documents',
            'Verified',
            AppTheme.verifiedGreen,
          ),
        
        // Active Status
        _buildTrustChip(
          Icons.check_circle_outline,
          'Active',
          'since ${_getActiveSinceText()}',
          AppTheme.verifiedGreen,
        ),
      ],
    );
  }

  Widget _buildTrustChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            QrImageView(
              data: card.id, // In production, encode full card data
              version: QrVersions.auto,
              size: 150,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              'Scan to Verify',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.white.withOpacity(0.3)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${card.id.length >= 8 ? card.id.substring(0, 8).toUpperCase() : card.id.toUpperCase()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Version ${card.version}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            
            if (card.expiryDate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Valid Until',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _formatDate(card.expiryDate!),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  LinearGradient _getCardGradient() {
    if (card.isCompanyVerified) {
      // Gold gradient for company verified
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E3A8A), // Dark blue
          Color(0xFF3B82F6), // Blue
          Color(0xFF1E40AF), // Blue
        ],
      );
    } else if (card.verificationLevel == VerificationLevel.document) {
      // Green gradient for document verified
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF065F46), // Dark green
          Color(0xFF10B981), // Green
          Color(0xFF059669), // Green
        ],
      );
    } else if (card.verificationLevel == VerificationLevel.peer) {
      // Blue gradient for peer verified
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E40AF), // Dark blue
          Color(0xFF3B82F6), // Blue
          Color(0xFF2563EB), // Blue
        ],
      );
    } else {
      // Default gradient for basic verified
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4B5563), // Gray
          Color(0xFF6B7280), // Gray
          Color(0xFF374151), // Dark gray
        ],
      );
    }
  }

  // Phone masking disabled - showing full number
  // Uncomment below if you want to mask phone numbers for privacy
  // String _maskPhoneNumber(String phone) {
  //   if (phone.length <= 4) return phone;
  //   return '${phone.substring(0, phone.length - 4).replaceAll(RegExp(r'\d'), 'X')}${phone.substring(phone.length - 4)}';
  // }

  String _getActiveSinceText() {
    final duration = DateTime.now().difference(card.createdAt);
    if (duration.inDays > 365) {
      return '${(duration.inDays / 365).floor()}y ago';
    } else if (duration.inDays > 30) {
      return '${(duration.inDays / 30).floor()}m ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Custom painter for card background pattern
class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw grid pattern
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
