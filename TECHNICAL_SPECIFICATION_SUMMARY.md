# Technical Specification Summary - accex.in Web Portal

## 📋 **Executive Summary**

This document provides a comprehensive technical specification for building the **accex.in web portal** as a separate project** that integrates with the existing TestCard mobile application ecosystem.

### **Key Recommendations**
- ✅ **Separate Project**: Keep accex.in as independent repository
- ✅ **Shared Backend**: Use existing Firebase infrastructure
- ✅ **Technology Stack**: Next.js + Material-UI + Firebase Admin SDK
- ✅ **Domain**: www.accex.in (GoDaddy domain)
- ✅ **Deployment**: Vercel/Netlify for web hosting

---

## 🎯 **Project Scope & Objectives**

### **Primary Goals**
1. **Admin Dashboard**: Comprehensive user and system management
2. **Analytics Platform**: Real-time insights and reporting
3. **Abuse Prevention**: Advanced monitoring and flagging system
4. **System Configuration**: Dynamic settings management
5. **User Support**: Enhanced customer service tools

### **Target Users**
- **Super Admins**: Full system access and configuration
- **Admins**: User management and abuse prevention
- **Moderators**: Limited user support and monitoring

---

## 🏗️ **Architecture Overview**

### **System Architecture**
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
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Framework** | Next.js | 14.x | React framework with SSR |
| **UI Library** | Material-UI | 5.x | Component library |
| **State Management** | Redux Toolkit | 2.x | Global state management |
| **Charts** | Chart.js | 4.x | Data visualization |
| **Authentication** | Firebase Auth | 10.x | User authentication |
| **Deployment** | Vercel | Latest | Hosting platform |

#### **Backend Integration**
| Component | Technology | Purpose |
|-----------|------------|---------|
| **Firebase Admin SDK** | Node.js | Server-side operations |
| **API Routes** | Next.js | Custom endpoints |
| **Real-time** | Firebase Realtime DB | Live updates |
| **Security** | Firebase Rules | Access control |

---

## 📊 **Database Schema Design**

### **Existing Collections (TestCard)**
```javascript
// Current TestCard collections (unchanged)
users/                    # User profiles
user_cards/              # Individual cards
user_profiles/           # User account data
account_lifecycle/       # Abuse prevention
flagged_users/           # Flagged users
app_config/             # System configuration
```

### **New Collections (accex.in)**
```javascript
// New collections for web portal
admin_users/             # Admin user accounts
system_analytics/        # Daily analytics data
admin_actions/          # Admin action logs
realtime_updates/       # Live dashboard data
system_config/          # Enhanced configuration
```

### **Enhanced Data Models**
```typescript
// Enhanced user profile with admin fields
interface UserProfile {
  // Existing fields (unchanged)
  uid: string;
  fullName: string;
  email: string;
  phoneNumber: string;
  
  // New admin fields
  status: 'active' | 'flagged' | 'suspended';
  flaggedBy?: string;
  flaggedAt?: Timestamp;
  flaggedReason?: string;
  adminNotes?: string;
  
  // Analytics fields
  lastLoginAt: Timestamp;
  totalCardsCreated: number;
  totalScansReceived: number;
  totalScansPerformed: number;
}
```

---

## 🔌 **API Specification**

### **Authentication APIs**
```typescript
// Admin login
POST /api/auth/admin-login
{
  "email": "admin@accex.in",
  "password": "secure_password"
}

// Token verification
GET /api/auth/verify
Authorization: Bearer <token>
```

### **User Management APIs**
```typescript
// Get users with filtering
GET /api/users?page=1&limit=50&filter=active&sort=trustScore

// Flag/unflag user
POST /api/users/{userId}/flag
{
  "reason": "Suspicious activity",
  "action": "flag" | "unflag"
}

// Suspend user
POST /api/users/{userId}/suspend
{
  "reason": "Policy violation",
  "duration": 24 // hours
}
```

### **Analytics APIs**
```typescript
// Dashboard metrics
GET /api/analytics/dashboard?period=7d

// Detailed analytics
GET /api/analytics/detailed?startDate=2024-01-01&endDate=2024-01-15

// Real-time updates
WebSocket: wss://accex.in/api/realtime
```

### **System Configuration APIs**
```typescript
// Get configuration
GET /api/config

// Update configuration
PUT /api/config
{
  "cardLimits": {
    "maxCardsPerUser": 15
  }
}
```

---

## 🛡️ **Security Implementation**

### **Authentication & Authorization**
```typescript
// Role-based access control
interface PermissionSet {
  userManagement: boolean;
  analytics: boolean;
  systemConfig: boolean;
  abuseReview: boolean;
}

// Admin roles
type AdminRole = 'super_admin' | 'admin' | 'moderator';

// Permission hierarchy
const roleHierarchy = {
  'moderator': ['moderator'],
  'admin': ['moderator', 'admin'],
  'super_admin': ['moderator', 'admin', 'super_admin']
};
```

### **Firebase Security Rules**
```javascript
// Enhanced rules for web portal
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
    }
    
    // Enhanced user access for web portal
    match /users/{userId} {
      // Mobile app access (existing)
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Admin access for web portal
      allow read: if isAdmin(request.auth.uid);
      allow write: if isAdmin(request.auth.uid);
    }
  }
}
```

### **Data Protection**
- **Encryption**: Sensitive data encrypted at rest
- **Anonymization**: Analytics data anonymized
- **Access Logging**: All admin actions logged
- **Rate Limiting**: API rate limiting implemented
- **CORS**: Proper cross-origin configuration

---

## 📈 **Performance & Scalability**

