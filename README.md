# AvtoTest

O'zbekiston YHQ (yo'l harakati qoidalari) nazariy imtihoniga tayyorgarlik uchun
brauzerda ishlaydigan, backendsiz mashq ilovasi.

## Xususiyatlar

- **Biletlar** — 64 ta rasmiy bilet (63 tasi 20 tadan, 64-biletda 15 ta savol —
  manbadagi haqiqiy tarkib).
- **Mavzular** — 33 ta mavzu bo'yicha tasodifiy mashq (20 tadan).
- **Imtihon** — 20 ta tasodifiy savol, 25 daqiqa, 3-xatoda avtomatik to'xtaydi
  (haqiqiy imtihon qoidasi).
- 3 tilda: o'zbekcha (lotin/kirill) va ruscha.
- Har bir savolda tasdiqlangan **izoh** va (mavjud bo'lsa) **rasm**.
- Natijalar/rekordlar brauzer `localStorage`'ida saqlanadi — Firebase
  sozlanmagan bo'lsa ham ilova **to'liq ishlaydi**, faqat login/cloud sync
  bo'lmaydi (pastga qarang).
- **Ixtiyoriy: Google bilan kirish + qurilmalar orasida progress sinxronlash**
  (Firebase Auth + Firestore).

## Ma'lumotlar manbai

Barcha kontent (1275 savol, 64 bilet, 33 mavzu, izohlar, rasmlar) ochiq
[`Hoffenuz/avtotestu-v3.0.0`](https://github.com/Hoffenuz/avtotestu-v3.0.0)
repozitoriyasidan (`public/barcha.json`, `public/mavzuli2/*.json`,
`public/images/`) `scripts/build-data.py` yordamida qayta ishlangan:

```bash
git clone https://github.com/Hoffenuz/avtotestu-v3.0.0 ../avtotestu-v3.0.0
python3 scripts/build-data.py ../avtotestu-v3.0.0
cp public/data/*.json mobile/assets/data/
cp -r public/images/questions/. mobile/assets/images/questions/
```

Bu manba xuddi shu rasmiy YHQ savol bankining mustaqil transkripsiyasi —
avvalgi `sherzod-prostaleev/avtotestuz`dan farqli o'laroq **har bir savolda
izoh** va savollarning **59%'ida (754/1275) rasm** bilan birga keladi (qolgan
savollarda vizual material shart emas — faqat matn asosida javob beriladi).

## Ishga tushirish

```bash
npm install
npm run dev      # http://localhost:5173
npm run build    # production build -> dist/
npm run preview  # build'ni lokal ko'rish
```

## Firebase sozlash (ixtiyoriy — Google login + cloud sync)

Firebase **bepul** (Spark tarifi): 1 GB Firestore, kuniga 50k o'qish/20k
yozish, cheksiz Google-orqali login — bu ilova uchun bu limitlar juda katta
zaxira bilan yetarli. To'lov faqat limitdan oshib ketilsa kerak bo'ladi.

1. [Firebase Console](https://console.firebase.google.com)da yangi loyiha
   yarating.
2. **Authentication** → Sign-in method → **Google**ni yoqing.
3. **Firestore Database** yarating (istalgan region; production mode).
4. Firestore qoidalarini shu repodagi `firestore.rules`dan nusxalab qo'ying
   (Firestore → Rules → Publish) — har bir foydalanuvchi faqat o'z
   ma'lumotini o'qiy/yoza oladi.
5. Project settings → Your apps → **Web app** qo'shing (`</>` belgisi),
   config qiymatlarini oling.
6. `.env.example`ni `.env` qilib nusxalang va Firebase config qiymatlarini
   qo'ying:
   ```bash
   cp .env.example .env
   # .env faylini Firebase config bilan to'ldiring
   ```
7. Flutter (Android) tomoni uchun: `mobile/README.md`dagi "Firebase
   sozlash" bo'limiga qarang (`flutterfire configure` buyrug'i kerak).

`.env` git'ga **hech qachon** commit qilinmaydi (`.gitignore`da).
Sozlanmasa ilova xatosiz, faqat login tugmasisiz ishlayveradi.

## Texnologiyalar

React + TypeScript + Vite + Tailwind CSS + React Router + (ixtiyoriy)
Firebase Auth/Firestore. To'liq client-side — statik hosting (GitHub Pages,
Netlify, Vercel va h.k.) uchun mos.
