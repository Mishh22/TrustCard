#!/bin/bash

# TrustCard Production Deployment Script
# Run this script to deploy the app to production

set -e  # Exit on any error

echo "🚀 TrustCard Production Deployment"
echo "=================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Step 1: Install dependencies
echo ""
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Step 2: Deploy Firebase Security Rules
echo ""
echo "🔒 Deploying Firebase Security Rules..."
firebase deploy --only storage
firebase deploy --only firestore

echo "✅ Security rules deployed"

# Step 3: Set up admin users (if script exists)
if [ -f "scripts/set_admin.js" ]; then
    echo ""
    echo "👑 Setting up admin users..."
    echo "   Note: You need to run this manually:"
    echo "   cd scripts && node set_admin.js set manish@email.com"
    echo "   cd scripts && node set_admin.js list"
fi

# Step 4: Build and test
echo ""
echo "🔨 Building Flutter app..."
flutter clean
flutter pub get

# Build for Android
echo "📱 Building Android APK..."
flutter build apk --release

# Build for iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS app..."
    flutter build ios --release
fi

echo ""
echo "✅ Build completed successfully!"

# Step 5: Cost estimation
echo ""
echo "💰 Estimated Monthly Costs (1000 users):"
echo "   Firebase Storage: ~₹8/month"
echo "   Firestore Reads: ~₹20/month" 
echo "   Firestore Writes: ~₹10/month"
echo "   Total: ~₹40-50/month"
echo ""
echo "📊 Monitor usage at: https://console.firebase.google.com"

# Step 6: Testing checklist
echo ""
echo "🧪 Pre-Launch Testing Checklist:"
echo "   □ Test admin login (manish@email.com)"
echo "   □ Verify admin dashboard appears"
echo "   □ Upload document as regular user"
echo "   □ Approve/reject from admin dashboard"
echo "   □ Check user receives notification"
echo "   □ Test rate limiting (upload 4 documents quickly)"
echo "   □ Verify image compression works"
echo "   □ Test on both Android and iOS"

echo ""
echo "🎉 Deployment completed!"
echo "   Your app is ready for production testing."
echo ""
echo "📱 Next steps:"
echo "   1. Test the complete flow with real documents"
echo "   2. Set up Firebase Budget Alerts"
echo "   3. Monitor Firebase Console for usage"
echo "   4. Deploy to app stores when ready"