### **Caching Strategy**
```typescript
// Redis cache implementation
const cacheStrategy = {
  userData: { ttl: 300 },      // 5 minutes
  analytics: { ttl: 3600 },    // 1 hour
  dashboard: { ttl: 900 }      // 15 minutes
};
```

### **Database Optimization**
```javascript
// Firestore indexes for web portal queries
{
  "indexes": [
    {
      "collectionGroup": "users",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "trustScore", "order": "DESCENDING" }
      ]
    }
  ]
}
```

### **Real-time Updates**
```typescript
// Firebase Realtime Database for live updates
const syncDashboard = () => {
  const db = getDatabase();
  const dashboardRef = ref(db, 'realtime_updates/dashboard');
  
  onValue(dashboardRef, (snapshot) => {
    updateDashboardMetrics(snapshot.val());
  });
};
```

---

## 🚀 **Deployment Strategy**

### **Development Environment**
```bash
# Project setup
npx create-next-app@latest accex-portal --typescript
cd accex-portal

# Install dependencies
npm install @mui/material @reduxjs/toolkit firebase-admin
npm install chart.js react-chartjs-2

# Environment configuration
cp .env.example .env.local
```

### **Production Deployment**
```yaml
# vercel.json
{
  "env": {
    "FIREBASE_PROJECT_ID": "@firebase-project-id",
    "FIREBASE_PRIVATE_KEY": "@firebase-private-key"
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
# DNS setup for accex.in
# A Record: accex.in -> Vercel IP
# CNAME: www.accex.in -> accex.in
# SSL: Automatic via Vercel
```

---

## 📅 **Implementation Roadmap**

### **Phase 1: Foundation (Weeks 1-2)**
- [ ] Project setup and basic authentication
- [ ] Firebase Admin SDK integration
- [ ] Basic dashboard with user metrics
- [ ] User management interface

**Deliverables:**
- Working authentication system
- Basic admin dashboard
- User list with filtering
- Firebase integration

### **Phase 2: Core Features (Weeks 3-4)**
- [ ] Advanced analytics and reporting
- [ ] System configuration management
- [ ] Admin action logging
- [ ] Role-based access control

**Deliverables:**
- Analytics dashboard with charts
- System configuration panel
- Admin action logs
- User flagging/suspension

### **Phase 3: Advanced Features (Weeks 5-6)**
- [ ] Real-time notifications
- [ ] Advanced filtering and search
- [ ] Export functionality
- [ ] Mobile-responsive design

**Deliverables:**
- Real-time dashboard updates
- Advanced search and filtering
- Data export capabilities
- Mobile-responsive UI

### **Phase 4: Production (Weeks 7-8)**
- [ ] Security hardening
- [ ] Performance optimization
- [ ] Testing and QA
- [ ] Production deployment

**Deliverables:**
- Production-ready application
- Security audit completed
- Performance optimized
- Full documentation

---

## 💰 **Cost Estimation**

### **Development Costs**
| Component | Estimated Hours | Cost (if applicable) |
|-----------|----------------|---------------------|
| **Frontend Development** | 120 hours | - |
| **Backend Integration** | 80 hours | - |
| **Testing & QA** | 40 hours | - |
| **Deployment & Setup** | 20 hours | - |
| **Total** | **260 hours** | - |

### **Infrastructure Costs**
| Service | Monthly Cost | Annual Cost |
|---------|-------------|-------------|
| **Vercel Hosting** | $20 | $240 |
| **Firebase (existing)** | $0 | $0 |
| **Domain (accex.in)** | $2 | $24 |
| **SSL Certificate** | $0 | $0 |
| **Total** | **$22/month** | **$264/year** |

---

## 🔗 **Integration Points**

### **Shared Firebase Backend**
- **Authentication**: Shared user accounts
- **Database**: Same Firestore collections + admin collections
- **Storage**: Shared Firebase Storage
- **Functions**: Shared Cloud Functions

### **Data Flow**
```
Mobile App → Firebase → Web Portal
     ↓           ↓         ↓
User Actions → Analytics → Admin Dashboard
     ↓           ↓         ↓
Notifications → Reports → System Config
```

### **API Communication**
- **Real-time**: Firebase Realtime Database
- **Webhooks**: Cloud Functions trigger updates
- **Shared Services**: Common business logic

---

## 📋 **Success Metrics**

### **Technical Metrics**
- **Performance**: < 2s page load time
- **Uptime**: 99.9% availability
- **Security**: Zero security incidents
- **Scalability**: Support 10,000+ users

### **Business Metrics**
- **Admin Efficiency**: 50% faster user management
- **Abuse Prevention**: 90% reduction in false positives
- **System Monitoring**: Real-time system health
- **User Support**: Enhanced customer service

---

## 🎯 **Next Steps**

### **Immediate Actions**
1. **Create Repository**: Set up accex-portal repository
2. **Domain Setup**: Configure accex.in domain
3. **Environment Setup**: Configure development environment
4. **Team Assignment**: Assign development team

### **Development Kickoff**
1. **Technical Review**: Review this specification
2. **Architecture Approval**: Approve technical architecture
3. **Timeline Confirmation**: Confirm 8-week timeline
4. **Resource Allocation**: Allocate development resources

---

## 📞 **Support & Maintenance**

### **Ongoing Support**
- **Bug Fixes**: Continuous bug fixing
- **Feature Updates**: Regular feature additions
- **Security Updates**: Regular security patches
- **Performance Monitoring**: Continuous monitoring

### **Documentation**
- **API Documentation**: Comprehensive API docs
- **User Manual**: Admin user guide
- **Technical Docs**: Architecture documentation
- **Deployment Guide**: Production deployment guide

---

This technical specification provides a complete roadmap for building the accex.in web portal as a separate, integrated system that enhances your TestCard ecosystem with powerful admin capabilities and analytics.
