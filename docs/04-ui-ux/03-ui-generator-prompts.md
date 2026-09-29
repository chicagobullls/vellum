---
project: "vellum"
phase: 4
doc_type: "ui-prompts"
status: "approved"
last_updated: "2026-09-29"
tags:
  - airam
  - ui-ux
  - prompts
  - v0
  - lovable
  - mobile-ui
---

# 💻 Готовые промпты для UI-генераторов (v0.dev / Lovable.dev): Vellum

> **Как использовать:**  
> Скопируйте один из блоков ниже и вставьте его напрямую в интерфейс `v0.dev`, `Lovable.dev`, `bolt.new` или передайте кодинг-агенту для генерации экранных компонентов Flutter / React.

---

## 🖥 Экран `SCR-01`: Daily Sanctuary (Стих дня и Ghost Typing)

```text
Create an ultra-minimalist, breathtakingly aesthetic mobile screen for a poetry typing app called "Vellum".
Aesthetic: Victorian Modernity meets Apple Scandinavian Minimalism (Dark Academia / Editorial Serifs).

Color Palette:
- Background: Warm delicate Ivory Parchment (#FBF8F1).
- Text (Full Inked): Antique Charcoal Ink (#1A1816).
- Ghost Ink (Un-typed): Translucent Charcoal with 22% opacity (#1A1816 with opacity 0.22).
- Accent & Flourishes: Antique Gold (#C29B38) and Muted Burgundy Wax (#842D2D).

Typography:
- Heading / Verses: Elegant Classic Editorial Serif (EB Garamond / Cormorant Garamond).
- Dates & Meta: Modern minimalist Sans-Serif (SF Pro / Inter) with wide letter-spacing (2px).

Layout Structure (Mobile 390x844 iPhone canvas):
1. Top Minimal Bar:
   - Left: Roman numeral date in subtle gold-gray ("XXIX · IX · MMXXVI").
   - Center: Tiny monogram logo "V".
   - Right: Language pill switcher ("RU" / "EN") and a minimalist Book icon ("Folio").
2. Core Verse Card (Vertically centered):
   - Poet Name in spaced uppercase: "LORD BYRON"
   - Poem Title in medium italic: "She Walks in Beauty"
   - The Stanza (8 lines): Rendered with high line-height (1.65). 
   - Interactive Ghost Typing mechanic: The first 3 lines are filled with dark carbon ink (#1A1816); the active 4th line has a blinking antique gold hairline cursor after the 3rd word; the remaining lines are faint ghost ink (22% opacity).
3. Bottom Focus Strip:
   - Subtle acoustic status pill: "Underwood No. 5 · Haptics On" with a tiny vintage typewriter icon.
   - Discreet floating action buttons: "Practice Memorizing" (with small wax seal icon) and "Export Story Card".
```

---

## 🖥 Экран `SCR-02`: Memory Sanctuary (Cloze Deletion Practice)

```text
Create an interactive poem memorization screen for "Vellum" using the Cloze Deletion technique.

Design Style:
- Warm parchment background (#FBF8F1), bordered with a 1px soft hairline border (#E8DFD1).
- Editorial typography with antique gold accents.

Screen Elements:
1. Header: Back arrow, poem title, and a Roman numeral 4-step progress tracker:
   - Tabs: [I. Full Ghost] · [II. 30% Words] · [III. Rhymes Only] · [IV. Blind Memory]
   - The active tab (Step III) is highlighted with an Antique Gold underline and tiny dot.
2. The Exercise Area:
   - Display a 4-line stanza by Alexander Pushkin.
   - Rhyming words at the end of lines are visible in deep ink (#1A1816).
   - In-between words are replaced with smooth, elegant dashed underline blanks: "_______".
   - Active blank has a soft pulsing gold glow.
3. Floating Assist Bar:
   - "Peek Line" button (icon of a vintage feather quill) that shows a 2-second ghost hint.
   - Mistakes counter: "0 errors".
4. Success State (Modal overlay trigger):
   - When the user finishes typing, show a textured burgundy wax seal animation with an embossed golden stamp: "MASTERED · MMXXVI".
   - Buttons: "Save to Folio" (Primary, dark button with gold text) and "Share Achievement".
```

---

## 🖥 Экран `SCR-03`: The Personal Folio (Личная книжечка выученных стихов)

```text
Design a private library / book folio screen for "Vellum".

Visual Theme:
- Antique bound collector's journal. 
- Option to toggle between "Parchment Light" (#FBF8F1) and "Dark Academia Charcoal" (#151413).

Layout:
1. Header: 
   - Title: "The Folio" in classic Garamond serif (32px).
   - Subtitle: "14 of 15 Verses Collected · Free Tier" with a progress bar and a golden "Unlock Unlimited" Pro pill.
2. Filters Bar:
   - Minimal text pills: "All (14)", "Mastered (6)", "Favorites (4)", "19th Century (9)".
3. List of Saved Poems:
   - Beautiful editorial cards styled like pressed bookplates:
     - Card 1: "A. Pushkin — Я помню чудное мгновенье", 4/4 Wax Seal Stamp, Saved on "Sep 24, 2026", 100% accuracy.
     - Card 2: "John Keats — Ode on a Grecian Urn", 2/4 Stamp, Saved on "Sep 28, 2026", 96% accuracy.
     - Card 3: "M. Lermontov — Парус", 4/4 Wax Seal Stamp, gold bookmark ribbon in top corner.
4. Floating Action Button:
   - Elegant circle button with antique gold border and a "+" icon: "Add Custom Verse" (tagged with small PRO badge).
```

---

## 🖥 Экран `SCR-04`: Story Card Studio (Виральный генератор для соцсетей)

```text
Create a viral card generation screen for exporting poetry quotes to Instagram Stories and Twitter/X for "Vellum".

Layout:
1. Card Canvas (Center Preview, 9:16 aspect ratio with rounded corners and drop shadow):
   - Background: Tactile paper grain in Warm Ivory (#FBF8F1).
   - Top: Embossed Roman date and elegant flourish ornament.
   - Body: Beautiful quote in EB Garamond serif:
     "She walks in beauty, like the night
      Of cloudless climes and starry skies;
      And all that’s best of dark and bright
      Meet in her aspect and her eyes..."
   - Bottom: Author signature "LORD BYRON", small embossed wax seal graphic, and subtle logo "vellum.app".
2. Bottom Customization Toolbar:
   - Theme Selector: [Parchment Light] | [Dark Academia Charcoal] | [Deep Forest Emerald].
   - Format Selector: [9:16 Story] | [1:1 Square Post].
   - Primary CTA: "Share to Instagram Stories" (Full width dark ink button with gold icon).
```
