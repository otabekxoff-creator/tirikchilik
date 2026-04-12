# Tirikchilik 💰

[![Flutter Version](https://img.shields.io/badge/Flutter-3.11+-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Reklama ko'rib pul ishlash ilovasi** | Watch ads and earn money app

![App Screenshot](https://via.placeholder.com/800x400/007AFF/FFFFFF?text=Tirikchilik+App+Preview)

## 🌟 Xususiyatlar | Features

### Foydalanuvchi uchun | For Users:
- 📺 **Reklama ko'rish** - Har xil darajadagi reklamalar (Oddiy, O'rta, Jiddiy)
- 💵 **Pul ishlash** - Har bir reklama uchun so'mda to'lov
- 👛 **Hamyon** - Balansni ko'rish va yechib olish
- 📊 **Statistika** - Kunlik, haftalik daromadlar
- 🏆 **Reyting** - Boshqa foydalanuvchilar bilan bellashish
- 🔗 **Referral tizimi** - Do'stlaringizni taklif qilish orqali bonus

### Admin uchun | For Admin:
- 👤 **Foydalanuvchilarni boshqarish** - Ro'yxat, tahrirlash, o'chirish
- 📢 **Reklamalarni boshqarish** - Yangi reklamalar qo'shish
- 📈 **Statistika paneli** - Umumiy analitika
- 💳 **To'lovlarni nazorat qilish** - Yechib olish so'rovlari

## 🛠 Texnologiyalar | Tech Stack

### Core
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Riverpod** - State management
- **Go Router** - Navigation

### Backend & Storage
- **Firebase** - (Optional) Auth, Firestore, Storage
- **Hive** - Local database caching
- **Shared Preferences** - Simple data storage
- **Flutter Secure Storage** - Encrypted storage

### Monetization
- **Google Mobile Ads** - AdMob integration
- **In-App Purchases** - Premium subscriptions

### Security
- **Crypto** - SHA-256 password hashing
- **Encrypt** - AES encryption
- **UUID** - Unique identifier generation

### UI/UX
- **Material 3** - Modern design system
- **iOS Design** - iOS-style components
- **Shimmer** - Loading effects
- **Confetti** - Celebration animations
- **FL Chart** - Data visualization

## 🚀 O'rnatish | Installation

### Talablar | Requirements
```bash
Flutter SDK ^3.11.0
Dart SDK ^3.0.0
Android SDK (for Android)
Xcode (for iOS)
```

### 1. Repository ni klonlash | Clone repository
```bash
git clone https://github.com/username/tirikchilik.git
cd tirikchilik
```

### 2. Dependencyni o'rnatish | Install dependencies
```bash
flutter pub get
```

### 3. Environment sozlash | Environment setup
```bash
cp .env.example .env
```

`.env` faylni tahrirlang va o'zingizning qiymatlaringizni qo'ying:
```env
# Admin ma'lumotlari | Admin credentials
ADMIN_LOGIN=your_admin_username
ADMIN_PASSWORD=your_secure_password

# AdMob (Test ID lar o'rniga haqiqiylarni qo'ying)
ADMOB_APP_ID=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
ADMOB_BANNER_ID=ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy
ADMOB_INTERSTITIAL_ID=ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy
ADMOB_REWARDED_ID=ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy

# Firebase (ixtiyoriy)
FIREBASE_ENABLED=true
FIREBASE_API_KEY=your_api_key
```

### 4. Ilovani ishga tushirish | Run the app

#### Android
```bash
flutter run
```

#### iOS (MacOS kerak)
```bash
cd ios
pod install
cd ..
flutter run
```

#### Web (Chrome)
```bash
flutter run -d chrome
```

## 📱 Platformalar | Platforms

| Platform | Status | Eslatma |
|----------|--------|---------|
| Android | ✅ Production Ready | API 21+ |
| iOS | ✅ Production Ready | iOS 12+ |
| Web (Chrome) | ✅ Development | Testing purposes |
| Linux | ❌ Removed | Not supported |
| macOS | ❌ Removed | Not supported |
| Windows | ❌ Removed | Not supported |

## 🏗 Loyiha strukturasi | Project Structure

```
lib/
├── constants/          # App constants
├── core/               # Core functionality
│   ├── app_initializer.dart
│   └── error_handler.dart
├── l10n/               # Localization files
├── models/             # Data models
│   ├── ad_model.dart
│   ├── user_model.dart
│   └── wallet_model.dart
├── providers/          # State management
├── routing/            # Navigation
├── screens/            # UI screens
│   ├── admin_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── profile_screen.dart
│   ├── register_screen.dart
│   ├── splash_screen.dart
│   ├── wallet_screen.dart
│   └── watch_ad_screen.dart
├── services/           # Business logic
│   ├── admob_service.dart
│   ├── auth_service.dart
│   ├── cache_service.dart
│   ├── firebase_service.dart
│   ├── network_service.dart
│   ├── secure_storage_service.dart
│   └── wallet_service.dart
├── theme/              # App theme
├── utils/              # Utilities
└── widgets/            # Reusable widgets
```

## 🔐 Xavfsizlik | Security

- ✅ **Password Hashing** - SHA-256 with salt
- ✅ **Encryption** - AES encryption for sensitive data
- ✅ **Secure Storage** - Keychain (iOS) / Keystore (Android)
- ✅ **Biometric Auth** - Fingerprint / Face ID support
- ✅ **Environment Variables** - No hardcoded secrets
- ✅ **Certificate Pinning** - For API calls (optional)

## 📊 Monetization Strategy

### Reklama | Ads
- Banner ads (Home screen)
- Interstitial ads (Navigation)
- Rewarded ads (Premium rewards)

### Premium Subscription
- Daily ad limit: 50 → 100
- 1.5x reward multiplier
- Priority withdrawals

### Referral System
- Referrer: +1.0 so'm per signup
- New user: +0.5 so'm bonus

## 🌍 Lokallash | Localization

Ilova uchta tilni qo'llab-quvvatlaydi | App supports 3 languages:
- 🇺🇿 **O'zbek** (Uzbek)
- 🇷🇺 **Русский** (Russian)
- 🇬🇧 **English** (English)

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/
```

## 📦 Build | Yig'ish

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🚀 Deployment

### Play Store (Android)
1. `flutter build appbundle`
2. Google Play Console ga yuklash
3. Internal testing → Production

### App Store (iOS)
1. `flutter build ios`
2. Xcode orqali archive
3. App Store Connect ga yuklash
4. TestFlight → Production

## 📝 License

MIT License - see [LICENSE](LICENSE) file

## 👨‍💻 Author

**Your Name**
- GitHub: [@username](https://github.com/username)
- Email: your.email@example.com

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev)
- [Firebase](https://firebase.google.com)
- [Google AdMob](https://admob.google.com)

---

<p align="center">
  Made with ❤️ in Uzbekistan
</p>

