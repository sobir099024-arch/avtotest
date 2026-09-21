import 'models.dart';

const Map<String, Map<String, String>> _dict = {
  'appTitle': {'uz-Latn': 'AvtoTest', 'uz-Cyrl': 'АвтоТест', 'ru': 'АвтоТест'},
  'tickets': {'uz-Latn': 'Biletlar', 'uz-Cyrl': 'Билетлар', 'ru': 'Билеты'},
  'categories': {'uz-Latn': 'Mavzular', 'uz-Cyrl': 'Мавзулар', 'ru': 'Темы'},
  'exam': {'uz-Latn': 'Imtihon', 'uz-Cyrl': 'Имтиҳон', 'ru': 'Экзамен'},
  'ticketsDesc': {
    'uz-Latn': "Har biri 20 savoldan iborat rasmiy biletlar bo'yicha mashq qiling",
    'uz-Cyrl': 'Ҳар бири 20 саволдан иборат расмий билетлар бўйича машқ қилинг',
    'ru': 'Тренируйтесь по официальным билетам, в каждом по 20 вопросов',
  },
  'categoriesDesc': {
    'uz-Latn': "Mavzu bo'yicha savollarni mashq qiling",
    'uz-Cyrl': 'Мавзу бўйича саволларни машқ қилинг',
    'ru': 'Тренируйтесь по вопросам определённой темы',
  },
  'examDesc': {
    'uz-Latn': "20 ta tasodifiy savol, 25 daqiqa, 3 xatoda to'xtaydi",
    'uz-Cyrl': '20 та тасодифий савол, 25 дақиқа, 3 хатода тўхтайди',
    'ru': '20 случайных вопросов, 25 минут, останавливается на 3 ошибке',
  },
  'ticket': {'uz-Latn': 'Bilet', 'uz-Cyrl': 'Билет', 'ru': 'Билет'},
  'questionsCount': {'uz-Latn': 'savol', 'uz-Cyrl': 'савол', 'ru': 'вопросов'},
  'start': {'uz-Latn': 'Boshlash', 'uz-Cyrl': 'Бошлаш', 'ru': 'Начать'},
  'next': {'uz-Latn': 'Keyingisi', 'uz-Cyrl': 'Кейингиси', 'ru': 'Далее'},
  'finish': {'uz-Latn': 'Yakunlash', 'uz-Cyrl': 'Якунлаш', 'ru': 'Завершить'},
  'question': {'uz-Latn': 'Savol', 'uz-Cyrl': 'Савол', 'ru': 'Вопрос'},
  'correct': {'uz-Latn': "To'g'ri javob", 'uz-Cyrl': 'Тўғри жавоб', 'ru': 'Правильный ответ'},
  'yourResult': {'uz-Latn': 'Sizning natijangiz', 'uz-Cyrl': 'Сизнинг натижангиз', 'ru': 'Ваш результат'},
  'passed': {'uz-Latn': "O'tdingiz", 'uz-Cyrl': 'Ўтдингиз', 'ru': 'Сдано'},
  'failed': {'uz-Latn': "O'tmadingiz", 'uz-Cyrl': 'Ўтмадингиз', 'ru': 'Не сдано'},
  'tryAgain': {'uz-Latn': "Qayta urinish", 'uz-Cyrl': 'Қайта уриниш', 'ru': 'Попробовать снова'},
  'backHome': {'uz-Latn': 'Bosh sahifaga', 'uz-Cyrl': 'Бош саҳифага', 'ru': 'На главную'},
  'imageMissing': {
    'uz-Latn': "Rasm mavjud emas (manba materialda cheklangan)",
    'uz-Cyrl': 'Расм мавжуд эмас (манба материалда чекланган)',
    'ru': 'Изображение недоступно (ограничение исходных материалов)',
  },
  'explanation': {'uz-Latn': 'Izoh', 'uz-Cyrl': 'Изоҳ', 'ru': 'Пояснение'},
  'timeLeft': {'uz-Latn': 'Vaqt qoldi', 'uz-Cyrl': 'Вақт қолди', 'ru': 'Осталось времени'},
  'stoppedTooManyErrors': {
    'uz-Latn': "3-xato bilan imtihon to'xtatildi",
    'uz-Cyrl': '3-хато билан имтиҳон тўхтатилди',
    'ru': 'Экзамен остановлен из-за 3-й ошибки',
  },
  'stoppedTimeUp': {
    'uz-Latn': 'Vaqt tugadi',
    'uz-Cyrl': 'Вақт тугади',
    'ru': 'Время вышло',
  },
  'reviewAnswers': {'uz-Latn': "Javoblarni ko'rish", 'uz-Cyrl': 'Жавобларни кўриш', 'ru': 'Просмотреть ответы'},
  'yourAnswer': {'uz-Latn': 'Sizning javobingiz', 'uz-Cyrl': 'Сизнинг жавобингиз', 'ru': 'Ваш ответ'},
  'noAnswer': {'uz-Latn': 'Javob berilmagan', 'uz-Cyrl': 'Жавоб берилмаган', 'ru': 'Без ответа'},
  'bestResult': {'uz-Latn': 'Eng yaxshi natija', 'uz-Cyrl': 'Энг яхши натижа', 'ru': 'Лучший результат'},
  'heroSubtitle': {
    'uz-Latn': "YHQ nazariy imtihoniga tayyorgarlik",
    'uz-Cyrl': 'ЙҲҚ назарий имтиҳонига тайёргарлик',
    'ru': 'Подготовка к теоретическому экзамену ПДД',
  },
  'dataSource': {
    'uz-Latn': "Savollar manbasi: sherzod-prostaleev/avtotestuz (ochiq repo)",
    'uz-Cyrl': 'Саволлар манбаси: sherzod-prostaleev/avtotestuz (очиқ репо)',
    'ru': 'Источник вопросов: sherzod-prostaleev/avtotestuz (открытый репозиторий)',
  },
};

String t(String key, AppLocale locale) {
  final entry = _dict[key];
  if (entry == null) return key;
  return entry[locale.code] ?? entry['uz-Latn'] ?? key;
}
