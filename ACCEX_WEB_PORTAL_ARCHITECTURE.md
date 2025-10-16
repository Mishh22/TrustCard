# accex.in Web Portal - Architecture & API Design

## 🎯 **Project Overview**

**Domain**: www.accex.in  
**Purpose**: Admin dashboard and analytics portal for TestCard ecosystem  
**Technology Stack**: React/Next.js + Firebase Admin SDK  
**Integration**: Shared Firebase backend with TestCard mobile app  

---

## 🏗️ **System Architecture**

### **High-Level Architecture**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   TestCard App  │    │  accex.in Web  │    │  Firebase      │
│   (Mobile/Web)  │◄──►│   Portal       │◄──►│  Backend       │
│                 │    │                 │    │                │
│ • User Cards    │    │ • Admin Panel  │    │ • Firestore    │
│ • QR Scanning   │    │ • Analytics    │    │ • Auth         │
│ • Trust Scores  │    │ • User Mgmt    │    │ • Storage      │
│ • Verification  │    │ • Reports      │    │ • Functions    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Technology Stack**

#### **Frontend (accex.in)**
- **Framework**: Next.js 14 (React 18)
- **UI Library**: Material-UI (MUI) v5
- **State Management**: Redux Toolkit + RTK Query
- **Charts**: Chart.js / Recharts
- **Authentication**: Firebase Auth
- **Deployment**: Vercel / Netlify

#### **Backend Integration**
- **Firebase Admin SDK**: Server-side operations
- **API Routes**: Next.js API routes for custom endpoints
- **Real-time**: Firebase Realtime Database for live updates
- **Security**: Firebase Security Rules + Custom middleware

---

## 📊 **Database Schema Extensions**

### **New Collections for Web Portal**

#### **1. Admin Users Collection**
```javascript
// admin_users/{adminId}
{
  "uid": "admin_user_id",
  "email": "admin@accex.in",
  "role": "super_admin" | "admin" | "moderator",
  "permissions": {
    "userManagement": true,
    "analytics": true,
    "systemConfig": false,
    "abuseReview": true
  },
  "createdAt": "2024-01-15T10:30:00Z",
  "lastLogin": "2024-01-15T10:30:00Z",
  "isActive": true
}
```

#### **2. System Analytics Collection**
```javascript
// system_analytics/{date}
{
  "date": "2024-01-15",
  "metrics": {
    "totalUsers": 1250,
    "activeUsers": 890,
    "newRegistrations": 45,
    "cardsCreated": 120,
    "cardsScanned": 340,
    "verificationRequests": 25,
    "abuseFlags": 3
  },
  "trends": {
    "userGrowth": 12.5,
    "engagementRate": 78.3,
    "trustScoreAvg": 85.2
  }
}
```

#### **3. Admin Actions Log**
```javascript
// admin_actions/{actionId}
{
  "adminId": "admin_user_id",
  "action": "user_flagged" | "user_unflagged" | "config_updated",
  "targetUserId": "target_user_id",
  "details": {
    "reason": "Suspicious activity detected",
    "previousStatus": "active",
    "newStatus": "flagged"
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "ipAddress": "192.168.1.1"
}
```

#### **4. System Configuration**
```javascript
// system_config/{configId}
{
  "cardLimits": {
    "maxCardsPerUser": 10,
    "maxScansPerDay": 50,
    "maxVerificationRequests": 3
  },
  "abusePrevention": {
    "cooldownPeriods": [24, 72, 168],
    "velocityLimits": {
      "maxDeletionsPerMonth": 3,
      "maxCardsPerDevice": 5
    },
    "trustScorePenalties": [-5, -10, -20]
  },
  "notifications": {
    "emailTemplates": {...},
    "pushSettings": {...}
  },
  "updatedBy": "admin_user_id",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

---

## 🔌 **API Design**

### **1. Authentication APIs**

#### **Admin Login**
```javascript
POST /api/auth/admin-login
{
  "email": "admin@accex.in",
  "password": "secure_password"
}

