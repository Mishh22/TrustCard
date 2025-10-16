import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/card_provider.dart';
import '../models/user_card.dart';
import '../widgets/digital_card_widget.dart';
import '../utils/app_theme.dart';
import '../services/block_card_service.dart';
import '../services/firebase_service.dart';

class CardDetailScreen extends StatefulWidget {
  final String cardId;

  const CardDetailScreen({
    super.key,
    required this.cardId,
  });

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  UserCard? _card;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    final cardProvider = context.read<CardProvider>();
    
    // Try to get from scanned cards first, then from user cards
    _card = cardProvider.getScannedCardById(widget.cardId) ?? 
            cardProvider.getCardById(widget.cardId);
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_card == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Card Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Card not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The requested card could not be found.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Digital Card Display
            Container(
              margin: const EdgeInsets.all(16),
              child: DigitalCardWidget(
                card: _card!,
                showQR: true,
                isCompact: false,
              ),
            ),
            
            // Trust Score Section
            _buildTrustScoreSection(),
            
            // Verification Details
            _buildVerificationDetails(),
            
            // Trust Ratings
            if (_card!.customerRating != null)
              _buildTrustRatings(),
            
            // Colleague Verification
            if (_card!.verifiedByColleagues.isNotEmpty)
              _buildColleagueVerification(),
            
            // Action Buttons
            _buildActionButtons(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustScoreSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security,
                    color: AppTheme.getTrustScoreColor(_card!.trustScore),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Trust Score',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_card!.trustScore.toInt()}%',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppTheme.getTrustScoreColor(_card!.trustScore),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _card!.trustScore / 100.0,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.getTrustScoreColor(_card!.trustScore),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getTrustScoreDescription(_card!.trustScore),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getTrustScoreColor(_card!.trustScore).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTrustScoreIcon(_card!.trustScore),
                      color: AppTheme.getTrustScoreColor(_card!.trustScore),
                      size: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
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
                      _card!.verificationLevel,
                      _card!.isCompanyVerified,
                    ),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Verification Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildVerificationItem(
                'Verification Level',
                _card!.verificationBadgeText,
                AppTheme.getVerificationColor(
                  _card!.verificationLevel,
                  _card!.isCompanyVerified,
                ),
              ),
              
              _buildVerificationItem(
                'Company Verified',
                _card!.isCompanyVerified ? 'Yes' : 'No',
                _card!.isCompanyVerified ? AppTheme.verifiedGreen : AppTheme.verifiedRed,
              ),
              
              _buildVerificationItem(
                'Created',
                _formatDate(_card!.createdAt),
                Colors.grey[600]!,
              ),
              
