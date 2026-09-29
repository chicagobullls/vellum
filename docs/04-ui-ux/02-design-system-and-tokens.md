---
project: "vellum"
phase: 4
doc_type: "design-system"
status: "approved"
last_updated: "2026-09-29"
tags:
  - airam
  - ui-ux
  - design-system
  - dark-academia
  - typography
---

# 🎨 Дизайн-система и токены: Vellum (Victorian Modernity)

> **Философия визуального стиля:**  
> Сочетание очарования **викторианского книжного кабинета (Dark Academia)** и **скандинавского минимализма Apple**. Тактильное ощущение плотной верже-бумаги, глубоких типографских чернил, золотого тиснения и ультра-чистых отступов без визуального мусора.

---

## 1. Цветовая палитра и токены (Palette Tokens)

### Режим «Дневной пергамент» (Parchment Light — Default)
| Токен | HEX | HSL | Назначение |
| :--- | :--- | :--- | :--- |
| `parchment-bg` | `#FBF8F1` | `hsl(41, 56%, 96%)` | Основной фон экрана (теплая слоновая кость, мягкая для глаз) |
| `parchment-surface` | `#F4EFE6` | `hsl(38, 35%, 93%)` | Карточки книг, подложка набора, всплывающие листы |
| `ink-primary` | `#1A1816` | `hsl(30, 8%, 10%)` | Текст набранных стихов (глубокий угольно-чернильный оттенок) |
| `ink-ghost` | `rgba(26,24,22, 0.22)` | — | Призрачный текст в режиме Ghost Typing |
| `antique-gold` | `#C29B38` | `hsl(43, 55%, 49%)` | Золотые корешки, бейджи Pro, активные индикаторы уровней |
| `wax-burgundy` | `#842D2D` | `hsl(0, 49%, 35%)` | Цвет сургучной печати мастерства и микро-подсветки ошибок |
| `parchment-border` | `#E8DFD1` | `hsl(37, 30%, 86%)` | Тончайшие разделители и рамки (1px) |

### Режим «Ночная библиотека» (Dark Academia — Night)
| Токен | HEX | HSL | Назначение |
| :--- | :--- | :--- | :--- |
| `dark-bg` | `#151413` | `hsl(30, 4%, 8%)` | Фон (оттенок старинного кожаного переплета) |
| `dark-surface` | `#201E1C` | `hsl(30, 7%, 12%)` | Поверхности карточек и панели настроек |
| `dark-ink-primary` | `#E8E2D8` | `hsl(38, 25%, 88%)` | Читаемый мягкий антиквенный текст |
| `dark-ink-ghost` | `rgba(232,226,216, 0.20)` | — | Призрачный текст в ночной теме |
| `dark-gold-glow` | `#D4AF37` | `hsl(46, 65%, 52%)` | Золотое тиснение с мягким свечением |

---

## 2. Типографика (Typography System)

В основе типографики лежит контраст между благородной классической антиквой (для стихов) и современным гротеском (для служебных дат и навигации):

- **Поэтическая антиква (Poetry Serif):** **`EB Garamond`** (или `Cormorant Garamond`). Классические пропорции ренессансной гарнитуры XVI века Клода Гарамона.
- **Интерфейсный гротеск (Modern Sans):** **`SF Pro Display / Text`** (Apple нативный шрифт с увеличенным трекингом `+0.5px` для лаконичности).

| Стиль типографики | Гарнитура | Размер | Вес | Line Height | Letter Spacing |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **Roman Date (Дата дня)** | SF Pro Text | 12px | 500 (Medium) | 1.2 | `+2.0px (All Caps)` |
| **Poem Title (Название)** | EB Garamond | 24px | 600 (SemiBold) | 1.3 | `-0.2px` |
| **Poet Author (Автор)** | SF Pro Text | 13px | 400 (Regular) | 1.4 | `+1.0px (Uppercase)` |
| **Verse Line (Строфа)** | EB Garamond | 21px | 400 (Regular) | 1.65 | `0.0px` |
| **Folio Counter (Счетчик)** | EB Garamond Italic| 15px | 400 (Italic) | 1.4 | `0.0px` |
| **Button / Caption** | SF Pro Text | 14px | 600 (SemiBold) | 1.2 | `+0.8px` |

---

## 3. Сетка, формы и кинестетические токены

- **Сетка и ритм:** 8-пиксельный шаг (`8px`, `16px`, `24px`, `32px`, `48px`).
- **Скругления (Border Radius):**
  - Кнопки действий: `12px` (мягкий органический силуэт).
  - Карточки книг: `16px` с внутренней рамкой `1px solid var(--parchment-border)`.
  - Сургучная печать: `50%` (круг `44x44px` с фактурным неровным тиснением).
- **Кинестетические токены (Акустика + Taptic):**
  - `token_key_press`: длительность PCM 12мс, CoreHaptics transient `intensity=0.5, sharpness=0.6`.
  - `token_line_complete`: короткий механический щелчок возврата.
  - `token_stanza_bell`: 350мс звонок колокольчика печатной машинки, Taptic success notification.
  - `token_error_shake`: анимация сдвига `dx = [-3, 3, -2, 2, 0]` px за 110 мс, глухой отклик.

---

## 4. Исполняемые токены темы во Flutter (`lib/core/theme/vellum_theme.dart`)

```dart
import 'package:flutter/material.dart';

class VellumColors {
  // Light Parchment
  static const Color parchmentBg = Color(0xFFFBF8F1);
  static const Color parchmentSurface = Color(0xFFF4EFE6);
  static const Color inkPrimary = Color(0xFF1A1816);
  static const Color inkGhost = Color(0x381A1816); // 22% opacity
  static const Color antiqueGold = Color(0xFFC29B38);
  static const Color waxBurgundy = Color(0xFF842D2D);
  static const Color parchmentBorder = Color(0xFFE8DFD1);

  // Dark Academia
  static const Color darkBg = Color(0xFF151413);
  static const Color darkSurface = Color(0xFF201E1C);
  static const Color darkInkPrimary = Color(0xFFE8E2D8);
  static const Color darkInkGhost = Color(0x33E8E2D8); // 20% opacity
  static const Color darkGold = Color(0xFFD4AF37);
}

class VellumTypography {
  static const TextStyle romanDate = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    color: Color(0xFF8A8275),
  );

  static const TextStyle verseText = TextStyle(
    fontFamily: 'EBGaramond',
    fontSize: 21,
    height: 1.65,
    fontWeight: FontWeight.normal,
    color: VellumColors.inkPrimary,
  );
}
```
