# TrustCard Admin Setup

This directory contains scripts to set up admin privileges for the TrustCard app.

## 🔐 Admin Authentication System

### Who Can Be Admin:
- **Project Owner** (you) - Primary admin
- **Trusted Team Members** - Document reviewers
- **Company HR/Admin** - For company verification

### How Admin Access Works:

1. **Firebase Custom Claims**: Admin status is stored in Firebase Authentication
2. **App-Level Check**: The app checks if user has `admin: true` claim
3. **UI Access Control**: Only admins see "Admin Verification" menu

## 🚀 Setup Instructions

### Method 1: Firebase Console (Manual)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `trustcard-aee4a`
3. Go to **Authentication** → **Users**
4. Find the user (e.g., `manish@email.com`)
5. Click **"Custom Claims"**
6. Add: `{"admin": true}`
7. Click **"Save"**

### Method 2: Script (Automated)
1. **Install dependencies:**
   ```bash
   cd scripts
   npm install
   ```

2. **Get Firebase Service Account:**
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate new private key"
   - Download the JSON file
   - Replace the `serviceAccount` object in `setup-admin.js`

3. **Run the script:**
   ```bash
   npm run setup-admin
   ```

## 👥 Who Should Have Admin Access:

### Primary Admins:
- `manish@email.com` - Project owner
- `admin@trustcard.com` - Main admin account

### Document Reviewers:
- HR managers
- Trusted team members
- Company administrators

## 🔧 Admin Features:

Once admin access is granted, users can:
- ✅ See "Admin Verification" in profile menu
- ✅ Review pending document uploads
- ✅ Approve/reject documents with reasons
- ✅ Send notifications to users about their verification status

## 🛡️ Security Notes:

- **Admin privileges are permanent** until manually removed
- **Only Firebase Console admins** can grant/revoke admin access
- **Custom claims are secure** and cannot be modified by app users
- **Admin actions are logged** in Firebase for audit purposes

## 🚨 Troubleshooting:

### "Admin Verification" not showing:
1. Check if user has `admin: true` in Firebase Console
2. User must log out and log back in
3. Check Firebase Console → Authentication → Users → Custom Claims

### Script not working:
1. Ensure Firebase CLI is installed: `npm install -g firebase-tools`
2. Login to Firebase: `firebase login`
3. Set project: `firebase use trustcard-aee4a`
4. Check service account JSON is correct

## 📞 Support:

If you need help setting up admin access, check:
1. Firebase Console → Authentication → Users
2. Look for "Custom Claims" column
3. Ensure `{"admin": true}` is set for admin users
