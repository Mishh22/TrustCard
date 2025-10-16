# Card Deletion Abuse Prevention System

This document explains the comprehensive abuse prevention system implemented to prevent users from gaming the trust scoring system through card deletion and recreation.

## 🚨 **Critical Security Features**

### **1. Lifecycle Tracking**
- **Permanent Audit Trail**: All card creations and deletions are tracked in `account_lifecycle` collection
- **Immutable Logs**: Deletion history persists even after card deletion
- **Device Fingerprinting**: Tracks device IDs to detect same-device abuse
- **IP Address Tracking**: Monitors IP patterns for suspicious activity

### **2. Cooldown Periods**
- **1st Deletion**: 24-hour cooldown before creating new card
- **2nd Deletion**: 72-hour (3-day) cooldown
- **3+ Deletions**: 168-hour (7-day) cooldown
- **Escalating Penalties**: Longer cooldowns for repeated abuse

### **3. Trust Score Inheritance**
- **Deletion Penalties**: New cards inherit penalties from previous deletions
- **1st Recreation**: -5 trust score points
- **2nd Recreation**: -10 trust score points  
- **3+ Recreations**: -20 trust score points
- **Suspicious Deletions**: Additional -10 points per deletion after bad reviews

### **4. Velocity Limits**
- **Card Creation**: Max 3 deletions in 30 days triggers flagging
- **Device Limits**: Max 5 cards per device in 30 days
- **Automatic Flagging**: Suspicious patterns trigger admin review

### **5. Database-Level Protection**
- **Firestore Security Rules**: Enforce limits at database level
- **User Flagging**: Blocked users cannot create cards
- **Device Blocking**: Flagged devices cannot create accounts

## 📊 **Firebase Collections**

### **account_lifecycle**
```json
{
  "userId": "user123",
  "cardId": "card456", 
  "action": "deleted",
  "timestamp": "2024-01-01T00:00:00Z",
  "finalTrustScore": 45.5,
  "totalRatings": 12,
  "deviceId": "android_device_123",
  "ipAddress": "192.168.1.1",
  "metadata": {
    "platform": "android",
    "version": "13"
  }
}
```

### **flagged_users**
```json
{
  "userId": "user123",
  "reason": "excessive_card_deletion",
  "flaggedAt": "2024-01-01T00:00:00Z",
  "status": "pending_review",
  "autoDetected": true
}
```

### **flagged_devices**
```json
{
  "deviceId": "android_device_123",
  "reason": "excessive_account_creation", 
  "flaggedAt": "2024-01-01T00:00:00Z",
  "status": "active"
}
```

## 🔧 **Implementation Details**

### **Card Creation Flow**
1. Check user flagging status
2. Verify cooldown period
3. Check device fingerprinting
4. Validate velocity limits
5. Track creation in lifecycle
6. Apply trust score penalties

### **Card Deletion Flow**
1. Capture card data before deletion
2. Track deletion in lifecycle
3. Record trust score and ratings
4. Update user flagging if needed
5. Enforce cooldown period

### **Trust Score Calculation**
```dart
// Base score calculation
double baseScore = calculateBasicTrustScore(...);

// Apply deletion penalties
if (deletionCount == 1) baseScore -= 5.0;
else if (deletionCount == 2) baseScore -= 10.0;
else if (deletionCount >= 3) baseScore -= 20.0;

// Apply suspicious deletion penalties
if (suspiciousDeletions > 0) {
  baseScore -= (suspiciousDeletions * 10);
}

return baseScore.clamp(0.0, 100.0);
```

## 🛡️ **Security Rules**

### **Firestore Rules**
- Users can only read their own lifecycle data
- Card creation blocked for flagged users
- Device fingerprinting enforced
- Velocity limits at database level

### **Helper Functions**
```javascript
function isUserFlagged(userId) {
  return exists(/databases/$(database)/documents/flagged_users/$(userId));
}

function getCardCount(userId) {
  return get(/databases/$(database)/documents/users/$(userId)).data.activeCardCount || 0;
}

function getCardLimit() {
  return get(/databases/$(database)/documents/app_config/limits).data.maxCardsPerUser || 10;
}
```

## 📈 **Monitoring & Analytics**

### **Admin Dashboard Metrics**
- Total flagged users
- Suspicious deletion patterns
- Device abuse detection
- Trust score distribution
- Cooldown period effectiveness

### **Alert Triggers**
- 3+ deletions in 30 days
- 5+ cards from same device
- Low trust score + immediate deletion
- Rapid delete-recreate cycles

## 🔄 **Admin Review Process**

### **Automatic Flagging**
1. System detects suspicious patterns
2. User flagged for review
3. Card creation temporarily blocked
4. Admin notification sent

### **Manual Review**
1. Admin reviews flagged user
2. Approve or ban decision
3. Update user status
4. Unblock legitimate users

## ⚙️ **Configuration**

### **Card Limits**
```json
{
  "maxCardsPerUser": 10,
  "updatedAt": "2024-01-01T00:00:00Z",
  "updatedBy": "admin"
}
```

### **Cooldown Periods**
- First deletion: 24 hours
- Second deletion: 72 hours  
- Third+ deletion: 168 hours

### **Velocity Limits**
- Max 3 deletions per 30 days
- Max 5 cards per device per 30 days
- Max 10 cards per user total

## 🚀 **Deployment**

### **Phase 1: Core Protection**
1. ✅ Lifecycle tracking
2. ✅ Trust score penalties
3. ✅ Firestore security rules
4. ✅ Cooldown periods

### **Phase 2: Advanced Detection**
1. ✅ Device fingerprinting
2. ✅ IP address monitoring
3. ✅ Pattern detection
4. ✅ Admin review system

### **Phase 3: Machine Learning**
1. 🔄 Behavioral analysis
2. 🔄 Anomaly detection
3. 🔄 Predictive flagging
4. 🔄 Dynamic thresholds

## 📋 **Testing Scenarios**

### **Test Case 1: Basic Abuse**
1. User creates card
2. Gets bad ratings (trust score drops)
3. Deletes card immediately
4. Tries to create new card
5. **Expected**: Blocked by cooldown + trust score penalty

### **Test Case 2: Device Abuse**
1. User creates 5 cards from same device
2. System flags device
3. User tries to create 6th card
4. **Expected**: Blocked by device flagging

### **Test Case 3: Velocity Abuse**
1. User deletes 3 cards in 30 days
2. System flags user
3. User tries to create new card
4. **Expected**: Blocked by user flagging

## 🔒 **Privacy & Compliance**

### **Data Collected**
- Device IDs (Android ID, iOS Vendor ID)
- IP addresses (for pattern detection)
- Card lifecycle events
- Trust score history

### **Data Retention**
- Lifecycle data: Permanent (for audit trail)
- Flagged users: Until manually cleared
- Device fingerprints: 1 year
- IP addresses: 30 days

### **User Rights**
- Users can request deletion of personal data
- Lifecycle audit trail cannot be deleted (legal requirement)
- Flagged users can appeal decisions
- Admin review process for false positives

## 📞 **Support**

### **False Positives**
- Users can contact support for review
- Admin can manually unflag users
- Appeal process for banned users
- Transparent flagging reasons

### **Legitimate Use Cases**
- Account migration (admin approval)
- Data correction (admin approval)
- Security incidents (admin approval)
- Platform changes (admin approval)

---

**⚠️ Important**: This system is designed to prevent abuse while maintaining legitimate user functionality. All restrictions include appeal processes and admin override capabilities.
