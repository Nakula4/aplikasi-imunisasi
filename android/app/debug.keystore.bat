@echo off
echo 🔑 Creating debug keystore...

cd android\app

if not exist "debug.keystore" (
    echo 📝 Generating debug keystore...
    keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
    
    if %errorlevel% equ 0 (
        echo ✅ Debug keystore created successfully!
    ) else (
        echo ❌ Failed to create debug keystore
        pause
        exit /b 1
    )
) else (
    echo ✅ Debug keystore already exists
)

echo 📋 Keystore info:
keytool -list -v -keystore debug.keystore -storepass android

cd ..\..
echo 🎯 Keystore location: android\app\debug.keystore
pause