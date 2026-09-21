import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'models.dart';

class DataRepository {
  DataRepository._();
  static final DataRepository instance = DataRepository._();

  List<Question>? _questions;
  List<Category>? _categories;
  List<Variant>? _variants;

  Future<List<Question>> loadQuestions() async {
    if (_questions != null) return _questions!;
    final raw = await rootBundle.loadString('assets/data/questions.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _questions = list.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList();
    return _questions!;
  }

  Future<List<Category>> loadCategories() async {
    if (_categories != null) return _categories!;
    final raw = await rootBundle.loadString('assets/data/categories.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _categories = list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    return _categories!;
  }

  Future<List<Variant>> loadVariants() async {
    if (_variants != null) return _variants!;
    final raw = await rootBundle.loadString('assets/data/variants.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _variants = list.map((e) => Variant.fromJson(e as Map<String, dynamic>)).toList();
    return _variants!;
  }
}
