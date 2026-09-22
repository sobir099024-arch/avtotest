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

(`lib/firebase_options.dart`dagi `web` bloki hali placeholder — bu Play
Market uchun ahamiyatsiz, faqat Flutter Web'ga ta'sir qiladi.)

## Play Market uchun imzolash (release keystore)

Play Store `flutter build apk`ning debug-imzolangan versiyasini qabul
qilmaydi — o'zingizning release keystore'ingiz kerak. Buni **faqat bir
marta** yaratasiz va uni **hech qachon yo'qotmang** (yo'qolsa, ilovani
keyingi yangilanishlarda qayta imzolab bo'lmaydi — Play Store yangi ilova
sifatida qaraydi).

1. Keystore yarating (`mobile/android/app/` papkasida ishga tushiring —
   JDK/keytool kerak, odatda Android Studio bilan birga keladi):
   ```bash
   cd android/app
   keytool -genkey -v -keystore upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   So'raladigan parollarni **eslab qoling** (parol menejerga saqlang) —
   ism-familiya va tashkilot kabi savollarga xohlagan javobni berishingiz
   mumkin, ular muhim emas.
2. `android/key.properties.example`ni nusxalab `android/key.properties`
   qiling (bu fayl **gitignore qilingan** — hech qachon commit bo'lmaydi)
   va keytool'da kiritgan parollar bilan to'ldiring:
   ```bash
   cd ..
   cp key.properties.example key.properties
   # key.properties'ni ochib storePassword/keyPassword'ni to'ldiring
   ```
3. Endi release build **avtomatik shu keystore bilan imzolanadi**:
   ```bash
   cd ..
   flutter build appbundle --release   # Play Store .aab (tavsiya etiladi)
   # yoki
   flutter build apk --release         # to'g'ridan-to'g'ri sinash uchun .apk
   ```
   `.aab` fayli: `build/app/outputs/bundle/release/app-release.aab` —
   shuni Play Console'ga yuklaysiz.
4. Shu keystore'ning SHA-1'ini ham Firebase Console'ga qo'shing (yuqoridagi
   "Firebase sozlash"dagi kabi, lekin `signingReport`da **release**
   variant qatoridan oling — debug emas):
   ```bash
   cd android && ./gradlew signingReport
   ```

`upload-keystore.jks` va `key.properties` — ikkalasi ham gitignore
qilingan: repo'da hech qachon ko'rinmaydi, faqat sizning kompyuteringizda
qoladi. Boshqa kompyuterda build qilmoqchi bo'lsangiz, shu ikki faylni
o'zingiz (xavfsiz kanal orqali) ko'chirib olib borishingiz kerak.
