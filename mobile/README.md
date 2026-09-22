# AvtoTest — Flutter (Android)

Web ilova (`../`) bilan bir xil funksionallikka ega, backendsiz, faqat lokal
ma'lumot bilan ishlaydigan Android ilovasi.

## Xususiyatlar

- **Biletlar** — 64 ta rasmiy bilet, har biri 20 savoldan.
- **Mavzular** — 42 ta kategoriya bo'yicha tasodifiy mashq (20 tadan).
- **Imtihon** — 20 ta tasodifiy savol, 25 daqiqa, 3-xatoda avtomatik to'xtaydi.
- 3 tilda: o'zbekcha (lotin/kirill) va ruscha.
- Ma'lumotlar `assets/data/*.json` ichida ilova bilan birga keladi (internet
  yoki server shart emas). Natijalar/rekordlar `shared_preferences` orqali
  qurilmada lokal saqlanadi.

Savol ma'lumotlari `../scripts/build-data.py` va `../scripts/attach-images.py`
bilan tayyorlangan bir xil `public/data/*.json` va `public/images/questions/`
fayllaridan nusxalangan (520 ta savol rasmi bilan — tafsilot uchun asosiy
`../README.md`ga qarang). Yangilash uchun avval web-ilova tomonida
skriptlarni qayta ishga tushiring, so'ng:

```bash
cp ../public/data/*.json assets/data/
cp -r ../public/images/questions assets/images/
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
