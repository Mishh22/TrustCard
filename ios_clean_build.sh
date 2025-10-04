#!/bin/bash

# iOS Clean Build Script for TrustCard
# Run this before every iOS build to ensure clean environment

echo "🧹 Starting iOS Clean Build Process..."

# Kill any running processes
echo "📱 Stopping running processes..."
pkill -f Xcode 2>/dev/null || true
pkill -f flutter 2>/dev/null || true
pkill -f xcodebuild 2>/dev/null || true

# Clean Flutter
echo "🔄 Cleaning Flutter build artifacts..."
flutter clean

# Clean iOS specific
echo "🗑️ Cleaning iOS build artifacts..."
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Install pods
echo "🍎 Installing iOS pods..."
cd ios
pod install
cd ..

# Open in Xcode
echo "🚀 Opening project in Xcode..."
open ios/Runner.xcworkspace

echo "✅ iOS Clean Build Complete!"
echo "📱 Select your iPhone 14 Pro in Xcode and click ▶️ Build and Run"
echo "⚠️  Ignore deprecation warnings - they're cosmetic only"
