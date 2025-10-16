# TestCard - Digital Business Card App

## 📱 **App Overview**

TestCard is a comprehensive Flutter-based digital business card application that enables users to create, share, and manage digital business cards with advanced trust scoring, verification systems, and abuse prevention mechanisms.

### **Key Features**
- 🎴 **Digital Business Cards**: Create and manage professional digital cards
- 📱 **QR Code System**: Generate and scan QR codes for easy sharing
- 🏆 **Trust Scoring**: Advanced algorithm-based trust scoring system
- 🏢 **Company Verification**: Multi-level verification workflow
- 🛡️ **Abuse Prevention**: Comprehensive security and abuse prevention system
- 📊 **Analytics**: User behavior and engagement tracking
- 🔐 **Security**: Multi-layer security with Firebase backend

---

## 📚 **Documentation Index**

### **📖 Core Documentation**
- **[APP_DOCUMENTATION.md](./APP_DOCUMENTATION.md)** - Complete app documentation with features, architecture, and usage
- **[TECHNICAL_ARCHITECTURE.md](./TECHNICAL_ARCHITECTURE.md)** - Technical architecture, system design, and implementation details
- **[CHANGE_LOG.md](./CHANGE_LOG.md)** - Change tracking and version history

### **🛡️ Security & Abuse Prevention**
- **[ABUSE_PREVENTION_SETUP.md](./ABUSE_PREVENTION_SETUP.md)** - Comprehensive abuse prevention system documentation
- **[CARD_LIMITS_SETUP.md](./CARD_LIMITS_SETUP.md)** - Card limits configuration guide

### **🔧 Configuration & Setup**
- **[FIREBASE_SETUP.md](./FIREBASE_SETUP.md)** - Firebase configuration and setup
- **[DEPLOY_RULES.md](./DEPLOY_RULES.md)** - Deployment guidelines and rules
- **[TEST_PHONE_SETUP.md](./TEST_PHONE_SETUP.md)** - Testing phone number setup

---

## 🚀 **Quick Start**

### **Prerequisites**
- Flutter SDK 3.x
- Dart 3.x
- Firebase project setup
- Android Studio / VS Code
- Git

### **Installation**
```bash
# Clone the repository
git clone <repository-url>
cd TestCard

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **Firebase Setup**
1. Create Firebase project
2. Enable Authentication, Firestore, Storage
3. Configure security rules
4. Set up Cloud Functions
5. Update `firebase_options.dart`

---

## 🏗️ **Architecture Overview**

### **Frontend (Flutter)**
- **State Management**: Provider pattern
- **Navigation**: GoRouter declarative routing
- **UI Framework**: Material Design 3
- **Platform Support**: Android, iOS, Web, Desktop

### **Backend (Firebase)**
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Functions**: Cloud Functions
- **Security**: Firestore Security Rules

### **Key Components**
```
lib/
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Business logic
├── widgets/         # Reusable components
└── utils/           # Utilities
```

---

## 🛡️ **Security Features**

### **Multi-Layer Security**
1. **Client-Side Validation**: Input validation and format checking
2. **Authentication**: Phone OTP and email verification
3. **Authorization**: Role-based access control
4. **Abuse Prevention**: Comprehensive abuse detection system
5. **Database Security**: Firestore security rules

### **Abuse Prevention System**
- **Lifecycle Tracking**: Permanent audit trail of all operations
- **Device Fingerprinting**: Cross-device abuse detection
- **Trust Score Inheritance**: Deletion penalties carry forward
- **Velocity Limits**: Prevents rapid card creation/deletion
- **Admin Review**: Manual oversight for flagged users

---

## 🏆 **Trust Scoring System**

### **Algorithm Components**
- **Account Age (30%)**: Time-based trust building
- **Verification Level (30%)**: Document and company verification
- **Service History (25%)**: Customer ratings and reviews
- **Network Trust (15%)**: Colleague endorsements

### **Verification Levels**
1. **Basic**: Phone verification only
2. **Document**: Document upload verification
3. **Peer**: Colleague endorsements
4. **Company**: Official company verification

---

## 📊 **Features Overview**

### **Core Features**
- ✅ Digital card creation and management
- ✅ QR code generation and scanning
- ✅ Multi-level verification system
- ✅ Trust scoring algorithm
- ✅ Company verification workflow
- ✅ Card sharing and networking
- ✅ Firebase backend integration

### **Security Features**
- ✅ Abuse prevention system
- ✅ Device fingerprinting
- ✅ Trust score inheritance
- ✅ Velocity limits and cooldowns
- ✅ Admin review system
- ✅ Appeal process for false positives

### **Advanced Features**
- ✅ Configurable card limits
- ✅ Demo cards system
- ✅ Real-time synchronization
- ✅ Offline support
- ✅ Cross-platform compatibility

---

## 🔧 **Configuration**

### **Card Limits**
```json
// Firebase: app_config/limits
{
  "maxCardsPerUser": 10,
  "updatedAt": "2024-01-01T00:00:00Z",
  "updatedBy": "admin"
}
```

### **Abuse Prevention Settings**
- **Cooldown Periods**: 24h → 72h → 168h
- **Velocity Limits**: Max 3 deletions per 30 days
- **Device Limits**: Max 5 cards per device per 30 days
- **Trust Score Penalties**: -5, -10, -20 points for recreations

---

## 📱 **Platform Support**

### **Supported Platforms**
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Modern browsers
- **Desktop**: Windows, macOS, Linux

### **Dependencies**
```yaml
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

