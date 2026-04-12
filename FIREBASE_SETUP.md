# Firebase Konfiguratsiyasi

## Firebase Project Yaratish

1. [Firebase Console](https://console.firebase.google.com/) ga boring
2. Yangi project yaratish tugmasini bosing
3. Project nomini kiriting (masalan: "tirikchilik")
4. Google Analytics yoqishni xohlasangiz yoqing, yoki o'tkazib yuboring

## Web Platform Konfiguratsiyasi

1. Firebase Console da projectingizni oching
2. "Build" -> "Authentication" ga boring
3. "Get started" tugmasini bosing
4. "Google" sign-in metodini yoqing
5. "Build" -> "Web" (</> icon) ga boring
6. App nomini kiriting
7. Firebase SDK konfiguratsiyasini nusxalang
8. `web/index.html` faylida quyidagilarni almashtiring:
   ```javascript
   const firebaseConfig = {
     apiKey: "YOUR_API_KEY",
     authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
     projectId: "YOUR_PROJECT_ID",
     storageBucket: "YOUR_PROJECT_ID.appspot.com",
     messagingSenderId: "YOUR_SENDER_ID",
     appId: "YOUR_APP_ID"
   };
   ```

## Android Platform Konfiguratsiyasi

1. Firebase Console da "Build" -> "Android" ga boring
2. Package nomini kiriting: `com.example.tirikchilik` (yoki o'zingizning package nomingiz)
3. `google-services.json` faylini yuklab oling
4. `android/app/` papkasiga `google-services.json` faylini qo'ying
5. `android/build.gradle` faylga qo'shing:
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.3.15'
       }
   }
   ```
6. `android/app/build.gradle` faylga qo'shing:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## iOS Platform Konfiguratsiyasi

1. Firebase Console da "Build" -> "iOS" ga boring
2. Bundle ID ni kiriting: `com.example.tirikchilik` (yoki o'zingizning bundle ID)
3. `GoogleService-Info.plist` faylini yuklab oling
4. Xcode da projectni oching
5. `GoogleService-Info.plist` faylini projectga qo'shing
6. `ios/Runner/Info.plist` faylga URL scheme qo'shing:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>YOUR_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

## Google Sign-In Konfiguratsiyasi

### Android
1. Firebase Console -> Authentication -> Sign-in method
2. Google ni yoqing
3. OAuth consent screen ni sozlang
4. Support email ni kiriting
5. OAuth client ID ni oling

### iOS
1. Firebase Console -> Authentication -> Sign-in method
2. Google ni yoqing
3. OAuth consent screen ni sozlang
4. Xcode da URL scheme qo'shing (yuqorida ko'rsatilgan)

## Muvaffaqiyatli Testlash

1. Firebase Console -> Authentication -> Users bo'limida foydalanuvchilarni ko'rishingiz mumkin
2. Ilovada Google bilan ro'yxatdan o'tishni sinang
3. Foydalanuvchi avtomatik ravishda yaratiladi

## Eslatmalar

- Web platformda Firebase config `web/index.html` da sozlanadi
- Android uchun `google-services.json` fayl kerak
- iOS uchun `GoogleService-Info.plist` fayl kerak
- Google Sign-In uchun OAuth consent screen sozlash shart
