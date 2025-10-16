import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../providers/card_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_card.dart';
import '../models/verification_request.dart';
import '../services/verification_request_service.dart';
import '../widgets/contact_picker_dialog.dart';
import '../utils/app_theme.dart';

class ColleagueVerificationScreen extends StatefulWidget {
  const ColleagueVerificationScreen({super.key});

  @override
  State<ColleagueVerificationScreen> createState() => _ColleagueVerificationScreenState();
}

class _ColleagueVerificationScreenState extends State<ColleagueVerificationScreen> {
  final List<Map<String, String>> _colleagues = []; // {phone, name}
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colleague Verification'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitVerification,
            child: const Text('Submit'),
          ),
        ],
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.verifiedBlue,
                    Color(0xFF2563EB),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peer Verification',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Get verified by your colleagues',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // How it works
            _buildHowItWorks(),
            
            const SizedBox(height: 24),
            
            // Add Colleagues
            _buildAddColleagues(),
            
            const SizedBox(height: 24),
            
            // Verification Requests
            _buildVerificationRequests(),
            
            const SizedBox(height: 24),
            
            // Added Colleagues
            if (_colleagues.isNotEmpty) _buildAddedColleagues(),
            
            const SizedBox(height: 24),
            
            // Benefits
            _buildBenefits(),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How Peer Verification Works',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildStepItem(
              '1',
              'Add Colleagues',
              'Add phone numbers of 2-3 colleagues from your company',
              Icons.person_add,
            ),
            
            _buildStepItem(
              '2',
              'Send Invitations',
              'We\'ll send them a verification request via SMS',
              Icons.send,
            ),
            
            _buildStepItem(
              '3',
              'Get Verified',
              'Once they confirm, you get the "Peer Verified" badge',
              Icons.verified,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.verifiedBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            icon,
            color: AppTheme.verifiedBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
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
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddColleagues() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Colleagues',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Contact picker button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickContacts,
                icon: const Icon(Icons.contacts),
                label: const Text('Select from Contacts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verifiedBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.verifiedBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.verifiedBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.verifiedBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add at least 2 colleagues from the same company to get verified',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.verifiedBlue,
                      ),
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

  Widget _buildAddedColleagues() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Added Colleagues (${_colleagues.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._colleagues.map((colleague) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.verifiedBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.verifiedBlue,
                    size: 20,
                  ),
                ),
                title: Text(colleague['name'] ?? 'Unknown'),
                subtitle: Text(colleague['phone'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeColleague(colleague['phone']!),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefits() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.verifiedBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.verifiedBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppTheme.verifiedBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Benefits of Peer Verification',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.verifiedBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildBenefitItem(
            'Community Trust',
            'Verified by people who know you personally',
          ),
          _buildBenefitItem(
            'Blue Verification Badge',
            'Get the "Peer Verified" badge on your card',
          ),
          _buildBenefitItem(
            'Higher Trust Score',
            'Significantly increases your trust level',
          ),
          _buildBenefitItem(
            'Network Effect',
            'Helps build a trusted network of workers',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.verifiedBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickContacts() async {
    try {
      // Check if permission is already granted
      final permission = await FlutterContacts.requestPermission();
      
      if (!permission) {
        // Show permission dialog with explanation
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Contacts Permission Required'),
              content: const Text(
                'To select colleagues from your contacts, please allow access to your contacts. This helps you quickly add colleagues for verification.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Try again after user acknowledges
                    _pickContacts();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final contacts = await FlutterContacts.getContacts(withProperties: true);
      
      if (contacts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No contacts found on your device'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show contact picker dialog
      final selectedContacts = await showDialog<List<Contact>>(
        context: context,
        builder: (context) => ContactPickerDialog(contacts: contacts),
      );

      if (selectedContacts != null && selectedContacts.isNotEmpty) {
        for (final contact in selectedContacts) {
          final phone = contact.phones.isNotEmpty 
              ? contact.phones.first.number
              : '';
          final name = contact.displayName;
          
          if (phone.isNotEmpty && !_colleagues.any((c) => c['phone'] == phone)) {
            _colleagues.add({'name': name, 'phone': phone});
          }
        }
        
        setState(() {});
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${selectedContacts.length} colleagues'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accessing contacts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _removeColleague(String phone) {
    setState(() {
      _colleagues.removeWhere((c) => c['phone'] == phone);
    });
  }

  Future<void> _submitVerification() async {
    if (_colleagues.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least 2 colleagues'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send verification requests to all colleagues
      int successCount = 0;
      for (final colleague in _colleagues) {
        final success = await VerificationRequestService.sendVerificationRequest(
          colleaguePhone: colleague['phone']!,
          colleagueName: colleague['name']!,
        );
        if (success) successCount++;
      }
      
      if (successCount > 0) {
        // Update user's verification level
        final authProvider = context.read<AuthProvider>();
        final cardProvider = context.read<CardProvider>();
        
        if (authProvider.currentUser != null) {
          final colleaguePhones = _colleagues.map((c) => c['phone']!).toList();
          final updatedCard = authProvider.currentUser!.copyWith(
            verificationLevel: VerificationLevel.peer,
            verifiedByColleagues: colleaguePhones,
          );
          
          await cardProvider.updateCard(updatedCard);
          await authProvider.updateProfile();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification requests sent to $successCount colleagues!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send verification requests. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit verification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildVerificationRequests() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.verifiedBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Requests',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View and respond to verification requests from colleagues',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/pending-verification'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View Requests'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.verifiedBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
