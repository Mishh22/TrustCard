# 🍎 Apple App Store Deployment Guide

## 📱 **TrustCard iOS App Store Upload Process**

---

## 🚀 **Step 1: Build iOS App for App Store**

### **1.1 Open Xcode Project:**
```bash
cd /Users/manishyadav/AndroidStudioProjects/TestCard
open ios/Runner.xcworkspace
```

### **1.2 Build iOS App:**
```bash
flutter build ios --release
```

### **1.3 Archive for App Store:**
- Open Xcode
- Select "Any iOS Device" as target
- Go to **Product → Archive**
- Wait for archive to complete

---

## 🔐 **Step 2: iOS Code Signing Setup**

### **2.1 Apple Developer Account Requirements:**
- **Apple Developer Program membership** ($99/year)
- **Valid Apple ID** with developer access
- **iOS Distribution Certificate**
- **App Store Provisioning Profile**

### **2.2 Automatic Signing (Recommended):**
1. **Open Xcode**
2. **Select Runner project**
3. **Go to "Signing & Capabilities" tab**
4. **Check "Automatically manage signing"**
5. **Select your Team** (Apple Developer Account)
6. **Bundle Identifier:** `com.accexasia.TrustCard`

### **2.3 Manual Signing (If needed):**
1. **Create Distribution Certificate** in Apple Developer Portal
2. **Create App Store Provisioning Profile**
3. **Download and install** both files
4. **Configure in Xcode**

---

## 📤 **Step 3: Upload to App Store Connect**

### **3.1 Using Xcode Organizer:**
1. **Open Xcode Organizer** (Window → Organizer)
2. **Select your archive**
3. **Click "Distribute App"**
4. **Select "App Store Connect"**
5. **Choose "Upload"**
6. **Select your team**
7. **Click "Upload"**

### **3.2 Using Application Loader (Alternative):**
1. **Build IPA file** in Xcode
2. **Open Application Loader**
3. **Upload IPA file**

---

## 🏪 **Step 4: App Store Connect Configuration**

### **4.1 Access App Store Connect:**
- Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- **Sign in** with your Apple Developer Account
- **Create new app** if not exists

### **4.2 App Information:**
- **Name:** TrustCard
- **Bundle ID:** com.accexasia.TrustCard
- **SKU:** TrustCard-2024
- **Language:** English (US)
- **Category:** Business

### **4.3 App Store Listing:**
- **App Name:** TrustCard - Digital ID Verification
- **Subtitle:** Secure Digital Identity & QR Cards
- **Description:** [Use the same description from Google Play]
- **Keywords:** digital ID, QR code, business card, identity verification
- **Support URL:** [Your website or support email]
- **Marketing URL:** [Your website]

---

## 📸 **Step 5: Screenshots and Metadata**

### **5.1 Required Screenshots:**
- **iPhone 6.7" Display:** 1290 x 2796 pixels
- **iPhone 6.5" Display:** 1242 x 2688 pixels
- **iPhone 5.5" Display:** 1242 x 2208 pixels
- **iPad Pro (6th gen):** 2048 x 2732 pixels

### **5.2 App Icon:**
- **1024 x 1024 pixels** (PNG format)
- **No transparency or rounded corners**
- **High resolution**

### **5.3 App Preview (Optional):**
- **30-second video** showing app functionality
- **MP4 or MOV format**
- **Various device sizes**

---

## 📋 **Step 6: App Store Review Information**

### **6.1 Review Notes:**
```
TrustCard is a digital identity verification app that allows users to:
- Create secure digital identities
- Generate QR codes for sharing
- Verify identity documents
- Manage business profiles

The app requires camera permission for QR code scanning and photo library access for document uploads.
```

### **6.2 Contact Information:**
- **First Name:** [Your name]
- **Last Name:** [Your last name]
- **Phone Number:** [Your phone]
- **Email:** accexasia@gmail.com

---

## 🔍 **Step 7: Submit for Review**

### **7.1 Final Checklist:**
- ✅ **App uploaded successfully**
- ✅ **Screenshots added**
- ✅ **App description complete**
- ✅ **Privacy policy URL provided**
- ✅ **App icon uploaded**
- ✅ **Review notes added**
- ✅ **Contact information filled**

### **7.2 Submit for Review:**
1. **Go to "App Store" tab**
2. **Click "Submit for Review"**
3. **Confirm submission**
4. **Wait for Apple's review** (1-7 days)

---

## ⏰ **Timeline and Expectations**

### **Review Process:**
- **Initial review:** 1-7 days
- **Rejection (if any):** Fix issues and resubmit
- **Approval:** App goes live on App Store

### **Common Rejection Reasons:**
- **Missing privacy policy**
- **Incomplete app information**
- **App crashes or bugs**
- **Policy violations**

---

## 🆘 **Troubleshooting**

### **Build Issues:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build ios --release
```

### **Signing Issues:**
- **Check Apple Developer Account** membership
- **Verify certificates** are valid
- **Update provisioning profiles**

### **Upload Issues:**
- **Check internet connection**
- **Verify app size** (under 4GB)
- **Ensure all required fields** are completed

---

## 📞 **Support Resources**

- **Apple Developer Documentation:** [developer.apple.com](https://developer.apple.com)
- **App Store Connect Help:** [help.apple.com](https://help.apple.com)
- **Xcode Documentation:** [developer.apple.com/xcode](https://developer.apple.com/xcode)

---

**Your TrustCard app is ready for Apple App Store deployment! 🚀**
