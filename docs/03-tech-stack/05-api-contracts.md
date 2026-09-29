---
project: "vellum"
phase: 3
doc_type: "api-contracts"
status: "approved"
last_updated: "2026-09-29"
tags:
  - airam
  - architecture
  - api
  - dart-contracts
  - clean-architecture
  - storekit
---

# 🔌 Спецификация программных контрактов и API: Vellum

> **Назначение:**  
> Так как Vellum является автономным 100% Offline-first клиентом, документ фиксирует:  
> 1. Внутренние интерфейсы слоев Clean Architecture (Репозитории и Сервисы в Dart);  
> 2. Внешние протоколы интеграции (Apple StoreKit 2 и анонимная телеметрия TelemetryDeck API).

---

## 1. Внутренние сервисные контракты (Dart Repository Interfaces)

Кодинг-агенты **обязаны** строго следовать этим контрактам в слое `lib/domain/repositories/`:

### 1.1 Контракт репозитория стихов (`PoemRepository`)
```dart
abstract class PoemRepository {
  /// Получить детерминированный стих текущего дня
  Future<Poem> getDailyPoem({
    required DateTime date, 
    required String language,
  });

  /// Получить стих по уникальному ID
  Future<Poem?> getPoemById(int id);

  /// Поиск стихов по автору или первой строке
  Future<List<Poem>> searchPoems({
    required String query, 
    String? language,
  });

  /// Добавить пользовательский стих (UGC, Vellum Pro)
  Future<int> insertCustomPoem({
    required String title,
    required String author,
    required List<String> lines,
    required String language,
  });
}
```

### 1.2 Контракт личной книжечки («Фолиант») (`FolioRepository`)
```dart
abstract class FolioRepository {
  /// Получить список всех сохраненных стихов с пагинацией
  Stream<List<UserFolioEntry>> watchFolioEntries();

  /// Сохранить стих в книжечку
  Future<void> saveToFolio(int poemId);

  /// Обновить уровень заучивания (1..4)
  Future<void> updateMasteryLevel({
    required int poemId, 
    required int newLevel,
  });

  /// Зафиксировать завершенную сессию набора
  Future<void> logTypingSession(TypingSession session);
}
```

### 1.3 Контракт кинестетики (Звук + Тактильность) (`KinestheticService`)
```dart
abstract class KinestheticService {
  /// Предзагрузить аудио-сэмплы активной печатной машинки в память
  Future<void> preloadTheme(String themeId);

  /// Воспроизвести акустический клик клавиши (< 8мс задержки)
  void onKeyPress();

  /// Воспроизвести звонок каретки в конце строфы
  void onCarriageReturn();

  /// Воспроизвести глухой звук ошибки и вибро-покачивание
  void onError();
}
```

---

## 2. Внешний контракт биллинга: Apple StoreKit 2

Взаимодействие с транзакционной системой App Store:

### Идентификаторы продуктов (App Store Product Identifiers)
| Product ID | Тип покупки | Цена | Описание |
| :--- | :--- | :--- | :--- |
| `app.vellum.pro.monthly` | Auto-renewable Subscription | $2.99 / mo | Ежемесячный доступ Vellum Pro |
| `app.vellum.pro.annual` | Auto-renewable Subscription | $19.99 / yr | Годовой доступ с 3-дневным триалом |
| `app.vellum.patron.lifetime` | Non-Consumable (IAP) | $49.99 | Пожизненная лицензия мецената |

### Интерфейс управления подпиской (`BillingService`)
```dart
abstract class BillingService {
  /// Получить актуальные ценники из App Store
  Future<List<ProductDetails>> fetchProducts();

  /// Запустить покупку через системный диалог Apple Pay
  Future<PurchaseResult> purchase(String productId);

  /// Восстановить ранее совершенные покупки
  Future<void> restorePurchases();

  /// Поток изменений статуса Pro-подписки
  Stream<bool> get isProActiveStream;
}
```

---

## 3. Внешний контракт анонимной телеметрии: TelemetryDeck HTTP API

- **Endpoint:** `POST https://nom.telemetrydeck.com/v2/`
- **Заголовки:**  
  `Content-Type: application/json`  
  `X-Telemetry-App-ID: 7E429B81-...`
- **Тело запроса (Zero-PII Payload):**
```json
[
  {
    "appID": "7E429B81-...",
    "clientUser": "sha256_anonymous_hash_of_uuid",
    "type": "typing_session_completed",
    "receivedAt": "2026-09-29T09:15:00.000Z",
    "payload": {
      "poem_id": "42",
      "duration_sec": "180",
      "wpm": "54",
      "accuracy_pct": "98.5",
      "audio_theme": "underwood_1920",
      "is_pro": "false"
    }
  }
]
```
