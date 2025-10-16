# TrustCard App - Comprehensive Data Collection & Analytics Analysis

## 📊 **DATA COLLECTION OVERVIEW**

The TrustCard app collects extensive data across multiple categories for user experience, business intelligence, compliance, and security purposes.

---

## 🗄️ **FIREBASE COLLECTIONS & DATA STRUCTURES**

### **1. USER DATA COLLECTIONS**

#### **`user_profiles` Collection**
```javascript
{
  "userId": "firebase_auth_uid",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "email": "john@example.com",
  "profilePhotoUrl": "https://...",
  "createdAt": "2024-01-15T10:30:00Z",
  "lastLoginAt": "2024-01-20T14:22:00Z",
  "isActive": true,
  "preferredLanguage": "en",
  "notificationsEnabled": true,
  "fcmToken": "firebase_messaging_token"
}
```

#### **`user_cards` Collection**
```javascript
{
  "id": "card_uuid",
  "userId": "firebase_auth_uid",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "profilePhotoUrl": "https://...",
  "companyName": "Acme Corp",
  "designation": "Software Engineer",
  "companyId": "company_uuid",
  "companyPhone": "+1234567890",
  "verificationLevel": "verified",
  "isCompanyVerified": true,
  "companyVerificationDepth": "deep",
  "customerRating": 4.8,
  "totalRatings": 25,
  "verifiedByColleagues": ["colleague1", "colleague2"],
  "createdAt": "2024-01-15T10:30:00Z",
  "expiryDate": "2025-01-15T10:30:00Z",
  "version": 1,
  "isActive": true,
  "companyEmail": "john@acme.com",
  "workLocation": "New York, NY",
  "uploadedDocuments": ["doc1", "doc2"],
  "additionalInfo": "Additional details",
  "userRole": "employee",
  "isDemoCard": false,
  "verifiedBy": "admin_id",
  "verifiedAt": "2024-01-16T09:15:00Z",
  "rejectedBy": null,
  "rejectedAt": null,
  "rejectionReason": null
}
```

#### **`users` Collection (Legacy)**
```javascript
// Old structure maintained for backward compatibility
{
  "id": "firebase_auth_uid",
  "userId": "firebase_auth_uid",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "email": "john@example.com",
  "companyName": "Acme Corp",
  "designation": "Software Engineer",
  // ... all card fields mixed with profile fields
}
```

---

### **2. ANALYTICS COLLECTIONS**

#### **`scan_history` Collection**
```javascript
{
  "id": "scan_uuid",
  "cardId": "card_uuid",
  "cardOwnerId": "owner_firebase_uid",
  "scannerId": "scanner_firebase_uid",
  "scannerName": "Jane Smith",
  "scannerCompany": "Tech Corp",
  "scannedAt": "2024-01-20T14:22:00Z",
  "location": "New York, NY",
  "metadata": {
    "deviceType": "mobile",
    "appVersion": "1.0.0",
    "networkType": "wifi"
  }
}
```

#### **`scan_analytics` Collection**
```javascript
{
  "cardId": "card_uuid",
  "totalScans": 25,
  "uniqueScanners": 20,
  "lastScanned": "2024-01-20T14:22:00Z",
  "firstScanned": "2024-01-15T10:30:00Z",
  "scansByDay": {
    "2024-01-15": 5,
    "2024-01-16": 3,
    "2024-01-17": 7
  },
  "scansByHour": {
    "09": 2,
    "10": 5,
    "14": 8
  },
  "topScanners": ["scanner1", "scanner2"],
  "averageScansPerDay": 2.5
}
```

#### **`sessions` Collection**
```javascript
{
  "id": "session_uuid",
  "userId": "firebase_auth_uid",
  "sessionStart": "2024-01-20T14:00:00Z",
  "sessionEnd": "2024-01-20T14:30:00Z",
  "deviceId": "device_unique_id",
  "appVersion": "1.0.0",
  "networkType": "wifi",
  "screen": "home_screen",
  "durationSeconds": 1800,
  "isActive": false
}
```

#### **`session_events` Collection**
```javascript
{
  "id": "event_uuid",
  "userId": "firebase_auth_uid",
  "eventType": "screen_view",
  "screen": "profile_screen",
  "metadata": {
    "previousScreen": "home_screen",
    "timeSpent": 45
  },
  "timestamp": "2024-01-20T14:15:00Z",
  "platform": "android",
  "sessionId": "session_uuid"
}
```

---

### **3. ENGAGEMENT & FEATURE TRACKING**

#### **`engagement_events` Collection**
```javascript
{
  "id": "event_uuid",
  "userId": "firebase_auth_uid",
  "action": "card_created",
  "screen": "create_card_screen",
  "metadata": {
    "cardType": "business",
    "verificationLevel": "basic"
  },
  "timestamp": "2024-01-20T14:15:00Z"
}
```

