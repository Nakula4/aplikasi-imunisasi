#!/bin/bash

echo "🔑 Creating debug keystore..."

# Navigate to app directory
cd android/app

# Create debug keystore if not exists
if [ ! -f "debug.keystore" ]; then
    echo "📝 Generating debug keystore..."
    keytool -genkey -v \
        -keystore debug.keystore \
        -storepass android \
        -alias androiddebugkey \
        -keypass android \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -dname "CN=Android Debug,O=Android,C=US"
    
    if [ $? -eq 0 ]; then
        echo "✅ Debug keystore created successfully!"
    else
        echo "❌ Failed to create debug keystore"
        exit 1
    fi
else
    echo "✅ Debug keystore already exists"
fi

# List keystore info
echo "📋 Keystore info:"
keytool -list -v -keystore debug.keystore -storepass android

cd ../..
echo "🎯 Keystore location: android/app/debug.keystore"