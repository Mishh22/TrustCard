#!/bin/bash

echo "📱 TrustCard App Testing & Screenshot Tool"
echo "=========================================="

# Create screenshots directory
mkdir -p screenshots/{android,ios}

echo ""
echo "🔧 Available Commands:"
echo "1. Test Android build"
echo "2. Test iOS build" 
echo "3. Run app for screenshots"
echo "4. Check app status"
echo ""

read -p "Choose an option (1-4): " choice

case $choice in
    1)
        echo "🤖 Testing Android build..."
        echo "Building Android App Bundle..."
        flutter build appbundle --release
        
        if [ $? -eq 0 ]; then
            echo "✅ Android build successful!"
            echo "📁 AAB file location: build/app/outputs/bundle/release/app-release.aab"
            echo ""
            echo "🚀 Next steps:"
            echo "1. Upload the .aab file to Google Play Console"
            echo "2. Complete the store listing"
            echo "3. Submit for review"
        else
            echo "❌ Android build failed!"
            echo "Check the error messages above."
        fi
        ;;
    2)
        echo "🍎 Testing iOS build..."
        echo "Building iOS app..."
        flutter build ios --release
        
        if [ $? -eq 0 ]; then
            echo "✅ iOS build successful!"
            echo "📁 iOS app location: build/ios/iphoneos/Runner.app"
            echo ""
            echo "🚀 Next steps:"
            echo "1. Open Xcode and archive the app"
            echo "2. Upload to App Store Connect"
            echo "3. Complete the store listing"
        else
            echo "❌ iOS build failed!"
            echo "Check the error messages above."
        fi
        ;;
    3)
        echo "📸 Running app for screenshots..."
        echo ""
        echo "📋 Screenshot Checklist:"
        echo "1. Main Profile Screen"
        echo "2. QR Code Generation"
        echo "3. QR Code Scanner"
        echo "4. Contact List"
        echo "5. Settings Screen"
        echo ""
        echo "🚀 Starting app..."
        flutter run
        
        echo ""
        echo "📸 Screenshot Instructions:"
        echo "- Navigate through the app"
        echo "- Take screenshots of each main screen"
        echo "- Save screenshots to screenshots/ directory"
        echo "- Use the naming convention from SCREENSHOTS_GUIDE.md"
        ;;
    4)
        echo "📊 App Status Check"
        echo "=================="
        echo ""
        echo "🔍 Checking Flutter setup..."
        flutter doctor
        
        echo ""
        echo "📱 Available devices..."
        flutter devices
        
        echo ""
        echo "📦 Dependencies status..."
        flutter pub get
        
        echo ""
        echo "✅ Status check complete!"
        ;;
    *)
        echo "❌ Invalid option. Please choose 1-4."
        ;;
esac

echo ""
echo "📚 Additional Resources:"
echo "- Screenshots Guide: SCREENSHOTS_GUIDE.md"
echo "- Deployment Checklist: DEPLOYMENT_CHECKLIST.md"
echo "- App Store Descriptions: APP_STORE_DESCRIPTIONS.md"
echo "- Privacy Policy: PRIVACY_POLICY.md"
