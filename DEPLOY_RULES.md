# Deploy Firestore Rules via Console

Since Firebase CLI is not installed, you can deploy the rules directly in the Firebase Console:

## Option 1: Deploy via Firebase Console (Recommended - 2 minutes)

1. Go to https://console.firebase.google.com/
2. Select project **trustcard-aee4a**
3. Click **Firestore Database** in the left sidebar
4. Click the **Rules** tab at the top
5. Replace ALL the content with the rules below
6. Click **Publish**

### Copy these rules:

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // User cards - users can read/write their own (using userId as docId)
    match /userCards/{userId} {
      // Allow read/write if authenticated user matches the document ID
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow creation if authenticated
      allow create: if request.auth != null;
    }
    
    // Verification requests - users can manage their own
    match /verificationRequests/{requestId} {
      // Allow users to read their own requests
      allow read: if request.auth != null 
                  && request.auth.uid == resource.data.userId;
      
      // Allow users to create requests for themselves
      allow create: if request.auth != null 
                   && request.auth.uid == request.resource.data.userId;
      
      // Allow users to update their own requests
      allow update: if request.auth != null 
                   && request.auth.uid == resource.data.userId;
    }
    
    // User notifications - users can read their own
    match /userNotifications/{notificationId} {
      allow read: if request.auth != null 
                  && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    // Activity logs - minimal write access for tracking
    match /activityLogs/{logId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null 
                  && request.auth.uid == resource.data.userId;
    }
    
    // Development mode: Allow authenticated users basic access
    // TODO: Tighten these rules for production
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Option 2: Install Firebase CLI (Optional)

If you want to use the CLI in the future:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init

# Deploy rules
firebase deploy --only firestore:rules
```

---

## ✅ After Publishing Rules

Your app will be able to:
- Save user data to Firestore
- Load user data from Firestore
- Sync changes in real-time across devices
- Authenticate with phone OTP

The Firestore errors in your app should disappear after publishing these rules!
