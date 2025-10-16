import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/card_provider.dart';
import '../models/user_card.dart';
import '../utils/app_theme.dart';
import '../services/company_matching_service.dart';
import '../services/company_approval_service.dart';
import '../services/company_verification_service.dart';
import '../services/firebase_service.dart';
import '../models/company_details.dart';
import '../models/company_approval_request.dart';

/// Screen for users to request company verification for their specific cards
class CardVerificationRequestScreen extends StatefulWidget {
  const CardVerificationRequestScreen({super.key});

  @override
  State<CardVerificationRequestScreen> createState() => _CardVerificationRequestScreenState();
}

class _CardVerificationRequestScreenState extends State<CardVerificationRequestScreen> with SingleTickerProviderStateMixin {
  UserCard? _selectedCard;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _companyStatus;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserCards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cardProvider = context.read<CardProvider>();
      await cardProvider.loadCards();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load cards: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get cards that are eligible for company verification
  List<UserCard> _getEligibleCards(List<UserCard> cards) {
    return cards.where((card) => 
      card.companyName != null && 
      card.companyName!.isNotEmpty && 
      !card.isCompanyVerified &&
      !card.isDemoCard
    ).toList();
  }

  /// Check if a card has an existing request
  Future<CompanyApprovalRequest?> _getExistingRequest(String cardId) async {
    try {
      return await CompanyApprovalService.getApprovalRequestByCardId(cardId);
    } catch (e) {
      print('Error checking existing request: $e');
      return null;
    }
  }

