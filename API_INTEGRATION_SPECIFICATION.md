# API Integration Specification - TestCard ↔ accex.in

## 🔗 **Integration Overview**

This document outlines the API integration strategy between the TestCard mobile app and the accex.in web portal, ensuring seamless data flow, security, and real-time synchronization.

---

## 🏗️ **Integration Architecture**

### **Shared Backend Strategy**
```
┌─────────────────┐    ┌─────────────────┐
│   TestCard App  │    │  accex.in Web  │
│   (Mobile/Web)  │    │   Portal       │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
          ┌─────────▼─────────┐
          │   Firebase        │
          │   Backend        │
          │                  │
          │ • Firestore      │
          │ • Auth           │
          │ • Storage        │
          │ • Functions      │
          │ • Analytics      │
          └──────────────────┘
```

### **Data Flow Patterns**
1. **Real-time Sync**: Firebase Realtime Database for live updates
2. **Event-driven**: Cloud Functions trigger web portal updates
3. **Batch Processing**: Scheduled analytics and reporting
4. **Webhook Integration**: External service notifications

---

## 📊 **Shared Data Models**

### **1. User Profile (Enhanced)**
```typescript
interface UserProfile {
  // Basic Info
  uid: string;
  fullName: string;
  email: string;
  phoneNumber: string;
  profilePhotoUrl?: string;
  
  // Account Status
  status: 'active' | 'flagged' | 'suspended';
  verificationLevel: 'basic' | 'document' | 'peer' | 'company';
  trustScore: number;
  
  // Analytics (Web Portal)
  lastLoginAt: Timestamp;
  totalCardsCreated: number;
  totalScansReceived: number;
  totalScansPerformed: number;
  
  // Admin Fields
  flaggedBy?: string;
  flaggedAt?: Timestamp;
  flaggedReason?: string;
  adminNotes?: string;
  
  // Metadata
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### **2. User Card (Enhanced)**
```typescript
interface UserCard {
  // Basic Card Info
  id: string;
  userId: string;
  fullName: string;
  companyName: string;
  designation: string;
  
  // Analytics (Web Portal)
  scanCount: number;
  lastScannedAt?: Timestamp;
  averageTrustScore: number;
  
  // Admin Fields
  isPublic: boolean;
  isVerified: boolean;
  adminVerified?: boolean;
  adminNotes?: string;
  
