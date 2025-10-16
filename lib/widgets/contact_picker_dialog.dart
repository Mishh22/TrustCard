import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../utils/app_theme.dart';

class ContactPickerDialog extends StatefulWidget {
  final List<Contact> contacts;

  const ContactPickerDialog({
    super.key,
    required this.contacts,
  });

  @override
  State<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  final List<Contact> _selectedContacts = [];
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredContacts = widget.contacts;
      } else {
        _filteredContacts = widget.contacts.where((contact) {
          final name = contact.displayName?.toLowerCase() ?? '';
          final searchText = _searchController.text.toLowerCase();
          return name.contains(searchText);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.verifiedBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.contacts,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select Colleagues',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            // Selected contacts count
            if (_selectedContacts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.verifiedBlue.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.verifiedBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedContacts.length} contact${_selectedContacts.length == 1 ? '' : 's'} selected',
                      style: TextStyle(
                        color: AppTheme.verifiedBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Contacts list
            Expanded(
              child: ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  final isSelected = _selectedContacts.contains(contact);
                  final hasPhone = contact.phones.isNotEmpty;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected 
                          ? AppTheme.verifiedBlue 
                          : Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                    title: Text(
                      contact.displayName ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: hasPhone 
                        ? Text(contact.phones.first.number)
                        : const Text('No phone number', style: TextStyle(color: Colors.red)),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppTheme.verifiedBlue,
                          )
                        : null,
                    enabled: hasPhone,
                    onTap: hasPhone ? () => _toggleContact(contact) : null,
                  );
                },
              ),
            ),
            
            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedContacts.isNotEmpty 
                          ? () => Navigator.of(context).pop(_selectedContacts)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.verifiedBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Select (${_selectedContacts.length})'),
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

  void _toggleContact(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }
}