  /// Check if the selected card's company is verified
  Future<void> _checkCompanyStatus() async {
    if (_selectedCard?.companyName == null) return;

    setState(() {
      _isLoading = true;
      _companyStatus = null;
    });

    try {
      print('🔍 Checking company: "${_selectedCard!.companyName!}"');
      
      // DIRECT DATABASE CHECK - Let's see what's actually in the database
      print('🔍 DIRECT DATABASE CHECK:');
      
      // Check company_details collection
      final companyDetailsQuery = await FirebaseFirestore.instance
          .collection('company_details')
          .where('companyName', isEqualTo: _selectedCard!.companyName!)
          .get();
      print('📊 company_details collection: ${companyDetailsQuery.docs.length} documents');
      for (var doc in companyDetailsQuery.docs) {
        print('📋 company_details: ${doc.id} - ${doc.data()}');
      }
      
      // Check users collection for company-verified users
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('companyName', isEqualTo: _selectedCard!.companyName!)
          .where('isCompanyVerified', isEqualTo: true)
          .get();
      print('📊 users collection (company-verified): ${usersQuery.docs.length} documents');
      for (var doc in usersQuery.docs) {
        print('📋 users: ${doc.id} - ${doc.data()}');
      }
      
      // Check new system first (company_details collection)
      final company = await CompanyMatchingService.findExistingCompany(_selectedCard!.companyName!);
      print('📊 New system result: ${company?.companyName} (verified: ${company?.isVerified}, hasAdmin: ${company?.hasAdmin})');
      print('📊 Company details: ${company?.toMap()}');
      
      // If company was found in users collection (old system), migrate it to new system
      if (company != null && company.adminUserId.isNotEmpty && !company.isVerified) {
        print('🔄 Migrating company from old system to new system...');
        await _migrateCompanyToNewSystem(company);
        print('✅ Company migration completed');
      }
      
      if (company != null && company.isVerified && company.hasAdmin) {
        // Company is verified in new system
        print('✅ Company verified in new system');
        setState(() {
          _companyStatus = 'verified';
        });
        return;
      }
      
      // Check old system (company_verification_requests collection)
      print('🔍 Checking old system...');
      final verificationRequestsStream = CompanyVerificationService.getAllRequests();
      final verificationRequests = await verificationRequestsStream.first;
      print('📊 Found ${verificationRequests.length} verification requests');
      
      // Print all company names for debugging
      for (var request in verificationRequests) {
        print('📋 Request: "${request.companyName}" (status: ${request.status.name})');
      }
      
      try {
        final verifiedCompany = verificationRequests.firstWhere(
          (request) => request.companyName.toLowerCase() == _selectedCard!.companyName!.toLowerCase() &&
                       request.status.name == 'approved',
        );
        
        // Company is verified in old system
        print('✅ Company verified in old system: ${verifiedCompany.companyName}');
        setState(() {
          _companyStatus = 'verified_old_system';
        });
        return;
      } catch (e) {
        print('❌ Company not found in old system: $e');
        // Company not found in old system, continue to check other conditions
      }
      
      // Company not found in either system
      print('❌ Company not found in either system');
      setState(() {
        if (company != null && !company.isVerified) {
          _companyStatus = 'unverified';
          print('📊 Status set to: unverified');
        } else {
          _companyStatus = 'not_found';
          print('📊 Status set to: not_found');
        }
      });
    } catch (e) {
      setState(() {
        _companyStatus = 'error';
        _errorMessage = 'Failed to check company status: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Migrate company from old system (users collection) to new system (company_details collection)
  Future<void> _migrateCompanyToNewSystem(CompanyDetails company) async {
    try {
      // Create company_details record
      await FirebaseFirestore.instance
          .collection('company_details')
          .doc(company.id)
          .set({
        'companyName': company.companyName,
        'canonicalCompanyName': company.canonicalCompanyName,
        'businessAddress': company.businessAddress,
        'phoneNumber': company.phoneNumber,
        'email': company.email,
        'contactPerson': company.contactPerson,
        'adminUserId': company.adminUserId,
        'employees': company.employees,
        'employeeCount': company.employeeCount,
        'createdAt': company.createdAt,
        'verifiedAt': DateTime.now(), // Mark as verified
        'isActive': true,
        'verificationStatus': 'verified',
      });
      
      print('✅ Company migrated to company_details collection');
    } catch (e) {
      print('❌ Error migrating company: $e');
    }
  }

  /// Submit verification request for the selected card
  Future<void> _submitVerificationRequest() async {
    if (_selectedCard == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final currentUser = FirebaseService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get company details
      final company = await CompanyMatchingService.findExistingCompany(_selectedCard!.companyName!);
      print('🔍 Submit - Company found: ${company?.companyName}');
      print('🔍 Submit - Company details: ${company?.toMap()}');
      
      if (company == null) {
        throw Exception('Company not found');
      }
      
      // For companies from users collection (old system), they are considered verified
      // For companies from company_details collection (new system), check isVerified and hasAdmin
      bool isCompanyVerified = false;
      String adminUserId = '';
      
      if (company.adminUserId.isNotEmpty) {
        // Company from users collection (old system) - always considered verified
        isCompanyVerified = true;
        adminUserId = company.adminUserId;
        print('✅ Using company from old system (users collection)');
      } else if (company.isVerified && company.hasAdmin) {
        // Company from company_details collection (new system)
        isCompanyVerified = true;
        adminUserId = company.adminUserId;
        print('✅ Using company from new system (company_details collection)');
      }
      
      if (!isCompanyVerified || adminUserId.isEmpty) {
        throw Exception('Company is not verified or has no admin');
      }

      // Check for existing request for this card
      final existingRequest = await CompanyApprovalService.getApprovalRequestByCardId(_selectedCard!.id);
      if (existingRequest != null) {
        String statusMessage = '';
        switch (existingRequest.status) {
          case CompanyApprovalStatus.pending:
            statusMessage = 'You already have a pending request for this card.';
            break;
          case CompanyApprovalStatus.approved:
            statusMessage = 'This card has already been approved by the company.';
            break;
          case CompanyApprovalStatus.rejected:
            statusMessage = 'Your previous request for this card was rejected. You can submit a new request.';
            break;
        }
        
        if (existingRequest.status != CompanyApprovalStatus.rejected) {
          throw Exception(statusMessage);
        }
      }

      // Create approval request
      final requestId = await CompanyApprovalService.createApprovalRequest(
        cardId: _selectedCard!.id,
        companyId: company.id,
        companyAdminId: adminUserId,
        requesterId: currentUser.uid,
        companyName: _selectedCard!.companyName!,
        requesterName: _selectedCard!.fullName,
        requesterPhone: _selectedCard!.phoneNumber,
        designation: _selectedCard!.designation,
      );

      if (requestId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification request submitted successfully!'),
              backgroundColor: AppTheme.verifiedGreen,
            ),
          );
          context.pop();
        }
      } else {
        throw Exception('Failed to create verification request');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit request: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Verification'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Submit Request'),
            Tab(text: 'My Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubmitRequestTab(),
          _buildMyRequestsTab(),
        ],
      ),
    );
  }

