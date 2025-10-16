enum VerificationLevel {
  basic,
  document,
  peer,
  company,
}

enum CompanyVerificationDepth {
  basic,        // Self-declared company (no verification)
  verified,     // Manual verification passed (email + call)
  certified,    // Full documentation provided (GST, PAN, etc.)
  enterprise    // Large registered company (additional validation)
}

enum UserRole {
  user,
  companyAdmin,
  superAdmin,
}

class UserCard {
  String id; // Unique card ID (UUID)
  String userId; // Owner of this card (links to user_profiles collection)
  String fullName;
  String phoneNumber;
  String? profilePhotoUrl;
  String? companyName;
  String? designation;
  String? companyId;
  String? companyPhone;
  VerificationLevel verificationLevel;
  bool isCompanyVerified;
  CompanyVerificationDepth? companyVerificationDepth;
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
  UserRole userRole;
  bool isDemoCard;
  
  // Company approval fields
  String? verifiedBy;
  DateTime? verifiedAt;
  String? rejectedBy;
  DateTime? rejectedAt;
  String? rejectionReason;

  UserCard({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    this.profilePhotoUrl,
    this.companyName,
    this.designation,
    this.companyId,
    this.companyPhone,
    this.verificationLevel = VerificationLevel.basic,
    this.isCompanyVerified = false,
    this.companyVerificationDepth,
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
    this.userRole = UserRole.user,
    this.isDemoCard = false,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
  });

