import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/card_provider.dart';
import '../models/user_card.dart';
import '../utils/app_theme.dart';
import '../widgets/public_card_widget.dart';

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});

  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  MobileScannerController? controller;
  bool _isScanning = true;
  String? _lastScannedCode;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () async {
              await controller?.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () async {
              await controller?.switchCamera();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // QR Scanner
          Expanded(
            flex: 4,
            child: _isScanning
                ? MobileScanner(
                    controller: controller ??= MobileScannerController(),
                    onDetect: _onDetect,
                  )
                : _buildScanningDisabled(),
          ),
          
          // Instructions
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Reduced bottom padding
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 48,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan a TrustCard QR Code',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Point your camera at the QR code on the worker\'s digital ID card to verify their identity and see their trust level.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInstructionItem(
                          Icons.verified_user,
                          'Verify Identity',
                          'Check worker details',
                        ),
                        _buildInstructionItem(
                          Icons.security,
                          'Trust Level',
                          'See verification status',
                        ),
                        _buildInstructionItem(
                          Icons.rate_review,
                          'Rate Service',
                          'Help build trust',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // Add bottom spacing
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningDisabled() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Camera access required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please enable camera permission to scan QR codes',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String title, String description) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code != _lastScannedCode) {
        _lastScannedCode = code;
        _handleScannedCode(code);
      }
    }
  }

  Future<void> _handleScannedCode(String code) async {
    // Stop scanning temporarily
    setState(() {
      _isScanning = false;
    });

    try {
      // In a real app, you would decode the QR code data and fetch card details
      // For now, we'll simulate finding a card by ID
      final cardProvider = context.read<CardProvider>();
      
      // Simulate API call to get card details
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a mock scanned card (in real app, this would come from API)
      final scannedCard = UserCard(
        id: code,
        fullName: 'Rahul Kumar',
        phoneNumber: '+91 9876543210',
        companyName: 'Swiggy',
        designation: 'Delivery Partner',
        companyId: 'SWG12345',
        verificationLevel: VerificationLevel.document,
        isCompanyVerified: false,
        customerRating: 4.5,
        totalRatings: 120,
        verifiedByColleagues: ['colleague1', 'colleague2'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 60)),
        version: 1,
        isActive: true,
      );

      // Add to scanned cards
      await cardProvider.scanCard(scannedCard);

      if (mounted) {
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card scanned: ${scannedCard.fullName}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => _showScannedCard(scannedCard),
            ),
          ),
        );

        // Show privacy-respecting public card view
        _showScannedCard(scannedCard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan card: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Resume scanning after a delay
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isScanning = true;
              _lastScannedCode = null;
            });
          }
        });
      }
    }
  }

  void _showScannedCard(UserCard scannedCard) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Privacy notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This is a public view - personal details are protected',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Public card view (privacy-respecting)
                  PublicCardWidget(
                    card: scannedCard,
                    showQR: true,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactOptions(scannedCard);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.verifiedGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone, size: 16),
                              SizedBox(width: 4),
                              Text('Contact'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _shareCard(scannedCard);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share, size: 16),
                              SizedBox(width: 4),
                              Text('Share'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContactOptions(UserCard card) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact ${card.fullName}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: AppTheme.verifiedGreen),
              title: const Text('Call'),
              subtitle: Text(card.phoneNumber),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement phone call
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: AppTheme.primaryBlue),
              title: const Text('Send Message'),
              subtitle: const Text('Send SMS or WhatsApp'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement messaging
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.verifiedYellow),
              title: const Text('Email'),
              subtitle: Text(card.companyEmail ?? 'No email available'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement email
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareCard(UserCard card) {
    // TODO: Implement card sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card sharing feature coming soon!'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }
}