#### **`feature_usage` Collection**
```javascript
{
  "id": "usage_uuid",
  "userId": "firebase_auth_uid",
  "feature": "qr_scanning",
  "action": "scan_completed",
  "metadata": {
    "scanDuration": 2.5,
    "success": true
  },
  "timestamp": "2024-01-20T14:15:00Z"
}
```

---

### **4. MARKETING & ATTRIBUTION**

#### **`marketing_attribution` Collection**
```javascript
{
  "id": "attribution_uuid",
  "userId": "firebase_auth_uid",
  "source": "google",
  "medium": "cpc",
  "campaign": "trustcard_launch",
  "adGroup": "business_cards",
  "channel": "mobile",
  "firstTouchAt": "2024-01-15T10:30:00Z",
  "lastTouchAt": "2024-01-20T14:22:00Z",
  "firstSessionAt": "2024-01-15T10:30:00Z",
  "invitedBy": "referrer_id",
  "inviteId": "invite_uuid"
}
```

#### **`campaign_conversions` Collection**
```javascript
{
  "id": "conversion_uuid",
  "userId": "firebase_auth_uid",
  "campaign": "trustcard_launch",
  "conversionType": "card_created",
  "metadata": {
    "value": 0,
    "currency": "USD"
  },
  "timestamp": "2024-01-20T14:15:00Z"
}
```

#### **`referrals` Collection**
```javascript
{
  "id": "referral_uuid",
  "referrerId": "referrer_firebase_uid",
  "referredId": "referred_firebase_uid",
  "referralCode": "REF123",
  "timestamp": "2024-01-20T14:15:00Z"
}
```

---

### **5. COMPLIANCE & SECURITY**

#### **`consent_records` Collection**
```javascript
{
  "id": "consent_uuid",
  "userId": "firebase_auth_uid",
  "scopes": ["analytics", "marketing", "personalization"],
  "policyVersion": "1.0",
  "jurisdiction": "US",
  "grantedAt": "2024-01-15T10:30:00Z",
  "revokedAt": null,
  "method": "in-app",
  "ipAddress": "192.168.1.1",
  "deviceId": "device_unique_id",
  "isActive": true
}
```

#### **`admin_audit_logs` Collection**
```javascript
{
  "id": "audit_uuid",
  "actorUserId": "admin_firebase_uid",
  "role": "admin",
  "action": "user_verified",
  "resourcePath": "/users/user_id",
  "beforeHash": "hash_before_change",
  "afterHash": "hash_after_change",
  "reasonCode": "verification_request",
  "ipAddress": "192.168.1.1",
  "deviceId": "device_unique_id",
  "timestamp": "2024-01-20T14:15:00Z",
  "outcome": "success"
}
```

#### **`retention_policies` Collection**
```javascript
{
  "id": "policy_uuid",
  "collection": "scan_history",
  "piiLevel": "PII",
  "ttlDays": 365,
  "archivalBucket": "gs://archive-bucket",
  "eraseStrategy": "tombstone",
  "lastEvaluatedAt": "2024-01-20T14:15:00Z",
  "isActive": true
}
```

#### **`pii_catalog` Collection**
```javascript
{
  "id": "pii_uuid",
  "collection": "user_profiles",
  "field": "phoneNumber",
  "classification": "PII",
  "encryption": "KMS",
  "maskPolicy": "partial",
  "isActive": true
}
```

---

### **6. MONITORING & PERFORMANCE**

#### **`error_events` Collection**
```javascript
{
  "id": "error_uuid",
  "userId": "firebase_auth_uid",
  "platform": "android",
  "appVersion": "1.0.0",
  "screen": "scan_card_screen",
  "action": "qr_scan",
  "errorCode": "CAMERA_PERMISSION_DENIED",
  "stackHash": "abc123def456",
  "occurredAt": "2024-01-20T14:15:00Z",
  "correlatedEventId": "event_uuid"
}
```

#### **`performance_metrics` Collection**
```javascript
{
  "id": "metric_uuid",
  "userId": "firebase_auth_uid",
  "action": "card_creation",
  "latencyMs": 2500,
  "screen": "create_card_screen",
  "timestamp": "2024-01-20T14:15:00Z",
  "platform": "android"
}
```

#### **`api_metrics` Collection**
```javascript
{
  "id": "api_uuid",
  "endpoint": "/api/cards",
  "responseTime": 150,
  "statusCode": 200,
  "userId": "firebase_auth_uid",
  "timestamp": "2024-01-20T14:15:00Z",
  "platform": "android"
}
```