              if (_card!.expiryDate != null)
                _buildVerificationItem(
                  'Expires',
                  _formatDate(_card!.expiryDate!),
                  _card!.isExpired ? AppTheme.verifiedRed : Colors.grey[600]!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustRatings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.verifiedYellow,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Trust Ratings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Text(
                    '${_card!.customerRating!.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.verifiedYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < _card!.customerRating!.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: AppTheme.verifiedYellow,
                            size: 20,
                          );
                        }),
                      ),
                      Text(
                        '${_card!.totalRatings} ratings',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColleagueVerification() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    color: AppTheme.verifiedBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Colleague Verification',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Text(
                'Verified by ${_card!.verifiedByColleagues.length} colleagues',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.verifiedBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This person has been verified by their colleagues at ${_card!.companyName}.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _rateCard(),
              icon: const Icon(Icons.star),
              label: const Text('Rate Professional'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.verifiedYellow,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reportCard(),
                  icon: const Icon(Icons.flag),
                  label: const Text('Report'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareCard(),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('View Full Details'),
              onTap: () {
                Navigator.pop(context);
                _showFullDetailsModal();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View History'),
              onTap: () {
                Navigator.pop(context);
                context.push('/scan-history/${_card!.id}');
              },
            ),
            // Dynamic Block/Unblock based on current status
            FutureBuilder<bool>(
              future: _isCardBlocked(_card!.id),
              builder: (context, snapshot) {
                final isBlocked = snapshot.data ?? false;
                return ListTile(
                  leading: Icon(isBlocked ? Icons.block : Icons.block),
                  title: Text(isBlocked ? 'Unblock Card' : 'Block Card'),
                  onTap: () {
                    Navigator.pop(context);
                    isBlocked ? _unblockCard() : _blockCard();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _rateCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Professional'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How was your professional experience with this person?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _submitRating(index + 1);
                  },
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _submitRating(int rating) async {
    final success = await context.read<CardProvider>().rateCard(_card!.id, rating.toDouble());
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _reportCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Card'),
        content: const Text('Are you sure you want to report this card? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitReport();
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _submitReport() async {
    final success = await context.read<CardProvider>().reportCard(_card!.id, 'Inappropriate content');
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareCard() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
      ),
    );
  }

  void _showFullDetailsModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full Card Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', _card!.fullName),
              _buildDetailRow('Phone', _card!.phoneNumber),
              if (_card!.companyName != null && _card!.companyName!.isNotEmpty)
                _buildDetailRow('Company', _card!.companyName!),
              if (_card!.designation != null && _card!.designation!.isNotEmpty)
                _buildDetailRow('Designation', _card!.designation!),
              if (_card!.companyPhone != null && _card!.companyPhone!.isNotEmpty)
                _buildDetailRow('Company Phone', _card!.companyPhone!),
              if (_card!.companyEmail != null && _card!.companyEmail!.isNotEmpty)
                _buildDetailRow('Company Email', _card!.companyEmail!),
              if (_card!.workLocation != null && _card!.workLocation!.isNotEmpty)
                _buildDetailRow('Work Location', _card!.workLocation!),
              _buildDetailRow('Verification Level', _card!.verificationLevel.name),
              _buildDetailRow('Company Verified', _card!.isCompanyVerified ? 'Yes' : 'No'),
              if (_card!.customerRating != null)
                _buildDetailRow('Trust Score', '${_card!.customerRating!.toStringAsFixed(1)}/5.0'),
              if (_card!.totalRatings != null)
                _buildDetailRow('Total Ratings', _card!.totalRatings.toString()),
              _buildDetailRow('Created At', _formatDate(_card!.createdAt)),
              if (_card!.expiryDate != null)
                _buildDetailRow('Expiry Date', _formatDate(_card!.expiryDate!)),
              _buildDetailRow('Version', _card!.version.toString()),
              _buildDetailRow('Active', _card!.isActive ? 'Yes' : 'No'),
              if (_card!.verifiedByColleagues.isNotEmpty)
                _buildDetailRow('Verified By', '${_card!.verifiedByColleagues.length} colleagues'),
            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _isCardBlocked(String cardId) async {
    final currentUser = FirebaseService.getCurrentUser();
    if (currentUser == null) return false;

    return await BlockCardService.isCardBlocked(
      blockerId: currentUser.uid,
      blockedCardId: cardId,
    );
  }

  void _blockCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Card'),
        content: const Text('Are you sure you want to block this card? You won\'t be able to scan it again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _implementBlocking();
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _unblockCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock Card'),
        content: const Text('Are you sure you want to unblock this card? You\'ll be able to scan it again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _implementUnblocking();
            },
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  Future<void> _implementBlocking() async {
    final currentUser = FirebaseService.getCurrentUser();
    if (currentUser == null) return;

    try {
      final success = await BlockCardService.blockCard(
        blockerId: currentUser.uid,
        blockedCardId: _card!.id,
        blockedCardOwnerId: _card!.userId,
        reason: 'User blocked card',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card blocked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to block card. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error blocking card. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _implementUnblocking() async {
    final currentUser = FirebaseService.getCurrentUser();
    if (currentUser == null) return;

    try {
      final success = await BlockCardService.unblockCard(
        blockerId: currentUser.uid,
        blockedCardId: _card!.id,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card unblocked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to unblock card. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error unblocking card. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTrustScoreDescription(double score) {
    if (score >= 80) return 'Excellent trust level';
    if (score >= 60) return 'Good trust level';
    if (score >= 40) return 'Fair trust level';
    return 'Low trust level';
  }

  IconData _getTrustScoreIcon(double score) {
    if (score >= 80) return Icons.star;
    if (score >= 60) return Icons.thumb_up;
    if (score >= 40) return Icons.check_circle;
    return Icons.warning;
  }
}
