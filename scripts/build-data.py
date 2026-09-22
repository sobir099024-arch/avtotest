import json
import os
import shutil
import sys

# Usage: python3 scripts/build-data.py [path-to-avtotestu-v3-checkout]
#
# Full data source switch: everything (questions, tickets, categories,
# explanations, images) now comes from a single local clone of
# https://github.com/Hoffenuz/avtotestu-v3.0.0 — an independent
# transcription of the official YHQ exam question bank that, unlike the
# sherzod-prostaleev/avtotestuz source used previously, ships with real
# question images AND a verified explanation for every question. This
# replaces the old two-source setup (avtotestuz for text + a separate
# attach-images.py fuzzy-matching pass against this same repo for images).
REPO_ROOT = sys.argv[1] if len(sys.argv) > 1 else "../avtotestu-v3.0.0"
ALL_QUESTIONS = os.path.join(REPO_ROOT, "public/barcha.json")
MAVZULI_DIR = os.path.join(REPO_ROOT, "public/mavzuli2")
IMAGES_DIR = os.path.join(REPO_ROOT, "public/images")

HERE = os.path.dirname(__file__)
DATA_OUT = os.path.join(HERE, "..", "public", "data")
IMAGES_OUT = os.path.join(HERE, "..", "public", "images", "questions")

