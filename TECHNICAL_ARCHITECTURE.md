# TestCard App - Technical Architecture

## 🏗️ **System Architecture Overview**

TestCard is built using Flutter with Firebase backend, implementing a modern mobile-first architecture with comprehensive security and abuse prevention systems.

---

## 📱 **Frontend Architecture**

### **Flutter Framework**
- **Version**: Flutter 3.x
- **Language**: Dart
- **Platform Support**: Android, iOS, Web, Desktop
- **State Management**: Provider pattern
- **Navigation**: GoRouter declarative routing

### **UI Architecture**
```
lib/
├── main.dart                    # App entry point
├── screens/                     # Presentation layer
│   ├── auth_screen.dart        # Authentication UI
│   ├── home_screen.dart        # Dashboard UI
│   ├── create_card_screen.dart # Card creation UI
│   └── ...
├── widgets/                     # Reusable UI components
│   ├── digital_card_widget.dart
│   └── ...
├── providers/                   # State management
│   ├── auth_provider.dart      # Auth state
│   ├── card_provider.dart      # Card state
│   └── ...
└── services/                    # Business logic layer
    ├── firebase_service.dart   # Firebase operations
    └── ...
```

### **State Management Pattern**
```dart
// Provider-based state management
class CardProvider extends ChangeNotifier {
  List<UserCard> _cards = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<UserCard> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Business logic methods
  Future<bool> createCard(UserCard card) async { ... }
  Future<bool> deleteCard(String cardId) async { ... }
}
```

---

## 🔥 **Backend Architecture**

### **Firebase Services**
```
Firebase Project: trustcard-aee4a
├── Authentication
│   ├── Phone Auth (Primary)
│   └── Email/Password (Secondary)
├── Firestore Database
│   ├── users/                  # User profiles
│   ├── userCards/              # User's cards
│   ├── account_lifecycle/      # Abuse prevention
│   ├── flagged_users/          # Flagged users
│   └── app_config/             # Configuration
├── Cloud Storage
│   ├── profile_photos/         # User photos
│   └── documents/              # Verification docs
├── Cloud Functions
│   ├── sendCompanyVerificationEmail
│   └── updateUserVerificationStatus
└── Security Rules
    ├── Firestore Rules
    └── Storage Rules
```

### **Database Schema**
```javascript
// Firestore Collections Structure
users: {
  [userId]: {
    fullName: string,
    phoneNumber: string,
    email: string,
    profilePhotoUrl: string,
    createdAt: timestamp,
    lastLoginAt: timestamp,
    canCreateCards: boolean,
    activeCardCount: number
  }
}

userCards: {
  [userId]: {
    cards: UserCard[],
    scannedCards: UserCard[],
    lastUpdated: timestamp
  }
}

account_lifecycle: {
  [lifecycleId]: {
    userId: string,
    cardId: string,
    action: 'created' | 'deleted',
    timestamp: timestamp,
    deviceId: string,
    ipAddress: string,
    finalTrustScore: number,
    totalRatings: number
  }
}
```

---

## 🛡️ **Security Architecture**

### **Multi-Layer Security**
```
Layer 1: Client-Side Validation
├── Input validation
├── Format checking
└── Business logic validation

Layer 2: Authentication
├── Firebase Auth
├── Phone OTP verification
└── Email verification

Layer 3: Authorization
├── Firestore security rules
├── User-based access control
└── Resource-level permissions

Layer 4: Abuse Prevention
├── Lifecycle tracking
├── Device fingerprinting
├── Velocity limits
└── Pattern detection

Layer 5: Database Security
├── Firestore security rules
├── Data encryption
└── Access logging
```

### **Firestore Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User cards - authenticated users only
    match /userCards/{userId} {
      allow read, write: if request.auth != null 
                        && request.auth.uid == userId
                        && !isUserFlagged(request.auth.uid)
                        && getCardCount(request.auth.uid) < getCardLimit();
    }
    
    // Account lifecycle - system tracking
    match /account_lifecycle/{lifecycleId} {
      allow read: if request.auth != null 
                  && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    // Helper functions
    function isUserFlagged(userId) {
      return exists(/databases/$(database)/documents/flagged_users/$(userId));
    }
    
    function getCardCount(userId) {
      return get(/databases/$(database)/documents/users/$(userId)).data.activeCardCount || 0;
    }
  }
}
```

---

## 🔄 **Data Flow Architecture**

### **Card Creation Flow**
```
User Input → Validation → Abuse Prevention Check → Trust Score Calculation → Firebase Storage → Local Storage → UI Update
```

### **Authentication Flow**
```
Phone Input → OTP Request → SMS Verification → Firebase Auth → User Profile Creation → Dashboard
```

### **Trust Score Calculation Flow**
```
Card Data → Base Score Calculation → Deletion Penalties → Suspicious Pattern Detection → Final Score → UI Display
```

---

## 📊 **Trust Scoring Algorithm**

### **Algorithm Implementation**
```dart
class TrustScoreCalculator {
  static double calculateTrustScore({
    required int ageInDays,
    required VerificationLevel verificationLevel,
    double? customerRating,
    int? totalRatings,
    required List<String> verifiedByColleagues,
    int deletionCount = 0,
    int suspiciousDeletions = 0,
  }) {
    double score = 0.0;
    
    // 1. Account Age (30% weight)
    score += _calculateAgeScore(ageInDays);
    
    // 2. Verification Level (30% weight)
    score += _calculateVerificationScore(verificationLevel);
    
    // 3. Service History (25% weight)
    score += _calculateServiceScore(customerRating, totalRatings);
    
    // 4. Network Trust (15% weight)
    score += _calculateNetworkScore(verifiedByColleagues.length);
    
    // 5. Deletion Penalties
    score -= _calculateDeletionPenalties(deletionCount, suspiciousDeletions);
    
    // 6. Anti-fraud cap for new accounts
    if (ageInDays < 30) {
      score = score.clamp(0.0, 40.0);
    }
    
    return score.clamp(0.0, 100.0);
  }
}
```

---

## 🔧 **Abuse Prevention Architecture**

### **AccountLifecycleService**
```dart
class AccountLifecycleService {
  // Track card operations
  static Future<void> trackCardCreation(String userId, String cardId) async {
    await _firestore.collection('account_lifecycle').add({
      'userId': userId,
      'cardId': cardId,
      'action': 'created',
      'timestamp': FieldValue.serverTimestamp(),
      'deviceId': await _getDeviceId(),
      'ipAddress': await _getIPAddress(),
    });
  }
  
