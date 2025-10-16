import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/company_verification_request.dart';
import '../models/company_details.dart';
import 'company_matching_service.dart';

class CompanyVerificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Submit company verification request
  static Future<String> submitVerificationRequest({
    required String userId,
    required String companyName,
    required String businessAddress,
    required String phoneNumber,
    required String email,
    required String contactPerson,
    required File businessPhoto,
    String? panNumber,
    String? gstNumber,
    File? gstCertificate,
    File? panCertificate,
  }) async {
    try {
      // Generate unique request ID
      final requestId = _firestore.collection('company_verification_requests').doc().id;
      
      // Upload photos to Firebase Storage
      final businessPhotoUrl = await _uploadPhoto(businessPhoto, 'business_$requestId');
      String? gstCertificateUrl;
      String? panCertificateUrl;
      
      if (gstCertificate != null) {
        gstCertificateUrl = await _uploadPhoto(gstCertificate, 'gst_$requestId');
      }
      if (panCertificate != null) {
        panCertificateUrl = await _uploadPhoto(panCertificate, 'pan_$requestId');
      }
      
      // Create verification request
      final request = CompanyVerificationRequest(
        id: requestId,
        userId: userId,
        companyName: companyName,
        businessAddress: businessAddress,
        phoneNumber: phoneNumber,
        email: email,
        contactPerson: contactPerson,
        businessPhotoUrl: businessPhotoUrl,
        gstNumber: gstNumber,
        panNumber: panNumber,
        gstCertificateUrl: gstCertificateUrl,
        panCertificateUrl: panCertificateUrl,
        status: CompanyVerificationStatus.pending,
        submittedAt: DateTime.now(),
      );
      
      // Save to Firestore
      // This will automatically trigger the Firebase Function to send email to info@accexasia.com
      await _firestore
          .collection('company_verification_requests')
          .doc(requestId)
          .set(request.toMap());
      
      // Log submission activity
      await _firestore.collection('activityLogs').add({
        'userId': userId,
        'type': 'company_verification_request',
        'title': 'Company Verification Request Submitted',
        'details': 'You submitted a company verification request for $companyName',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
        'data': {
          'requestId': requestId,
          'companyName': companyName,
          'submittedAt': FieldValue.serverTimestamp(),
        },
      });
      
      print('Company verification request submitted: $requestId');
      print('Email will be sent automatically to info@accexasia.com');
      
      return requestId;
    } catch (e) {
      print('Error submitting verification request: $e');
      rethrow;
    }
  }

  // Upload photo to Firebase Storage
  static Future<String> _uploadPhoto(File photo, String fileName) async {
    try {
      final ref = _storage.ref().child('company_verification/$fileName');
      final uploadTask = await ref.putFile(photo);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading photo: $e');
      rethrow;
    }
  }

  // Get user's verification request status
  static Future<CompanyVerificationRequest?> getUserVerificationRequest(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('company_verification_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return CompanyVerificationRequest.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user verification request: $e');
      return null;
    }
  }

  // Stream user's verification request status (for real-time updates)
  static Stream<CompanyVerificationRequest?> getUserVerificationRequestStream(String userId) {
    return _firestore
        .collection('company_verification_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return CompanyVerificationRequest.fromMap(doc.data(), doc.id);
      }
      return null;
    });
  }

  // Check if user has pending verification request
  static Future<bool> hasPendingRequest(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('company_verification_requests')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: CompanyVerificationStatus.pending.name)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking pending request: $e');
      return false;
    }
  }

  // Get all pending verification requests (for admin)
  static Stream<List<CompanyVerificationRequest>> getPendingRequests() {
    return _firestore
        .collection('company_verification_requests')
        .where('status', isEqualTo: CompanyVerificationStatus.pending.name)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CompanyVerificationRequest.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get all verification requests (for admin)
  static Stream<List<CompanyVerificationRequest>> getAllRequests() {
    return _firestore
        .collection('company_verification_requests')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CompanyVerificationRequest.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Approve verification request (admin function)
  static Future<bool> approveRequest({
    required String requestId,
    required String reviewedBy,
  }) async {
    try {
      // Get the request
      final requestDoc = await _firestore
          .collection('company_verification_requests')
          .doc(requestId)
          .get();
      
      if (!requestDoc.exists) return false;
      
      final request = CompanyVerificationRequest.fromMap(requestDoc.data()!, requestId);
      
      // Update request status
      await _firestore
          .collection('company_verification_requests')
          .doc(requestId)
          .update({
        'status': CompanyVerificationStatus.approved.name,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': reviewedBy,
      });
      
      // Update user's company verification status
      await _firestore
          .collection('users')
          .doc(request.userId)
          .update({
        'isCompanyVerified': true,
        'companyId': requestId,
        'companyName': request.companyName,
      });
      
      // Create company details record
      await _createCompanyDetails(request, requestId);
      
      return true;
    } catch (e) {
      print('Error approving request: $e');
      return false;
    }
  }

  // Reject verification request (admin function)
  static Future<bool> rejectRequest({
    required String requestId,
    required String reviewedBy,
    required String rejectionReason,
  }) async {
    try {
      await _firestore
          .collection('company_verification_requests')
          .doc(requestId)
          .update({
        'status': CompanyVerificationStatus.rejected.name,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': reviewedBy,
        'rejectionReason': rejectionReason,
      });
      
      return true;
    } catch (e) {
      print('Error rejecting request: $e');
      return false;
    }
  }

  // Withdraw verification request (user function)
  static Future<bool> withdrawRequest({
    required String requestId,
    required String userId,
  }) async {
    try {
      // Get the request to verify ownership
      final requestDoc = await _firestore
          .collection('company_verification_requests')
          .doc(requestId)
          .get();
      
      if (!requestDoc.exists) return false;
      
      final request = CompanyVerificationRequest.fromMap(requestDoc.data()!, requestId);
      
      // Verify the user owns this request
      if (request.userId != userId) return false;
      
      // Only allow withdrawal if status is pending
      if (request.status != CompanyVerificationStatus.pending) return false;
      
      // Update request status to withdrawn
      await _firestore
          .collection('company_verification_requests')
          .doc(requestId)
          .update({
        'status': CompanyVerificationStatus.withdrawn.name,
        'withdrawnAt': FieldValue.serverTimestamp(),
        'withdrawnBy': userId,
      });
      
      // Log withdrawal activity
      await _firestore.collection('activityLogs').add({
        'userId': userId,
        'type': 'company_verification_withdrawal',
        'title': 'Company Verification Withdrawn',
        'description': 'You withdrew your company verification request for ${request.companyName}',
        'timestamp': FieldValue.serverTimestamp(),
        'data': {
          'requestId': requestId,
          'companyName': request.companyName,
          'withdrawnAt': FieldValue.serverTimestamp(),
        },
      });
      
      return true;
    } catch (e) {
      print('Error withdrawing request: $e');
      return false;
    }
  }

  // Create company details record
  static Future<void> _createCompanyDetails(CompanyVerificationRequest request, String companyId) async {
    final companyDetails = CompanyDetails(
      id: companyId,
      companyName: request.companyName,
      canonicalCompanyName: CompanyMatchingService.canonicalizeCompanyName(request.companyName),
      businessAddress: request.businessAddress,
      phoneNumber: request.phoneNumber,
      email: request.email,
      contactPerson: request.contactPerson,
      adminUserId: request.userId,
      employees: [request.userId], // Add the admin as first employee
      employeeCount: 1,
      createdAt: DateTime.now(),
      verifiedAt: DateTime.now(),
      isActive: true,
      gstNumber: request.gstNumber,
      panNumber: request.panNumber,
      verificationStatus: CompanyStatus.verified, // Mark as verified
    );
    
    await _firestore
        .collection('company_details')
        .doc(companyId)
        .set(companyDetails.toMap());
  }

  // Get company details
  static Future<CompanyDetails?> getCompanyDetails(String companyId) async {
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
      print('Error getting company details: $e');
      return null;
    }
  }

  // Add employee to company
  static Future<bool> addEmployeeToCompany({
    required String companyId,
    required String employeeUserId,
  }) async {
    try {
      await _firestore
          .collection('company_details')
          .doc(companyId)
          .update({
        'employees': FieldValue.arrayUnion([employeeUserId]),
      });
      
      return true;
    } catch (e) {
      print('Error adding employee: $e');
      return false;
    }
  }

  // Remove employee from company
  static Future<bool> removeEmployeeFromCompany({
    required String companyId,
    required String employeeUserId,
  }) async {
    try {
      await _firestore
          .collection('company_details')
          .doc(companyId)
          .update({
        'employees': FieldValue.arrayRemove([employeeUserId]),
      });
      
      return true;
    } catch (e) {
      print('Error removing employee: $e');
      return false;
    }
  }

  // Change verification request status (admin function)
  static Future<bool> changeRequestStatus({
    required String requestId,
    required String newStatus,
    required String reviewedBy,
    String? reason,
  }) async {
    try {
      await _firestore
          .collection('company_verification_requests')
          .doc(requestId)
          .update({
        'status': newStatus,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': reviewedBy,
        if (reason != null) 'rejectionReason': reason,
        'lastModifiedAt': FieldValue.serverTimestamp(),
      });
      
      // Log status change for audit trail
      await _firestore.collection('audit_logs').add({
        'action': 'status_change',
        'requestId': requestId,
        'newStatus': newStatus,
        'performedBy': reviewedBy,
        'timestamp': FieldValue.serverTimestamp(),
        if (reason != null) 'reason': reason,
      });
      
      return true;
    } catch (e) {
      print('Error changing status: $e');
      return false;
    }
  }
}
