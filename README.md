# Farketmez 🎯

> **"Ne yapalım? Farketmez."**
> 
> Arkadaş gruplarının "ne yiyelim, ne yapsak" tartışmasını 10 saniyede bitiren, konuma göre akıllı öneri yapan mobil uygulama.

---

## 🚀 Kurulum

### 1. Flutter Dependencies
```bash
flutter pub get
```

### 2. Firebase Kurulumu
1. [Firebase Console](https://console.firebase.google.com)'a git
2. Yeni proje oluştur: **"FarketmezKnk"**
3. Android uygulaması ekle: `com.farketmezknk.farketmez_knk`
4. `google-services.json` dosyasını `android/app/` klasörüne koy
5. iOS için `GoogleService-Info.plist` → `ios/Runner/` klasörüne koy

### 3. Google Maps API Key
1. [Google Cloud Console](https://console.cloud.google.com) → APIs & Services → Credentials
2. **"Create Credentials"** → API Key
3. Bu API'leri etkinleştir:
   - Maps SDK for Android ✅
   - Maps SDK for iOS ✅
   - Places API ✅
   - Geocoding API ✅
   - Distance Matrix API ✅
4. API Key'i şu dosyalara ekle:
   - `lib/core/constants/app_constants.dart` → `googleMapsApiKey`
   - `android/app/src/main/AndroidManifest.xml` → `YOUR_GOOGLE_MAPS_API_KEY_HERE`
   - `ios/Runner/AppDelegate.swift` → `GMSServices.provideAPIKey("KEY")`

### 4. Firebase'i main.dart'ta aktif et
`lib/main.dart` dosyasında şu satırları uncomment et:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// main() içinde:
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 5. Çalıştır
```bash
flutter run
```

---

## 📁 Proje Yapısı

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart    # API key, kategoriler, sabitler
│   ├── models/
│   │   ├── place_model.dart      # Mekan modeli
│   │   └── user_model.dart       # Kullanıcı & Ziyaret modelleri
│   ├── providers/
│   │   └── app_provider.dart     # Ana state yönetimi
│   ├── router/
│   │   └── app_router.dart       # GoRouter navigasyon
│   ├── services/
│   │   ├── auth_service.dart     # Firebase Auth
│   │   ├── memory_service.dart   # Firestore hafıza sistemi
│   │   └── places_service.dart   # Google Maps API
│   └── theme/
│       └── app_theme.dart        # Renk, font, theme
│
└── features/
    ├── splash/
    │   └── splash_screen.dart    # Giriş + Auth
    ├── home/
    │   └── home_screen.dart      # Ana karar ekranı
    ├── recommendation/
    │   └── recommendation_screen.dart  # Öneri ekranı
    ├── feedback/
    │   └── feedback_screen.dart  # 👍👎 geri bildirim
    ├── memory/
    │   └── memory_screen.dart    # Geçmiş & hafıza
    └── profile/
        └── profile_screen.dart   # Profil & tercihler
```

---

## 💰 Google Maps Ücretsiz Kullanım

- Ayda **$200 ücretsiz kredi** (Google'dan)
- Places API: ~$17/1000 istek
- **~11.000 ücretsiz istek/ay** → başlangıç için fazlasıyla yeterli
- Ödeme bilgisi eklemek zorunlu ama limit aşılmadığı sürece para çekilmez

---

## 🎨 Tasarım

- **Background:** `#0D0D0F` (near-black)
- **Accent:** `#FF6B35` (energetic orange)
- **Font:** Outfit (Google Fonts)
- **Style:** Dark mode, glassmorphism hints, glow effects

---

## 📱 Ekranlar

| Ekran | Yol | Açıklama |
|-------|-----|----------|
| Splash | `/` | Giriş, konum izni, auth |
| Ana Ekran | `/home` | FARKETMEZ butonu |
| Öneri | `/recommendation` | Seçilen mekan detayı |
| Geri Bildirim | `/feedback` | 👍👎 |
| Hafıza | `/memory` | Geçmiş mekanlar |
| Profil | `/profile` | Tercihler & ayarlar |