  // Check abuse prevention measures
  static Future<bool> canCreateNewCard(String userId) async {
    // Check deletion velocity
    final recentDeletions = await _getRecentDeletions(userId);
    if (recentDeletions >= 3) {
      await _flagSuspiciousActivity(userId, 'excessive_card_deletion');
      return false;
    }
    
    // Check cooldown period
    if (await _isInCooldown(userId)) {
      return false;
    }
    
    // Check device fingerprinting
    final deviceId = await _getDeviceId();
    if (await _isDeviceFlagged(deviceId)) {
      return false;
    }
    
    return true;
  }
}
```

### **Device Fingerprinting**
```dart
class DeviceFingerprintService {
  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }
    return 'unknown';
  }
}
```

---

## 🚀 **Performance Architecture**

### **Caching Strategy**
```
Local Storage (Hive)
├── User Cards Cache
├── Scanned Cards Cache
├── User Profile Cache
└── Settings Cache

Firebase Cache
├── Firestore Offline Cache
├── Authentication Cache
└── Storage Cache

Memory Cache
├── Provider State
├── Image Cache
└── Network Cache
```

### **Optimization Techniques**
- **Lazy Loading**: Cards loaded on demand
- **Image Optimization**: Compressed profile photos
- **Network Optimization**: Batch operations
- **Memory Management**: Efficient state management

---

## 📱 **Platform-Specific Architecture**

### **Android**
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### **iOS**
```swift
// ios/Runner/Info.plist
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to upload profile photos</string>
```

### **Web**
```html
<!-- web/index.html -->
<script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-firestore.js"></script>
```

---

## 🔄 **Deployment Architecture**

### **Build Pipeline**
```
Development → Testing → Staging → Production
     ↓           ↓         ↓         ↓
   Local      Unit Tests  QA Tests  Live Users
```

### **Environment Configuration**
```dart
// lib/firebase_options.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }
}
```

---

## 📊 **Monitoring & Analytics**

### **Error Tracking**
```dart
// Error handling and logging
try {
  await _performOperation();
} catch (e) {
  print("Error: $e");
  // Log to Firebase Analytics
  await FirebaseAnalytics.instance.logEvent(
    name: 'error_occurred',
    parameters: {'error': e.toString()},
  );
}
```

### **Performance Monitoring**
- **Firebase Performance**: App performance tracking
- **Crashlytics**: Crash reporting and analysis
- **Analytics**: User behavior tracking
- **Custom Metrics**: Business-specific metrics

---

## 🔐 **Security Best Practices**

### **Data Protection**
- **Encryption**: All data encrypted in transit and at rest
- **Authentication**: Multi-factor authentication support
- **Authorization**: Role-based access control
- **Audit Logging**: Comprehensive activity logging

### **Privacy Compliance**
- **Data Minimization**: Only necessary data collected
- **User Consent**: Clear consent mechanisms
- **Data Retention**: Automatic data cleanup
- **Right to Deletion**: User data deletion support

---

## 🚀 **Scalability Architecture**

### **Horizontal Scaling**
- **Firebase Auto-scaling**: Automatic resource scaling
- **CDN Integration**: Global content delivery
- **Load Balancing**: Distributed request handling

### **Vertical Scaling**
- **Database Optimization**: Query performance improvements
- **Caching Strategy**: Multi-level caching
- **Resource Optimization**: Efficient resource usage

---

## 📋 **Development Guidelines**

### **Code Standards**
```dart
// Dart/Flutter style guide
class UserCard {
  final String id;
  final String fullName;
  final String phoneNumber;
  
  const UserCard({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
  });
  
  // Factory constructor for JSON
  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
```

### **Testing Strategy**
- **Unit Tests**: Individual component testing
- **Integration Tests**: End-to-end testing
- **Widget Tests**: UI component testing
- **Performance Tests**: Load and stress testing

---

**Last Updated**: January 9, 2024  
**Architecture Version**: 1.4.0  
**Maintainer**: Development Team
