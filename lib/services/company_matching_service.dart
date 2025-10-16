import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_details.dart';

/// Service for company name matching and canonicalization
/// Handles fuzzy matching to detect existing companies despite variations in naming
class CompanyMatchingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Canonicalize company name for matching
  /// Removes punctuation, extra whitespace, and converts to lowercase
  /// Example: "Company 1 Pvt. Ltd." -> "company 1 pvt ltd"
  static String canonicalizeCompanyName(String companyName) {
    return companyName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ')     // Normalize whitespace
        .trim();
  }

  /// Find existing company by canonical name
  /// Returns the company details if found, null otherwise
  static Future<CompanyDetails?> findExistingCompany(String companyName) async {
    try {
      final canonicalName = canonicalizeCompanyName(companyName);
      
      // Query by canonical name
      final querySnapshot = await _firestore
          .collection('company_details')
          .where('canonicalCompanyName', isEqualTo: canonicalName)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return CompanyDetails.fromMap(doc.data(), doc.id);
      }

      // Fallback: Try exact match if canonical match fails
      final exactQuerySnapshot = await _firestore
          .collection('company_details')
          .where('companyName', isEqualTo: companyName)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (exactQuerySnapshot.docs.isNotEmpty) {
        final doc = exactQuerySnapshot.docs.first;
        return CompanyDetails.fromMap(doc.data(), doc.id);
      }

      // Fallback: Check users collection for company-verified users
      final companyFromUsers = await _findExistingCompanyFromUsers(companyName);
      if (companyFromUsers != null) {
        print('Found company from users collection: ${companyFromUsers.companyName}');
        return companyFromUsers;
      }

      return null;
    } catch (e) {
      print('Error finding existing company: $e');
      return null;
    }
  }

  /// Find existing company from users collection (fallback for company-verified users)
  /// This ensures backward compatibility with users who have company verification
  /// but don't have a company_details record yet
  static Future<CompanyDetails?> _findExistingCompanyFromUsers(String companyName) async {
    try {
      final canonicalName = canonicalizeCompanyName(companyName);
      
      // Search users collection for company-verified users with matching company name
      final querySnapshot = await _firestore
          .collection('users')
          .where('companyName', isEqualTo: companyName)
          .where('isCompanyVerified', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final userId = querySnapshot.docs.first.id;
        
        print('Found company-verified user: $userId with company: $companyName');
        
        // Create a CompanyDetails object from user data
        // This allows the approval system to work with existing company-verified users
        return CompanyDetails(
          id: userData['companyId'] ?? userId, // Use companyId if available, otherwise userId
          companyName: userData['companyName'] ?? companyName,
          canonicalCompanyName: canonicalName,
          businessAddress: userData['workLocation'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          email: userData['companyEmail'] ?? '',
          contactPerson: userData['fullName'] ?? '',
          adminUserId: userId,
          employees: [userId],
          createdAt: _parseDateTime(userData['createdAt']),
          isActive: true,
        );
      }
      
      return null;
    } catch (e) {
      print('Error finding company from users: $e');
      return null;
    }
  }

  /// Helper method to parse DateTime from Firestore data
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is DateTime) return dateTime;
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    }
    // Handle Firestore Timestamp
    try {
      return dateTime.toDate();
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Find company by unique identifier (GST/PAN)
  /// More reliable than name matching
  static Future<CompanyDetails?> findCompanyByIdentifier({
    String? gstNumber,
    String? panNumber,
  }) async {
    try {
      if (gstNumber != null && gstNumber.isNotEmpty) {
        final querySnapshot = await _firestore
            .collection('company_details')
            .where('gstNumber', isEqualTo: gstNumber)
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          return CompanyDetails.fromMap(doc.data(), doc.id);
        }
      }

      if (panNumber != null && panNumber.isNotEmpty) {
        final querySnapshot = await _firestore
            .collection('company_details')
            .where('panNumber', isEqualTo: panNumber)
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          return CompanyDetails.fromMap(doc.data(), doc.id);
        }
      }

      return null;
    } catch (e) {
      print('Error finding company by identifier: $e');
      return null;
    }
  }

  /// Calculate similarity score between two company names
  /// Uses Levenshtein distance for fuzzy matching
  /// Returns score from 0.0 (no match) to 1.0 (perfect match)
  static double calculateSimilarity(String name1, String name2) {
    final canonical1 = canonicalizeCompanyName(name1);
    final canonical2 = canonicalizeCompanyName(name2);

    if (canonical1 == canonical2) return 1.0;

    final distance = _levenshteinDistance(canonical1, canonical2);
    final maxLength = canonical1.length > canonical2.length 
        ? canonical1.length 
        : canonical2.length;
    
    return 1.0 - (distance / maxLength);
  }

  /// Levenshtein distance algorithm
  /// Measures minimum number of single-character edits needed
  static int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;
    
    final matrix = List.generate(
      len1 + 1, 
      (i) => List.filled(len2 + 1, 0),
    );

    for (var i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// Find similar companies (for suggesting alternatives)
  /// Returns list of companies with similarity >= threshold
  static Future<List<Map<String, dynamic>>> findSimilarCompanies(
    String companyName, {
    double threshold = 0.7,
    int limit = 5,
  }) async {
    try {
      // Get all active companies
      final querySnapshot = await _firestore
          .collection('company_details')
          .where('isActive', isEqualTo: true)
          .limit(50) // Limit initial fetch for performance
          .get();

      final similarCompanies = <Map<String, dynamic>>[];

      for (final doc in querySnapshot.docs) {
        final company = CompanyDetails.fromMap(doc.data(), doc.id);
        final similarity = calculateSimilarity(companyName, company.companyName);

        if (similarity >= threshold) {
          similarCompanies.add({
            'company': company,
            'similarity': similarity,
          });
        }
      }

      // Sort by similarity (highest first)
      similarCompanies.sort((a, b) => 
        (b['similarity'] as double).compareTo(a['similarity'] as double)
      );

      // Return top results
      return similarCompanies.take(limit).toList();
    } catch (e) {
      print('Error finding similar companies: $e');
      return [];
    }
  }

  /// Validate if company name is unique
  /// Used during company registration
  static Future<bool> isCompanyNameUnique(String companyName) async {
    final existingCompany = await findExistingCompany(companyName);
    return existingCompany == null;
  }
}

