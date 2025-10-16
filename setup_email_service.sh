#!/bin/bash

# TrustCard Email Service Setup Script
# This script sets up Firebase Functions for sending company verification emails

set -e  # Exit on any error

echo "📧 TrustCard Email Service Setup"
echo "================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Step 1: Install Firebase Functions dependencies
echo ""
echo "📦 Installing Firebase Functions dependencies..."
cd functions
npm install
cd ..

echo "✅ Dependencies installed"

# Step 2: Build TypeScript
echo ""
echo "🔨 Building TypeScript..."
cd functions
npm run build
cd ..

echo "✅ TypeScript compiled"

# Step 3: Instructions for SendGrid setup
echo ""
echo "📧 SendGrid Setup Required:"
echo "1. Sign up for SendGrid: https://sendgrid.com/"
echo "2. Create an API key in SendGrid dashboard"
echo "3. Set the API key in Firebase Functions config:"
echo ""
echo "   firebase functions:config:set sendgrid.key=\"YOUR_SENDGRID_API_KEY\""
echo ""
echo "4. Deploy the functions:"
echo "   firebase deploy --only functions"
echo ""

# Step 4: Test instructions
echo "🧪 Testing Instructions:"
echo "1. Deploy functions: firebase deploy --only functions"
echo "2. Test email: firebase functions:shell"
echo "3. Run: sendTestEmail()"
echo "4. Check logs: firebase functions:log"
echo ""

echo "✅ Email service setup complete!"
echo ""
echo "📋 What happens next:"
echo "- When a company verification request is submitted"
echo "- Firebase Function automatically triggers"
echo "- Email sent to info@accexasia.com with all details"
echo "- Includes company info, attachments, and request ID"
echo ""
echo "🔗 Email will be sent to: info@accexasia.com"
echo "📎 Attachments included: Business photo, GST cert, PAN cert"
