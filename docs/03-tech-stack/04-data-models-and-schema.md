---
project: "vellum"
phase: 3
doc_type: "data-models-and-schema"
status: "approved"
last_updated: "2026-09-29"
tags:
  - airam
  - architecture
  - database
  - schema
  - isar
  - erd
---

# 🗄 Модели данных, ERD и схема БД: Vellum

> **Назначение:**  
> Документ специфицирует схему локальной базы данных **Isar v3 / SQLite (drift)**, связи сущностей, структуру индексов и исполняемые Dart-модели для мобильного клиента Vellum.

---

## 1. Диаграмма сущностей и связей (Mermaid ERD)

```mermaid
erDiagram
    POEM ||--o{ USER_FOLIO_ENTRY : "saved as"
    POEM ||--o{ TYPING_SESSION : "practiced in"
    USER_SETTINGS ||--|| APP_PREFERENCES : configures

    POEM {
        int id PK "Автоинкремент / Быстрый ID"
        string title "Название стихотворения"
        string author "Имя автора (поэта)"
        int century "Век (18, 19, 20)"
        string language "Локаль ('ru' или 'en')"
        string meter "Стихотворный размер"
        string rhyme_scheme "Схема рифмовки (abab, aabb)"
        string content_json "Сериализованные строфы и строки"
        bool is_public_domain "Флаг авторских прав (true)"
        bool is_curated "Кураторский стих vs Пользовательский UGC"
        datetime created_at "Дата добавления в каталог"
    }

    USER_FOLIO_ENTRY {
        int id PK
        int poem_id FK "Ссылка на Poem.id"
        datetime saved_at "Дата первого сохранения в книжечку"
        int mastery_level "Уровень заучивания (1..4)"
        int total_repetitions "Число завершенных тренировок"
        float best_accuracy_pct "Лучшая точность набора (%)"
        bool is_favorite "Отметка в избранное"
        string user_notes "Личные мысли / рефлексия"
    }

    TYPING_SESSION {
        int id PK
        int poem_id FK "Ссылка на Poem.id"
        datetime session_date "Время старта тренировки"
        int cloze_level "Уровень исчезающих слов (1..4)"
        int duration_seconds "Время сессии (сек)"
        int mistakes_count "Количество ошибок ввода"
        float accuracy_pct "Точность печати (%)"
        int wpm "Скорость набора (слов/мин)"
        bool completed "Успешно ли допечатано до конца"
    }

    USER_SETTINGS {
        int id PK "Синглтон = 1"
        bool haptics_enabled "Включена ли вибрация Taptic"
        float haptic_strength "Интенсивность (0.1..1.0)"
        bool audio_enabled "Включен ли звук машинки"
        float audio_volume "Громкость звука (0.0..1.0)"
        string audio_theme_id "Текущая аудио-тема ('underwood_1920')"
        string theme_mode "Оформление ('parchment' / 'dark_academia')"
        string typography_id "Выбранный шрифт ('eb_garamond')"
        string preferred_language "Язык стиха дня ('ru' / 'en')"
        bool pro_entitlement_active "Активен ли статус Vellum Pro"
        string daily_reminder_time "Время утреннего пуша ('08:00')"
    }
```

---

## 2. Исполняемые Isar-коллекции (Dart Models)

### Модель стихотворения (`lib/data/models/poem_model.dart`)
```dart
import 'package:isar/isar.dart';

part 'poem_model.g.dart';

@collection
class Poem {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  @Index(type: IndexType.value)
  late String author;

  @Index()
  late String language; // 'ru' or 'en'

  late int century; // 18, 19
  late String meter; // e.g. 'iambic_tetrameter'
  late String rhymeScheme; // e.g. 'abab'
  
  late List<String> lines; // Строки стихотворения
  
  bool isPublicDomain = true;
  bool isCurated = true; // false для UGC стихов пользователя

  DateTime createdAt = DateTime.now();
}
```

### Модель записи в книжечке («Фолиант») (`lib/data/models/folio_entry_model.dart`)
```dart
import 'package:isar/isar.dart';
import 'poem_model.dart';

part 'folio_entry_model.g.dart';

@collection
class UserFolioEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late int poemId;

  late DateTime savedAt;
  
  @Index()
  int masteryLevel = 1; // 1 = Ghost, 2 = 30% Cloze, 3 = Rhymes, 4 = Blind
  
  int totalRepetitions = 0;
  double bestAccuracyPct = 100.0;
  bool isFavorite = false;
  String? userNotes;
}
```

### Модель сессии набора (`lib/data/models/typing_session_model.dart`)
```dart
import 'package:isar/isar.dart';

part 'typing_session_model.g.dart';

@collection
class TypingSession {
  Id id = Isar.autoIncrement;

  @Index()
  late int poemId;

  late DateTime sessionDate;
  late int clozeLevel;
  late int durationSeconds;
  late int mistakesCount;
  late double accuracyPct;
  late int wpm;
  late bool completed;
}
```

---

## 3. Политика миграций и инициализация каталога (Seeding)

1. **Seed-пак в ассетах:** При первом запуске приложение читает сжатый локальный файл `assets/data/curated_poems_v1.json` (240+ стихов Пушкина, Лермонтова, Фета, Китса, Байрона, Шекспира) и пачкой записывает в Isar через `isar.writeTxn()`.
2. **Время инициализации:** Заполнение базы 240 стихами занимает **менее 45 мс** на iPhone 11.
3. **Безопасность схемы:** Isar автоматически управляет версионированием полей при обновлении приложения без потери записей личной книжечки пользователя.