  Widget _buildSubmitRequestTab() {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        if (_isLoading && cardProvider.cards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_errorMessage != null) {
          return _buildErrorWidget();
        }

        final eligibleCards = _getEligibleCards(cardProvider.cards);

        if (eligibleCards.isEmpty) {
          return _buildNoEligibleCardsWidget();
        }

        return _buildCardSelectionWidget(eligibleCards);
      },
    );
  }

  Widget _buildMyRequestsTab() {
    final currentUser = FirebaseService.getCurrentUser();
    
    if (currentUser == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('User not authenticated'),
          ],
        ),
      );
    }

    return StreamBuilder<List<CompanyApprovalRequest>>(
      stream: CompanyApprovalService.getUserRequests(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading requests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pending_actions,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Requests Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You haven\'t submitted any company verification requests yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Trigger rebuild by calling setState
            // The StreamBuilder will automatically refresh
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _buildRequestCard(context, requests[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserCards,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoEligibleCardsWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Cards Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You need cards with company names to request verification.\nCreate a card first to get started.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/create-card'),
              child: const Text('Create Card'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSelectionWidget(List<UserCard> eligibleCards) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Card for Verification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a card that you want to get verified by your company.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Card selection
          ...eligibleCards.map((card) => _buildCardOptionWithStatus(card)),
          
          const SizedBox(height: 24),
          
          // Company status check
          if (_selectedCard != null) ...[
            _buildCompanyStatusSection(),
            const SizedBox(height: 24),
          ],
          
          // Submit button
          if (_selectedCard != null && (_companyStatus == 'verified' || _companyStatus == 'verified_old_system')) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitVerificationRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verifiedGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Submit Verification Request'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardOptionWithStatus(UserCard card) {
    return FutureBuilder<CompanyApprovalRequest?>(
      future: _getExistingRequest(card.id),
      builder: (context, snapshot) {
        final existingRequest = snapshot.data;
        return _buildCardOption(card, existingRequest);
      },
    );
  }

  Widget _buildCardOption(UserCard card, [CompanyApprovalRequest? existingRequest]) {
    final isSelected = _selectedCard?.id == card.id;
    final isDisabled = existingRequest != null && 
                      (existingRequest.status == CompanyApprovalStatus.pending || 
                       existingRequest.status == CompanyApprovalStatus.approved);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : 
               isDisabled ? Colors.grey[100] : null,
        child: InkWell(
          onTap: isDisabled ? null : () {
            setState(() {
              _selectedCard = card;
              _companyStatus = null;
            });
            _checkCompanyStatus();
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppTheme.primaryBlue : Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDisabled ? Colors.grey[500] : null,
                        ),
                      ),
                      if (card.companyName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          card.companyName!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDisabled ? Colors.grey[500] : AppTheme.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (existingRequest != null) ...[
                        const SizedBox(height: 8),
                        _buildRequestStatusChip(existingRequest.status),
                      ],
                      if (card.designation != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          card.designation!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryBlue,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_companyStatus) {
      case 'verified':
      case 'verified_old_system':
        return AppTheme.verifiedGreen;
      case 'unverified':
        return Colors.orange;
      case 'not_found':
        return Colors.red;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_companyStatus) {
      case 'verified':
      case 'verified_old_system':
        return Icons.verified;
      case 'unverified':
        return Icons.pending;
      case 'not_found':
        return Icons.business;
      case 'error':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusTitle() {
    switch (_companyStatus) {
      case 'verified':
        return 'Company Verified';
      case 'verified_old_system':
        return 'Company Verified (Legacy)';
      case 'unverified':
        return 'Company Not Verified';
      case 'not_found':
        return 'Company Not Found';
      case 'error':
        return 'Error Checking Company';
      default:
        return 'Checking Company Status...';
    }
  }

  String _getStatusDescription() {
    switch (_companyStatus) {
      case 'verified':
        return 'Your company is verified and has an admin. You can submit a verification request.';
      case 'verified_old_system':
        return 'Your company is verified in the legacy system. You can submit a verification request.';
      case 'unverified':
        return 'Your company exists but is not verified yet. Contact your company admin to get verified first.';
      case 'not_found':
        return 'This company is not registered in our system. Ask your company admin to register first.';
      case 'error':
        return 'Unable to check company status. Please try again.';
      default:
        return 'Checking if your company is verified...';
    }
  }

  Widget _buildRequestCard(BuildContext context, CompanyApprovalRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.companyName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (request.designation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            request.designation!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildRequestStatusChip(request.status),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Request details
              _buildDetailRow(
                context,
                Icons.access_time,
                'Submitted',
                _formatDate(request.createdAt),
              ),
              
              if (request.reviewedAt != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  Icons.check_circle,
                  'Reviewed',
                  _formatDate(request.reviewedAt!),
                ),
              ],
              
              if (request.rejectionReason != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  Icons.info_outline,
                  'Reason',
                  request.rejectionReason!,
                  color: Colors.red[600],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Status description
              Text(
                _getRequestStatusDescription(request.status),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getRequestStatusColor(request.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestStatusChip(CompanyApprovalStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRequestStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getRequestStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRequestStatusIcon(status),
            size: 16,
            color: _getRequestStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            _getRequestStatusText(status),
            style: TextStyle(
              color: _getRequestStatusColor(status),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Color _getRequestStatusColor(CompanyApprovalStatus status) {
    switch (status) {
      case CompanyApprovalStatus.pending:
        return Colors.orange;
      case CompanyApprovalStatus.approved:
        return AppTheme.verifiedGreen;
      case CompanyApprovalStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getRequestStatusIcon(CompanyApprovalStatus status) {
    switch (status) {
      case CompanyApprovalStatus.pending:
        return Icons.pending;
      case CompanyApprovalStatus.approved:
        return Icons.check_circle;
      case CompanyApprovalStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getRequestStatusText(CompanyApprovalStatus status) {
    switch (status) {
      case CompanyApprovalStatus.pending:
        return 'Pending';
      case CompanyApprovalStatus.approved:
        return 'Approved';
      case CompanyApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  String _getRequestStatusDescription(CompanyApprovalStatus status) {
    switch (status) {
      case CompanyApprovalStatus.pending:
        return 'Your request is being reviewed by the company admin.';
      case CompanyApprovalStatus.approved:
        return 'Your card has been verified by the company.';
      case CompanyApprovalStatus.rejected:
        return 'Your request was not approved by the company.';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
