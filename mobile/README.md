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

## Firebase sozlash (Google login + cloud sync)

Android tomoni **allaqachon ulangan**: `android/app/google-services.json`
va `lib/firebase_options.dart`dagi `android` qiymatlari loyiha
`avto-test-e6978`ga tegishli haqiqiy config (Gradle'da `com.google.gms.google-services`
plugin ham `android/settings.gradle.kts` + `android/app/build.gradle.kts`da
ulangan). **Bitta qadam qoldi — Google Sign-In'ni ishga tushirish uchun
SHA-1 fingerprint kerak:**

```bash
cd android && ./gradlew signingReport
```

Natijada chiqqan **debug** variant ostidagi `SHA1:` qatorini nusxalang, so'ng
Firebase Console → Project settings → Your apps → sizning Android app →
**"Add fingerprint"** tugmasi orqali qo'shing. Buni qilmasangiz, ilovada
"Google bilan kirish" tugmasi bosilganda xatolik (`DEVELOPER_ERROR` yoki
shunga o'xshash) chiqadi — SHA-1 tarmoq orqali qurilma/kompyuterni
tasdiqlash uchun shart. Play Store'ga chiqarishda release keystore'ning
SHA-1'ini ham qo'shish kerak bo'ladi (Google Play App Signing ishlatilsa,
Play Console → App integrity'dagi SHA-1'ni qo'shing).

> Ushbu sessiyada Gradle build haqiqiy sinab ko'rilmadi (muhitda Android SDK
> `dl.google.com`ga cheklangan kirish tufayli o'rnatilmagan — `flutter
> analyze` esa xatosiz o'tdi). Birinchi `flutter run` paytida Gradle xatolik
> bersa, xato matnini yuboring — birga tuzatamiz.

Flutter Web'da ishlatmoqchi bo'lsangiz, `lib/firebase_options.dart`dagi
`web` blokini ham to'ldiring (yoki `flutterfire configure` bilan ikkala
platformani birga sozlang — buning uchun Firebase CLI kerak):

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
```

`lib/firebase_options.dart`dagi `web` bloki placeholder holida qolsa ham
muammo yo'q — bu faqat Flutter Web'ga ta'sir qiladi, Android'da
`Firebase.initializeApp()` haqiqiy config bilan ishlayveradi
(`cloud_sync.dart`dagi `firebaseEnabled` buni boshqaradi).
