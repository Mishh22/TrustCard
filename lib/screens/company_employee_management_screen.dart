import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/card_provider.dart';
import '../models/user_card.dart';
import '../utils/app_theme.dart';

class CompanyEmployeeManagementScreen extends StatefulWidget {
  const CompanyEmployeeManagementScreen({super.key});

  @override
  State<CompanyEmployeeManagementScreen> createState() => _CompanyEmployeeManagementScreenState();
}

class _CompanyEmployeeManagementScreenState extends State<CompanyEmployeeManagementScreen> {
  final List<EmployeeData> _employees = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
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
                  'Swiggy Employee Management',
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
    showDialog(
      context: context,
      builder: (context) => _EmployeeFormDialog(
        onSave: (employee) {
          setState(() {
            _employees.add(employee);
          });
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

  void _handleEmployeeAction(String action, EmployeeData employee) {
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

  void _editEmployee(EmployeeData employee) {
    showDialog(
      context: context,
      builder: (context) => _EmployeeFormDialog(
        employee: employee,
        onSave: (updatedEmployee) {
          setState(() {
            final index = _employees.indexWhere((e) => e.id == employee.id);
            if (index != -1) {
              _employees[index] = updatedEmployee;
            }
          });
        },
      ),
    );
  }

  void _createEmployeeCard(EmployeeData employee) {
    // Create a UserCard for the employee
    final userCard = UserCard(
      id: 'emp_${employee.id}',
      fullName: employee.fullName,
      phoneNumber: employee.phoneNumber,
      companyName: 'Swiggy',
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

  void _deleteEmployee(EmployeeData employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _employees.removeWhere((e) => e.id == employee.id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _EmployeeFormDialog extends StatefulWidget {
  final EmployeeData? employee;
  final Function(EmployeeData) onSave;

  const _EmployeeFormDialog({
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
  final _emailController = TextEditingController();
  final _designationController = TextEditingController();
  final _employeeIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.fullName;
      _phoneController.text = widget.employee!.phoneNumber;
      _emailController.text = widget.employee!.email ?? '';
      _designationController.text = widget.employee!.designation;
      _employeeIdController.text = widget.employee!.employeeId ?? '';
    }
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
                ),
                validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty == true ? 'Phone is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Designation is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _employeeIdController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID (Optional)',
                  border: OutlineInputBorder(),
                ),
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

  void _saveEmployee() {
    if (_formKey.currentState!.validate()) {
      final employee = EmployeeData(
        id: widget.employee?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        designation: _designationController.text,
        employeeId: _employeeIdController.text.isEmpty ? null : _employeeIdController.text,
      );
      
      widget.onSave(employee);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }
}

class EmployeeData {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String designation;
  final String? employeeId;
  final String? profilePhoto;

  EmployeeData({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    required this.designation,
    this.employeeId,
    this.profilePhoto,
  });
}
