---
project: "vellum"
phase: "05-backlog"
artifact: "03-qa-and-test-strategy"
title: "Стратегия тестирования и план обеспечения качества (QA)"
status: "approved"
created_at: "2026-09-29"
tags:
  - airam
  - backlog
  - qa
  - flutter-test
  - integration-test
---

# 🧪 Стратегия тестирования и обеспечение качества (QA): Vellum

> **Назначение:**  
> Документ регламентирует пирамиду тестирования Flutter-клиента, модульные тесты алгоритмов Cloze Deletion, сквозные интеграционные тесты (Integration Tests) и 10-минутный предрелизный Smoke Runbook на физическом iPhone.

---

## 1. Пирамида тестирования Vellum

```
        / \
       /   \        E2E Integration Tests (Flutter Driver / Integration Test):
      / E2E \       4 критических сценария на реальном симуляторе iOS
     /-------\
    / Widget  \     Widget Tests (UI & Kinesthetics):
   /   Tests   \    Проверка Ghost Typing, анимаций скролла и отрисовки карточек
  /-------------\
 /  Unit Tests   \  Модульные тесты (Pure Dart):
/ (Coverage >=90%)\ Алгоритм Cloze, детерминированный хэш стиха, парсер БД
-------------------
```

### Нормативы покрытия кода (Coverage Targets):
- **Domain Algorithms (`cloze_mask_generator.dart`, `date_scheduler.dart`):** `100%`
- **Data Repositories & Isar Mappings:** `>= 85%`
- **Presentation State Notifiers (Riverpod):** `>= 80%`

---

## 2. Матрица сквозных сценариев (Integration Tests)

| ID Сценария | Название пути | Шаги выполнения | Ожидаемый результат | Автоматизация |
| :--- | :--- | :--- | :--- | :---: |
| **`IT-01`** | **Холодный старт и Стих Дня** | 1. Запуск приложения с чистой БД<br>2. Проверка экрана `SCR-01` | Отображается стихотворение дня текущей даты, время холодного старта < 400мс | ✅ Integration Test |
| **`IT-02`** | **Полный цикл Ghost Typing** | 1. Посимвольный ввод тестового четверостишия<br>2. Ввод неверной буквы | Неверная буква не печатается, строка покачивается. При завершении — звонок каретки | ✅ Integration Test |
| **`IT-03`** | **Тренажер памяти Cloze Deletion** | 1. Переход на `SCR-02`<br>2. Выбор Уровня III (Рифмы)<br>3. Успешный набор скрытых слов | Появление анимированной сургучной печати «MASTERED» | ✅ Integration Test |
| **`IT-04`** | **Feature Gating и лимит 15 стихов** | 1. Симуляция сохранения 15 стихов<br>2. Попытка сохранить 16-й стих | Блокировка сохранения и открытие экрана Vellum Pro Paywall `SCR-05` | ✅ Integration Test |
| **`IT-05`** | **Оффлайн-автономность (Offline Check)** | 1. Включение симуляции Airplane Mode<br>2. Перезапуск приложения и набор стиха | 100% функционала работает без ошибок сети и падений | ✅ Integration Test |

---

## 3. Исполняемый модульный тест алгоритма Cloze (`test/domain/cloze_test.dart`)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vellum/domain/algorithms/cloze_mask_generator.dart';

void main() {
  group('ClozeMaskGenerator Tests', () {
    const sampleLine = "Я помню чудное мгновенье";

    test('Уровень 1: 0% скрытых слов', () {
      final mask = ClozeMaskGenerator.generate(sampleLine, level: 1);
      expect(mask.hiddenIndices.isEmpty, isTrue);
    });

    test('Уровень 2: скрываются смысловые слова, предлоги сохраняются', () {
      final mask = ClozeMaskGenerator.generate("Буря мглою небо кроет", level: 2);
      expect(mask.hiddenIndices.length, inInclusiveRange(1, 2));
    });

    test('Уровень 3: Рифма сохраняется в конце строки', () {
      final mask = ClozeMaskGenerator.generate("И сердце бьется в упоенье", level: 3);
      // Последнее слово ("упоенье") должно оставаться видимым
      expect(mask.isWordVisible(wordIndex: 4), isTrue);
    });
  });
}
```

---

## 4. 10-минутный предрелизный Smoke Runbook (Физический iPhone)

Перед отправкой сборки на ревью в App Store Connect тестировщик проходит обязательный чеклист:

- [ ] **Тактильность Taptic Engine:** Нажать 10 клавиш подряд на реальном iPhone (вибрация мягкая, без треска динамика).
- [ ] **Акустический лаг:** Набрать фразу со скоростью 60+ слов/мин в наушниках AirPods и через динамик (звук не отстает от пальцев).
- [ ] **Смена темы оформления:** Переключить системную тему iOS с Light на Dark (стих плавно переходит в Dark Academia).
- [ ] **Экспорт открытки:** Сгенерировать Story Card и нажать «Сохранить в Фото» (картинка 1080x1920 сохранена без артефактов).
- [ ] **StoreKit Sandbox:** Оформить тестовую подписку в TestFlight через Sandbox Apple ID (сургучная печать Pro разблокирована).
- [ ] **Авиарежим:** Включить авиарежим, выгрузить приложение из памяти, открыть заново (мгновенный старт без экранов ошибок).
