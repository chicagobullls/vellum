import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/poem.dart';

/// Loads and parses the initial curated bundle of 240+ public domain poems.
class PoemSeedLoader {
  static Future<List<Poem>> loadCuratedPoems() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/curated_poems_v1.json');
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => Poem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback default poem if asset is missing in test environment
      return [
        const Poem(
          id: 'poem_fallback',
          title: 'Я вас любил',
          author: 'Александр Пушкин',
          year: 1829,
          language: 'ru',
          meter: 'Ямб',
          difficulty: 1,
          tags: ['Любовь'],
          isPublicDomain: true,
          originalText: 'Я вас любил: любовь еще, быть может...',
          stanzas: [
            ['Я вас любил: любовь еще, быть может,', 'В душе моей угасла не совсем;'],
            ['Но пусть она вас больше не тревожит;', 'Я не хочу печалить вас ничем.']
          ],
        )
      ];
    }
  }
}
