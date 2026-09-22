# AvtoTest — Flutter (Android)

Web ilova (`../`) bilan bir xil funksionallikka ega, backendsiz, faqat lokal
ma'lumot bilan ishlaydigan Android ilovasi.

## Xususiyatlar

- **Biletlar** — 64 ta rasmiy bilet (63 tasi 20 tadan, 64-biletda 15 ta savol).
- **Mavzular** — 33 ta mavzu bo'yicha tasodifiy mashq (20 tadan).
- **Imtihon** — 20 ta tasodifiy savol, 25 daqiqa, 3-xatoda avtomatik to'xtaydi.
- 3 tilda: o'zbekcha (lotin/kirill) va ruscha.
- Har bir savolda izoh, 754/1275 savolda rasm.
- Ma'lumotlar `assets/data/*.json` va `assets/images/questions/*.webp` ichida
  ilova bilan birga keladi (internet yoki server shart emas). Natijalar/
  rekordlar `shared_preferences` orqali qurilmada lokal saqlanadi.
- **Ixtiyoriy: Google bilan kirish + progress sinxronlash** (Firebase Auth +
  Firestore) — sozlanmasa ilova xatosiz, faqat login tugmasisiz ishlayveradi.

Savol ma'lumotlari `../scripts/build-data.py` bilan tayyorlangan bir xil
`public/data/*.json` va `public/images/questions/` fayllaridan nusxalangan
(manba: [`Hoffenuz/avtotestu-v3.0.0`](https://github.com/Hoffenuz/avtotestu-v3.0.0) —
tafsilot uchun asosiy `../README.md`ga qarang). Yangilash uchun avval
web-ilova tomonida skriptni qayta ishga tushiring, so'ng:

```bash
cp ../public/data/*.json assets/data/
cp -r ../public/images/questions/. assets/images/questions/
```

## Ishga tushirish

Talab: [Flutter SDK](https://flutter.dev) + Android SDK (Android Studio orqali
o'rnatiladi).

```bash
flutter pub get
flutter run                 # ulangan qurilma/emulyatorda ishga tushirish
flutter build apk --release # release APK: build/app/outputs/flutter-apk/
```

> Ushbu sessiyada kod `flutter analyze` bilan tekshirilgan (xatosiz), ammo
> APK haqiqiy build qilinmagan — muhitda Android SDK (`dl.google.com`)
> tarmoqqa cheklangan kirish tufayli o'rnatib bo'lmadi. Android
> Studio/SDK o'rnatilgan mashinada `flutter build apk` ishlashi kerak.

## Firebase sozlash (ixtiyoriy — Google login + cloud sync)

Avval asosiy `../README.md`dagi "Firebase sozlash" bo'limida Firebase
loyihasini yarating, Google sign-in'ni yoqing va Firestore'ni sozlang (1—4
qadamlar). Shundan keyin Flutter/Android tomoni:

1. Firebase CLI va FlutterFire CLI o'rnating (bir marta):
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   firebase login
   ```
2. `mobile/` papkasida ishga tushiring:
   ```bash
   flutterfire configure
   ```
   Loyihangizni tanlang, faqat **android** platformasini belgilang. Bu
   buyruq `lib/firebase_options.dart`ni (hozirgi placeholder faylni) haqiqiy
   qiymatlar bilan qayta yozadi va `android/app/google-services.json`ni
   yuklab, Gradle wiring'ni (`google-services` plugin) avtomatik qo'shadi.
3. Google Sign-In Android'da ishlashi uchun debug SHA-1 fingerprint'ni
   Firebase Console'da (Project settings → Your apps → Android app) qo'shing:
   ```bash
   cd android && ./gradlew signingReport
   ```
   (`SHA1` qatorini debug variant'dan oling). Play Store'ga chiqarishda
   release keystore'ning SHA-1'ini ham qo'shish kerak bo'ladi.
4. `flutter run` — endi Bosh sahifada "Google bilan kirish" tugmasi
   ko'rinishi kerak.

`lib/firebase_options.dart` placeholder holida (haqiqiy loyiha ulanmagan)
qolsa, ilova `Firebase.initializeApp()` xatosini ushlab, oddiy lokal rejimda
ishlayveradi (`cloud_sync.dart`dagi `firebaseEnabled` shuni boshqaradi).
