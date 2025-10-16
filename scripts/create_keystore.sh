#!/bin/bash

echo "🔐 Creating Android Production Keystore"
echo "======================================="

# Set default passwords (you can change these)
STORE_PASSWORD="TrustCard2024!"
KEY_PASSWORD="TrustCard2024!"

echo "Creating keystore with default passwords..."
echo "Store Password: $STORE_PASSWORD"
echo "Key Password: $KEY_PASSWORD"
echo ""

# Create keystore with non-interactive mode
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass "$STORE_PASSWORD" -keypass "$KEY_PASSWORD" -dname "CN=TrustCard, OU=Development, O=TrustCard, L=City, S=State, C=US"

if [ $? -eq 0 ]; then
    echo "✅ Keystore created successfully!"
    
    # Update key.properties with actual passwords
    cat > android/key.properties << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
EOF
    
    echo "✅ Updated key.properties with actual passwords"
    echo ""
    echo "📁 Keystore location: ~/upload-keystore.jks"
    echo "🔑 Store Password: $STORE_PASSWORD"
    echo "🔑 Key Password: $KEY_PASSWORD"
    echo ""
    echo "⚠️  IMPORTANT: Save these passwords securely!"
    echo "   You'll need them for future app updates."
    echo ""
    echo "🚀 Ready to test the build!"
    
else
    echo "❌ Keystore creation failed!"
    echo "Please check the error messages above."
fi
