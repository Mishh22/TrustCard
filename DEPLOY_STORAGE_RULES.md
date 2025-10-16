# Deploy Firebase Storage Rules

## ⚠️ URGENT: You need to deploy these rules to fix document uploads

The "too many uploads" error is happening because the Firebase Storage rules don't match the new document storage path.

## Quick Fix (2 minutes):

### Step 1: Go to Firebase Console
1. Open: https://console.firebase.google.com/
2. Select project: **trustcard-aee4a**
3. Click **Storage** in the left sidebar
4. Click the **Rules** tab at the top

### Step 2: Replace Rules
Copy and paste these rules (replace everything):

```
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // User documents for card verification
    match /users/{userId}/cards/{cardId}/documents/{documentId}/{filename} {
      // Users can only read/write their own documents
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null 
                   && request.auth.uid == userId
                   && request.resource.size < 10 * 1024 * 1024;  // 10MB max (for PDFs and images)
    }
    
    // Verification documents - strict security (legacy path, keeping for compatibility)
    match /verification-docs/{documentId}/{filename} {
      // Only authenticated users can read/write
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.resource.size < 5 * 1024 * 1024;  // 5MB max
    }
    
    // Profile photos - less strict
    match /profile-photos/{userId}/{filename} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.auth.uid == userId
                   && request.resource.size < 2 * 1024 * 1024  // 2MB max
                   && request.resource.contentType.matches('image/.*');
    }
    
    // Deny all other paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Step 3: Publish
1. Click **Publish** button
2. Wait for confirmation message

### Step 4: Test
1. Go back to your iPhone app
2. Try uploading a document again
3. It should work now! ✅

## What Changed?

- ✅ **Added new path**: `/users/{userId}/cards/{cardId}/documents/` for the document management system
- ✅ **Increased size limit**: 10MB (was 5MB) to support larger PDFs
- ✅ **Removed rate limiting**: No more "wait 1 hour" messages
- ✅ **Better security**: Users can only upload to their own user ID path
- ✅ **Supports PDFs & Images**: Both file types are now allowed

## Storage Path Structure:
```
users/
  {userId}/
    cards/
      {cardId}/
        documents/
          {documentId}/
            {filename}
```

Example:
```
users/aR7ug3kIyhdeyRYhAKTELHt2X2q1/cards/abc123/documents/doc456/aadhaar.pdf
```

