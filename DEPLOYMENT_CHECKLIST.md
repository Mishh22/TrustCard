# TrustCard App Deployment Checklist

## ✅ Completed Preparations

### Android Configuration
- [x] **Release Signing**: Configured Android release signing (using debug keystore for now)
- [x] **App Icons**: Generated all required Android icon sizes (48dp, 72dp, 96dp, 144dp, 192dp)
- [x] **Manifest**: Updated AndroidManifest.xml with proper configuration
- [x] **ProGuard**: Added ProGuard rules for code obfuscation
- [x] **Firebase**: Google Services configuration is in place

### iOS Configuration
- [x] **App Icons**: Generated all required iOS icon sizes (20pt to 1024pt)
- [x] **Info.plist**: Proper permissions and descriptions configured
- [x] **Bundle ID**: Configured as com.accexasia.TrustCard
- [x] **Firebase**: iOS Firebase configuration ready

### App Store Assets
- [x] **App Icons**: All sizes generated from your TClogo_dark.png
- [x] **Privacy Policy**: Comprehensive privacy policy created
- [x] **Store Descriptions**: Complete app store descriptions and metadata
- [x] **Keywords**: ASO keywords identified

## 🚨 Critical Actions Required Before Deployment

### 1. Android Production Signing (CRITICAL)
```bash
# Generate production keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Create key.properties file
echo "storePassword=YOUR_STORE_PASSWORD" > android/key.properties
echo "keyPassword=YOUR_KEY_PASSWORD" >> android/key.properties
echo "keyAlias=upload" >> android/key.properties
echo "storeFile=../upload-keystore.jks" >> android/key.properties
```

### 2. iOS Code Signing (CRITICAL)
- [ ] **Apple Developer Account**: Register for Apple Developer Program ($99/year)
- [ ] **Certificates**: Create iOS Distribution Certificate
- [ ] **Provisioning Profile**: Create App Store Distribution Provisioning Profile
- [ ] **Bundle ID**: Register com.accexasia.TrustCard in Apple Developer Portal

### 3. Developer Accounts
- [ ] **Google Play Console**: Register and pay $25 one-time fee
- [ ] **Apple App Store Connect**: Register and pay $99/year fee

### 4. App Store Listings
- [ ] **Screenshots**: Take screenshots on different devices (iPhone, iPad, Android)
- [ ] **App Description**: Use the provided descriptions
- [ ] **Keywords**: Add identified keywords
- [ ] **Age Rating**: Complete age rating questionnaires
- [ ] **Content Rating**: Ensure compliance with store guidelines

## 🚀 Deployment Commands

### Android Release Build
```bash
# Build Android App Bundle (recommended)
flutter build appbundle --release

# Or build APK
flutter build apk --release
```

### iOS Release Build
```bash
# Build iOS app
flutter build ios --release

# Archive for App Store
# Use Xcode to archive and upload to App Store Connect
```

## 📱 Testing Before Release

### Device Testing
- [ ] **Android**: Test on multiple Android devices (different screen sizes)
- [ ] **iOS**: Test on iPhone and iPad
- [ ] **Permissions**: Test all camera, storage, and contact permissions
- [ ] **QR Scanning**: Test QR code generation and scanning
- [ ] **Firebase**: Test authentication and data sync
- [ ] **Offline**: Test app behavior without internet

### Store Compliance
- [ ] **Privacy Policy**: Host privacy policy online
- [ ] **Terms of Service**: Create and host terms of service
- [ ] **Data Collection**: Ensure compliance with GDPR/CCPA
- [ ] **Permissions**: Justify all requested permissions

## 🔄 Update Process

### For Future Updates
1. **Update Version**: Change version in `pubspec.yaml`
2. **Build Release**: Create new release builds
3. **Upload**: Upload to respective app stores
4. **Review**: Wait for approval (Apple: 1-7 days, Google: 1-3 hours)
5. **Release**: Users receive automatic updates

### Version Management
```yaml
# pubspec.yaml
version: 1.0.1+2  # version+build_number
```

## 📊 Post-Launch Monitoring

### Analytics Setup
- [ ] **Firebase Analytics**: Monitor app usage
- [ ] **Crash Reporting**: Set up crash reporting
- [ ] **User Feedback**: Monitor app store reviews
- [ ] **Performance**: Monitor app performance metrics

### Maintenance
- [ ] **Regular Updates**: Plan for regular feature updates
- [ ] **Security Updates**: Keep dependencies updated
- [ ] **Store Compliance**: Stay updated with store policies
- [ ] **User Support**: Set up customer support channels

## 🎯 Ready for Deployment?

### Current Status: **ALMOST READY** ✅

**What's Done:**
- ✅ App icons generated from your logo
- ✅ Android signing configured
- ✅ Privacy policy created
- ✅ Store descriptions written
- ✅ App configuration optimized

**What's Needed:**
- 🔄 Production keystore for Android
- 🔄 Apple Developer account setup
- 🔄 Screenshots for store listings
- 🔄 Final testing on devices

**Estimated Time to Launch:** 2-3 days (after completing critical actions)

## 📞 Support Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Google Play Console**: https://play.google.com/console
- **Apple App Store Connect**: https://appstoreconnect.apple.com
- **Firebase Console**: https://console.firebase.google.com

---

**Next Steps:**
1. Generate production keystore for Android
2. Set up Apple Developer account
3. Take app screenshots
4. Test on real devices
5. Submit to app stores
