# Profile Update Issue Analysis

## Current Problem
The profile edit functionality is getting stuck on a "waiting wheel" (loading spinner) and never completes.

## Root Cause Analysis

### What Happens When Profile is Updated:
1. User clicks "Edit" button in profile screen
2. `_showEditProfileDialog` shows a dialog with text fields
3. User enters new name/company/designation
4. User clicks "Save"
5. Dialog closes and shows loading spinner
6. Calls `authProvider.updateProfile()`
7. **Gets stuck here - never completes**

### Code Flow:
```dart
// profile_screen.dart
await authProvider.updateProfile(
  fullName: nameController.text.trim(),
  companyName: companyController.text.trim(),
  designation: designationController.text.trim(),
);

// auth_provider.dart - updateProfile method
_currentUser = _currentUser!.copyWith(/* updated fields */);
await _saveUserToFirestore(_currentUser!);  // <- Gets stuck here

// auth_provider.dart - _saveUserToFirestore method
await FirebaseService.saveUserCard(user.userId, user.toMap());  // <- Hangs

// firebase_service.dart - saveUserCard method
await _firestore.collection('users').doc(userId).set(cardData, SetOptions(merge: true));
```

## Possible Causes

### 1. **userId is Invalid or Empty**
- If `user.userId` is null or empty, the Firestore operation might fail
- Old data loaded from `users` collection might not have `userId` field
- The fallback in `UserCard.fromMap` sets `userId = id`, but this might not be working correctly

### 2. **Firestore Permission Error**
- The app might not have permission to write to the `users` collection
- Firestore security rules might be blocking the write operation

### 3. **Network/Connection Issue**
- The Firestore operation is timing out
- No error handling to catch timeout

### 4. **Data Structure Mismatch**
- The data being saved has fields that violate Firestore schema
- Some field types might be incompatible

## Current Data Structure

### Old Structure (what's currently in Firestore):
```javascript
users/{userId}/
  - id: userId (Firebase auth UID)
  - fullName: string
  - phoneNumber: string
  - companyName: string
  - designation: string
  - ... other fields
```

### New Structure (what we implemented):
```javascript
users/{userId}/  // Old collection (for backward compatibility)
  - id: cardId (UUID)
  - userId: userId (Firebase auth UID)
  - fullName: string
  - ...

user_cards/{cardId}/  // New collection (for QR codes)
  - id: cardId (UUID)
  - userId: userId (Firebase auth UID)
  - fullName: string
  - ...
```

## The Issue

When loading existing users:
- Data in Firestore has: `id = Firebase UID`
- `UserCard.fromMap` loads this and sets: `userId = id` (fallback)
- So both `id` and `userId` become the Firebase UID
- When we try to save: `FirebaseService.saveUserCard(user.userId, user.toMap())`
- We're passing Firebase UID, which is correct
- **But the data being saved has `id = Firebase UID` and `userId = Firebase UID`**
- This should work...

## Most Likely Cause

The operation is hanging due to **Firestore offline mode or caching issues**. The `set()` operation with `SetOptions(merge: true)` might be waiting for network confirmation and never timing out.

## Recommended Fix

Add explicit error handling and timeout to the save operation:

```dart
Future<void> _saveUserToFirestore(UserCard user) async {
  try {
    await FirebaseService.saveUserCard(user.userId, user.toMap())
        .timeout(Duration(seconds: 10));
  } catch (e) {
    print('Error saving user to Firestore: $e');
    rethrow;
  }
}
```

Or, more simply, check if `userId` is valid before saving:

```dart
Future<void> _saveUserToFirestore(UserCard user) async {
  try {
    if (user.userId.isEmpty) {
      throw Exception('User ID is empty');
    }
    print('Saving user with userId: ${user.userId}');
    await FirebaseService.saveUserCard(user.userId, user.toMap());
    print('User saved successfully');
  } catch (e) {
    print('Error saving user to Firestore: $e');
    rethrow;
  }
}
```

## Status
- ✅ Fixed `userId` field addition to UserCard model
- ✅ Fixed UserCard instantiations across the app
- ✅ Fixed `_saveUserToFirestore` to use `user.userId` instead of `user.id`
- ❌ Profile update still hangs (needs more investigation)

## Next Steps
1. Add debug logging to see exactly where it's getting stuck
2. Add timeout to Firestore operations
3. Check Firestore console for actual data structure
4. Verify network connectivity and Firestore rules

