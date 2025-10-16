import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/user_card.dart';
import 'firebase_service.dart';
import 'profile_service.dart';

/// Service for migrating data from old structure to new structure
/// Old: Everything in `users` collection
/// New: Profiles in `user_profiles`, Cards in `user_cards`
class DataMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrate a single user's data from old structure to new structure
  static Future<void> migrateUserData(String userId) async {
    try {
      print('Starting migration for user: $userId');
      
      // 1. Get data from old structure (users collection)
      final oldUserData = await FirebaseService.getUserCard(userId);
      if (oldUserData == null) {
        print('No data found for user: $userId');
        return;
      }
      
      // 2. Check if already migrated
      final profileExists = await ProfileService.profileExists(userId);
      if (profileExists) {
        print('User already migrated: $userId');
        return;
      }
      
      // 3. Create user profile from old data
      final profile = UserProfile(
        userId: userId,
        fullName: oldUserData['fullName'] ?? '',
        phoneNumber: oldUserData['phoneNumber'] ?? '',
        email: oldUserData['email'],
        profilePhotoUrl: oldUserData['profilePhotoUrl'],
        createdAt: oldUserData['createdAt'] != null
            ? DateTime.parse(oldUserData['createdAt'])
            : DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: oldUserData['isActive'] ?? true,
        notificationsEnabled: true,
      );
      
      // 4. Save profile to new structure
      await ProfileService.saveProfile(profile);
      print('Profile migrated for user: $userId');
      
      // 5. Migrate card if it exists (user's own card in users collection)
      // The card ID in old structure is same as userId
      // In new structure, we generate a new UUID for the card
      await _migrateUserCard(userId, oldUserData);
      
      print('Migration completed for user: $userId');
    } catch (e) {
      print('Error migrating user data: $e');
      rethrow;
    }
  }

  /// Migrate user's card from users collection to user_cards collection
  static Future<void> _migrateUserCard(String userId, Map<String, dynamic> oldUserData) async {
    try {
      // Check if card data exists
      if (oldUserData['fullName'] == null || oldUserData['phoneNumber'] == null) {
        print('No card data to migrate for user: $userId');
        return;
      }
      
      // Create card data for new structure
      final cardData = {
        'id': oldUserData['id'] ?? userId, // Keep old ID for QR code compatibility
        'userId': userId,
        'fullName': oldUserData['fullName'],
        'phoneNumber': oldUserData['phoneNumber'],
        'profilePhotoUrl': oldUserData['profilePhotoUrl'],
        'companyName': oldUserData['companyName'],
        'designation': oldUserData['designation'],
        'companyId': oldUserData['companyId'],
        'companyPhone': oldUserData['companyPhone'],
        'verificationLevel': oldUserData['verificationLevel'] ?? 'basic',
        'isCompanyVerified': oldUserData['isCompanyVerified'] ?? false,
        'companyVerificationDepth': oldUserData['companyVerificationDepth'],
        'customerRating': oldUserData['customerRating'],
        'totalRatings': oldUserData['totalRatings'],
        'verifiedByColleagues': oldUserData['verifiedByColleagues'] ?? [],
        'createdAt': oldUserData['createdAt'] ?? DateTime.now().toIso8601String(),
        'expiryDate': oldUserData['expiryDate'],
        'version': oldUserData['version'] ?? 1,
        'isActive': oldUserData['isActive'] ?? true,
        'companyEmail': oldUserData['companyEmail'],
        'workLocation': oldUserData['workLocation'],
        'uploadedDocuments': oldUserData['uploadedDocuments'] ?? [],
        'additionalInfo': oldUserData['additionalInfo'] ?? {},
        'userRole': oldUserData['userRole'] ?? 'user',
        'isDemoCard': oldUserData['isDemoCard'] ?? false,
        'verifiedBy': oldUserData['verifiedBy'],
        'verifiedAt': oldUserData['verifiedAt'],
        'rejectedBy': oldUserData['rejectedBy'],
        'rejectedAt': oldUserData['rejectedAt'],
        'rejectionReason': oldUserData['rejectionReason'],
      };
      
      // Save to new user_cards collection
      await FirebaseService.saveUserCardToCardsCollection(cardData);
      print('Card migrated to user_cards collection for user: $userId');
    } catch (e) {
      print('Error migrating user card: $e');
      // Don't rethrow - card migration failure shouldn't stop profile migration
    }
  }

  /// Migrate all users (admin function - use with caution!)
  static Future<void> migrateAllUsers() async {
    try {
      print('Starting migration of all users...');
      
      // Get all documents from users collection
      final usersSnapshot = await _firestore.collection('users').get();
      
      int successful = 0;
      int failed = 0;
      
      for (final userDoc in usersSnapshot.docs) {
        try {
          await migrateUserData(userDoc.id);
          successful++;
        } catch (e) {
          print('Failed to migrate user ${userDoc.id}: $e');
          failed++;
        }
      }
      
      print('Migration complete! Successful: $successful, Failed: $failed');
    } catch (e) {
      print('Error in bulk migration: $e');
      rethrow;
    }
  }

  /// Check migration status for a user
  static Future<Map<String, bool>> checkMigrationStatus(String userId) async {
    try {
      final profileExists = await ProfileService.profileExists(userId);
      
      // Check if card exists in user_cards collection
      final userCards = await FirebaseService.getUserCards(userId);
      final cardExists = userCards.isNotEmpty;
      
      return {
        'profileMigrated': profileExists,
        'cardMigrated': cardExists,
        'fullyMigrated': profileExists && cardExists,
      };
    } catch (e) {
      print('Error checking migration status: $e');
      return {
        'profileMigrated': false,
        'cardMigrated': false,
        'fullyMigrated': false,
      };
    }
  }

  /// Automatic migration on user login
  /// This should be called when a user logs in
  static Future<void> migrateOnLogin(String userId) async {
    try {
      final status = await checkMigrationStatus(userId);
      
      if (!status['fullyMigrated']!) {
        print('User not fully migrated, starting migration...');
        await migrateUserData(userId);
      } else {
        print('User already migrated');
      }
    } catch (e) {
      print('Error in auto-migration: $e');
      // Don't rethrow - migration failure shouldn't prevent login
    }
  }
}