  // Copy with method for updates
  UserCard copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phoneNumber,
    String? profilePhotoUrl,
    String? companyName,
    String? designation,
    String? companyId,
    String? companyPhone,
    VerificationLevel? verificationLevel,
    bool? isCompanyVerified,
    CompanyVerificationDepth? companyVerificationDepth,
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
    UserRole? userRole,
    bool? isDemoCard,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? rejectedBy,
    DateTime? rejectedAt,
    String? rejectionReason,
  }) {
    return UserCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      companyName: companyName ?? this.companyName,
      designation: designation ?? this.designation,
      companyId: companyId ?? this.companyId,
      companyPhone: companyPhone ?? this.companyPhone,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      isCompanyVerified: isCompanyVerified ?? this.isCompanyVerified,
      companyVerificationDepth: companyVerificationDepth ?? this.companyVerificationDepth,
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
      userRole: userRole ?? this.userRole,
      isDemoCard: isDemoCard ?? this.isDemoCard,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  // Get trust score based on verification level (0-100 scale)
  double get trustScore {
    double score = 0.0;
    
    // 1. ACCOUNT AGE (30% weight) - Impossible to fake quickly
    final ageInDays = daysSinceCreation;
    if (ageInDays >= 365) {
      score += 30.0;  // 1 year+ = maximum time trust
    } else if (ageInDays >= 180) {
      score += 25.0;  // 6 months+ = high time trust
    } else if (ageInDays >= 90) {
      score += 20.0;  // 3 months+ = medium time trust
    } else if (ageInDays >= 30) {
      score += 10.0;  // 1 month+ = basic time trust
    }
    // New accounts get 0 time points - prevents instant high scores
    
    // 2. VERIFICATION LEVEL (30% weight)
    switch (verificationLevel) {
      case VerificationLevel.company:
        score += 30.0;  // Company verified
        break;
      case VerificationLevel.document:
        score += 20.0;  // Documents uploaded
        break;
      case VerificationLevel.peer:
        score += 10.0;  // Peer verification
        break;
      case VerificationLevel.basic:
        score += 5.0;   // Phone only
        break;
    }
    
    // 3. SERVICE HISTORY (25% weight) - Must be REAL transactions
    if (totalRatings != null && customerRating != null) {
      if (totalRatings! >= 50 && customerRating! >= 4.5) {
        score += 25.0;  // 50+ ratings with 4.5+ average = exceptional
      } else if (totalRatings! >= 20 && customerRating! >= 4.0) {
        score += 15.0;  // 20+ ratings with 4.0+ average = good
      } else if (totalRatings! >= 10 && customerRating! >= 3.5) {
        score += 10.0;  // 10+ ratings with 3.5+ average = decent
      }
    }
    // No ratings or insufficient ratings = 0 points
    
    // 4. NETWORK TRUST (15% weight) - Validated colleagues
    // Note: Full validation requires checking colleague age/activity
    // For now, apply progressive scoring
    final colleagueCount = verifiedByColleagues.length;
    if (colleagueCount >= 3) {
      score += 15.0;  // 3+ colleagues = strong network
    } else if (colleagueCount >= 2) {
      score += 10.0;  // 2+ colleagues = good network
    } else if (colleagueCount >= 1) {
      score += 5.0;   // 1+ colleague = basic network
    }
    
    // 5. ANTI-FRAUD CAP: New accounts can't exceed 40 points total
    if (ageInDays < 30) {
      score = score.clamp(0.0, 40.0);  // Prevents instant high scores
    }
    
    return score.clamp(0.0, 100.0);
  }
  
  // Enhanced trust score with deletion penalties (for new cards)
  static Future<double> calculateTrustScoreWithPenalties(String userId, {
    required int ageInDays,
    required VerificationLevel verificationLevel,
    double? customerRating,
    int? totalRatings,
    required List<String> verifiedByColleagues,
  }) async {
    try {
      // Import the AccountLifecycleService
      final accountLifecycleService = await _getAccountLifecycleService();
      if (accountLifecycleService == null) {
        // Fallback to basic calculation if service unavailable
        return _calculateBasicTrustScore(ageInDays, verificationLevel, customerRating, totalRatings, verifiedByColleagues);
      }
      
      // Get deletion penalties
      final deletionCount = await accountLifecycleService.getDeletionCount(userId);
      final suspiciousDeletions = await accountLifecycleService.getSuspiciousDeletionCount(userId);
      
      // Calculate base score
      double score = _calculateBasicTrustScore(ageInDays, verificationLevel, customerRating, totalRatings, verifiedByColleagues);
      
      // Apply deletion penalties
      if (deletionCount == 1) {
        score -= 5.0;   // 1st recreation: -5 points
      } else if (deletionCount == 2) {
        score -= 10.0;  // 2nd recreation: -10 points
      } else if (deletionCount >= 3) {
        score -= 20.0;  // 3+ recreations: -20 points
      }
      
      // Heavy penalty for deleting after bad reviews
      if (suspiciousDeletions > 0) {
        score -= (suspiciousDeletions * 10);
      }
      
      return score.clamp(0.0, 100.0);
    } catch (e) {
      print("Error calculating trust score with penalties: $e");
      // Fallback to basic calculation
      return _calculateBasicTrustScore(ageInDays, verificationLevel, customerRating, totalRatings, verifiedByColleagues);
    }
  }
  
  // Basic trust score calculation (fallback)
  static double _calculateBasicTrustScore(
    int ageInDays,
    VerificationLevel verificationLevel,
    double? customerRating,
    int? totalRatings,
    List<String> verifiedByColleagues,
  ) {
    double score = 0.0;
    
    // Account age
    if (ageInDays >= 365) {
      score += 30.0;
    } else if (ageInDays >= 180) {
      score += 25.0;
    } else if (ageInDays >= 90) {
      score += 20.0;
    } else if (ageInDays >= 30) {
      score += 10.0;
    }
    
    // Verification level
    switch (verificationLevel) {
      case VerificationLevel.company:
        score += 30.0;
        break;
      case VerificationLevel.document:
        score += 20.0;
        break;
      case VerificationLevel.peer:
        score += 10.0;
        break;
      case VerificationLevel.basic:
        score += 5.0;
        break;
    }
    
    // Service history
    if (totalRatings != null && customerRating != null) {
      if (totalRatings >= 50 && customerRating >= 4.5) {
        score += 25.0;
      } else if (totalRatings >= 20 && customerRating >= 4.0) {
        score += 15.0;
      } else if (totalRatings >= 10 && customerRating >= 3.5) {
        score += 10.0;
      }
    }
    
    // Network trust
    final colleagueCount = verifiedByColleagues.length;
    if (colleagueCount >= 3) {
      score += 15.0;
    } else if (colleagueCount >= 2) {
      score += 10.0;
    } else if (colleagueCount >= 1) {
      score += 5.0;
    }
    
    // Anti-fraud cap for new accounts
    if (ageInDays < 30) {
      score = score.clamp(0.0, 40.0);
    }
    
    return score.clamp(0.0, 100.0);
  }
  
  // Helper method to get AccountLifecycleService (avoid circular imports)
  static Future<dynamic> _getAccountLifecycleService() async {
    try {
      // Import the service dynamically to avoid circular dependencies
      // This is a placeholder - in practice, we'll use a different approach
      return null;
    } catch (e) {
      print("Error importing AccountLifecycleService: $e");
      return null;
    }
  }
  
  // Get trust score as percentage (0.0 to 1.0) for backward compatibility
  double get trustScorePercentage {
    return (trustScore / 100.0).clamp(0.0, 1.0);
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

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': profilePhotoUrl,
      'companyName': companyName,
      'designation': designation,
      'companyId': companyId,
      'companyPhone': companyPhone,
      'verificationLevel': verificationLevel.toString().split('.').last,
      'isCompanyVerified': isCompanyVerified,
      'companyVerificationDepth': companyVerificationDepth?.toString().split('.').last,
      'customerRating': customerRating,
      'totalRatings': totalRatings,
      'verifiedByColleagues': verifiedByColleagues,
      'createdAt': createdAt.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'version': version,
      'isActive': isActive,
      'companyEmail': companyEmail,
      'workLocation': workLocation,
      'uploadedDocuments': uploadedDocuments,
      'additionalInfo': additionalInfo,
      'userRole': userRole.name,
      'isDemoCard': isDemoCard,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'rejectedBy': rejectedBy,
      'rejectedAt': rejectedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  // Create from Firestore Map
  factory UserCard.fromMap(Map<String, dynamic> map) {
    return UserCard(
      id: map['id'] ?? '',
      userId: map['userId'] ?? map['id'] ?? '', // Fallback to id for backward compatibility
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
      companyName: map['companyName'],
      designation: map['designation'],
      companyId: map['companyId'],
      companyPhone: map['companyPhone'],
      verificationLevel: _parseVerificationLevel(map['verificationLevel']),
      isCompanyVerified: map['isCompanyVerified'] ?? false,
      companyVerificationDepth: _parseCompanyVerificationDepth(map['companyVerificationDepth']),
      customerRating: map['customerRating']?.toDouble(),
      totalRatings: map['totalRatings']?.toInt(),
      verifiedByColleagues: List<String>.from(map['verifiedByColleagues'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      version: map['version'] ?? 1,
      isActive: map['isActive'] ?? true,
      companyEmail: map['companyEmail'],
      workLocation: map['workLocation'],
      uploadedDocuments: List<String>.from(map['uploadedDocuments'] ?? []),
      additionalInfo: Map<String, dynamic>.from(map['additionalInfo'] ?? {}),
      userRole: _parseUserRole(map['userRole']),
      isDemoCard: map['isDemoCard'] ?? false,
      verifiedBy: map['verifiedBy'],
      verifiedAt: map['verifiedAt'] != null ? DateTime.parse(map['verifiedAt']) : null,
      rejectedBy: map['rejectedBy'],
      rejectedAt: map['rejectedAt'] != null ? DateTime.parse(map['rejectedAt']) : null,
      rejectionReason: map['rejectionReason'],
    );
  }

  // Helper method to parse verification level
  static VerificationLevel _parseVerificationLevel(dynamic value) {
    if (value == null) return VerificationLevel.basic;
    if (value is VerificationLevel) return value;
    
    final stringValue = value.toString().toLowerCase();
    switch (stringValue) {
      case 'document':
        return VerificationLevel.document;
      case 'peer':
        return VerificationLevel.peer;
      case 'company':
        return VerificationLevel.company;
      default:
        return VerificationLevel.basic;
    }
  }

  // Helper method to parse company verification depth
  static CompanyVerificationDepth? _parseCompanyVerificationDepth(dynamic value) {
    if (value == null) return null;
    if (value is CompanyVerificationDepth) return value;
    
    final stringValue = value.toString().toLowerCase();
    switch (stringValue) {
      case 'basic':
        return CompanyVerificationDepth.basic;
      case 'verified':
        return CompanyVerificationDepth.verified;
      case 'certified':
        return CompanyVerificationDepth.certified;
      case 'enterprise':
        return CompanyVerificationDepth.enterprise;
      default:
        return null;
    }
  }

  // Helper method to parse user role
  static UserRole _parseUserRole(dynamic value) {
    if (value == null) return UserRole.user;
    if (value is UserRole) return value;
    
    final stringValue = value.toString().toLowerCase();
    switch (stringValue) {
      case 'companyadmin':
        return UserRole.companyAdmin;
      case 'superadmin':
        return UserRole.superAdmin;
      default:
        return UserRole.user;
    }
  }
}
