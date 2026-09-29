---
project: "vellum"
phase: "03-tech-stack"
artifact: "07-observability-and-ops"
title: "Наблюдаемость, мониторинг крэшей и телеметрия (Observability)"
status: "approved"
created_at: "2026-09-29"
tags:
  - airam
  - tech-stack
  - observability
  - sentry
  - performance
  - crashlytics
---

# 📡 Наблюдаемость, мониторинг крэшей и телеметрия: Vellum

> **Назначение:**  
> Документ регламентирует мобильный мониторинг стабильности приложения, отслеживание 120fps просадок, перехват исключений через Sentry Flutter SDK и сбор анонимной телеметрии.

---

## 1. Архитектура мониторинга сбоев (Sentry Mobile)

Для отлова необработанных исключений и ANR (зависаний интерфейса) используется **Sentry Flutter SDK**:

```dart
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      options.tracesSampleRate = 0.2; // 20% транзакций для контроля квот
      options.enableAutoPerformanceTracing = true;
      options.attachScreenshot = false; // Zero-PII: скриншоты отключены
      options.sendDefaultPii = false;   // Запрет сбора персональных данных
    },
    appRunner: () => runApp(const VellumApp()),
  );
}
```

### Политика сохранения приватности в логах (Zero-PII Breadcrumbs):
- ❌ **Категорически запрещено:** логировать символы, вводимые пользователем, или текст стихов.
- ✅ **Разрешено в Breadcrumbs:** переходы между экранами (`route: /daily_verse ➔ /folio`), инициализация аудио-плеера (`audio_theme: underwood`), запуск транзакции StoreKit (`iap_started: pro_annual`).

---

## 2. Метрики производительности (Performance & Frame Drop)

| Метрика | Норматив SLO | Как замеряется | Реакция при деградации |
| :--- | :---: | :--- | :--- |
| **Crash-Free Sessions** | **>= 99.8%** | Sentry Release Health | Блокировка релиза в App Store |
| **Cold Start Time** | **< 400 мс** | `WidgetsBinding.firstFrameRasterized` | Оптимизация Isar инициализации |
| **Input-to-Audio Latency** | **< 8 мс** | Stopwatch в тестах Native Bridge | Откат звукового сэмпла в PCM буфер |
| **UI Frame Budget** | **16.6мс (60fps) / 8.3мс (120fps)** | Flutter Frame Timing Listener | Оптимизация виджетов Ghost Typing |

---

## 3. Таксономия доменных ошибок (Domain Exceptions)

Все внутренние ошибки приложения типизированы:

```dart
sealed class VellumException implements Exception {
  final String message;
  final String code;
  const VellumException(this.message, this.code);
}

class StorageException extends VellumException {
  const StorageException(String msg) : super(msg, 'STORAGE_ERROR');
}

class AudioPlaybackException extends VellumException {
  const AudioPlaybackException(String msg) : super(msg, 'AUDIO_INIT_ERROR');
}

class StoreKitBillingException extends VellumException {
  final bool userCancelled;
  const StoreKitBillingException(String msg, {this.userCancelled = false}) 
      : super(msg, 'BILLING_ERROR');
}

class ClozeAlgorithmException extends VellumException {
  const ClozeAlgorithmException(String msg) : super(msg, 'CLOZE_PARSE_ERROR');
}
```