  // Metadata
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### **3. System Analytics (New)**
```typescript
interface SystemAnalytics {
  date: string; // YYYY-MM-DD
  metrics: {
    // User Metrics
    totalUsers: number;
    activeUsers: number;
    newRegistrations: number;
    verifiedUsers: number;
    
    // Card Metrics
    totalCards: number;
    cardsCreated: number;
    cardsScanned: number;
    averageScansPerCard: number;
    
    // Trust Metrics
    averageTrustScore: number;
    trustScoreDistribution: {
      '0-20': number;
      '21-40': number;
      '41-60': number;
      '61-80': number;
      '81-100': number;
    };
    
    // Abuse Metrics
    flaggedUsers: number;
    suspendedUsers: number;
    abuseReports: number;
  };
  
  trends: {
    userGrowthRate: number;
    engagementRate: number;
    verificationRate: number;
  };
}
```

---

## 🔌 **API Endpoints Specification**

### **1. Authentication & Authorization**

#### **Admin Authentication**
```typescript
// POST /api/auth/admin-login
interface AdminLoginRequest {
  email: string;
  password: string;
}

interface AdminLoginResponse {
  success: boolean;
  token: string;
  user: {
    uid: string;
    email: string;
    role: 'super_admin' | 'admin' | 'moderator';
    permissions: PermissionSet;
  };
}

// GET /api/auth/verify
interface VerifyResponse {
  valid: boolean;
  user?: AdminUser;
  permissions?: PermissionSet;
}
```

#### **Role-Based Access Control**
```typescript
interface PermissionSet {
  userManagement: boolean;
  analytics: boolean;
  systemConfig: boolean;
  abuseReview: boolean;
  systemConfig: boolean;
}

// Middleware for API protection
const requirePermission = (permission: keyof PermissionSet) => {
  return async (req: NextApiRequest, res: NextApiResponse) => {
    const admin = await verifyAdminToken(req.headers.authorization);
    
    if (!admin.permissions[permission]) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    
    req.admin = admin;
  };
};
```

### **2. User Management APIs**

#### **Get Users with Analytics**
```typescript
// GET /api/users?page=1&limit=50&filter=active&sort=trustScore&order=desc
interface GetUsersRequest {
  page?: number;
  limit?: number;
  filter?: 'all' | 'active' | 'flagged' | 'suspended';
  sort?: 'createdAt' | 'trustScore' | 'lastLogin' | 'cardCount';
  order?: 'asc' | 'desc';
  search?: string;
}

interface GetUsersResponse {
  users: UserProfile[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  filters: {
    active: number;
    flagged: number;
    suspended: number;
  };
}
```

#### **User Actions**
```typescript
// POST /api/users/{userId}/flag
interface FlagUserRequest {
  reason: string;
  action: 'flag' | 'unflag';
  adminNotes?: string;
}

// POST /api/users/{userId}/suspend
interface SuspendUserRequest {
  reason: string;
  duration?: number; // hours
  adminNotes?: string;
}

// GET /api/users/{userId}/analytics
interface UserAnalyticsResponse {
  user: UserProfile;
  cardStats: {
    totalCards: number;
    activeCards: number;
    totalScans: number;
    averageScansPerCard: number;
  };
  activityTimeline: ActivityEvent[];
  trustScoreHistory: TrustScorePoint[];
}
```

### **3. Analytics & Reporting APIs**

#### **Dashboard Metrics**
```typescript
// GET /api/analytics/dashboard?period=7d&granularity=day
interface DashboardRequest {
  period: '1d' | '7d' | '30d' | '90d' | '1y';
  granularity: 'hour' | 'day' | 'week' | 'month';
}

interface DashboardResponse {
  overview: {
    totalUsers: number;
    activeUsers: number;
    newUsers: number;
    totalCards: number;
    cardsCreated: number;
    scansToday: number;
    averageTrustScore: number;
  };
  
  charts: {
    userGrowth: ChartDataPoint[];
    engagement: ChartDataPoint[];
    trustScoreDistribution: DistributionData[];
    cardActivity: ChartDataPoint[];
  };
  
  topPerformers: {
    mostActiveUsers: UserActivity[];
    highestTrustScores: UserTrust[];
    mostScannedCards: CardActivity[];
  };
}
```

#### **Detailed Analytics**
```typescript
// GET /api/analytics/detailed?startDate=2024-01-01&endDate=2024-01-15
interface DetailedAnalyticsResponse {
  userMetrics: {
    registrations: number;
    verifications: number;
    trustScoreDistribution: DistributionData[];
    userRetention: RetentionData[];
  };
  
  cardMetrics: {
    totalCards: number;
    activeCards: number;
    scannedCards: number;
    averageScansPerCard: number;
    cardCreationTrend: ChartDataPoint[];
  };
  
  abuseMetrics: {
    flaggedUsers: number;
    suspendedUsers: number;
    abuseReports: number;
    abuseTrends: ChartDataPoint[];
  };
  
  systemMetrics: {
    apiCalls: number;
    responseTime: number;
    errorRate: number;
    storageUsage: number;
  };
}
```

### **4. Real-time Updates**

#### **WebSocket Integration**
```typescript
// Real-time dashboard updates
interface RealtimeUpdate {
  type: 'user_registered' | 'card_created' | 'card_scanned' | 'user_flagged';
  data: any;
  timestamp: Timestamp;
}

// WebSocket connection for live updates
const ws = new WebSocket('wss://accex.in/api/realtime');
ws.onmessage = (event) => {
  const update: RealtimeUpdate = JSON.parse(event.data);
  updateDashboard(update);
};
```

#### **Firebase Realtime Database Structure**
```javascript
// Firebase Realtime Database
{
  "realtime_updates": {
    "dashboard": {
      "userCount": 1250,
      "lastUpdate": "2024-01-15T10:30:00Z"
    },
    "notifications": {
      "admin_alerts": [
        {
          "id": "alert_1",
          "type": "abuse_detected",
          "message": "Suspicious activity detected",
          "timestamp": "2024-01-15T10:30:00Z",
          "read": false
        }
      ]
    }
  }
}
```

---

## 🔄 **Data Synchronization Strategy**

### **1. Real-time Sync (Firebase Realtime Database)**
```typescript
// Web portal subscribes to real-time updates
const syncDashboard = () => {
  const db = getDatabase();
  const dashboardRef = ref(db, 'realtime_updates/dashboard');
  
  onValue(dashboardRef, (snapshot) => {
    const data = snapshot.val();
    updateDashboardMetrics(data);
  });
};
```

### **2. Event-driven Updates (Cloud Functions)**
```typescript
// Cloud Function triggers web portal updates
export const onUserAction = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    
    // Update analytics
    await updateSystemAnalytics(after);
    
    // Notify web portal
    await notifyWebPortal({
      type: 'user_updated',
      userId: context.params.userId,
      changes: getChanges(before, after)
    });
  });
```

### **3. Batch Processing (Scheduled Functions)**
```typescript
// Daily analytics processing
export const dailyAnalytics = functions.pubsub
  .schedule('0 0 * * *') // Daily at midnight
  .timeZone('UTC')
  .onRun(async (context) => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    
    const analytics = await calculateDailyAnalytics(yesterday);
    await saveSystemAnalytics(analytics);
    
    // Update web portal cache
    await updateWebPortalCache(analytics);
  });
```

---

## 🛡️ **Security Implementation**

### **1. API Security Middleware**
```typescript
// utils/security.ts
export const apiSecurity = {
  // Rate limiting
  rateLimit: rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP'
  }),
  
  // CORS configuration
  cors: cors({
    origin: ['https://accex.in', 'https://www.accex.in'],
    credentials: true
  }),
  
  // Admin authentication
  requireAdmin: async (req: NextApiRequest, res: NextApiResponse) => {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }
    
    try {
      const admin = await verifyAdminToken(token);
      req.admin = admin;
    } catch (error) {
      return res.status(401).json({ error: 'Invalid token' });
    }
  }
};
```

### **2. Firebase Security Rules (Enhanced)**
```javascript
// Enhanced Firestore rules for web portal integration
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Admin users - super admin only
    match /admin_users/{adminId} {
      allow read, write: if isSuperAdmin(request.auth.uid);
    }
    
    // System analytics - admin read access
    match /system_analytics/{date} {
      allow read: if isAdmin(request.auth.uid);
      allow write: if isSuperAdmin(request.auth.uid);
    }
    
    // Admin actions - admin write access
    match /admin_actions/{actionId} {
      allow read: if isAdmin(request.auth.uid);
      allow write: if isAdmin(request.auth.uid);
    }
    
    // Real-time updates - admin read access
    match /realtime_updates/{updateId} {
      allow read: if isAdmin(request.auth.uid);
      allow write: if isSystemFunction();
    }
    
    // Enhanced user access for web portal
    match /users/{userId} {
      // Mobile app access (existing)
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Admin access for web portal
      allow read: if isAdmin(request.auth.uid);
      allow write: if isAdmin(request.auth.uid) && 
                   (request.resource.data.keys().hasAll(['adminNotes', 'status']) ||
                    request.resource.data.keys().hasAll(['flaggedBy', 'flaggedAt']));
    }
    
    // Helper functions
    function isAdmin(uid) {
      return exists(/databases/$(database)/documents/admin_users/$(uid))
             && get(/databases/$(database)/documents/admin_users/$(uid)).data.role in ['admin', 'super_admin'];
    }
    
    function isSuperAdmin(uid) {
      return exists(/databases/$(database)/documents/admin_users/$(uid))
             && get(/databases/$(database)/documents/admin_users/$(uid)).data.role == 'super_admin';
    }
    
    function isSystemFunction() {
      return request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

### **3. Data Encryption & Privacy**
```typescript
// Sensitive data encryption
export const encryptSensitiveData = (data: any) => {
  const sensitiveFields = ['phoneNumber', 'email', 'personalInfo'];
  
  const encrypted = { ...data };
  sensitiveFields.forEach(field => {
    if (encrypted[field]) {
      encrypted[field] = encrypt(encrypted[field]);
    }
  });
  
  return encrypted;
};

// Data anonymization for analytics
export const anonymizeUserData = (user: UserProfile) => {
  return {
    ...user,
    fullName: user.fullName.charAt(0) + '***',
    email: user.email.split('@')[0].charAt(0) + '***@' + user.email.split('@')[1],
    phoneNumber: user.phoneNumber.slice(0, 3) + '***' + user.phoneNumber.slice(-2)
  };
};
```

---

## 📈 **Performance Optimization**

### **1. Caching Strategy**
```typescript
// Redis cache for frequently accessed data
export const cacheStrategy = {
  // User data cache (5 minutes)
  userData: {
    ttl: 300,
    key: (userId: string) => `user:${userId}`
  },
  
  // Analytics cache (1 hour)
  analytics: {
    ttl: 3600,
    key: (date: string) => `analytics:${date}`
  },
  
  // Dashboard metrics cache (15 minutes)
  dashboard: {
    ttl: 900,
    key: 'dashboard:metrics'
  }
};

// Cache implementation
export const getCachedData = async (key: string, fetcher: () => Promise<any>) => {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  
  const data = await fetcher();
  await redis.setex(key, cacheStrategy[key.split(':')[0]].ttl, JSON.stringify(data));
  return data;
};
```

### **2. Database Optimization**
```typescript
// Firestore indexes for web portal queries
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "trustScore", "order": "DESCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "user_cards",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

### **3. API Response Optimization**
```typescript
// Pagination and filtering
export const optimizeQuery = (req: GetUsersRequest) => {
  const { page = 1, limit = 50, filter, sort, order = 'desc' } = req;
  
  let query = db.collection('users');
  
  // Apply filters
  if (filter && filter !== 'all') {
    query = query.where('status', '==', filter);
  }
  
  // Apply sorting
  if (sort) {
    query = query.orderBy(sort, order);
  }
  
  // Apply pagination
  const offset = (page - 1) * limit;
  query = query.limit(limit).offset(offset);
  
  return query;
};
```

---

## 🧪 **Testing Strategy**

### **1. API Testing**
```typescript
// Jest tests for API endpoints
describe('User Management API', () => {
  test('GET /api/users returns paginated users', async () => {
    const response = await request(app)
      .get('/api/users?page=1&limit=10')
      .set('Authorization', `Bearer ${adminToken}`);
    
    expect(response.status).toBe(200);
    expect(response.body.users).toHaveLength(10);
    expect(response.body.pagination.page).toBe(1);
  });
  
  test('POST /api/users/{id}/flag flags user correctly', async () => {
    const response = await request(app)
      .post('/api/users/user123/flag')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ reason: 'Suspicious activity' });
    
    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });
});
```

### **2. Integration Testing**
```typescript
// Test data synchronization
describe('Data Synchronization', () => {
  test('User update triggers web portal notification', async () => {
    // Update user in mobile app
    await updateUser('user123', { trustScore: 95 });
    
    // Verify web portal receives update
    const updates = await getRealtimeUpdates();
    expect(updates).toContainEqual({
      type: 'user_updated',
      userId: 'user123',
      changes: { trustScore: 95 }
    });
  });
});
```

---

## 🚀 **Deployment & Monitoring**

### **1. Environment Configuration**
```typescript
// Environment variables
const config = {
  development: {
    firebase: {
      projectId: 'trustcard-dev',
      apiKey: process.env.FIREBASE_API_KEY_DEV
    },
    redis: {
      host: 'localhost',
      port: 6379
    }
  },
  production: {
    firebase: {
      projectId: 'trustcard-prod',
      apiKey: process.env.FIREBASE_API_KEY_PROD
    },
    redis: {
      host: process.env.REDIS_HOST,
      port: process.env.REDIS_PORT
    }
  }
};
```

### **2. Monitoring & Logging**
```typescript
// Application monitoring
export const monitoring = {
  // Performance monitoring
  trackAPICall: (endpoint: string, duration: number) => {
    console.log(`API Call: ${endpoint} - ${duration}ms`);
    // Send to monitoring service
  },
  
  // Error tracking
  trackError: (error: Error, context: string) => {
    console.error(`Error in ${context}:`, error);
    // Send to error tracking service
  },
  
  // Business metrics
  trackUserAction: (action: string, userId: string) => {
    console.log(`User Action: ${action} by ${userId}`);
    // Send to analytics service
  }
};
```

---

This comprehensive API integration specification ensures seamless communication between your TestCard mobile app and the accex.in web portal while maintaining security, performance, and scalability.