---

### **7. BUSINESS DATA**

#### **`company_details` Collection**
```javascript
{
  "id": "company_uuid",
  "companyName": "Acme Corp",
  "industry": "Technology",
  "size": "100-500",
  "location": "New York, NY",
  "website": "https://acme.com",
  "verificationStatus": "verified",
  "createdAt": "2024-01-15T10:30:00Z",
  "verifiedAt": "2024-01-16T09:15:00Z",
  "employeeCount": 150
}
```

#### **`account_lifecycle` Collection**
```javascript
{
  "id": "lifecycle_uuid",
  "userId": "firebase_auth_uid",
  "cardId": "card_uuid",
  "action": "created",
  "timestamp": "2024-01-20T14:15:00Z",
  "deviceId": "device_unique_id",
  "ipAddress": "192.168.1.1",
  "metadata": {
    "platform": "android",
    "version": "14"
  }
}
```

---

## 📈 **ANALYTICS CAPABILITIES**

### **1. USER ENGAGEMENT ANALYTICS**

#### **Engagement Metrics**
- **Total Engagement Events**: Count of all user interactions
- **Feature Usage**: Track which features are used most
- **Session Duration**: Average time spent in app
- **Daily Active Users**: Users active in last 7 days
- **Engagement Score**: Weighted score (0-100) based on:
  - Engagement events (30%)
  - Feature usage (20%)
  - Session count (30%)
  - Scan count (20%)

#### **Session Analytics**
- **Session Duration**: Total and average session time
- **Screen Views**: Most visited screens
- **Session Frequency**: How often users return
- **Session Events**: Detailed event tracking per session

### **2. BUSINESS INTELLIGENCE**

#### **Growth Metrics**
- **Total Users**: Registered user count
- **Total Cards**: Digital cards created
- **Total Scans**: QR code scans performed
- **Total Companies**: Verified companies
- **User Growth Rate**: New users in last 30 days
- **Scan Growth Rate**: New scans in last 7 days
- **Cards Per User**: Average cards per user
- **Scans Per User**: Average scans per user

#### **Cohort Analysis**
- **User Cohorts**: Group users by creation month
- **Retention Rates**: 1-day, 7-day, 30-day retention
- **Cohort Size**: Number of users in each cohort
- **Retention Trends**: How retention changes over time

### **3. SCAN ANALYTICS**

#### **Scan Statistics**
- **Total Scans**: Overall scan count
- **Unique Scanners**: Number of different people who scanned
- **Scan Trends**: Scans by day/hour
- **Top Scanners**: Most active scanners
- **Average Scans Per Day**: Daily scan rate

#### **Card Performance**
- **Most Scanned Cards**: Cards with highest scan count
- **Scan Velocity**: Scans per time period
- **Geographic Distribution**: Scan locations
- **Time-based Patterns**: When scans happen most

### **4. FEATURE ADOPTION**

#### **Feature Usage Metrics**
- **Feature Adoption Rates**: Percentage of users using each feature
- **Feature Usage Counts**: Raw usage numbers
- **Feature Progression**: How users move through features
- **Feature Stickiness**: How often features are used repeatedly

### **5. MARKETING ANALYTICS**

#### **Attribution Tracking**
- **Traffic Sources**: Where users come from
- **Campaign Performance**: Which campaigns drive users
- **Channel Analysis**: Mobile vs web performance
- **Conversion Tracking**: From attribution to action

#### **Referral Analytics**
- **Referral Chains**: Who referred whom
- **Referral Success**: Conversion from referrals
- **Referral Codes**: Most effective codes
- **Viral Coefficient**: How many users each user brings

### **6. COMPLIANCE ANALYTICS**

#### **Consent Management**
- **Consent Rates**: Percentage of users who consent
- **Consent Scopes**: Which data users consent to
- **Consent Withdrawals**: How often users revoke consent
- **Jurisdiction Compliance**: Different consent by region

#### **Data Governance**
- **PII Classification**: What data is classified as PII
- **Retention Compliance**: Data kept within retention periods
- **Audit Trail**: Who accessed what data when
- **Data Quality**: Completeness and accuracy metrics

### **7. PERFORMANCE ANALYTICS**

#### **Error Monitoring**
- **Error Rates**: Frequency of errors by type
- **Error Trends**: How errors change over time
- **Error Impact**: Which errors affect users most
- **Error Resolution**: How quickly errors are fixed

#### **Performance Metrics**
- **Response Times**: API and UI performance
- **Latency Analysis**: Where performance bottlenecks occur
- **Platform Performance**: Android vs iOS performance
- **User Experience Impact**: How performance affects engagement

---

## 🔍 **ANALYTICS QUERIES & INSIGHTS**