# id -> (uz-Latn, uz-Cyrl, ru) names + source mavzuli2 filename. Mirrors
# src/lib/mavzuNomlari.ts from the source repo (the UI's own single source
# of truth for topic names/order), plus "35a" (kept separate there as
# "new questions") added here so every question lands in some category.
TOPICS = [
    ("1", "1.json", "Umumiy qoidalar", "Умумий қоидалар", "Общие правила"),
    ("2", "2.json", "Haydovchining umumiy vazifalari", "Ҳайдовчининг умумий вазифалари ва пиёдалар", "Общие обязанности водителя и пешеходы"),
    ("3", "3.json", "Ogohlantiruvchi belgilar", "Огоҳлантирувчи белгилар", "Предупреждающие знаки"),
    ("4", "4.json", "Imtiyoz belgilar", "Имтиёз белгилар", "Знаки приоритета"),
    ("5", "5.json", "Taqiqlovchi belgilar", "Тақиқловчи белгилар", "Запрещающие знаки"),
    ("6", "6.json", "Buyuruvchi belgilar", "Буюрувчи белгилар", "Предписывающие знаки"),
    ("7", "7.json", "Axborot ishora belgilari", "Ахборот ишора белгилари", "Информационные знаки"),
    ("8", "8.json", "Qo'shimcha axborot belgilari", "Қўшимча ахборот белгилари", "Дополнительные информационные знаки"),
    ("9", "9.json", "Yotiq chiziqlar 1", "Ётиқ чизиқлар 1", "Горизонтальная разметка 1"),
    ("10", "10.json", "Yotiq va tik chiziqlar 2", "Ётиқ ва тик чизиқлар 2", "Горизонтальная и вертикальная разметка 2"),
    ("11", "11.json", "Svetafor ishoralari", "Светафор ишоралари", "Сигналы светофора"),
    ("12", "12.json", "Tartibga soluvchining ishoralari", "Тартибга солувчининг ишоралари", "Сигналы регулировщика"),
    ("13", "13.json", "Ogohlantiruvchi va avariya ishoralari", "Огоҳлантирувчи ва авария ишоралари", "Предупредительные и аварийные сигналы"),
    ("14", "14.json", "Yo'llarda harakatlanish", "Йўлларда ҳаракатланиш", "Начало движения (Маневр)"),
    ("15", "15.json", "Transport vositalarining joylashuvi", "Tранспорт воситаларининг жойлашуви", "Расположение транспортных средств на проезжей части"),
    ("16", "16.json", "Harakatlanish tezligi", "Ҳаракатланиш тезлиги", "Скорость движения"),
    ("17", "17.json", "Quvib o'tish", "Қувиб ўтиш", "Обгон"),
    ("18", "18.json", "To'xtash va to'xtab turish qoidalari 1", "Тўхташ ва тўхтаб туриш қоидалари 1", "Правила остановки и стоянки 1"),
    ("19", "19.json", "To'xtash va to'xtab turish qoidalari 2", "Тўхташ ва тўхтаб туриш қоидалари 2", "Правила остановки и стоянки 2"),
    ("20", "20.json", "Chorrahalarda harakatlanish", "Чорраҳаларда ҳаракатланиш", "Движение на перекрестках"),
    ("21", "21.json", "Piyodalar o'tish joylari va turar joylar", "Пиёдалар ўтиш жойлари ва турар жой", "Пешеходные переходы и движение в жилых зонах"),
    ("22", "22.json", "Temir yo'l kesishmalari va Avtomagistrallar", "Темир йўл кесишмалари ва Автомагистраллар", "Железнодорожные переезды и движение по автомагистралям"),
    ("23", "23.json", "Yo'nalishli transport vositalarining imtiyozlari", "Йўналишли транспорт воситаларининг имтиёзлари", "Преимущества маршрутных транспортных средств"),
    ("24", "24.json", "Shatakka olish", "Транспорт воситаларини шатакка олиш", "Буксировка транспортных средств"),
    ("25", "25.json", "Yo'l harakati xavfsizligini ta'minlash", "Йўл ҳаракати хавфсизлигини таъминлаш", "Обучение вождению"),
    ("26", "26.json", "Odam va yuk tashish", "Одам ва юк ташиш", "Перевозка людей и грузов"),
    ("27", "27.json", "Harakatlanish taqiqlanadigan vaziyatlar", "ҳаракатланиш тақиқланадиган вазиятлар", "Ситуации, когда запрещено движение транспортных средств"),
    ("28", "28.json", "Harakat xavfsizligini ta'minlash 1", "Ҳаракат хавфсизлигини таъминлаш 1", "Обеспечение безопасности движения 1"),
    ("29", "29.json", "Harakat xavfsizligini ta'minlash 2", "Ҳаракат хавфсизлигини таъминлаш 2", "Обеспечение безопасности движения 2"),
    ("30", "30.json", "Birinchi tibbiy yordam", "Биринчи тиббий ёрдам", "Первая медицинская помощь"),
    ("33", "33.json", "Tartibga solinmagan chorrahada asosiy yo'l", "Тартибга солинмаган чорраҳада асосий йўл", "Главная дорога на нерегулируемом перекрестке"),
    ("34", "34tengaxamiyatli.json", "Teng ahamiyatli chorrahalar", "Тенг аҳамиятли чорраҳалар", "Равнозначные перекрестки"),
    ("35a", "35a.json", "Yangi savollar", "Янги саволлар", "Новые вопросы"),
]


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def main():
    all_questions = load(ALL_QUESTIONS)

    # global_id -> topic id, first topic file that contains it wins.
    category_of = {}
    category_count = {tid: 0 for tid, *_ in TOPICS}
    for tid, filename, *_ in TOPICS:
        for q in load(os.path.join(MAVZULI_DIR, filename)):
            gid = q["task_info"]["global_id"]
            category_of.setdefault(gid, tid)

    os.makedirs(DATA_OUT, exist_ok=True)
    if os.path.isdir(IMAGES_OUT):
        shutil.rmtree(IMAGES_OUT)
    os.makedirs(IMAGES_OUT)

    questions_out = []
    id_index = {}
    variants_by_number = {}

    for q in all_questions:
        gid = q["task_info"]["global_id"]
        ticket_num = q["task_info"]["ticket_num"]
        order = q["task_info"]["order"]

        media = q.get("media_url") or None
        image_path = None
        if media:
            ext = os.path.splitext(media)[1]
            dest_name = f"{gid}{ext}"
            shutil.copyfile(os.path.join(IMAGES_DIR, media), os.path.join(IMAGES_OUT, dest_name))
            image_path = f"images/questions/{dest_name}"

        content = q["content"]
        izoh = q.get("izoh") or {}

        entry = {
            "id": gid,
            "category": category_of.get(gid, "35a"),
            "hasImage": media is not None,
            "texts": {
                "uz-Latn": content["uz_lat"]["text"],
                "uz-Cyrl": content["uz_cyr"]["text"],
                "ru": content["ru"]["text"],
            },
            "answers": [
                {
                    "correct": bool(opt["is_correct"]),
                    "texts": {
                        "uz-Latn": content["uz_lat"]["options"][i]["text"],
                        "uz-Cyrl": content["uz_cyr"]["options"][i]["text"],
                        "ru": content["ru"]["options"][i]["text"],
                    },
                }
                for i, opt in enumerate(content["uz_lat"]["options"])
            ],
        }
        if image_path:
            entry["image"] = image_path
        if izoh.get("uz_lat") or izoh.get("uz_cyr") or izoh.get("ru"):
            entry["explanation"] = {
                loc: [{"text": izoh[key]}]
                for loc, key in (("uz-Latn", "uz_lat"), ("uz-Cyrl", "uz_cyr"), ("ru", "ru"))
                if izoh.get(key)
            }

        category_count[entry["category"]] = category_count.get(entry["category"], 0) + 1
        idx = len(questions_out)
        questions_out.append(entry)
        id_index[gid] = idx
        variants_by_number.setdefault(ticket_num, []).append((order, idx))

    variants_out = [
        {"number": num, "questions": [idx for _, idx in sorted(items)]}
        for num, items in sorted(variants_by_number.items())
    ]

    categories_out = [
        {
            "code": tid,
            "names": {"uz-Latn": uz_lat, "uz-Cyrl": uz_cyr, "ru": ru},
            "count": category_count.get(tid, 0),
        }
        for tid, _file, uz_lat, uz_cyr, ru in TOPICS
        if category_count.get(tid, 0) > 0
    ]

    def dump(name, obj):
        with open(os.path.join(DATA_OUT, name), "w", encoding="utf-8") as f:
            json.dump(obj, f, ensure_ascii=False, separators=(",", ":"))

    dump("questions.json", questions_out)
    dump("variants.json", variants_out)
    dump("categories.json", categories_out)

    print("questions:", len(questions_out))
    print("variants (tickets):", len(variants_out))
    print("categories:", len(categories_out))
    print("with image:", sum(1 for q in questions_out if q["hasImage"]))
    print("with explanation:", sum(1 for q in questions_out if "explanation" in q))


if __name__ == "__main__":
    main()
