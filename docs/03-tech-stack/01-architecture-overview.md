---
project: "vellum"
phase: 3
doc_type: "architecture-overview"
status: "approved"
last_updated: "2026-09-29"
tags:
  - airam
  - architecture
  - tech-stack
  - flutter
  - offline-first
---

# 🏗 Архитектурный обзор и выбор технологий: Vellum

> **Цель документа:** Зафиксировать инженерные решения, структуру компонентов и диаграммы контейнеров C4 для 100% Offline-first мобильного клиента **Vellum** на базе Flutter 3.x и движка Impeller.

---

## 1. Сравнительный анализ альтернатив стека

| Слой | Рекомендуемый стек (Выбор) | Альтернатива А | Альтернатива B | Обоснование выбора |
| :--- | :--- | :--- | :--- | :--- |
| **UI Framework** | **Flutter 3.x (Dart 3)** | Swift / SwiftUI | React Native (Expo) | Полный контроль над посимвольным рендерингом (Impeller), шейдерами состаренной бумаги и кроссплатформенностью без раздувания кодовой базы. |
| **Графический рендерер** | **Impeller 2D Engine** | Skia (Legacy) | WebKit Canvas | Полное устранение шейдерных задержек (shader compilation jank), гарантированные **120 fps ProMotion** на iPhone 13 Pro+. |
| **Локальная база данных** | **Isar Database v3** | SQLite (sqflite / drift) | Hive / Realm | Высочайшая скорость чтения (< 2мс на запрос стиха), строгая статическая типизация, поддержка ACID-транзакций, нулевые серверные расходы. |
| **Аудио-движок (ASMR)** | **SoundPool / Native AVAudioPlayer** | just_audio | audioplayers (Default) | Предзагрузка аудио-сэмплов печатных машинок в несжатый PCM буфер памяти. **Латентность < 8мс** между тапом по экрану и звуковым импульсом. |
| **Тактильный отклик** | **CoreHaptics MethodChannel** | HapticFeedback (System) | vibration | Тончайшая модуляция силы и резкости импульса Taptic Engine под вес молоточка механической машинки. |
| **State Management** | **Flutter Riverpod 2.x** | BLoC | Provider | Реактивность без boilerplate-кода, декларативное управление состоянием сессии набора и кэшем прав Pro. |
| **Биллинг (IAP)** | **StoreKit 2 (in_app_purchase)** | RevenueCat | Собственный сервер валидации | Нативная интеграция без сторонних комиссий и без обязательного бэкенда для валидации чеков в MVP. |

---

## 2. Диаграмма контейнеров C4 (Mermaid C4 Container)

```mermaid
flowchart TB
    User[Пользователь / Эстет]

    subgraph iOSDevice [Мобильное устройство: iOS / Flutter Impeller]
        subgraph UI_Layer [Presentation Layer]
            GhostTypingUI[Ghost Typing & Screen View]
            AudioController[Acoustic ASMR Engine]
            HapticEngine[CoreHaptics Controller]
            FolioBookUI[My Folio Book View]
            PaywallModal[Vellum Pro StoreKit View]
        end

        subgraph Core_Logic [Domain & State Layer: Riverpod]
            SessionNotifier[Typing Session Manager]
            ClozeAlgorithm[Cloze Deletion Mask Generator]
            DailyVerseScheduler[Deterministic Date-Hash Engine]
            EntitlementGuard[Local Pro Feature Gating]
        end

        subgraph Storage_Layer [Data & Storage Layer]
            IsarDB[(Isar Embedded DB - 365+ Poems)]
            SecureKeychain[(iOS Secure Keychain - Pro Keys)]
            LocalAudioAssets[(Raw PCM WAV Audio Themes)]
        end
    end

    subgraph ExternalEcosystem [Внешняя инфраструктура Apple & Store]
        AppStore[Apple App Store / StoreKit 2]
        Telemetry[TelemetryDeck Anonymous Analytics]
        iCloudSync[(Apple iCloud Drive - Future v1.2)]
    end

    User -->|Тапы по клавиатуре| GhostTypingUI
    GhostTypingUI --> SessionNotifier
    SessionNotifier -->|Индекс верной буквы| AudioController
    SessionNotifier -->|Импульс нажатия| HapticEngine
    AudioController --> LocalAudioAssets
    
    SessionNotifier --> ClozeAlgorithm
    DailyVerseScheduler --> IsarDB
    SessionNotifier -->|Сохранение прогресса| IsarDB
    
    PaywallModal --> EntitlementGuard
    EntitlementGuard --> SecureKeychain
    EntitlementGuard -->|IAP Purchase / Restore| AppStore
    
    SessionNotifier -.->|Анонимная телеметрия| Telemetry
    FolioBookUI -.->|Синхронизация бэкапа| iCloudSync
```

---

## 3. Поток выполнения сессии Ghost Typing (Sequence Diagram)

```mermaid
sequenceDiagram
    autonumber
    actor User as Пользователь
    participant Keyboard as Экранная клавиатура
    participant State as TypingSessionNotifier
    participant Audio as SoundPool (AVAudioPlayer)
    participant Haptic as CoreHaptics Engine
    participant UI as Impeller Render Pipeline
    participant DB as Isar Embedded DB

    User->>Keyboard: Нажатие клавиши 'A'
    Keyboard->>State: processInputKey('A')
    
    rect rgb(240, 248, 255)
        note right of State: Параллельное исполнение за < 8 мс
        par Звук клика
            State->>Audio: play(activeKeyClickId)
        and Виброотклик
            State->>Haptic: triggerTransientHaptic(0.6f, 0.4f)
        and Обновление UI
            State->>UI: markGlyphActive(charIndex, inkColor)
        end
    end
    
    alt Символ верен
        UI-->>User: Буква залита чернильным цветом (#1A1A1A)
    else Ошибка ввода
        State->>Haptic: triggerErrorShake()
        UI-->>User: Мягкое покачивание строки (shake animation)
    end

    opt Завершение последней строки строфы
        State->>Audio: playCarriageReturnBell()
        State->>DB: updatePoemProgress(poemId, completed=true)
    end
```

---

## 4. Архитектурные принципы Vellum

1. **Zero-Latency Principle:** Никакая операция внутри сессии набора не должна блокировать UI-поток. Воспроизведение звуков и haptics запускается в неблокирующем асинхронном режиме.
2. **100% Offline Autonomy:** Все 365+ стихотворений, звуковые файлы печатных машинок и шрифты поставляются внутри установочного бандла. Приложение готово к работе на высоте 10 000 метров без связи.
3. **Decoupled Business Logic:** Логика маскирования слов (Cloze Deletion) вынесена в чистые Dart-классы, покрываемые 100% модульными Unit-тестами без зависимости от Flutter SDK.
