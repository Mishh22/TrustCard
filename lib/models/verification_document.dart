enum DocumentType {
  companyId('company_id', 'Company ID Card'),
  aadhaar('aadhaar', 'Aadhaar Card'),
  pan('pan', 'PAN Card'),
  salarySlip('salary_slip', 'Salary Slip'),
  offerLetter('offer_letter', 'Offer Letter'),
  other('other', 'Other');

  final String value;
  final String displayName;

  const DocumentType(this.value, this.displayName);

  static DocumentType fromString(String value) {
    return DocumentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DocumentType.other,
    );
  }
}

enum VerificationStatus {
  pending('pending', 'Pending'),
  verified('verified', 'Verified'),
  rejected('rejected', 'Rejected');

  final String value;
  final String displayName;

  const VerificationStatus(this.value, this.displayName);

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}

class VerificationDocument {
  final String id;
  final String userId;
  final String cardId; // Links document to specific card
  final DocumentType documentType;
  final String fileName;
  final int fileSize;
  final String fileHash; // For duplicate detection
  final String firebaseStorageUrl;
  final String? localPath; // Nullable - might only exist in cloud
  final DateTime uploadedAt;
  final VerificationStatus verificationStatus;
  final String? verifiedBy; // Admin ID who verified (for future use)
  final DateTime? verifiedAt;
  final String? rejectionReason;

  VerificationDocument({
    required this.id,
    required this.userId,
    required this.cardId,
    required this.documentType,
    required this.fileName,
    required this.fileSize,
    required this.fileHash,
    required this.firebaseStorageUrl,
    this.localPath,
    required this.uploadedAt,
    this.verificationStatus = VerificationStatus.pending,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cardId': cardId,
      'documentType': documentType.value,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileHash': fileHash,
      'firebaseStorageUrl': firebaseStorageUrl,
      'localPath': localPath,
      'uploadedAt': uploadedAt.toIso8601String(),
      'verificationStatus': verificationStatus.value,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  // Create from Firestore Map
  factory VerificationDocument.fromMap(Map<String, dynamic> map) {
    return VerificationDocument(
      id: map['id'] as String,
      userId: map['userId'] as String,
      cardId: map['cardId'] as String,
      documentType: DocumentType.fromString(map['documentType'] as String),
      fileName: map['fileName'] as String,
      fileSize: map['fileSize'] as int,
      fileHash: map['fileHash'] as String,
      firebaseStorageUrl: map['firebaseStorageUrl'] as String,
      localPath: map['localPath'] as String?,
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
      verificationStatus: VerificationStatus.fromString(
        map['verificationStatus'] as String? ?? 'pending',
      ),
      verifiedBy: map['verifiedBy'] as String?,
      verifiedAt: map['verifiedAt'] != null
          ? DateTime.parse(map['verifiedAt'] as String)
          : null,
      rejectionReason: map['rejectionReason'] as String?,
    );
  }

  // Copy with method for updates
  VerificationDocument copyWith({
    String? id,
    String? userId,
    String? cardId,
    DocumentType? documentType,
    String? fileName,
    int? fileSize,
    String? fileHash,
    String? firebaseStorageUrl,
    String? localPath,
    DateTime? uploadedAt,
    VerificationStatus? verificationStatus,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? rejectionReason,
  }) {
    return VerificationDocument(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardId: cardId ?? this.cardId,
      documentType: documentType ?? this.documentType,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileHash: fileHash ?? this.fileHash,
      firebaseStorageUrl: firebaseStorageUrl ?? this.firebaseStorageUrl,
      localPath: localPath ?? this.localPath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  // Check if document is synced (exists both locally and in Firebase)
  bool get isSynced => localPath != null && firebaseStorageUrl.isNotEmpty;

  // Check if document is only in cloud
  bool get isCloudOnly => localPath == null && firebaseStorageUrl.isNotEmpty;

  // Check if document needs upload
  bool get needsUpload => firebaseStorageUrl.isEmpty && localPath != null;

  // Get file extension
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Check if document is an image
  bool get isImage {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    return imageExtensions.contains(fileExtension);
  }

  // Check if document is a PDF
  bool get isPdf => fileExtension == 'pdf';

  // Format file size for display
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

