#!/usr/bin/env node

/**
 * TrustCard Admin Setup Script
 * 
 * This script sets up admin privileges for specific users in Firebase.
 * Run this script to grant admin access to users who can review documents.
 * 
 * Usage:
 * 1. Install Firebase CLI: npm install -g firebase-tools
 * 2. Login: firebase login
 * 3. Set project: firebase use trustcard-aee4a
 * 4. Run: node scripts/setup-admin.js
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = {
  // You need to download this from Firebase Console → Project Settings → Service Accounts
  // Click "Generate new private key" and save the JSON file
  // Then replace this object with the contents of that file
  "type": "service_account",
  "project_id": "trustcard-aee4a",
  "private_key_id": "YOUR_PRIVATE_KEY_ID",
  "private_key": "YOUR_PRIVATE_KEY",
  "client_email": "YOUR_CLIENT_EMAIL",
  "client_id": "YOUR_CLIENT_ID",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "YOUR_CERT_URL"
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'trustcard-aee4a'
});

async function setupAdmin() {
  try {
    console.log('🔐 Setting up admin privileges...');
    
    // List of emails that should have admin access
    const adminEmails = [
      'manish@email.com',  // Your email
      'admin@trustcard.com', // Main admin
      // Add more admin emails here
    ];
    
    for (const email of adminEmails) {
      try {
        // Get user by email
        const user = await admin.auth().getUserByEmail(email);
        
        // Set custom claims
        await admin.auth().setCustomUserClaims(user.uid, {
          admin: true,
          role: 'document_reviewer',
          permissions: ['review_documents', 'approve_documents', 'reject_documents']
        });
        
        console.log(`✅ Admin privileges granted to: ${email}`);
      } catch (error) {
        if (error.code === 'auth/user-not-found') {
          console.log(`⚠️  User not found: ${email} - They need to sign up first`);
        } else {
          console.error(`❌ Error setting admin for ${email}:`, error.message);
        }
      }
    }
    
    console.log('\n🎉 Admin setup complete!');
    console.log('\n📋 Next steps:');
    console.log('1. Users with admin privileges will see "Admin Verification" in their profile');
    console.log('2. They can review pending documents in the admin dashboard');
    console.log('3. To add more admins, edit this script and run it again');
    
  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    process.exit(1);
  }
}

// Run the setup
setupAdmin();
