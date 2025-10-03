enum VerificationLevel {
  basic,
  document,
  peer,
  company,
}

class UserCard {
  String id;
  String fullName;
  String phoneNumber;
  String? profilePhotoUrl;
  String? companyName;
  String? designation;
  String? companyId;
  String? companyPhone;
  VerificationLevel verificationLevel;
  bool isCompanyVerified;
  double? customerRating;
  int? totalRatings;
  List<String> verifiedByColleagues;
  DateTime createdAt;
  DateTime? expiryDate;
  int version;
  bool isActive;
  String? companyEmail;
  String? workLocation;
  List<String> uploadedDocuments;
  Map<String, dynamic> additionalInfo;

  UserCard({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.profilePhotoUrl,
    this.companyName,
    this.designation,
    this.companyId,
    this.companyPhone,
    this.verificationLevel = VerificationLevel.basic,
    this.isCompanyVerified = false,
    this.customerRating,
    this.totalRatings,
    this.verifiedByColleagues = const [],
    required this.createdAt,
    this.expiryDate,
    this.version = 1,
    this.isActive = true,
    this.companyEmail,
    this.workLocation,
    this.uploadedDocuments = const [],
    this.additionalInfo = const {},
  });

  // Copy with method for updates
  UserCard copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? profilePhotoUrl,
    String? companyName,
    String? designation,
    String? companyId,
    String? companyPhone,
    VerificationLevel? verificationLevel,
    bool? isCompanyVerified,
    double? customerRating,
    int? totalRatings,
    List<String>? verifiedByColleagues,
    DateTime? createdAt,
    DateTime? expiryDate,
    int? version,
    bool? isActive,
    String? companyEmail,
    String? workLocation,
    List<String>? uploadedDocuments,
    Map<String, dynamic>? additionalInfo,
  }) {
    return UserCard(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      companyName: companyName ?? this.companyName,
      designation: designation ?? this.designation,
      companyId: companyId ?? this.companyId,
      companyPhone: companyPhone ?? this.companyPhone,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      isCompanyVerified: isCompanyVerified ?? this.isCompanyVerified,
      customerRating: customerRating ?? this.customerRating,
      totalRatings: totalRatings ?? this.totalRatings,
      verifiedByColleagues: verifiedByColleagues ?? this.verifiedByColleagues,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      companyEmail: companyEmail ?? this.companyEmail,
      workLocation: workLocation ?? this.workLocation,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Get trust score based on verification level
  double get trustScore {
    double baseScore = 0.0;
    
    switch (verificationLevel) {
      case VerificationLevel.basic:
        baseScore = 0.3;
        break;
      case VerificationLevel.document:
        baseScore = 0.6;
        break;
      case VerificationLevel.peer:
        baseScore = 0.8;
        break;
      case VerificationLevel.company:
        baseScore = 1.0;
        break;
    }
    
    // Add bonus for customer ratings
    if (customerRating != null && totalRatings != null && totalRatings! > 0) {
      baseScore += (customerRating! / 5.0) * 0.2;
    }
    
    // Add bonus for colleague verification
    if (verifiedByColleagues.isNotEmpty) {
      baseScore += (verifiedByColleagues.length / 5.0) * 0.1;
    }
    
    return baseScore.clamp(0.0, 1.0);
  }

  // Check if card is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  // Get verification badge color
  String get verificationBadgeText {
    if (isCompanyVerified) return 'COMPANY VERIFIED';
    switch (verificationLevel) {
      case VerificationLevel.basic:
        return 'BASIC VERIFIED';
      case VerificationLevel.document:
        return 'DOCUMENT VERIFIED';
      case VerificationLevel.peer:
        return 'PEER VERIFIED';
      case VerificationLevel.company:
        return 'COMPANY VERIFIED';
    }
  }

  // Get days since creation
  int get daysSinceCreation {
    return DateTime.now().difference(createdAt).inDays;
  }

  // Check if card needs renewal
  bool get needsRenewal {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7; // Renew if expires within 7 days
  }
}
