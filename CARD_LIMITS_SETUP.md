# Card Limits Configuration

This document explains how to configure card creation limits for users in the TestCard app.

## Overview

The app now supports configurable card creation limits that can be adjusted through Firebase without requiring app updates. Demo cards are excluded from the limit count.

## Firebase Configuration

### Step 1: Create Configuration Collection

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **trustcard-aee4a**
3. Click **Firestore Database** in the left sidebar
4. Click **Start collection**
5. Collection ID: `app_config`
6. Document ID: `limits`

### Step 2: Add Configuration Fields

Add the following fields to the `limits` document:

```json
{
  "maxCardsPerUser": 5,
  "updatedAt": "2024-01-01T00:00:00Z",
  "updatedBy": "admin"
}
```

### Step 3: Adjust Limits

To change the card limit:
1. Open the `app_config/limits` document
2. Update the `maxCardsPerUser` field
3. Update the `updatedAt` timestamp
4. Save the document

## How It Works

### Demo Cards Exclusion
- Demo cards (Rahul Kumar, Priya Sharma) are marked with `isDemoCard: true`
- These cards do NOT count towards the user's card limit
- Users can create cards up to the configured limit in addition to demo cards

### Limit Enforcement
- When a user tries to create a new card, the app checks their current card count
- Only user-created cards (non-demo) are counted
- If the limit is reached, creation is blocked with an error message

### Default Behavior
- If no configuration is found, the default limit is 10 cards
- If Firebase is unavailable, the default limit is still enforced
- Demo cards are always excluded from the count

## Example Scenarios

### Scenario 1: Limit = 5
- User gets 2 demo cards (not counted)
- User can create 5 additional cards
- Total cards displayed: 7 (2 demo + 5 user)
- 6th user card creation will be blocked

### Scenario 2: Limit = 3
- User gets 2 demo cards (not counted)
- User can create 3 additional cards
- Total cards displayed: 5 (2 demo + 3 user)
- 4th user card creation will be blocked

## Error Messages

When the limit is reached, users will see:
```
Card limit reached. Maximum X cards allowed.
```

## Technical Implementation

- **Model**: `UserCard` has `isDemoCard` field
- **Provider**: `CardProvider.createCard()` checks limits
- **Service**: `FirebaseService.getCardLimit()` fetches configuration
- **Storage**: Configuration stored in `app_config/limits` document

## Monitoring

To monitor card creation:
1. Check Firestore usage in Firebase Console
2. Monitor `users/{userId}/scannedCards` collection size
3. Review error logs for limit enforcement

## Troubleshooting

### "Card limit reached" but user has fewer cards
- Check if demo cards are being counted (they shouldn't be)
- Verify the `isDemoCard` field is set correctly
- Check Firebase configuration document

### Limit not being enforced
- Verify `app_config/limits` document exists
- Check `maxCardsPerUser` field value
- Ensure user is authenticated
- Check Firebase connection

### Configuration not updating
- Clear app cache and restart
- Check Firebase Console for document updates
- Verify network connectivity
