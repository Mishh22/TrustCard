import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();
  final _emailController = TextEditingController();
  final _stepsController = TextEditingController();
  String _selectedCategory = 'Bug Report';
  String _selectedPriority = 'Medium';
  bool _includeLogs = true;

  final List<String> _categories = [
    'Bug Report',
    'Feature Request',
    'Performance Issue',
    'UI/UX Problem',
    'Security Concern',
    'Other',
  ];

  final List<String> _priorities = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  @override
  void dispose() {
    _issueController.dispose();
    _emailController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Issue'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bug_report, color: AppTheme.primaryBlue, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Help Us Improve',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Report issues, bugs, or suggest new features to help us make TrustCard better.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Category Selection
              _buildSection(
                context,
                'Issue Category',
                Icons.category,
                [
                  _buildCategorySelector(),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Priority Selection
              _buildSection(
                context,
                'Priority Level',
                Icons.priority_high,
                [
                  _buildPrioritySelector(),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Contact Information
              _buildSection(
                context,
                'Contact Information',
                Icons.contact_mail,
                [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Your Email (Optional)',
                      hintText: 'your.email@example.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Issue Description
              _buildSection(
                context,
                'Issue Description',
                Icons.description,
                [
                  TextFormField(
                    controller: _issueController,
                    decoration: const InputDecoration(
                      labelText: 'Describe the issue',
                      hintText: 'Please provide a detailed description of the problem...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please describe the issue';
                      }
                      if (value.trim().length < 10) {
                        return 'Please provide more details (at least 10 characters)';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Steps to Reproduce
              _buildSection(
                context,
                'Steps to Reproduce',
                Icons.list_alt,
                [
                  TextFormField(
                    controller: _stepsController,
                    decoration: const InputDecoration(
                      labelText: 'How to reproduce this issue',
                      hintText: '1. Go to...\n2. Click on...\n3. Then...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.list),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Additional Options
              _buildSection(
                context,
                'Additional Options',
                Icons.settings,
                [
                  SwitchListTile(
                    title: const Text('Include App Logs'),
                    subtitle: const Text('Help us debug by including technical logs'),
                    value: _includeLogs,
                    onChanged: (value) {
                      setState(() {
                        _includeLogs = value;
                      });
                    },
                    activeColor: AppTheme.primaryBlue,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitReport,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Help Text
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
                        Icon(Icons.info, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for Better Reports',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Be specific about what happened\n• Include screenshots if possible\n• Mention your device and app version\n• Describe what you expected vs what happened',
                      style: TextStyle(color: Colors.blue[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPriority,
          isExpanded: true,
          items: _priorities.map((String priority) {
            Color priorityColor = _getPriorityColor(priority);
            return DropdownMenuItem<String>(
              value: priority,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(priority),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedPriority = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Get current user
        final user = FirebaseAuth.instance.currentUser;
        final userId = user?.uid ?? 'anonymous';
        
        // Create bug report data
        final bugReportData = {
          'userId': userId,
          'userEmail': _emailController.text.isNotEmpty ? _emailController.text : user?.email,
          'issue': _issueController.text.trim(),
          'steps': _stepsController.text.trim(),
          'category': _selectedCategory,
          'priority': _selectedPriority,
          'includeLogs': _includeLogs,
          'status': 'pending',
          'submittedAt': FieldValue.serverTimestamp(),
          'emailSent': false,
        };

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('bug_reports')
            .add(bugReportData);

        // Close loading dialog
        Navigator.pop(context);
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Report Submitted'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thank you for your feedback!'),
                const SizedBox(height: 8),
                Text('Category: $_selectedCategory'),
                Text('Priority: $_selectedPriority'),
                if (_emailController.text.isNotEmpty)
                  Text('We\'ll contact you at: ${_emailController.text}'),
                const SizedBox(height: 8),
                const Text('Your report has been saved and will be reviewed by our team. We\'ll get back to you soon.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to help center
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );

        // Clear form
        _issueController.clear();
        _emailController.clear();
        _stepsController.clear();
        setState(() {
          _selectedCategory = 'Bug Report';
          _selectedPriority = 'Medium';
          _includeLogs = true;
        });

      } catch (e) {
        // Close loading dialog
        Navigator.pop(context);
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Error'),
              ],
            ),
            content: Text('Failed to submit report: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }
}
