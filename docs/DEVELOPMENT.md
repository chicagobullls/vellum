# 🛠 Руководство разработчика и онбординг (Day-1 Developer Guide): Vellum

Добро пожаловать в проектную команду **Vellum**! 

Это руководство создано для инженеров и автономных AI кодинг-агентов (Antigravity, Cursor, Claude Code). Цель документа — развернуть локальное окружение Flutter, запустить кодогенерацию Isar, прогнать тесты и запустить приложение на симуляторе iPhone за 10 минут.

---

## ⚡ Экспресс-запуск за 10 минут (First 10 Minutes)

### 1. Предварительные требования (Prerequisites)
- **Flutter SDK:** `>= 3.24.x (stable channel)` (`flutter --version`)
- **Xcode:** `>= 15.4` с iOS 17/18 Simulator
- **CocoaPods:** `>= 1.15.x` (`pod --version`)
- **Ruby & Fastlane:** (`fastlane --version`)

---

### 2. Пошаговая инициализация проекта

```bash
# Шаг 1: Клонирование репозитория
git clone https://github.com/alexche/vellum-app.git && cd vellum-app

# Шаг 2: Установка зависимостей Flutter и iOS Pods
flutter pub get
cd ios && pod install && cd ..

# Шаг 3: Генерация Isar-моделей базы данных
dart run build_runner build --delete-conflicting-outputs

# Шаг 4: Запуск Unit-тестов и алгоритмов заучивания
flutter test

# Шаг 5: Запуск приложения в симуляторе с движком Impeller
flutter run -d "iPhone 15 Pro"
```

---

## 🏛 Ментальная модель архитектуры кодовой базы

Проект построен по принципам **Feature-first Clean Architecture** на Flutter:

```
vellum/
├── lib/
│   ├── core/                       # Ядро приложения
│   │   ├── audio/                  # Низколатентный SoundPool (< 8мс)
│   │   ├── haptics/                # MethodChannel к CoreHaptics iOS
│   │   ├── theme/                  # Цвета пергамента, чернил, токены Vellum
│   │   └── utils/                  # Форматирование римских дат, хэш дня
│   ├── data/                       # Слой данных (Isar Database)
│   │   ├── models/                 # Poem, UserFolioEntry, TypingSession
│   │   ├── repositories/           # Реализации репозиториев
│   │   └── sources/                # Seeding бандла 240+ стихов Public Domain
│   ├── domain/                     # Бизнес-логика (Pure Dart, 0 зависимостей)
│   │   ├── algorithms/             # ClozeMaskGenerator (4 уровня исчезающих слов)
│   │   └── repositories/           # Интерфейсы репозиториев
│   ├── presentation/               # UI экраны и стейт-менеджмент (Riverpod)
│   │   ├── daily_sanctuary/        # SCR-01: Стих дня и Ghost Typing
│   │   ├── memory_practice/        # SCR-02: Тренировка памяти с сургучной печатью
│   │   ├── folio_book/             # SCR-03: Личная книжечка выученных стихов
│   │   ├── story_studio/           # SCR-04: Экспорт открыток 9:16 и 1:1
│   │   └── paywall/                # SCR-05: Модальное окно Vellum Pro
│   └── main.dart                   # Точка входа, Sentry и инициализация
├── assets/
│   ├── audio/                      # Несжатые PCM WAV сэмплы печатных машинок
│   ├── data/                       # Базовый каталог curated_poems_v1.json
│   └── fonts/                      # Шрифты EBGaramond, Cormorant
└── test/                           # Модульные и интеграционные тесты
```

---

## 🤖 Протокол разработки для AI кодинг-агентов (SDD)

При реализации задач из бэклога (`TASK-XXX`):

1. **Изучите спецификацию:** Откройте требования в `02-prd/01-product-requirements.md` и архитектурные решения в `03-tech-stack/`.
2. **Пишите тесты первыми (TDD):** Сначала создайте или проверьте падающий тест в `test/`, затем реализуйте код.
3. **Строго соблюдайте NFR:** Никаких тяжелых синхронных операций в UI-потоке. Любой звуковой отклик должен срабатывать за **<= 8 мс**.
4. **Контроль линтера:** Перед коммитом всегда выполняйте `flutter analyze --fatal-infos`.
