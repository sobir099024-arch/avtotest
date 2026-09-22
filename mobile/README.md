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
