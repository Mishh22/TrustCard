import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../widgets/digital_card_widget.dart';
import '../models/user_card.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import 'notification_center_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load cards when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Consumer2<AuthProvider, CardProvider>(
          builder: (context, authProvider, cardProvider, child) {
            if (authProvider.isLoading || cardProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (authProvider.error != null) {
              return _buildErrorWidget(authProvider.error!);
            }

            if (cardProvider.error != null) {
              return _buildErrorWidget(cardProvider.error!);
            }

            return _buildHomeContent(context, authProvider, cardProvider);
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, AuthProvider authProvider, CardProvider cardProvider) {
    return Container(
      color: AppTheme.backgroundLight,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height * 0.15, // Responsive height
          floating: false,
          pinned: true,
          backgroundColor: AppTheme.primaryBlue,
          elevation: 0,
          actions: [
            _buildCompanyAdminButton(context),
            _buildNotificationButton(context),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              'TrustCard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryLight,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Welcome Section
        SliverToBoxAdapter(
          child: Container(
            margin: ResponsiveHelper.getResponsiveMargin(context),
            padding: ResponsiveHelper.getResponsivePadding(context),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryBlue,
                  AppTheme.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your digital identity is secure and verified',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 400;
                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/scan'),
                            icon: Icon(Icons.qr_code_scanner, size: isSmallScreen ? 16 : 20),
                            label: Text(isSmallScreen ? 'Scan' : 'Scan Card'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryBlue,
                              padding: ResponsiveHelper.getResponsiveButtonPadding(context),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/create-card'),
                            icon: Icon(Icons.add, size: isSmallScreen ? 16 : 20),
                            label: Text(isSmallScreen ? 'Create' : 'Create Card'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 1.5),
                              padding: ResponsiveHelper.getResponsiveButtonPadding(context),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // My Cards Section
        SliverToBoxAdapter(
          child: Padding(
            padding: ResponsiveHelper.getResponsivePadding(context).copyWith(
              top: 0,
              bottom: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Cards',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Show all cards
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
        ),

        // Cards List
        if (cardProvider.cards.isEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: ResponsiveHelper.getResponsiveMargin(context),
              padding: ResponsiveHelper.getResponsivePadding(context),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.credit_card_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cards yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first digital ID card',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/create-card'),
                    child: const Text('Create Card'),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final card = cardProvider.cards[index];
                return Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: index == cardProvider.cards.length - 1 ? 16 : 8,
                  ),
                  child: GestureDetector(
                    onTap: () => context.push('/card-detail/${card.id}'),
                    child: DigitalCardWidget(
                      card: card,
                      showQR: false,
                      isCompact: true,
                    ),
                  ),
                );
              },
              childCount: cardProvider.cards.length,
            ),
          ),

        // Recent Scans Section
        if (cardProvider.scannedCards.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Scans',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Show all scanned cards
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),

        if (cardProvider.scannedCards.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final card = cardProvider.scannedCards[index];
                return Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: index == cardProvider.scannedCards.length - 1 ? 16 : 8,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: card.profilePhotoUrl != null
                            ? NetworkImage(card.profilePhotoUrl!)
                            : null,
                        child: card.profilePhotoUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(card.fullName),
                      subtitle: Text(card.companyName ?? 'Unknown Company'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.getVerificationColor(
                            card.verificationLevel,
                            card.isCompanyVerified,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          card.verificationBadgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () => context.push('/card-detail/${card.id}'),
                    ),
                  ),
                );
              },
              childCount: cardProvider.scannedCards.length,
            ),
          ),

        // Bottom padding to ensure content doesn't get cut off
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.bottom + 100, // Extra space for FAB
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Retry loading
                context.read<CardProvider>().loadCards();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyAdminButton(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            currentUser?.isCompanyVerified == true 
                ? Icons.business 
                : Icons.business_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            if (currentUser?.isCompanyVerified == true) {
              // User is verified, go to company admin dashboard
              context.push('/company-admin');
            } else {
              // User is not verified, go to verification request form
              context.push('/company-verification');
            }
          },
          tooltip: currentUser?.isCompanyVerified == true 
              ? 'Company Admin (Verified)' 
              : 'Company Verification (Pending)',
        ),
        if (currentUser?.isCompanyVerified == true)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return const SizedBox.shrink();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_notifications')
          .where('userId', isEqualTo: currentUser.id)
          .where('read', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data?.docs.length ?? 0;
        
        return Stack(
          children: [
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: const Icon(Icons.notifications, color: Colors.white),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

}