---

## 🚀 **Deployment**

### **Build Commands**
```bash
# Development
flutter run

# Production build
flutter build apk --release
flutter build ios --release
flutter build web --release
```

### **Firebase Deployment**
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Cloud Functions
firebase deploy --only functions

# Deploy Storage rules
firebase deploy --only storage
```

---

## 📈 **Monitoring & Analytics**

### **Firebase Services**
- **Analytics**: User behavior tracking
- **Crashlytics**: Crash reporting
- **Performance**: App performance monitoring
- **Remote Config**: Dynamic configuration

### **Custom Metrics**
- **Trust Score Distribution**: Track trust score patterns
- **Verification Rates**: Monitor verification success
- **Abuse Detection**: Track flagged users and devices
- **User Engagement**: Monitor app usage patterns

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

## 📞 **Support**

### **User Support**
- **In-App Help**: Built-in help system
- **FAQ**: Frequently asked questions
- **Contact**: Support contact information

### **Developer Support**
- **Documentation**: Comprehensive technical documentation
- **Code Examples**: Implementation examples
- **Best Practices**: Development guidelines

---

## 📋 **Contributing**

### **Development Guidelines**
- **Code Standards**: Follow Dart/Flutter style guide
- **Documentation**: Update documentation with changes
- **Testing**: Write tests for new features
- **Code Review**: Peer review process

### **Change Management**
- **Feature Requests**: Submit via issue tracker
- **Bug Reports**: Detailed bug reporting
- **Pull Requests**: Follow contribution guidelines
- **Version Control**: Git best practices

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📊 **Project Status**

### **Current Version**: 1.4.0
### **Last Updated**: January 9, 2024
### **Maintainer**: Development Team

### **Recent Updates**
- ✅ Comprehensive abuse prevention system
- ✅ Enhanced security and monitoring
- ✅ Complete documentation system
- ✅ Change tracking and version control

---

## 🔮 **Roadmap**

### **Version 1.5.0 (Planned)**
- 🤖 Machine learning for abuse detection
- 📊 Advanced analytics dashboard
- 🌐 Enhanced social features
- 🔗 API integrations

### **Version 2.0.0 (Planned)**
- 🏗️ Microservices architecture
- 📱 Enhanced offline support
- 🌍 Global CDN integration
- 🔐 Advanced security features

---

**📱 TestCard - Digital Business Cards with Trust & Security**