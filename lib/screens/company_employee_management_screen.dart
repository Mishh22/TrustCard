import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/card_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_card.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../services/employee_invitation_service.dart';
import '../utils/app_theme.dart';

class CompanyEmployeeManagementScreen extends StatefulWidget {
  const CompanyEmployeeManagementScreen({super.key});

  @override
  State<CompanyEmployeeManagementScreen> createState() => _CompanyEmployeeManagementScreenState();
}

class _CompanyEmployeeManagementScreenState extends State<CompanyEmployeeManagementScreen> {
  List<Employee> _employees = [];
  bool _isUploading = false;
  bool _isLoading = true;
  String? _companyId;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    print('🔄 Loading company data...');
    print('🔄 Current user: ${currentUser?.fullName}');
    print('🔄 Is company verified: ${currentUser?.isCompanyVerified}');
    print('🔄 Company ID: ${currentUser?.companyId}');
    
    if (currentUser != null && currentUser.isCompanyVerified) {
      setState(() {
        _companyId = currentUser.companyId;
      });
      print('✅ Company verified, loading employees...');
      _loadEmployees();
    } else {
      print('❌ Company not verified or user not found');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEmployees() async {
    if (_companyId == null) {
      print('❌ Company ID is null - cannot load employees');
      return;
    }

    print('🔄 Loading employees for company: $_companyId');
    try {
      final employees = await EmployeeService.getCompanyEmployees(_companyId!);
      print('🔄 Found ${employees.length} employees');
      for (var emp in employees) {
        print('  - ${emp.fullName} (${emp.employeeId})');
      }
      
      if (mounted) {
        setState(() {
          _employees = employees;
          _isLoading = false;
        });
        print('✅ Employee list updated in UI');
      }
    } catch (e) {
      print('❌ Error loading employees: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      // Today
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      // This week
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[date.weekday - 1]} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      // Older
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 BUILD: isLoading=$_isLoading, employees=${_employees.length}');
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _showUploadOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Company Info Header
          _buildCompanyHeader(),
          
          // Employee List
          Expanded(
            child: _employees.isEmpty
                ? _buildEmptyState()
                : _buildEmployeeList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEmployee,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.verifiedGold,
            Color(0xFFD97706),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Provider.of<AuthProvider>(context, listen: false).currentUser?.companyName != null
                      ? '${Provider.of<AuthProvider>(context, listen: false).currentUser!.companyName} - Employee Management'
                      : 'Employee Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_employees.length} employees managed',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'COMPANY VERIFIED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Employees Added',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add employees individually or upload a CSV file',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addEmployee,
              icon: const Icon(Icons.person_add),
              label: const Text('Add First Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _employees.length,
      itemBuilder: (context, index) {
        final employee = _employees[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: employee.profilePhoto != null
                  ? NetworkImage(employee.profilePhoto!)
                  : null,
              child: employee.profilePhoto == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              employee.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.designation),
                Text(employee.phoneNumber),
                if (employee.employeeId != null)
                  Text('ID: ${employee.employeeId}'),
                if (employee.invitationSentAt != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: employee.invitationStatus == 'sent' 
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: employee.invitationStatus == 'sent' 
                            ? Colors.orange
                            : Colors.green,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          employee.invitationStatus == 'sent' 
                              ? Icons.schedule
                              : Icons.check_circle,
                          size: 12,
                          color: employee.invitationStatus == 'sent' 
                              ? Colors.orange
                              : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          employee.invitationStatus == 'sent' 
                              ? 'Invitation sent on ${_formatDate(employee.invitationSentAt!)}'
                              : 'Invitation accepted on ${_formatDate(employee.invitationSentAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: employee.invitationStatus == 'sent' 
                                ? Colors.orange[700]
                                : Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'create_card',
                  child: const Row(
                    children: [
                      Icon(Icons.add_card, size: 18),
                      SizedBox(width: 8),
                      Text('Create TrustCard'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleEmployeeAction(value, employee),
            ),
          ),
        );
      },
    );
  }

  void _addEmployee() {
    if (_companyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Company ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _EmployeeFormDialog(
        companyId: _companyId!,
        onSave: (employee) async {
          print('🔄 SAVING EMPLOYEE: ${employee.fullName}');
          print('🔄 Company ID: ${employee.companyId}');
          print('🔄 Employee ID: ${employee.employeeId}');
          
          final success = await EmployeeService.addEmployee(employee);
          print('🔄 Save result: $success');
          
          if (success) {
            print('🔄 Refreshing employee list...');
            _loadEmployees();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${employee.fullName} added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            print('❌ FAILED TO SAVE EMPLOYEE');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to add employee'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Employee Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.upload_file, color: AppTheme.primaryBlue),
              title: const Text('Upload CSV File'),
              subtitle: const Text('Bulk upload employees from spreadsheet'),
              onTap: () {
                Navigator.pop(context);
                _uploadCSV();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: AppTheme.verifiedGreen),
              title: const Text('Add Individual Employee'),
              subtitle: const Text('Add one employee at a time'),
              onTap: () {
                Navigator.pop(context);
                _addEmployee();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _uploadCSV() {
    // TODO: Implement CSV upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV upload feature coming soon!'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _handleEmployeeAction(String action, Employee employee) {
    switch (action) {
      case 'edit':
        _editEmployee(employee);
        break;
      case 'create_card':
        _createEmployeeCard(employee);
        break;
      case 'delete':
        _deleteEmployee(employee);
        break;
    }
  }

  void _editEmployee(Employee employee) {
    if (_companyId == null) return;

    showDialog(
      context: context,
      builder: (context) => _EmployeeFormDialog(
        companyId: _companyId!,
        employee: employee,
        onSave: (updatedEmployee) async {
          final success = await EmployeeService.updateEmployee(updatedEmployee);
          if (success) {
            _loadEmployees();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${updatedEmployee.fullName} updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to update employee'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _createEmployeeCard(Employee employee) {
    // Create a UserCard for the employee
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    final userCard = UserCard(
      id: 'emp_${employee.id}',
      userId: currentUser?.id ?? 'unknown',
      fullName: employee.fullName,
      phoneNumber: employee.phoneNumber,
      companyName: currentUser?.companyName ?? 'Company',
      designation: employee.designation,
      companyId: employee.employeeId,
      verificationLevel: VerificationLevel.company,
      isCompanyVerified: true, // Auto-verified since created by company
      createdAt: DateTime.now(),
      version: 1,
      isActive: true,
      companyEmail: employee.email,
    );

    // TODO: Save to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('TrustCard created for ${employee.fullName}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteEmployee(Employee employee) {
    if (_companyId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to remove ${employee.fullName} from the company?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await EmployeeService.deleteEmployee(employee.id, _companyId!);
              if (success) {
                _loadEmployees();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${employee.fullName} removed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to remove employee'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _EmployeeFormDialog extends StatefulWidget {
  final String companyId;
  final Employee? employee;
  final Function(Employee) onSave;

  const _EmployeeFormDialog({
    required this.companyId,
    this.employee,
    required this.onSave,
  });

  @override
  State<_EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.fullName;
      _phoneController.text = widget.employee!.phoneNumber;
      _employeeIdController.text = widget.employee!.employeeId ?? '';
    }
  }
  
  void _generateEmployeeId() {
    // Generate unique employee ID
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final employeeId = 'EMP${timestamp.toString().substring(timestamp.toString().length - 8)}';
    setState(() {
      _employeeIdController.text = employeeId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  helperText: 'For admin reference only',
                ),
                validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  helperText: 'Employee will receive invitation SMS/WhatsApp',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty == true ? 'Phone is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _employeeIdController,
                decoration: InputDecoration(
                  labelText: 'Employee ID',
                  border: const OutlineInputBorder(),
                  helperText: 'Required for employee verification',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.auto_awesome),
                    tooltip: 'Generate Employee ID',
                    onPressed: _generateEmployeeId,
                  ),
                ),
                validator: (value) => value?.isEmpty == true ? 'Employee ID is required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveEmployee,
          child: Text(widget.employee == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      final createdAt = widget.employee?.createdAt ?? DateTime.now();
      final expiresAt = createdAt.add(const Duration(days: 7)); // 7-day expiry
      
      final employee = Employee(
        id: widget.employee?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        companyId: widget.companyId,
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        email: null, // Not collected in form
        designation: '', // Not collected in form
        employeeId: _employeeIdController.text,
        createdAt: createdAt,
        expiresAt: expiresAt,
        isActive: true,
        invitationSentAt: widget.employee == null ? DateTime.now() : widget.employee!.invitationSentAt,
        invitationStatus: widget.employee == null ? 'sent' : widget.employee!.invitationStatus,
      );
      
      // Send invitation for new employee BEFORE saving
      if (widget.employee == null) {
        final authProvider = context.read<AuthProvider>();
        final currentUser = authProvider.currentUser;
        
        print('🚀 SENDING EMPLOYEE INVITATION...');
        await EmployeeInvitationService.sendEmployeeInvitation(
          employeeId: employee.employeeId!,
          employeeName: employee.fullName,
          employeePhone: employee.phoneNumber,
          companyName: currentUser?.companyName ?? 'Company',
          adminName: currentUser?.fullName ?? 'Admin',
        );
        print('✅ EMPLOYEE INVITATION SENT');
      }
      
      // Save employee AFTER invitation - AWAIT the callback
      await widget.onSave(employee);
      
      // Close dialog ONLY after save completes
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

}