### **1. User Behavior Analysis**
```sql
-- Most active users
SELECT userId, COUNT(*) as engagement_count
FROM engagement_events
WHERE timestamp > DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY userId
ORDER BY engagement_count DESC;

-- Feature adoption rates
SELECT feature, COUNT(DISTINCT userId) as unique_users
FROM feature_usage
GROUP BY feature
ORDER BY unique_users DESC;
```

### **2. Business Metrics**
```sql
-- Daily active users
SELECT DATE(timestamp) as date, COUNT(DISTINCT userId) as dau
FROM sessions
WHERE timestamp > DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(timestamp)
ORDER BY date;

-- Scan velocity trends
SELECT DATE(scannedAt) as date, COUNT(*) as scans
FROM scan_history
WHERE scannedAt > DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(scannedAt)
ORDER BY date;
```

### **3. Cohort Analysis**
```sql
-- User retention by cohort
SELECT 
  cohort_month,
  COUNT(DISTINCT user_id) as cohort_size,
  COUNT(DISTINCT CASE WHEN last_session > cohort_start + INTERVAL 7 DAY THEN user_id END) as retained_7d
FROM user_cohorts
GROUP BY cohort_month;
```

---

## 📊 **DASHBOARD METRICS**

### **Executive Dashboard**
- **Total Users**: Real-time user count
- **Active Users**: DAU, WAU, MAU
- **Growth Rate**: Month-over-month growth
- **Engagement Score**: Overall app health
- **Revenue Metrics**: If monetized

### **Product Dashboard**
- **Feature Usage**: Most/least used features
- **User Journey**: How users navigate the app
- **Conversion Funnels**: From signup to key actions
- **Retention Cohorts**: User retention over time

### **Marketing Dashboard**
- **Attribution Sources**: Where users come from
- **Campaign Performance**: ROI of marketing efforts
- **Referral Analytics**: Viral growth metrics
- **Conversion Rates**: From traffic to users

### **Technical Dashboard**
- **Error Rates**: System health metrics
- **Performance**: Response times and latency
- **Usage Patterns**: Peak usage times
- **Platform Distribution**: Android vs iOS usage

---

## 🔒 **DATA PRIVACY & COMPLIANCE**

### **Data Classification**
- **PII Data**: Names, phone numbers, emails
- **SPI Data**: Company information, work details
- **Public Data**: Card display information
- **Analytics Data**: Aggregated usage statistics

### **Retention Policies**
- **User Data**: 7 years (business requirement)
- **Scan History**: 2 years (analytics value)
- **Session Data**: 1 year (performance analysis)
- **Error Logs**: 90 days (debugging)

### **Consent Management**
- **Analytics Consent**: Required for usage tracking
- **Marketing Consent**: Required for promotional communications
- **Personalization Consent**: Required for customized experience
- **Data Sharing Consent**: Required for third-party integrations

---

## 🚀 **RECOMMENDATIONS FOR ENHANCED ANALYTICS**

### **1. Advanced User Segmentation**
- **Behavioral Segments**: Based on usage patterns
- **Value Segments**: Based on engagement and scans
- **Lifecycle Segments**: New, active, at-risk, churned
- **Geographic Segments**: Based on location data

### **2. Predictive Analytics**
- **Churn Prediction**: Identify users likely to leave
- **Engagement Forecasting**: Predict future usage
- **Revenue Prediction**: If monetization is added
- **Feature Adoption**: Predict which features will be popular

### **3. Real-time Analytics**
- **Live Dashboards**: Real-time user activity
- **Alert Systems**: Notify on anomalies
- **A/B Testing**: Real-time experiment results
- **Performance Monitoring**: Live system health

### **4. Advanced Business Intelligence**
- **Market Analysis**: Industry trends and insights
- **Competitive Analysis**: Benchmark against competitors
- **ROI Analysis**: Return on investment for features
- **Strategic Planning**: Data-driven decision making

---

## 📋 **SUMMARY**

The TrustCard app collects comprehensive data across **20+ Firebase collections** covering:

✅ **User Data**: Profiles, cards, preferences
✅ **Engagement Data**: Sessions, events, feature usage  
✅ **Business Data**: Companies, employees, verification
✅ **Analytics Data**: Scans, interactions, performance
✅ **Marketing Data**: Attribution, campaigns, referrals
✅ **Compliance Data**: Consent, audit logs, retention
✅ **Monitoring Data**: Errors, performance, security

This data enables **comprehensive analytics** including user behavior, business intelligence, marketing effectiveness, compliance monitoring, and performance optimization.

The system is designed for **scalability**, **privacy compliance**, and **real-time insights** to support data-driven decision making and continuous product improvement.
