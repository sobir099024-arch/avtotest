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
- Natijalar va rekordlar brauzer `localStorage`'ida saqlanadi (backend/DB yo'q).

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

## Texnologiyalar

React + TypeScript + Vite + Tailwind CSS + React Router. To'liq client-side —
statik hosting (GitHub Pages, Netlify, Vercel va h.k.) uchun mos.
