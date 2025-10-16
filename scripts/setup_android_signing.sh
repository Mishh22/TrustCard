#!/bin/bash

echo "🔐 Android Production Signing Setup"
echo "===================================="

echo ""
echo "This script will help you set up production signing for your Android app."
echo "You'll need to create a keystore with a strong password (at least 6 characters)."
echo ""

# Check if keystore already exists
if [ -f ~/upload-keystore.jks ]; then
    echo "⚠️  Keystore already exists at ~/upload-keystore.jks"
    read -p "Do you want to create a new one? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing keystore..."
    else
        echo "Removing existing keystore..."
        rm ~/upload-keystore.jks
    fi
fi

echo ""
echo "📝 Keystore Information:"
echo "- Keystore file: ~/upload-keystore.jks"
echo "- Key alias: upload"
echo "- Algorithm: RSA"
echo "- Key size: 2048 bits"
echo "- Validity: 10000 days"
echo ""

echo "🚀 Generating keystore..."
echo "You'll be prompted for:"
echo "1. Keystore password (at least 6 characters)"
echo "2. Key password (can be same as keystore password)"
echo "3. Your name and organization details"
echo ""

keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore generated successfully!"
    echo ""
    echo "📁 Keystore location: ~/upload-keystore.jks"
    echo ""
    echo "🔧 Next steps:"
    echo "1. The script will create key.properties file"
    echo "2. Update build.gradle to use production signing"
    echo "3. Test the release build"
    echo ""
    
    # Create key.properties file
    echo "Creating key.properties file..."
    cat > android/key.properties << EOF
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
EOF
    
    echo "✅ Created android/key.properties template"
    echo ""
    echo "⚠️  IMPORTANT: Update android/key.properties with your actual passwords!"
    echo "   - Replace YOUR_STORE_PASSWORD with your keystore password"
    echo "   - Replace YOUR_KEY_PASSWORD with your key password"
    echo ""
    
    # Update build.gradle
    echo "Updating build.gradle to use production keystore..."
    
    # Create a backup
    cp android/app/build.gradle.kts android/app/build.gradle.kts.backup
    
    # Update the signing config
    cat > android/app/build.gradle.kts << 'EOF'
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.accexasia.TrustCard"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.accexasia.TrustCard"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
EOF
    
    echo "✅ Updated build.gradle.kts for production signing"
    echo ""
    echo "🎉 Android signing setup complete!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Update android/key.properties with your actual passwords"
    echo "2. Test the release build: flutter build appbundle --release"
    echo "3. The generated .aab file will be in build/app/outputs/bundle/release/"
    echo ""
    
else
    echo "❌ Keystore generation failed!"
    echo "Please try again or contact support."
fi
