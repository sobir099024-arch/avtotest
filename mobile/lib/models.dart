enum AppLocale { uzLatn, uzCyrl, ru }

extension AppLocaleCode on AppLocale {
  String get code {
    switch (this) {
      case AppLocale.uzLatn:
        return 'uz-Latn';
      case AppLocale.uzCyrl:
        return 'uz-Cyrl';
      case AppLocale.ru:
        return 'ru';
    }
  }

  String get label {
    switch (this) {
      case AppLocale.uzLatn:
        return "O'zbekcha (lotin)";
      case AppLocale.uzCyrl:
        return 'Ўзбекча (кирилл)';
      case AppLocale.ru:
        return 'Русский';
    }
  }

  static AppLocale fromCode(String code) {
    switch (code) {
      case 'uz-Cyrl':
        return AppLocale.uzCyrl;
      case 'ru':
        return AppLocale.ru;
      default:
        return AppLocale.uzLatn;
    }
  }
}

class LocalizedText {
  final Map<String, String> values;
  LocalizedText(this.values);

  factory LocalizedText.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LocalizedText({});
    return LocalizedText(json.map((k, v) => MapEntry(k, v?.toString() ?? '')));
  }

  String get(AppLocale locale) {
    return values[locale.code] ??
        values['uz-Latn'] ??
        values['ru'] ??
        (values.values.isNotEmpty ? values.values.first : '');
  }
}

class Answer {
  final bool correct;
  final LocalizedText texts;
  Answer({required this.correct, required this.texts});

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        correct: json['correct'] as bool? ?? false,
        texts: LocalizedText.fromJson(json['texts'] as Map<String, dynamic>?),
      );
}

class ExplanationBlock {
  final String text;
  ExplanationBlock(this.text);
  factory ExplanationBlock.fromJson(Map<String, dynamic> json) =>
      ExplanationBlock(json['text']?.toString() ?? '');
}

class Question {
  final String id;
  final String category;
  final bool hasImage;
  final LocalizedText texts;
  final List<Answer> answers;
  final Map<String, List<ExplanationBlock>> explanation;

  Question({
    required this.id,
    required this.category,
    required this.hasImage,
    required this.texts,
    required this.answers,
    required this.explanation,
  });

  int get correctIndex => answers.indexWhere((a) => a.correct);

  factory Question.fromJson(Map<String, dynamic> json) {
    final expRaw = json['explanation'] as Map<String, dynamic>?;
    final exp = <String, List<ExplanationBlock>>{};
    if (expRaw != null) {
      for (final entry in expRaw.entries) {
        final list = (entry.value as List<dynamic>? ?? [])
            .map((b) => ExplanationBlock.fromJson(b as Map<String, dynamic>))
            .toList();
        exp[entry.key] = list;
      }
    }
    return Question(
      id: json['id'] as String,
      category: json['category'] as String,
      hasImage: json['hasImage'] as bool? ?? false,
      texts: LocalizedText.fromJson(json['texts'] as Map<String, dynamic>?),
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((a) => Answer.fromJson(a as Map<String, dynamic>))
          .toList(),
      explanation: exp,
    );
  }
}

class Category {
  final String code;
  final LocalizedText names;
  final int count;

  Category({required this.code, required this.names, required this.count});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        code: json['code'] as String,
        names: LocalizedText.fromJson(json['names'] as Map<String, dynamic>?),
        count: json['count'] as int? ?? 0,
      );
}

class Variant {
  final int number;
  final List<int> questionIndices;

  Variant({required this.number, required this.questionIndices});

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        number: json['number'] as int,
        questionIndices:
            (json['questions'] as List<dynamic>? ?? []).map((e) => e as int).toList(),
      );
}

class AttemptRecord {
  final int correct;
  final int total;
  final DateTime finishedAt;

  AttemptRecord({required this.correct, required this.total, required this.finishedAt});

  Map<String, dynamic> toJson() => {
        'correct': correct,
        'total': total,
        'finishedAt': finishedAt.toIso8601String(),
      };

  factory AttemptRecord.fromJson(Map<String, dynamic> json) => AttemptRecord(
        correct: json['correct'] as int,
        total: json['total'] as int,
        finishedAt: DateTime.parse(json['finishedAt'] as String),
      );
}
