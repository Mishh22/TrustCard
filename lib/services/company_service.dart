import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_details.dart';
import 'company_matching_service.dart';
import 'company_approval_service.dart';

/// Comprehensive service for managing companies
/// Handles creation, verification, employee tracking, and company lifecycle
class CompanyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Find or create company when user creates a card
  /// This is the central method that handles all company logic
  static Future<CompanyDetails> findOrCreateCompany({
    required String companyName,
    required String userId,
    String? userFullName,
    String? userPhone,
  }) async {
    try {
      // Step 1: Try to find existing company
      final existingCompany = await CompanyMatchingService.findExistingCompany(companyName);
      
      if (existingCompany != null) {
        print('Found existing company: ${existingCompany.companyName} (Status: ${existingCompany.verificationStatus.name})');
        
        // Step 2: Add user to company's employee list if not already added
        await _addEmployeeToCompany(existingCompany.id, userId);
        
        return existingCompany;
      }
      
      // Step 3: Company not found, create new unverified company
      print('Creating new unverified company: $companyName');
      return await _createUnverifiedCompany(
        companyName: companyName,
        firstEmployeeId: userId,
        contactPerson: userFullName ?? '',
        phoneNumber: userPhone ?? '',
      );
    } catch (e) {
      print('Error in findOrCreateCompany: $e');
      rethrow;
    }
  }

  /// Create a new unverified company
  static Future<CompanyDetails> _createUnverifiedCompany({
    required String companyName,
    required String firstEmployeeId,
    String contactPerson = '',
    String phoneNumber = '',
  }) async {
    try {
      final companyId = _firestore.collection('company_details').doc().id;
      final canonicalName = CompanyMatchingService.canonicalizeCompanyName(companyName);
      
      final company = CompanyDetails(
        id: companyId,
        companyName: companyName,
        canonicalCompanyName: canonicalName,
        businessAddress: '',
        phoneNumber: phoneNumber,
        email: '',
        contactPerson: contactPerson,
        adminUserId: '', // No admin yet for unverified company
        employees: [firstEmployeeId],
        employeeCount: 1,
        createdAt: DateTime.now(),
        isActive: true,
        verificationStatus: CompanyStatus.unverified,
      );
      
      await _firestore
          .collection('company_details')
          .doc(companyId)
          .set(company.toMap());
      
      // Log activity
      await _logActivity(
        type: 'company_created',
        title: 'New Company Created',
        details: 'Company "$companyName" created (unverified) with first employee',
        data: {
          'companyId': companyId,
          'companyName': companyName,
          'firstEmployeeId': firstEmployeeId,
        },
      );
      
      print('Created unverified company: $companyId - $companyName');
      return company;
    } catch (e) {
      print('Error creating unverified company: $e');
      rethrow;
    }
  }

  /// Add employee to existing company
  static Future<void> _addEmployeeToCompany(String companyId, String userId) async {
    try {
      final companyDoc = await _firestore
          .collection('company_details')
          .doc(companyId)
          .get();
      
      if (!companyDoc.exists) {
        print('Company not found: $companyId');
        return;
      }
      
      final employees = List<String>.from(companyDoc.data()?['employees'] ?? []);
      
      // Check if user is already an employee
      if (employees.contains(userId)) {
        print('User $userId is already an employee of company $companyId');
        return;
      }
      
      // Add user to employees
      await _firestore
          .collection('company_details')
          .doc(companyId)
          .update({
        'employees': FieldValue.arrayUnion([userId]),
        'employeeCount': FieldValue.increment(1),
      });
      
      print('Added user $userId to company $companyId');
    } catch (e) {
      print('Error adding employee to company: $e');
    }
  }

  /// Verify company (called when admin approval happens)
  static Future<bool> verifyCompany({
    required String companyId,
    required String adminUserId,
    String? businessAddress,
    String? phoneNumber,
    String? email,
    String? gstNumber,
    String? panNumber,
  }) async {
    try {
      final updateData = {
        'verificationStatus': CompanyStatus.verified.name,
        'adminUserId': adminUserId,
        'verifiedAt': FieldValue.serverTimestamp(),
      };
      
      // Add optional fields if provided
      if (businessAddress != null) updateData['businessAddress'] = businessAddress;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (email != null) updateData['email'] = email;
      if (gstNumber != null) updateData['gstNumber'] = gstNumber;
      if (panNumber != null) updateData['panNumber'] = panNumber;
      
      await _firestore
          .collection('company_details')
          .doc(companyId)
          .update(updateData);
      
      // Log activity
      await _logActivity(
        type: 'company_verified',
        title: 'Company Verified',
        details: 'Company verified by admin',
        data: {
          'companyId': companyId,
          'adminUserId': adminUserId,
        },
      );
      
      print('Company $companyId verified by admin $adminUserId');
      return true;
    } catch (e) {
      print('Error verifying company: $e');
      return false;
    }
  }

  /// Get company details by ID
  static Future<CompanyDetails?> getCompanyById(String companyId) async {
    try {
      final doc = await _firestore
          .collection('company_details')
          .doc(companyId)
          .get();
      
      if (doc.exists) {
        return CompanyDetails.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting company by ID: $e');
      return null;
    }
  }

  /// Get all employees for a company
  static Future<List<String>> getCompanyEmployees(String companyId) async {
    try {
      final doc = await _firestore
          .collection('company_details')
          .doc(companyId)
          .get();
      
      if (doc.exists) {
        return List<String>.from(doc.data()?['employees'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting company employees: $e');
      return [];
    }
  }

  /// Get employee count for a company
  static Future<int> getCompanyEmployeeCount(String companyId) async {
    try {
      final doc = await _firestore
          .collection('company_details')
          .doc(companyId)
          .get();
      
      if (doc.exists) {
        return doc.data()?['employeeCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting company employee count: $e');
      return 0;
    }
  }

  /// Remove employee from company
  static Future<bool> removeEmployeeFromCompany({
    required String companyId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('company_details')
          .doc(companyId)
          .update({
        'employees': FieldValue.arrayRemove([userId]),
        'employeeCount': FieldValue.increment(-1),
      });
      
      print('Removed user $userId from company $companyId');
      return true;
    } catch (e) {
      print('Error removing employee from company: $e');
      return false;
    }
  }

  /// Deactivate company
  static Future<bool> deactivateCompany(String companyId) async {
    try {
      await _firestore
          .collection('company_details')
          .doc(companyId)
          .update({
        'isActive': false,
      });
      
      // Log activity
      await _logActivity(
        type: 'company_deactivated',
        title: 'Company Deactivated',
        details: 'Company marked as inactive',
        data: {'companyId': companyId},
      );
      
      print('Company $companyId deactivated');
      return true;
    } catch (e) {
      print('Error deactivating company: $e');
      return false;
    }
  }

  /// Get all unverified companies (for admin review)
  static Future<List<CompanyDetails>> getUnverifiedCompanies({int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('company_details')
          .where('verificationStatus', isEqualTo: CompanyStatus.unverified.name)
          .where('isActive', isEqualTo: true)
          .orderBy('employeeCount', descending: true) // Companies with more employees first
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CompanyDetails.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting unverified companies: $e');
      return [];
    }
  }

  /// Get all verified companies
  static Future<List<CompanyDetails>> getVerifiedCompanies({int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('company_details')
          .where('verificationStatus', isEqualTo: CompanyStatus.verified.name)
          .where('isActive', isEqualTo: true)
          .orderBy('employeeCount', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => CompanyDetails.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting verified companies: $e');
      return [];
    }
  }

  /// Stream company details (real-time updates)
  static Stream<CompanyDetails?> streamCompanyDetails(String companyId) {
    return _firestore
        .collection('company_details')
        .doc(companyId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return CompanyDetails.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  /// Log activity to Firestore
  static Future<void> _logActivity({
    required String type,
    required String title,
    required String details,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('activityLogs').add({
        'type': type,
        'title': title,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'data': data,
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }
}

