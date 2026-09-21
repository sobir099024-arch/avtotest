# AvtoTest

O'zbekiston YHQ (yo'l harakati qoidalari) nazariy imtihoniga tayyorgarlik uchun
brauzerda ishlaydigan, backendsiz mashq ilovasi.

## Xususiyatlar

- **Biletlar** — 64 ta rasmiy bilet, har biri 20 savoldan.
- **Mavzular** — 42 ta kategoriya bo'yicha tasodifiy mashq (20 tadan).
- **Imtihon** — 20 ta tasodifiy savol, 25 daqiqa, 3-xatoda avtomatik to'xtaydi
  (haqiqiy imtihon qoidasi).
- 3 tilda: o'zbekcha (lotin/kirill) va ruscha.
- Natijalar va rekordlar brauzer `localStorage`'ida saqlanadi (backend/DB yo'q).

## Ma'lumotlar manbai

Savol/javob/izoh matnlari ochiq [`sherzod-prostaleev/avtotestuz`](https://github.com/sherzod-prostaleev/avtotestuz)
repozitoriyasidagi `backend/seed/avtoimtihon/data.json`dan olingan va
`scripts/build-data.py` yordamida `public/data/*.json`ga qayta ishlangan
(faqat frontendga kerakli maydonlar qoldirilgan).

**Eslatma:** manba repoda savol rasmlari (`.webp`) `.gitignore` qilingan va
git tarixida yo'q, shuning uchun bu ilovada ham mavjud emas — rasmga muhtoj
savollarda ("Rasm mavjud emas") belgisi ko'rsatiladi. Yo'l belgilari katalogi
rasmlari manbada mavjud, lekin hozircha savollarga bog'lanmagan.

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
