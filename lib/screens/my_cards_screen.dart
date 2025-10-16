import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/card_provider.dart';
import '../models/user_card.dart';
import '../widgets/digital_card_widget.dart';
import '../utils/app_theme.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
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
      appBar: AppBar(
        title: const Text('My Cards'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push('/create-card'),
            icon: const Icon(Icons.add),
            tooltip: 'Create New Card',
          ),
        ],
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          if (cardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cardProvider.error != null) {
            return _buildErrorWidget(cardProvider.error!);
          }

          if (cardProvider.cards.isEmpty) {
            return _buildEmptyState();
          }

          return _buildCardsList(cardProvider);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Cards Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first digital ID card to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/create-card'),
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsList(CardProvider cardProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cardProvider.cards.length,
      itemBuilder: (context, index) {
        final card = cardProvider.cards[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              // Card Widget
              GestureDetector(
                onTap: () => context.push('/card-detail/${card.id}'),
                child: DigitalCardWidget(
                  card: card,
                  showQR: false,
                  isCompact: false,
                ),
              ),
              
              // Delete Button (positioned on top-right)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _showDeleteConfirmation(context, card),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                context.read<CardProvider>().clearError();
                context.read<CardProvider>().loadCards();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text(
          'Are you sure you want to delete "${card.fullName}" card? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get the parent context before closing the dialog
              final parentContext = Navigator.of(context).context;
              Navigator.of(context).pop();
              
              // Show loading
              showDialog(
                context: parentContext,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final cardProvider = Provider.of<CardProvider>(parentContext, listen: false);
                final success = await cardProvider.deleteCard(card.id);
                
                if (mounted) {
                  Navigator.of(parentContext).pop(); // Close loading dialog
                  
                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text('Card "${card.fullName}" deleted successfully'),
                          backgroundColor: AppTheme.verifiedGreen,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete card: ${cardProvider.error ?? "Unknown error"}'),
                          backgroundColor: AppTheme.error,
                        ),
                      );
                    }
                  }
                }
              } catch (e) {
                  if (mounted) {
                    Navigator.of(parentContext).pop(); // Close loading dialog
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting card: ${e.toString()}'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
