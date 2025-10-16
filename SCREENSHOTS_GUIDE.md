# App Screenshots Guide for TrustCard

## 📱 Required Screenshots for App Stores

### Google Play Store Requirements
- **Phone Screenshots**: 2-8 screenshots (16:9 or 9:16 aspect ratio)
- **Tablet Screenshots**: 1-8 screenshots (optional but recommended)
- **Feature Graphic**: 1024 x 500 pixels
- **App Icon**: 512 x 512 pixels (already generated)

### Apple App Store Requirements
- **iPhone Screenshots**: 6.7", 6.5", 5.5" display sizes
- **iPad Screenshots**: 12.9", 11" display sizes
- **App Preview Videos**: Optional but recommended

## 📸 Screenshot Checklist

### Essential Screens to Capture:

#### 1. **Main Profile Screen**
- Show user's digital ID profile
- Display profile photo and basic information
- Highlight the "TrustCard" branding

#### 2. **QR Code Generation**
- Show the generated QR code prominently
- Display sharing options
- Include the "Share" or "Generate QR" button

#### 3. **QR Code Scanner**
- Show the camera view with scanning interface
- Display scanning instructions or overlay
- Show successful scan result

#### 4. **Contact List/Sharing**
- Show saved contacts
- Display sharing options
- Highlight contact integration features

#### 5. **Settings/Profile Management**
- Show app settings
- Display profile editing options
- Include privacy/security settings

#### 6. **Scan History**
- Show previous scans
- Display verification history
- Highlight security features

## 🛠️ How to Take Screenshots

### Method 1: Using Flutter (Recommended)
```bash
# Run the app in debug mode
flutter run

# Take screenshots using device tools
# Android: Use device screenshot feature
# iOS: Use device screenshot feature
```

### Method 2: Using Emulators
```bash
# Start Android emulator
flutter emulators --launch <emulator_id>

# Start iOS simulator
open -a Simulator

# Run the app
flutter run
```

### Method 3: Using Physical Devices
1. Connect your Android/iOS device
2. Enable developer options
3. Run: `flutter run`
4. Take screenshots using device features

## 📐 Screenshot Specifications

### Android Screenshots
- **Resolution**: 1080x1920 (Full HD) or higher
- **Format**: PNG or JPEG
- **Aspect Ratio**: 9:16 (portrait) or 16:9 (landscape)
- **File Size**: Under 8MB each

### iOS Screenshots
- **iPhone 6.7"**: 1290 x 2796 pixels
- **iPhone 6.5"**: 1242 x 2688 pixels  
- **iPhone 5.5"**: 1242 x 2208 pixels
- **iPad 12.9"**: 2048 x 2732 pixels
- **iPad 11"**: 1668 x 2388 pixels

## 🎨 Screenshot Best Practices

### Design Guidelines
1. **Clean Interface**: Remove any debug overlays or development tools
2. **Consistent Branding**: Ensure TrustCard branding is visible
3. **Realistic Data**: Use realistic but fake user data
4. **High Quality**: Use high-resolution screenshots
5. **Proper Orientation**: Use portrait for most screenshots

### Content Guidelines
1. **Show Key Features**: Highlight main app functionality
2. **User-Friendly**: Show intuitive user interface
3. **Professional Look**: Ensure screenshots look polished
4. **Consistent Style**: Use similar styling across all screenshots

## 📱 Device-Specific Instructions

### Android Screenshots
```bash
# Method 1: Using ADB
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# Method 2: Using device
# Press Power + Volume Down buttons simultaneously
```

### iOS Screenshots
```bash
# Method 1: Using Xcode
# Open Xcode → Window → Devices and Simulators
# Select device → Take Screenshot

# Method 2: Using device
# Press Power + Volume Up buttons simultaneously
```

## 🖼️ Image Editing (Optional)

### Recommended Tools
- **Preview** (macOS): Built-in image editing
- **GIMP**: Free image editor
- **Photoshop**: Professional editing
- **Canva**: Online design tool

### Basic Editing Steps
1. **Crop**: Remove unnecessary areas
2. **Resize**: Adjust to required dimensions
3. **Enhance**: Improve brightness/contrast if needed
4. **Add Text**: Optional - add captions or descriptions

## 📋 Screenshot Organization

### File Naming Convention
```
screenshots/
├── android/
│   ├── phone_01_main_profile.png
│   ├── phone_02_qr_generation.png
│   ├── phone_03_qr_scanner.png
│   ├── phone_04_contacts.png
│   └── phone_05_settings.png
├── ios/
│   ├── iphone_01_main_profile.png
│   ├── iphone_02_qr_generation.png
│   ├── iphone_03_qr_scanner.png
│   ├── iphone_04_contacts.png
│   └── iphone_05_settings.png
└── feature_graphic.png
```

## 🚀 Quick Screenshot Script

Create this script to automate screenshot taking:

```bash
#!/bin/bash
echo "📸 TrustCard Screenshot Tool"
echo "============================"

# Create screenshots directory
mkdir -p screenshots/{android,ios}

echo "📱 Taking Android screenshots..."
# Add your Android screenshot commands here

echo "🍎 Taking iOS screenshots..."
# Add your iOS screenshot commands here

echo "✅ Screenshots saved to screenshots/ directory"
```

## 📊 Store-Specific Requirements

### Google Play Store
- **Minimum**: 2 screenshots
- **Maximum**: 8 screenshots
- **Format**: PNG or JPEG
- **Size**: 320KB - 8MB each
- **Dimensions**: 320px - 3840px (width or height)

### Apple App Store
- **Required**: Screenshots for all device sizes you support
- **Format**: PNG or JPEG
- **Size**: Under 5MB each
- **Dimensions**: Exact device resolutions

## 🎯 Pro Tips

1. **Test on Real Devices**: Screenshots look better on actual devices
2. **Use High-Quality Data**: Fill the app with realistic, professional-looking data
3. **Show Key Features**: Focus on the most important app features
4. **Consistent Branding**: Ensure TrustCard branding is prominent
5. **Clean Interface**: Remove any development tools or debug information

## 📞 Need Help?

If you need assistance with screenshots:
1. Run the app on your device
2. Navigate to each main screen
3. Take screenshots using device features
4. Save them in the organized folder structure
5. Use the provided naming convention

Remember: Good screenshots can significantly improve your app's download rate!
