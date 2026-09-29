# 📜 Vellum — Type the verse. Own the memory.

> *A meditative kinetic poetry memorization ritual designed in Victorian Dark Academia aesthetics meets Apple Scandinavian minimalism.*

---

## 🏛 О проекте (Project Overview)

**Vellum** — это 100% Offline-first мобильное приложение для ежедневного заучивания шедевров мировой классической поэзии (Пушкин, Лермонтов, Тютчев, Шекспир, Дикинсон, Байрон) через посимвольный кинетический набор (**Ghost Typing**) и технику постепенного угасания слов (**Cloze Deletion**).

### ✨ Ключевые особенности (Core Features)
- **Daily Sanctuary (`SCR-01`):** Ежедневный ритуал одного стихотворения дня, определяемого детерминированным хешем даты. Текст плавно проступает чернилами поверх призрачного шрифта под тактильный и акустический отклик антикварной печатной машинки.
- **Memory Practice (`SCR-02`):** 4 уровня заучивания наизусть:
  - *Уровень I:* Призрачный текст (Ghost Typing) — 100% подсказка.
  - *Уровень II:* Исчезновение гласных — остаются согласные и пунктуация.
  - *Уровень III:* Cloze-deletion — скрыто 50% чередующихся слов с первой буквой-подсказкой.
  - *Уровень IV:* Чистая память (The Void) — пустые строки, ввод исключительно по памяти.
- **Physical Wax Seal:** При успешном завершении стихотворения сургучная печать с золотым или рубиновым тиснением запечатывает выученный стих с глубоким тактильным и звуковым щелчком.
- **My Folio (`SCR-03`):** Личная иллюстрированная книга выученных стихов в переплете из состаренной кожи с сургучными оттисками и статистикой точности.
- **Story Studio (`SCR-04`):** Генератор открыток для Instagram Stories (9:16) и мессенджеров (1:1) на фактурном пергаменте.
- **Zero-Latency Audio (< 8ms):** Несжатые PCM WAV сэмплы ударов литер и звонка каретки.

---

## 🎨 Дизайн-система (Aesthetics & Tokens)

| Токен | Hex | Назначение |
| :--- | :--- | :--- |
| `parchmentLight` | `#FBF8F1` | Фон светлого пергамента ручной работы |
| `parchmentDark` | `#1A1816` | Глубокий оттенок состаренного дуба / ночной режим |
| `inkPrimary` | `#1A1816` | Густые чернила на светлом фоне |
| `inkGhost` | `rgba(26, 24, 22, 0.32)` | Призрачный контур букв для набора |
| `antiqueGold` | `#C29B38` | Благородная позолота, индикатор прогресса, тиснение |
| `waxCrimson` | `#842D2D` | Королевский рубиновый сургуч печати |

**Типографика:** `EB Garamond` (основной поэтический текст), `SF Pro` / `Inter` (интерфейсные элементы).

---

## ⚡ Экспресс-запуск (Quick Start)

### 1. Запуск интерактивного Web-демо (без компиляции):
```bash
open web_demo/index.html
# или просто дважды кликните по файлу web_demo/index.html
```

### 2. Запуск Flutter-приложения:
```bash
# Установка зависимостей
flutter pub get

# Запуск тестов
flutter test

# Запуск в симуляторе
flutter run
```

---

## 📂 Структура репозитория

```
vellum/
├── lib/
│   ├── core/                       # Звуковой движок, CoreHaptics, цветовая палитра
│   │   ├── audio/                  # vellum_sound_engine.dart
│   │   ├── haptics/                # vellum_haptic_engine.dart
│   │   ├── theme/                  # vellum_theme.dart
│   │   └── utils/                  # poem_date_selector.dart, roman_numerals.dart
│   ├── data/                       # Модели данных и репозитории
│   │   ├── models/                 # Poem, UserFolioEntry, TypingSession, UserSettings
│   │   ├── repositories/           # poem_repository.dart
│   │   └── sources/                # poem_seed_loader.dart
│   ├── domain/                     # Чистая бизнес-логика
│   │   └── algorithms/             # cloze_mask_generator.dart (4 уровня Cloze)
│   ├── presentation/               # UI экраны
│   │   ├── daily_sanctuary/        # Экран ежедневного набора
│   │   ├── memory_practice/        # Режим заучивания с сургучной печатью
│   │   ├── folio_book/             # Личная книга выученных стихов
│   │   ├── story_studio/           # Экспорт карточек в соцсети
│   │   ├── paywall/                # Модальное окно Vellum Pro
│   │   └── widgets/                # Сургучная печать и фон пергамента
│   └── main.dart                   # Точка входа в приложение
├── assets/
│   ├── audio/                      # Синтезированные WAV звуки клавиш и печати
│   └── data/                       # База стихов curated_poems_v1.json
├── docs/                           # Полная документация AIRAM (PRD, Архитектура, UI/UX, ADR)
├── web_demo/                       # Интерактивный standalone симулятор (HTML/CSS/JS)
└── test/                           # Модульные тесты алгоритмов
```

---

## 🧪 Тестирование
```bash
flutter test test/unit/cloze_mask_test.dart
flutter test test/unit/poem_date_selector_test.dart
```

Лицензия: Public Domain Poetry / Proprietary App Engine.
