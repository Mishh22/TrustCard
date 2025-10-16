# TestCard App - Complete Documentation

## 📱 **App Overview**

TestCard is a Flutter-based digital business card application that enables users to create, share, and manage digital business cards with trust scoring, verification systems, and QR code functionality.

### **Key Features**
- Digital business card creation and management
- QR code generation and scanning
- Multi-level verification system
- Trust scoring algorithm
- Company verification workflow
- Card sharing and networking
- Firebase backend integration
- Abuse prevention system

---

## 🏗️ **Architecture & Structure**

### **Project Structure**
```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
│   ├── user_card.dart          # UserCard model with trust scoring
│   ├── company_verification_request.dart
│   ├── notification.dart
│   ├── user.dart
│   ├── rating.dart
│   └── interaction.dart
├── providers/                   # State management
│   ├── auth_provider.dart      # Authentication state
│   ├── card_provider.dart      # Card management
│   └── document_provider.dart  # Document handling
├── screens/                     # UI screens
│   ├── auth_screen.dart        # Login/authentication
│   ├── home_screen.dart        # Main dashboard
│   ├── create_card_screen.dart # Card creation
│   ├── my_cards_screen.dart    # User's cards
│   ├── card_detail_screen.dart # Card details
│   ├── profile_screen.dart     # User profile
│   ├── verification_screen.dart # Document verification
│   ├── company_verification_screen.dart
│   ├── email_verification_screen.dart
│   └── scan_screen.dart        # QR code scanning
├── services/                    # Business logic
│   ├── firebase_service.dart   # Firebase operations
│   ├── auth_service.dart       # Authentication
│   ├── card_service.dart       # Card operations
│   ├── company_verification_service.dart
│   ├── notification_service.dart
│   ├── transaction_service.dart
│   ├── employee_service.dart
│   └── account_lifecycle_service.dart # Abuse prevention
├── widgets/                     # Reusable components
│   ├── digital_card_widget.dart
│   ├── public_card_widget.dart
│   └── verification_badge_widget.dart
└── utils/                       # Utilities
    ├── app_theme.dart          # Theme and colors
    └── app_router.dart         # Navigation routing
```

### **State Management**
- **Provider Pattern**: Used for state management
- **AuthProvider**: Manages user authentication state
- **CardProvider**: Handles card CRUD operations and local storage
- **DocumentProvider**: Manages document uploads and verification

### **Navigation**
- **GoRouter**: Declarative routing system
- **Route Guards**: Authentication-based route protection
- **Deep Linking**: Support for QR code scanning and card sharing

---

## 🔐 **Authentication System**

### **Authentication Methods**
1. **Phone Number + OTP** (Primary)
   - Indian phone number validation (10 digits)
   - OTP verification via Firebase Auth
   - SMS retriever integration

2. **Email + Password** (Secondary)
   - Standard email/password authentication
   - Email verification required

### **Phone Number Validation**
```dart
// 10-digit Indian mobile number validation
if (value.length != 10) {
  return 'Indian phone number must be 10 digits';
}
if (!RegExp(r'^[6-9]').hasMatch(value)) {
  return 'Indian mobile number must start with 6, 7, 8, or 9';
}
```

### **Email Validation**
```dart
// Standard email format validation
if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
  return 'Please enter a valid email address';
}
// Reject personal email domains
final personalDomains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com'];
```

---

## 🎴 **Card System**

### **UserCard Model**
```dart
class UserCard {
  String id;                    // Unique card identifier
  String fullName;              // User's full name
  String phoneNumber;           // Phone number
  String? profilePhotoUrl;      // Profile photo
  String? companyName;          // Company name
  String? designation;          // Job title
  String? companyId;            // Company identifier
  VerificationLevel verificationLevel; // Verification status
  bool isCompanyVerified;       // Company verification status
  double? customerRating;       // Average rating
  int? totalRatings;           // Total number of ratings
  List<String> verifiedByColleagues; // Colleague endorsements
  DateTime createdAt;           // Creation timestamp
  DateTime? expiryDate;        // Card expiry
  int version;                  // Card version
  bool isActive;                // Active status
  bool isDemoCard;              // Demo card flag
}
```

### **Card Creation Process**
1. **User Input**: Name, phone, email, company details
2. **Validation**: Format and business logic validation
3. **Verification Level**: Basic → Document → Peer → Company
4. **Trust Score**: Calculated based on verification and history
5. **Storage**: Saved to Firebase and local storage
6. **QR Code**: Generated for sharing

### **Card Limits System**
- **Configurable Limits**: Set via Firebase `app_config/limits`
- **Default Limit**: 10 cards per user
- **Demo Cards**: Excluded from limit count
- **Dynamic Updates**: Limits can be changed without app updates

