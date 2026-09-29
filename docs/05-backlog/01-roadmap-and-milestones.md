---
project: "vellum"
phase: 5
doc_type: "roadmap"
status: "approved"
last_updated: "2026-09-29"
tags:
  - airam
  - backlog
  - roadmap
  - milestones
---

# 🗺 Дорожная карта и майлстоуны: Vellum

> **Цель документа:** Структурировать график реализации от Proof-of-Concept до публикации в Apple App Store, распределить майлстоуны M0..M3 и зафиксировать четкие критерии выхода (Exit Criteria).

---

## 1. Фазы реализации продукта (Gantt Chart)

```mermaid
gantt
    title График разработки и запуска Vellum MVP (10 недель)
    dateFormat  YYYY-MM-DD
    
    section M0: PoC & Kinesthetics
    Стенд звука SoundPool + CoreHaptics (< 8мс)   :active,  m0_1, 2026-10-01, 7d
    Инициализация Flutter, Isar DB и сид 240 стихов:         m0_2, after m0_1, 5d
    
    section M1: Core Experience
    Экран SCR-01 (Daily Sanctuary + Ghost Typing) :         m1_1, after m0_2, 10d
    Алгоритм Cloze Deletion и экран заучивания SCR-02:      m1_2, after m1_1, 8d
    Личный фолиант SCR-03 (Книжечка на Isar)       :         m1_3, after m1_2, 7d
    
    section M2: Viral & TestFlight
    Генератор Story Cards SCR-04 + Share Sheet    :         m2_1, after m1_3, 6d
    Телеметрия TelemetryDeck + Sentry             :         m2_2, after m2_1, 4d
    Закрытая бета в TestFlight (50 тестеров)      :         m2_3, after m2_2, 12d
    
    section M3: StoreKit & Launch
    Интеграция StoreKit 2 и Пейволл SCR-05        :         m3_1, after m2_3, 7d
    App Store Review и публичный релиз            :         m3_2, after m3_1, 7d
```

---

## 2. Детализация контрольных майлстоунов

| Майлстоун | Название | Сроки | Ключевой результат (Deliverables) | Критерий успешности (Exit Criteria) |
| :--- | :--- | :--- | :--- | :--- |
| **`M0`** | **PoC & Кинестетика** | Недели 1–2 | Изолированный тестовый экран: звук щелчка печатной машинки + Taptic-импульс. База Isar с 240 стихами. | Задержка звука **< 8 мс**; выборка стиха из БД **< 2 мс**. Риск `RISK-02` снят. |
| **`M1`** | **Core Experience** | Недели 3–5 | Рабочий цикл: чтение стиха дня ➔ набор текста буква в букву ➔ исчезающие слова (Cloze) ➔ сохранение в книжечку. | Выполнены все критерии `FR-01`, `FR-02`, `FR-03`, `FR-04`, `FR-05`. 120 fps в Impeller. |
| **`M2`** | **Виральность & TestFlight** | Недели 6–7 | Экспорт эстетичных карточек цитат в Instagram Stories. Сборка через Fastlane в Apple TestFlight. | Успешная установка 50 тестерами. D7 Retention в тестовой когорте **> 30%**. 0 критических крэшей. |
| **`M3`** | **Биллинг & App Store Launch**| Недели 8–10 | Подключение StoreKit 2 (Vellum Pro). Экран настроек с темами звука. Прохождение модерации Apple. | Успешное одобрение в App Store. Появление первых платящих Pro-подписчиков (`GOAL-03`). |