Response:
{
  "success": true,
  "token": "firebase_admin_token",
  "user": {
    "uid": "admin_id",
    "email": "admin@accex.in",
    "role": "super_admin",
    "permissions": {...}
  }
}
```

#### **Role-Based Access Control**
```javascript
// Middleware for API protection
const adminAuth = (requiredRole) => {
  return async (req, res, next) => {
    const token = req.headers.authorization;
    const admin = await verifyAdminToken(token);
    
    if (!admin || !hasPermission(admin.role, requiredRole)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    
    req.admin = admin;
    next();
  };
};
```

### **2. User Management APIs**

#### **Get All Users**
```javascript
GET /api/users?page=1&limit=50&filter=active&sort=createdAt

Response:
{
  "users": [
    {
      "uid": "user_id",
      "fullName": "John Doe",
      "email": "john@example.com",
      "phoneNumber": "+1234567890",
      "trustScore": 85,
      "verificationLevel": "document",
      "cardCount": 3,
      "lastLogin": "2024-01-15T10:30:00Z",
      "status": "active" | "flagged" | "suspended",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 1250,
    "totalPages": 25
  }
}
```

#### **User Actions**
```javascript
// Flag/Unflag User
POST /api/users/{userId}/flag
{
  "reason": "Suspicious activity",
  "action": "flag" | "unflag"
}

// Suspend/Activate User
POST /api/users/{userId}/status
{
  "status": "suspended" | "active",
  "reason": "Policy violation"
}
```

### **3. Analytics APIs**

#### **Dashboard Metrics**
```javascript
GET /api/analytics/dashboard?period=7d

Response:
{
  "overview": {
    "totalUsers": 1250,
    "activeUsers": 890,
    "newUsers": 45,
    "cardsCreated": 120,
    "scansToday": 340
  },
  "charts": {
    "userGrowth": [
      {"date": "2024-01-01", "users": 1000},
      {"date": "2024-01-02", "users": 1050}
    ],
    "engagement": [
      {"date": "2024-01-01", "scans": 200, "cards": 50}
    ]
  },
  "topUsers": [
    {"name": "John Doe", "scans": 150, "trustScore": 95}
  ]
}
```

#### **Detailed Analytics**
```javascript
GET /api/analytics/detailed?startDate=2024-01-01&endDate=2024-01-15

Response:
{
  "userMetrics": {
    "registrations": 450,
    "verifications": 120,
    "trustScoreDistribution": {
      "0-20": 50,
      "21-40": 100,
      "41-60": 200,
      "61-80": 300,
      "81-100": 150
    }
  },
  "cardMetrics": {
    "totalCards": 2500,
    "activeCards": 2000,
    "scannedCards": 5000,
    "averageScansPerCard": 2.5
  },
  "abuseMetrics": {
    "flaggedUsers": 25,
    "suspendedUsers": 5,
    "abuseReports": 15
  }
}
```

### **4. System Configuration APIs**

#### **Get Configuration**
```javascript
GET /api/config

Response:
{
  "cardLimits": {
    "maxCardsPerUser": 10,
    "maxScansPerDay": 50
  },
  "abusePrevention": {
    "cooldownPeriods": [24, 72, 168],
    "velocityLimits": {...}
  }
}
```

#### **Update Configuration**
```javascript
PUT /api/config
{
  "cardLimits": {
    "maxCardsPerUser": 15
  }
}

Response:
{
  "success": true,
  "updatedBy": "admin_id",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

---

## 🎨 **Frontend Architecture**

### **Page Structure**
```
src/
├── pages/
│   ├── index.tsx                 # Dashboard
│   ├── users/
│   │   ├── index.tsx            # User list
│   │   └── [id].tsx             # User details
│   ├── analytics/
│   │   ├── index.tsx            # Analytics dashboard
│   │   └── reports.tsx          # Detailed reports
│   ├── system/
│   │   ├── config.tsx           # System configuration
│   │   └── logs.tsx             # Admin action logs
│   └── api/                     # API routes
├── components/
│   ├── layout/
│   │   ├── AdminLayout.tsx      # Main layout
│   │   └── Sidebar.tsx          # Navigation
│   ├── charts/
│   │   ├── UserGrowthChart.tsx
│   │   └── EngagementChart.tsx
│   └── tables/
│       ├── UserTable.tsx
│       └── ActionLogTable.tsx
├── hooks/
│   ├── useAuth.ts              # Authentication
│   ├── useUsers.ts             # User management
│   └── useAnalytics.ts         # Analytics data
├── store/
│   ├── authSlice.ts            # Auth state
│   ├── usersSlice.ts           # Users state
│   └── analyticsSlice.ts       # Analytics state
└── utils/
    ├── firebase.ts             # Firebase config
    ├── api.ts                  # API client
    └── permissions.ts          # Role-based access
```

### **Key Components**

#### **Dashboard Overview**
```typescript
// components/Dashboard.tsx
const Dashboard = () => {
  const { data: metrics } = useAnalytics();
  const { data: recentUsers } = useUsers({ limit: 5 });
  
  return (
    <Grid container spacing={3}>
      <Grid item xs={12} md={3}>
        <MetricCard 
          title="Total Users" 
          value={metrics?.totalUsers}
          trend={metrics?.userGrowth}
        />
      </Grid>
      <Grid item xs={12} md={9}>
        <UserGrowthChart data={metrics?.userGrowth} />
      </Grid>
    </Grid>
  );
};
```

#### **User Management Table**
```typescript
// components/UserTable.tsx
const UserTable = () => {
  const { data: users, isLoading } = useUsers();
  const [flagUser] = useFlagUserMutation();
  
  const handleFlagUser = async (userId: string, reason: string) => {
    await flagUser({ userId, reason });
  };
  
  return (
    <DataGrid
      rows={users}
      columns={[
        { field: 'fullName', headerName: 'Name' },
        { field: 'trustScore', headerName: 'Trust Score' },
        { field: 'status', headerName: 'Status' },
        { field: 'actions', renderCell: (params) => (
          <UserActions user={params.row} onFlag={handleFlagUser} />
        )}
      ]}
    />
  );
};
```

---

## 🔐 **Security Implementation**

### **Firebase Security Rules Extension**
```javascript
// Additional rules for web portal
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Admin users - only super admins can manage
    match /admin_users/{adminId} {
      allow read, write: if isSuperAdmin(request.auth.uid);
    }
    
    // System analytics - read-only for admins
    match /system_analytics/{date} {
      allow read: if isAdmin(request.auth.uid);
    }
    
    // Admin actions - write for admins, read for super admins
    match /admin_actions/{actionId} {
      allow read: if isAdmin(request.auth.uid);
      allow write: if isAdmin(request.auth.uid);
    }
    
    // System config - super admin only
    match /system_config/{configId} {
      allow read: if isAdmin(request.auth.uid);
      allow write: if isSuperAdmin(request.auth.uid);
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
  }
}
```

### **API Security Middleware**
```typescript
// utils/auth.ts
export const verifyAdminToken = async (token: string) => {
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    const adminDoc = await admin.firestore()
      .collection('admin_users')
      .doc(decodedToken.uid)
      .get();
    
    if (!adminDoc.exists) {
      throw new Error('Admin user not found');
    }
    
    return adminDoc.data();
  } catch (error) {
    throw new Error('Invalid admin token');
  }
};

export const hasPermission = (userRole: string, requiredRole: string) => {
  const roleHierarchy = {
    'moderator': ['moderator'],
    'admin': ['moderator', 'admin'],
    'super_admin': ['moderator', 'admin', 'super_admin']
  };
  
  return roleHierarchy[userRole]?.includes(requiredRole) || false;
};
```

---

## 🚀 **Deployment Strategy**

### **Development Environment**
```bash
# Project setup
npx create-next-app@latest accex-portal --typescript --tailwind --app
cd accex-portal

# Install dependencies
npm install @mui/material @emotion/react @emotion/styled
npm install @reduxjs/toolkit react-redux
npm install firebase-admin
npm install chart.js react-chartjs-2

# Environment setup
cp .env.example .env.local
# Configure Firebase credentials
```

### **Production Deployment**
```yaml
# vercel.json
{
  "env": {
    "FIREBASE_PROJECT_ID": "@firebase-project-id",
    "FIREBASE_PRIVATE_KEY": "@firebase-private-key",
    "FIREBASE_CLIENT_EMAIL": "@firebase-client-email"
  },
  "functions": {
    "pages/api/**/*.ts": {
      "runtime": "nodejs18.x"
    }
  }
}
```

### **Domain Configuration**
```bash
# DNS Configuration for accex.in
# A Record: accex.in -> Vercel IP
# CNAME: www.accex.in -> accex.in
# SSL: Automatic via Vercel
```

---

## 📈 **Implementation Roadmap**

### **Phase 1: Foundation (Week 1-2)**
- [ ] Project setup and basic authentication
- [ ] Firebase Admin SDK integration
- [ ] Basic dashboard with user metrics
- [ ] User management interface

### **Phase 2: Core Features (Week 3-4)**
- [ ] Advanced analytics and reporting
- [ ] System configuration management
- [ ] Admin action logging
- [ ] Role-based access control

### **Phase 3: Advanced Features (Week 5-6)**
- [ ] Real-time notifications
- [ ] Advanced filtering and search
- [ ] Export functionality
- [ ] Mobile-responsive design

### **Phase 4: Production (Week 7-8)**
- [ ] Security hardening
- [ ] Performance optimization
- [ ] Testing and QA
- [ ] Production deployment

---

## 🔗 **Integration Points**

### **Shared Firebase Backend**
- **Authentication**: Shared user accounts between mobile app and web portal
- **Database**: Same Firestore collections with additional admin collections
- **Storage**: Shared Firebase Storage for documents and images
- **Functions**: Shared Cloud Functions for business logic

### **API Communication**
- **Real-time Updates**: Firebase Realtime Database for live dashboard updates
- **Webhooks**: Cloud Functions can trigger web portal updates
- **Shared Services**: Common business logic in Cloud Functions

### **Data Flow**
```
Mobile App → Firebase → Web Portal
     ↓           ↓         ↓
User Actions → Analytics → Admin Dashboard
     ↓           ↓         ↓
Notifications → Reports → System Config
```

---

This architecture provides a comprehensive, scalable, and secure web portal that integrates seamlessly with your existing TestCard ecosystem while maintaining proper separation of concerns and security boundaries.