---

## 🏆 **Trust Scoring System**

### **Trust Score Calculation (0-100 scale)**
```dart
// 1. ACCOUNT AGE (30% weight)
if (ageInDays >= 365) score += 30.0;  // 1 year+
else if (ageInDays >= 180) score += 25.0;  // 6 months+
else if (ageInDays >= 90) score += 20.0;   // 3 months+
else if (ageInDays >= 30) score += 10.0;   // 1 month+

// 2. VERIFICATION LEVEL (30% weight)
switch (verificationLevel) {
  case VerificationLevel.company: score += 30.0;
  case VerificationLevel.document: score += 20.0;
  case VerificationLevel.peer: score += 10.0;
  case VerificationLevel.basic: score += 5.0;
}

// 3. SERVICE HISTORY (25% weight)
if (totalRatings >= 50 && customerRating >= 4.5) score += 25.0;
else if (totalRatings >= 20 && customerRating >= 4.0) score += 15.0;
else if (totalRatings >= 10 && customerRating >= 3.5) score += 10.0;

// 4. NETWORK TRUST (15% weight)
if (colleagueCount >= 3) score += 15.0;
else if (colleagueCount >= 2) score += 10.0;
else if (colleagueCount >= 1) score += 5.0;

// 5. ANTI-FRAUD CAP
if (ageInDays < 30) score = score.clamp(0.0, 40.0);
```

### **Verification Levels**
1. **Basic (Yellow Badge)**: Phone verification only
2. **Document (Green Badge)**: Document upload verification
3. **Peer (Blue Badge)**: Colleague endorsements
4. **Company (Gold Badge)**: Official company verification

---

## 🛡️ **Abuse Prevention System**

### **Multi-Layer Protection**
1. **Lifecycle Tracking**: Permanent audit trail of card operations
2. **Cooldown Periods**: 24h → 72h → 168h escalating cooldowns
3. **Trust Score Inheritance**: Penalties carry forward to new cards
4. **Device Fingerprinting**: Cross-device abuse detection
5. **Velocity Limits**: Max 3 deletions per 30 days
6. **Database-Level Protection**: Firestore security rules

### **Abuse Prevention Features**
- **AccountLifecycleService**: Tracks all card operations
- **Device Fingerprinting**: Android ID and iOS Vendor ID tracking
- **Suspicious Pattern Detection**: Flags users who delete after bad reviews
- **Admin Review System**: Manual oversight for flagged users
- **Appeal Process**: Users can request review of false positives

---

## 🏢 **Company Verification System**

### **Verification Workflow**
1. **User Submission**: Company details and documents
2. **Email Notification**: Sent to `info@accexasia.com`
3. **Admin Review**: Manual verification process
4. **Status Update**: Approved/rejected with notifications
5. **User Notification**: In-app notification of status change

### **Verification Requirements**
- **Company Email**: Must use company domain (not personal)
- **Document Upload**: Company ID, offer letter, or salary slip
- **Phone Verification**: Company phone number
- **Admin Approval**: Manual review required

---

## 📱 **QR Code System**

### **QR Code Generation**
- **Card Data**: Encoded with card ID and user information
- **Security**: Firebase-based validation
- **Format**: Standard QR code format
- **Sharing**: Easy sharing via various platforms

### **QR Code Scanning**
- **Camera Integration**: Real-time camera scanning
- **Data Extraction**: Card information retrieval
- **Validation**: Firebase-based card verification
- **Storage**: Scanned cards saved to user's collection

---

## 🔔 **Notification System**

### **Notification Types**
1. **Company Verification**: Status updates
2. **Card Sharing**: When someone scans your card
3. **Rating Updates**: New ratings received
4. **System Alerts**: Important app updates

### **Notification Channels**
- **In-App**: Real-time notifications
- **Email**: Company verification updates
- **Push**: System notifications (future)

---

## 🗄️ **Data Storage**

### **Firebase Collections**
```
users/                          # User profiles
├── {userId}                    # User document
└── scannedCards/               # User's scanned cards
    └── {cardId}                # Individual scanned cards

userCards/                      # User's own cards
└── {userId}                    # User's card data

account_lifecycle/              # Abuse prevention tracking
├── {lifecycleId}               # Lifecycle events

flagged_users/                  # Flagged users
└── {userId}                    # User flagging data

flagged_devices/                # Flagged devices
└── {deviceId}                  # Device flagging data

app_config/                     # App configuration
└── limits                      # Card limits configuration

company_verification_requests/  # Company verification
└── {requestId}                 # Verification requests

ratings/                        # User ratings
└── {ratingId}                  # Individual ratings

interactions/                   # User interactions
└── {interactionId}             # Interaction records
```

