import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_verification_request.dart';
import '../models/company_details.dart';
import 'company_matching_service.dart';

class ManualApprovalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Manually approve a company verification request
  static Future<bool> approveUserVerification(String userId) async {
    try {
      // Find the user's verification request
      final querySnapshot = await _firestore
          .collection('company_verification_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No verification request found for user: $userId');
        return false;
      }

      final requestDoc = querySnapshot.docs.first;
      final requestId = requestDoc.id;
      final request = CompanyVerificationRequest.fromMap(requestDoc.data(), requestId);

      print('Found verification request: $requestId for company: ${request.companyName}');

      // Update request status to approved
      await _firestore
          .collection('company_verification_requests')
          .doc(requestId)
          .update({
        'status': CompanyVerificationStatus.approved.name,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': 'manual_approval',
      });

      // Update user's company verification status
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'isCompanyVerified': true,
        'companyId': requestId,
        'companyName': request.companyName,
      });

      // Create company details record
      final companyDetails = CompanyDetails(
        id: requestId,
        companyName: request.companyName,
        canonicalCompanyName: CompanyMatchingService.canonicalizeCompanyName(request.companyName),
        businessAddress: request.businessAddress,
        phoneNumber: request.phoneNumber,
        email: request.email,
        contactPerson: request.contactPerson,
        adminUserId: userId,
        employees: [userId], // Add the admin as first employee
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
          .doc(requestId)
          .set(companyDetails.toMap());

      print('Successfully approved company verification for user: $userId');
      print('Company: ${request.companyName}');
      print('Company ID: $requestId');

      return true;
    } catch (e) {
      print('Error approving verification: $e');
      return false;
    }
  }

  // Check user's current verification status
  static Future<Map<String, dynamic>> getUserVerificationStatus(String userId) async {
    try {
      // Get user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return {'error': 'User not found'};
      }

      final userData = userDoc.data()!;
      
      // Get verification request
      final requestQuery = await _firestore
          .collection('company_verification_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();

      String requestStatus = 'No request found';
      if (requestQuery.docs.isNotEmpty) {
        final requestData = requestQuery.docs.first.data();
        requestStatus = requestData['status'] ?? 'Unknown';
      }

      return {
        'userId': userId,
        'isCompanyVerified': userData['isCompanyVerified'] ?? false,
        'companyId': userData['companyId'] ?? 'Not set',
        'companyName': userData['companyName'] ?? 'Not set',
        'requestStatus': requestStatus,
        'userData': userData,
      };
    } catch (e) {
      print('Error checking verification status: $e');
      return {'error': e.toString()};
    }
  }
}
