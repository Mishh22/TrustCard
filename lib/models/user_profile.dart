/// User Profile Model - Represents user account information
/// This is separate from UserCard which represents individual digital cards
class UserProfile {
  String userId;
  String fullName;
  String phoneNumber;
  String? email;
  String? profilePhotoUrl;
  DateTime createdAt;
  DateTime? lastLoginAt;
  bool isActive;
  
  // User preferences
  String? preferredLanguage;
  bool notificationsEnabled;
  
  // FCM Token for push notifications
  String? fcmToken;

  UserProfile({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.profilePhotoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.preferredLanguage,
    this.notificationsEnabled = true,
    this.fcmToken,
  });

  // Copy with method for updates
  UserProfile copyWith({
    String? userId,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? profilePhotoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    String? preferredLanguage,
    bool? notificationsEnabled,
    String? fcmToken,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
      'preferredLanguage': preferredLanguage,
      'notificationsEnabled': notificationsEnabled,
      'fcmToken': fcmToken,
    };
  }

  // Create from Firestore Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      profilePhotoUrl: map['profilePhotoUrl'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'])
          : null,
      isActive: map['isActive'] ?? true,
      preferredLanguage: map['preferredLanguage'],
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      fcmToken: map['fcmToken'],
    );
  }
}