### **Local Storage**
- **SharedPreferences**: User preferences and settings
- **Hive**: Offline card storage and caching
- **File System**: Document and image storage

---

## 🎨 **UI/UX Design**

### **Theme System**
```dart
class AppTheme {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color verifiedGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  
  // Trust Score Colors
  static Color getTrustScoreColor(double score) {
    if (score >= 80) return verifiedGreen;
    else if (score >= 60) return warningOrange;
    else return errorRed;
  }
}
```

### **Card Design**
- **Digital Card Widget**: Interactive card display
- **Public Card Widget**: Read-only card view
- **Verification Badges**: Visual verification indicators
- **Trust Score Display**: Color-coded trust indicators

---

## 🔧 **Configuration & Deployment**

### **Firebase Configuration**
```dart
// Firebase services used
- Firebase Auth (Authentication)
- Cloud Firestore (Database)
- Firebase Storage (File storage)
- Firebase Functions (Backend logic)
- Firebase Messaging (Push notifications)
```

### **Environment Setup**
```yaml
# pubspec.yaml dependencies
dependencies:
  flutter: SDK
  provider: ^6.1.2
  go_router: ^14.2.7
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  qr_flutter: ^4.1.0
  qr_code_scanner: ^1.0.1
  device_info_plus: ^10.1.2
```

### **Build Configuration**
- **Android**: Gradle-based build system
- **iOS**: Xcode project configuration
- **Web**: Flutter web support
- **Desktop**: Windows, macOS, Linux support

---

## 📊 **Analytics & Monitoring**

### **User Analytics**
- **Card Creation**: Track card creation patterns
- **Verification Rates**: Monitor verification success
- **Trust Scores**: Analyze trust score distribution
- **User Engagement**: Track app usage patterns

### **Abuse Prevention Metrics**
- **Flagged Users**: Monitor abuse detection
- **Device Tracking**: Cross-device abuse patterns
- **Deletion Patterns**: Suspicious deletion behavior
- **Admin Reviews**: Manual review workload

---

## 🚀 **Future Enhancements**

### **Planned Features**
1. **Machine Learning**: Behavioral analysis for abuse detection
2. **Advanced Analytics**: Detailed user behavior insights
3. **Social Features**: Enhanced networking capabilities
4. **API Integration**: Third-party service integrations
5. **Offline Support**: Enhanced offline functionality

### **Scalability Considerations**
- **Database Optimization**: Query performance improvements
- **Caching Strategy**: Enhanced local caching
- **CDN Integration**: Global content delivery
- **Microservices**: Backend service separation

---

## 📝 **Change Log**

### **Version History**
- **v1.0.0**: Initial release with basic card functionality
- **v1.1.0**: Added trust scoring system
- **v1.2.0**: Implemented company verification
- **v1.3.0**: Added abuse prevention system
- **v1.4.0**: Enhanced security and monitoring

### **Recent Changes**
- **2024-01-09**: Implemented comprehensive abuse prevention system
- **2024-01-09**: Added device fingerprinting and lifecycle tracking
- **2024-01-09**: Enhanced Firestore security rules
- **2024-01-09**: Updated trust score calculation with deletion penalties

---

## 🔍 **Troubleshooting**

### **Common Issues**
1. **QR Code Scanning**: Camera permission issues
2. **Firebase Connection**: Network connectivity problems
3. **Card Creation**: Validation errors
4. **Verification**: Document upload failures

### **Debug Information**
- **Logs**: Comprehensive logging system
- **Error Handling**: Graceful error recovery
- **User Feedback**: Error message system
- **Admin Tools**: Debug and monitoring tools

---

## 📞 **Support & Maintenance**

### **Support Channels**
- **User Support**: In-app help system
- **Admin Support**: Backend monitoring tools
- **Developer Support**: Technical documentation

### **Maintenance Tasks**
- **Regular Updates**: Security and feature updates
- **Database Cleanup**: Periodic data maintenance
- **Performance Monitoring**: System health checks
- **User Feedback**: Continuous improvement

---

## 📋 **Development Guidelines**

### **Code Standards**
- **Dart/Flutter**: Follow official style guide
- **Documentation**: Comprehensive code comments
- **Testing**: Unit and integration tests
- **Version Control**: Git best practices

### **Deployment Process**
1. **Development**: Feature development and testing
2. **Staging**: Pre-production testing
3. **Production**: Live deployment
4. **Monitoring**: Post-deployment monitoring

---

**Last Updated**: January 9, 2024  
**Version**: 1.4.0  
**Maintainer**: Development Team
