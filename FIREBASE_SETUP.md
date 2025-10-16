# Firebase Setup Guide for TestCard App

This guide will help you configure Firebase services for the TestCard app, including Authentication (with OTP), Firestore Database, and Storage.

## 🔥 Firebase Console Setup Steps

### 1. Enable Firestore Database

The app needs Firestore to store user data and enable real-time sync across devices.

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **trustcard-aee4a**
3. Click on **Firestore Database** in the left sidebar
4. Click **Create database**
5. Select **Start in production mode** (we've already configured security rules in `firestore.rules`)
6. Choose a location (preferably close to your users, e.g., `us-central1` or `asia-south1`)
7. Click **Enable**

**✅ Expected Result:** You should see an empty Firestore database ready to use.

---

### 2. Enable Phone Authentication (OTP)

The app supports phone number authentication with OTP for seamless login.

1. In Firebase Console, click **Authentication** in the left sidebar
2. Click **Get started** (if not already enabled)
3. Go to the **Sign-in method** tab
4. Find **Phone** in the list and click on it
5. Toggle **Enable** to ON
6. Click **Save**

#### 2.1 Configure Test Phone Numbers (For Development)

For testing on emulators or without real SMS, set up test phone numbers:

1. In the Phone sign-in settings, scroll down to **Phone numbers for testing**
2. Click **Add phone number**
3. Add test numbers with test codes:
   - Phone: `+91 9999999999` → Code: `123456`
   - Phone: `+1 5555555555` → Code: `123456`
4. Click **Save**

**Note:** These test numbers won't send actual SMS but will work with the test codes.

---

### 3. Deploy Firestore Security Rules

The app includes security rules in `firestore.rules` that need to be deployed:

```bash
# Deploy from project root
firebase deploy --only firestore:rules
```

**What the rules do:**
- ✅ Users can only read/write their own data
- ✅ Real-time sync works across all logged-in devices
- ✅ Development-friendly (allows authenticated users access)
- ⚠️ **Remember to tighten rules for production**

---

### 4. Verify Firebase Storage (Already Enabled)

You mentioned storage is already enabled. Verify it's working:

1. Click **Storage** in the left sidebar
2. You should see a bucket created
3. Storage rules are in `firebase-storage.rules`

---

## 📱 How the Features Work

### ✅ Phone Authentication with OTP

**User Flow:**
1. User enters phone number
2. Firebase sends SMS with OTP (or uses test code for test numbers)
3. User enters OTP
4. App authenticates and creates/loads user profile
5. User data is saved to Firestore

**Code location:** `lib/providers/auth_provider.dart` - `sendOTP()` and `verifyOTP()` methods

---

### ✅ Real-Time Sync Across Devices

**How it works:**
- When user logs in on Device A, their data loads from Firestore
- User updates profile on Device A → changes save to Firestore
- Device B (logged in with same account) **automatically receives updates in real-time**
- No refresh needed!

**Code location:** 
- `lib/services/firebase_service.dart` - `getUserCardStream()` for real-time listener
- `lib/providers/auth_provider.dart` - `_setupRealtimeSync()` sets up the listener

---

### ✅ Minimal Resource Usage During Development

**Current setup is development-optimized:**

1. **Firestore:**
   - Free tier: 50K reads/20K writes per day
   - Our app: ~10-50 reads/writes per user per day
   - **Recommendation:** Limit to 5-10 test users during development

2. **Storage:**
   - Free tier: 5GB stored, 1GB/day downloaded
   - Our app: Profile photos and documents
   - **Recommendation:** Use compressed images (max 500KB per image)

3. **Authentication:**
   - Completely free for phone auth
   - Use test phone numbers to avoid SMS charges

---

## 🧪 Testing the Setup

### Test Phone Authentication

1. Launch the app on Android emulator
2. On the login screen, enter a test phone number: `+91 9999999999`
3. Click **Send OTP**
4. Enter the test code: `123456`
5. User should be authenticated and see their profile

### Test Real-Time Sync

1. Log in with the same account on two different devices (or emulator + physical device)
2. On Device A: Update profile name
3. On Device B: **Profile name updates automatically** without refresh!

---

## 🔒 Security Reminders

### For Development:
- ✅ Current rules allow authenticated users full access
- ✅ Users can only access their own data
- ✅ Test phone numbers work without SMS charges

### Before Production:
1. Remove test phone numbers
2. Update Firestore rules to be more restrictive (see TODO in `firestore.rules`)
3. Enable App Check for additional security
4. Set up monitoring and alerts

---

## 📊 Monitoring Usage

Track your Firebase usage to stay within free tier:

1. Go to Firebase Console → **Usage and billing**
2. Monitor:
   - Firestore: Read/Write operations
   - Storage: Stored data and bandwidth
   - Authentication: Active users

**Free Tier Limits:**
- Firestore: 50K reads, 20K writes, 20K deletes per day
- Storage: 5GB stored, 1GB/day download
- Authentication: Unlimited

---

## 🚀 Quick Start Commands

```bash
# Check Firebase project
firebase projects:list

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# Monitor Firestore in real-time
firebase firestore:indexes

# Run the app
flutter run -d emulator-5554
```

---

## 🆘 Troubleshooting

### "Database does not exist" error
- **Solution:** Follow Step 1 to create Firestore database

### "Phone authentication failed" on emulator
- **Solution:** Use test phone numbers configured in Step 2.1

### "Permission denied" in Firestore
- **Solution:** Deploy Firestore rules using `firebase deploy --only firestore:rules`

### Real-time sync not working
- **Solution:** Check internet connection and ensure user is authenticated

---

## 📞 Need Help?

- Firebase Documentation: https://firebase.google.com/docs
- Flutter Fire: https://firebase.flutter.dev/
- Stack Overflow: Tag with `firebase`, `flutter`, `firestore`

---

**Your app is now configured for:**
- ✅ Phone OTP Authentication
- ✅ Real-time sync across devices
- ✅ Development-friendly resource usage
- ✅ Secure user data management

Happy coding! 🎉
