import 'models.dart';

const Map<String, Map<String, String>> _dict = {
  'appTitle': {'uz-Latn': 'AvtoTest', 'uz-Cyrl': 'АвтоТест', 'ru': 'АвтоТест'},
  'appTitlePrefix': {'uz-Latn': 'Avto', 'uz-Cyrl': 'Авто', 'ru': 'Авто'},
  'appTitleSuffix': {'uz-Latn': 'Test', 'uz-Cyrl': 'Тест', 'ru': 'Тест'},
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
  'signInGoogle': {
    'uz-Latn': 'Google bilan kirish',
    'uz-Cyrl': 'Google билан кириш',
    'ru': 'Войти через Google',
  },
  'signOut': {
    'uz-Latn': 'Chiqish',
    'uz-Cyrl': 'Чиқиш',
    'ru': 'Выйти',
  },
  'navHome': {'uz-Latn': 'Asosiy', 'uz-Cyrl': 'Асосий', 'ru': 'Главная'},
  'navStats': {'uz-Latn': 'Statistika', 'uz-Cyrl': 'Статистика', 'ru': 'Статистика'},
  'navFavorites': {'uz-Latn': 'Sevimlilar', 'uz-Cyrl': 'Севимлилар', 'ru': 'Избранное'},
  'navSettings': {'uz-Latn': 'Sozlamalar', 'uz-Cyrl': 'Созламалар', 'ru': 'Настройки'},
  'heroBanner': {
    'uz-Latn': "Bugun mashq qiling — birinchi urinishda topshiring!",
    'uz-Cyrl': 'Бугун машқ қилинг — биринчи уринишда топширинг!',
    'ru': 'Готовьтесь сегодня и сдайте с первого раза!',
  },
  'statQuestionsLabel': {'uz-Latn': 'Savollar', 'uz-Cyrl': 'Саволлар', 'ru': 'Вопросов'},
  'statAverageLabel': {'uz-Latn': "O'rtacha", 'uz-Cyrl': 'Ўртача', 'ru': 'Средний результат'},
  'statTopicsLabel': {'uz-Latn': "O'tilgan mavzu", 'uz-Cyrl': 'Ўтилган мавзу', 'ru': 'Пройдено тем'},
  'statStreakLabel': {'uz-Latn': 'Kunlik seriya', 'uz-Cyrl': 'Кунлик серия', 'ru': 'Дней подряд'},
  'goalTitle': {
    'uz-Latn': "Maqsadingiz — imtihondan o'tish!",
    'uz-Cyrl': 'Мақсадингиз — имтиҳондан ўтиш!',
    'ru': 'Ваша цель — сдать экзамен!',
  },
  'goalSubtitle': {
    'uz-Latn': 'Muntazam mashq — muvaffaqiyat kaliti',
    'uz-Cyrl': 'Мунтазам машқ — муваффақият калити',
    'ru': 'Регулярная практика — ключ к успеху',
  },
  'theoryAndPractice': {
    'uz-Latn': 'nazariya va amaliyot',
    'uz-Cyrl': 'назария ва амалиёт',
    'ru': 'теория и практика',
  },
  'minutes': {'uz-Latn': 'daqiqa', 'uz-Cyrl': 'дақиқа', 'ru': 'минут'},
  'statsOverall': {'uz-Latn': 'Umumiy statistika', 'uz-Cyrl': 'Умумий статистика', 'ru': 'Общая статистика'},
  'totalAttempts': {
    'uz-Latn': 'Yechilgan testlar',
    'uz-Cyrl': 'Ечилган тестлар',
    'ru': 'Пройдено тестов',
  },
  'statsByTopic': {'uz-Latn': "Mavzular bo'yicha", 'uz-Cyrl': 'Мавзулар бўйича', 'ru': 'По темам'},
  'noAttemptsYet': {
    'uz-Latn': "Hali birorta test yechilmagan",
    'uz-Cyrl': 'Ҳали бирорта тест ечилмаган',
    'ru': 'Тестов пока нет',
  },
  'favoritesEmpty': {
    'uz-Latn': "Sevimli savollar yo'q. Test paytida yurak belgisini bosib qo'shing.",
    'uz-Cyrl': 'Севимли саволлар йўқ. Тест пайтида юрак белгисини босиб қўшинг.',
    'ru': 'Избранных вопросов нет. Добавляйте их значком сердца во время теста.',
  },
  'language': {'uz-Latn': 'Til', 'uz-Cyrl': 'Тил', 'ru': 'Язык'},
  'account': {'uz-Latn': 'Hisob', 'uz-Cyrl': 'Ҳисоб', 'ru': 'Аккаунт'},
  'appVersion': {'uz-Latn': 'Ilova versiyasi', 'uz-Cyrl': 'Илова версияси', 'ru': 'Версия приложения'},
  'notSignedIn': {
    'uz-Latn': 'Tizimga kirilmagan',
    'uz-Cyrl': 'Тизимга кирилмаган',
    'ru': 'Вы не вошли в аккаунт',
  },
};

String t(String key, AppLocale locale) {
  final entry = _dict[key];
  if (entry == null) return key;
  return entry[locale.code] ?? entry['uz-Latn'] ?? key;
}
