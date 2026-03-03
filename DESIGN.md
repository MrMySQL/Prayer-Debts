# Prayer Debts (Qada Tracker) — App Design Document

## Concept

A minimal, emotionally intelligent iOS app for Muslims to track and repay missed (qada) prayers. No backend — fully on-device with iCloud sync via SwiftData + CloudKit.

---

## The Person Opening This App

**They carry weight.** They know they have a debt to Allah. It might be years of missed prayers — hundreds, thousands. That number can feel crushing. There's guilt, maybe shame, maybe anxiety.

**But they're here.** The very act of opening this app means they've decided to do something about it. That takes courage. That's tawbah in motion.

**Their emotional spectrum:**
- Overwhelmed by the scale ("I have 7,000 prayers to make up")
- Hopeful but fragile ("Can I actually do this?")
- Seeking peace, not pressure
- Private — this is between them and Allah, not a social thing
- Looking for quiet dignity, not gamification

---

## What the Design Must Feel Like

- **Calm, not clinical.** This is not a spreadsheet of debt. It's a companion on a spiritual journey.
- **Warm, not cold.** The app should feel like a gentle hand on the shoulder, not a judge pointing at numbers.
- **Spacious, not cramped.** Large numbers can trigger anxiety. The design needs breathing room — generous whitespace, soft typography, unhurried layouts.
- **Progress, not deficit.** The framing matters enormously:
  - Wrong: "6,847 remaining" (emphasizes what's left — daunting)
  - Right: "153 completed" (emphasizes what's done — empowering)
  - Both numbers are available, but the **visual weight** should celebrate progress
- **Sacred without being religious-kitsch.** No mosque clip art, no generic Islamic patterns slapped on. Instead — the kind of serenity you feel inside a beautifully lit mosque. Think warm light, stillness, subtle geometry.

## Design Mood Keywords

| | |
|---|---|
| **Serenity** | like the quiet moment right after salah |
| **Warmth** | like candlelight, amber, soft dawn |
| **Dignity** | like calligraphy — precise, beautiful, intentional |
| **Hope** | like the first light of Fajr on the horizon |
| **Intimacy** | this is private worship, not a leaderboard |

---

## Data Model

**5 Prayer Types (in sacred order):** Fajr (Subh), Dhuhr, Asr, Maghrib, Isha

Each prayer type tracks:
- `totalDebt` — initial number of missed prayers
- `completedCount` — how many qada prayers performed so far
- `remaining` = totalDebt - completedCount

Plus a **log** of each completed qada prayer (date + prayer type) for history.

---

## Color & Material

### Dark Mode (Default)

| Element | Color |
|---------|-------|
| Background | Near-black, slightly warm `#141210` |
| Card surface | Very dark warm gray `#1E1C19` |
| Primary text | Warm off-white `#F5F0E8` |
| Secondary text | Muted warm gray `#8A8279` |
| Accent / progress fill | Amber-gold gradient `#C8956C` → `#E8C47C` |
| Ripple on tap | Accent at 15% opacity |
| Progress bar empty | `#252320` |

### Light Mode

| Element | Color |
|---------|-------|
| Background | Warm off-white `#FAF7F2` |
| Lower area fade | Slightly deeper warm `#F5F0E8` |

### Typography

| Element | Style |
|---------|-------|
| Journey number | 48pt, light weight, accent color |
| "prayers offered" | 14pt, regular, secondary color |
| Arabic prayer name | 16pt, Arabic serif/naskh |
| Transliterated name | 20pt, medium weight, primary color |
| "248 offered" | 28pt, semibold, accent color |
| "Today: +3" | 13pt, regular, secondary color |

---

## Background — "Warm Darkness"

### Dark Mode
- **Base**: Not a pure flat color. A very subtle **radial gradient** emanating from the top center of the screen, as if there's a distant, warm light source above — like the glow inside a mosque from a high window.
- **Glow**: `#1E1A15` at ~12% intensity from the top center, fading into the base `#141210` by mid-screen.
- **Texture**: A very faint **noise layer** over the entire background at 2-3% opacity. The difference between a screen that feels like a digital surface and one that feels like **material**. Like handmade paper. Like the soft texture of a prayer rug under your fingers.
- **Nothing else**: No patterns. No geometric tiles. No stars. No arabesque borders. The restraint *is* the design.

### Light Mode
- Same principle inverted — warm off-white `#FAF7F2` with a subtle downward gradient to `#F5F0E8`. Like cream-colored paper under soft natural light.
- Same noise texture at 1-2% opacity.

### Background Image Prompts

#### Dark Mode Prompt (for Gemini)
> Generate a dark, seamless mobile wallpaper background at 1290x2796 pixels (iPhone 15 Pro Max resolution). The image should be extremely subtle and minimal — designed to sit behind UI elements, not to be looked at directly. The background is a near-black warm surface (#141210) with a very soft radial glow emanating from the top center, using a dark warm tone (#1E1A15) at about 10-12% intensity, fading smoothly into the base color by the middle of the image. The glow should feel like distant warm light filtering through a high window in a dimly lit room. Over the entire surface, apply a very faint organic noise texture at 2-3% opacity — similar to handmade paper or fine stone grain. The texture should add tactile warmth without being visible at arm's length. No patterns, no shapes, no geometric elements, no stars, no gradients with visible color shifts. No Islamic motifs. No decorative elements whatsoever. The image should look almost like a solid dark color at first glance — only on closer inspection should the subtle glow and texture become apparent. Color must stay strictly in the warm neutral family: deep browns, dark ambers, muted earth tones. No blue, no purple, no cool tones. Think: the darkness inside a quiet mosque lit by a single warm lantern far above. The image must tile-friendly at the edges (left/right) and should have no focal point, watermark, or text.

#### Light Mode Prompt (for Gemini)
> Generate a light, seamless mobile wallpaper background at 1290x2796 pixels (iPhone 15 Pro Max resolution). The image should be extremely subtle and minimal — designed to sit behind UI elements, not to be looked at directly. The background is a warm off-white surface (#FAF7F2) with a very soft radial glow emanating from the top center, using a slightly brighter warm cream (#FFFFFF at 30-40% opacity) that fades smoothly into the base color by the upper third of the image. The effect should feel like soft natural daylight falling from above onto handmade paper. Over the entire surface, apply a very faint organic noise texture at 1-2% opacity — similar to pressed cotton paper or fine linen. The texture should add tactile warmth and prevent the surface from feeling like a flat digital screen. The lower portion of the image should transition very gently to a slightly deeper warm tone (#F5F0E8) — like the natural shadow on a sheet of paper lying on a table. The transition should be imperceptible as a gradient — it should just feel like the bottom is slightly quieter than the top. No patterns, no shapes, no geometric elements, no decorative motifs. No visible gradients or color bands. The image should look almost like a solid cream color at first glance — only on closer inspection should the subtle light variation and paper texture become apparent. Color must stay strictly in the warm neutral family: cream, ivory, warm whites, soft beige. No blue, no gray, no cool tones. Think: a page from a beautiful handmade Quran manuscript — the paper itself, not the ink. The image must be tile-friendly at the edges (left/right) and should have no focal point, watermark, or text.

---

## Screens

### Screen 1 — Onboarding: Welcome

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│         بِسْمِ اللَّهِ          │
│                                 │
│     The best time to start      │
│     was years ago.              │
│                                 │
│     The second best time        │
│     is now.                     │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│       ┌─────────────────┐       │
│       │     Begin       │       │
│       └─────────────────┘       │
│                                 │
└─────────────────────────────────┘
```

- Bismillah in elegant Arabic at the top of the content area
- The quote below — not a hadith attribution, not preachy, just honest and warm
- Single button: **"Begin"**
- Background: the warm dark texture, with the ambient glow slightly brighter than usual
- No app logo, no feature list, no marketing speak

---

### Screen 2 — Onboarding: How Would You Like to Start?

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│     How would you like          │
│     to calculate your           │
│     prayer debt?                │
│                                 │
│                                 │
│  ┌─────────────────────────┐    │
│  │                         │    │
│  │   Calculate for me      │    │
│  │                         │    │
│  │   I'll enter the year   │    │
│  │   I became mukallaf     │    │
│  │   and when I started    │    │
│  │   praying regularly     │    │
│  │                         │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │                         │    │
│  │   I already know        │    │
│  │   my numbers            │    │
│  │                         │    │
│  │   I'll enter the count  │    │
│  │   for each prayer       │    │
│  │   myself                │    │
│  │                         │    │
│  └─────────────────────────┘    │
│                                 │
└─────────────────────────────────┘
```

- Two large, tappable cards
- No pressure toward either option — both are equally valid

---

### Screen 3A — Onboarding: Auto Calculate

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│     When did you become         │
│     mukallaf?                   │
│                                 │
│     (approximately)             │
│                                 │
│  ┌─────────────────────────┐    │
│  │     Year:  2009         │    │
│  └─────────────────────────┘    │
│                                 │
│                                 │
│                                 │
│     When did you start          │
│     praying regularly?          │
│                                 │
│  ┌─────────────────────────┐    │
│  │     Year:  2024         │    │
│  └─────────────────────────┘    │
│                                 │
│     Small helper text:          │
│     "If you're not fully        │
│      regular yet, choose        │
│      this year"                 │
│                                 │
│       ┌─────────────────┐       │
│       │    Calculate    │       │
│       └─────────────────┘       │
│                                 │
└─────────────────────────────────┘
```

- **Year only** — not month/day. Asking for exact dates feels like a tax form. The debt is approximate anyway; false precision adds stress, not value.
- After tapping "Calculate", the app computes: `(endYear - startYear) * 365`, applied equally to each of the 5 prayer types.

---

### Screen 3B — Onboarding: Manual Entry

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│     Enter your debt for         │
│     each prayer                 │
│                                 │
│                                 │
│     Fajr        ┌────────┐     │
│     الفجر       │   365  │     │
│                 └────────┘     │
│                                 │
│     Dhuhr       ┌────────┐     │
│     الظهر       │   365  │     │
│                 └────────┘     │
│                                 │
│     Asr         ┌────────┐     │
│     العصر       │   365  │     │
│                 └────────┘     │
│                                 │
│     Maghrib     ┌────────┐     │
│     المغرب      │   365  │     │
│                 └────────┘     │
│                                 │
│     Isha        ┌────────┐     │
│     العشاء      │   365  │     │
│                 └────────┘     │
│                                 │
│       ┌─────────────────┐       │
│       │    Continue     │       │
│       └─────────────────┘       │
│                                 │
└─────────────────────────────────┘
```

- Clean number input fields, each with the prayer name in Arabic and transliteration
- Numeric keyboard only
- Numbers can differ per prayer (someone might have prayed Fajr less consistently than Isha)

---

### Screen 4 — Onboarding: The Reveal

This is the most important screen in the entire app. The user is about to see a potentially terrifying number. The design must reframe it.

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│     Your journey is             │
│     5,475 prayers               │
│                                 │
│                                 │
│     That's one prayer           │
│     at a time.                  │
│                                 │
│                                 │
│                                 │
│                                 │
│     إِنَّ مَعَ الْعُسْرِ يُسْرًا  │
│     With hardship comes ease    │
│     — Quran 94:6                │
│                                 │
│                                 │
│                                 │
│                                 │
│       ┌─────────────────┐       │
│       │  I'm ready      │       │
│       └─────────────────┘       │
│                                 │
└─────────────────────────────────┘
```

**Critical design decisions:**
- The word **"journey"** — not "debt", not "total", not "remaining"
- **"one prayer at a time"** — immediately scales the mountain down to a single step
- The Quranic ayah provides divine reassurance at exactly the right moment
- The number is shown in the **warm accent color**, not in red or white
- **"I'm ready"** — the button text is a personal declaration, not a generic "Continue"

**Animation:**
- The number fades in first, then "one prayer at a time" fades in 0.5s later, then the ayah 0.5s after that
- The "I'm ready" button fades in last, after all text has settled
- Screens transition with slow, gentle **crossfade** (~0.5s), not slide

---

### Screen 5 — Main Dashboard ("The Sanctuary")

This is where the user lives. 95% of their time is here. Every element must earn its place.

```
┌─────────────────────────────────┐
│                                 │
│         Your Journey            │
│                                 │
│      ╭───────────────╮          │
│      │               │          │
│      │     1,247      │          │
│      │   prayers offered       │
│      │               │          │
│      ╰───────────────╯          │
│        soft progress arc        │
│                                 │
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐    │
│  │  الفجر                  │    │
│  │  Fajr                   │    │
│  │  248 offered            │    │
│  │  ▓▓▓▓▓▓▓▓░░░░░  68%   │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │  الظهر                  │    │
│  │  Dhuhr                  │    │
│  │  251 offered            │    │
│  │  ▓▓▓▓▓▓▓▓░░░░░  69%   │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │  العصر                  │    │
│  │  Asr                    │    │
│  │  250 offered            │    │
│  │  ▓▓▓▓▓▓▓▓░░░░░  68%   │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │  المغرب                 │    │
│  │  Maghrib                │    │
│  │  249 offered            │    │
│  │  ▓▓▓▓▓▓▓▓░░░░░  68%   │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │  العشاء                 │    │
│  │  Isha                   │    │
│  │  249 offered            │    │
│  │  ▓▓▓▓▓▓▓▓░░░░░  68%   │    │
│  └─────────────────────────┘    │
│                                 │
│         Today: +3               │
└─────────────────────────────────┘
```

#### Journey Header
- Total prayers completed across all types — large, elegant, warm-colored typography
- Word choice: **"prayers offered"** — not "completed", not "done". *Offered* carries spiritual weight
- A **thin progress arc** underneath — warm gradient (`#C8956C` → `#E8C47C`). No percentage text on it — purely visual
- The arc subtly shifts gradient based on **time of day**:
  - Fajr time → cool dawn blues bleeding into gold
  - Midday → warm, bright amber
  - Maghrib → deep orange to purple
  - Night → deep teal to soft gold

#### Prayer Cards
- 5 cards stacked vertically, full-width, generous padding
- Each card is a **tappable surface** — the whole card is the button
- Card ordering follows Islamic prayer order (Fajr → Dhuhr → Asr → Maghrib → Isha). Always. Not sortable — this order is sacred.

**Card anatomy:**
- **Arabic name** in small, calligraphic style — authentic, not decorative
- **Transliterated name** below, clean sans-serif, medium weight
- **"248 offered"** — the hero number, warm accent color
- **Progress bar** — thin, rounded, subtle. Filled portion uses the warm gradient. Unfilled is barely visible (`#252320` in dark mode)
- **No "remaining" number visible by default**. Long-press or expand to see "117 remaining of 365" — opt-in, not forced

**The tap interaction:**
1. User taps the card
2. Number increments: 248 → 249
3. A soft **ripple** emanates from the tap point (accent color at 15% opacity)
4. A gentle **haptic** (`UIImpactFeedbackGenerator`, `.soft`)
5. The progress bar nudges forward
6. A small **"undo" link** fades in at the bottom of the card for 3 seconds, then disappears — protection against accidental taps, no confirmation dialog needed

#### Today's Quiet Counter
- Bottom center, muted small text: **"Today: +3"**
- Not a goal, not a streak — just an acknowledgment

#### What's NOT on this screen
- No hamburger menu
- No tab bar (settings via a small gear icon, top-right)
- No badges, no streaks, no gamification
- No ads, no premium upsell
- No social sharing
- No "daily goal" pressure

---

## Settings Screen

Accessed via a **small gear icon** in the top-right of the main dashboard. Uses the same warm background as the rest of the app — not the iOS default grouped table view gray.

### What belongs in Settings
1. **Edit prayer debt numbers** — adjust individual prayer counts without starting over
2. **Recalculate from dates** — re-run the onboarding calculation with different years
3. **iCloud sync status** — is my data synced? When was last sync?
4. **Reset everything** — nuclear option, buried and double-confirmed

### What does NOT belong
- Language picker (use system language)
- Theme toggle (follow system dark/light mode)
- Notification settings (no notifications — no pressure)
- Rate the app prompts
- Account/login (there is no account)
- Tutorial replay

### Layout

```
┌─────────────────────────────────┐
│                                 │
│  ←  Settings                    │
│                                 │
├─────────────────────────────────┤
│                                 │
│  PRAYER DEBTS                   │
│                                 │
│  ┌─────────────────────────┐    │
│  │  Fajr                   │    │
│  │  الفجر                  │    │
│  │                         │    │
│  │  Offered    248         │    │
│  │  Total debt 365    [Edit]│   │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │  Dhuhr                  │    │
│  │  الظهر                  │    │
│  │                         │    │
│  │  Offered    251         │    │
│  │  Total debt 365    [Edit]│   │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │  Asr                    │    │
│  │  العصر                  │    │
│  │                         │    │
│  │  Offered    250         │    │
│  │  Total debt 365    [Edit]│   │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │  Maghrib                │    │
│  │  المغرب                 │    │
│  │                         │    │
│  │  Offered    249         │    │
│  │  Total debt 365    [Edit]│   │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │  Isha                   │    │
│  │  العشاء                 │    │
│  │                         │    │
│  │  Offered    249         │    │
│  │  Total debt 365    [Edit]│   │
│  └─────────────────────────┘    │
│                                 │
│  Recalculate from dates →       │
│                                 │
├─────────────────────────────────┤
│                                 │
│  ICLOUD                         │
│                                 │
│  ┌─────────────────────────┐    │
│  │  ☁ Synced               │    │
│  │  Last sync: just now    │    │
│  └─────────────────────────┘    │
│                                 │
├─────────────────────────────────┤
│                                 │
│  ABOUT                          │
│                                 │
│  Version 1.0                    │
│  Made with ikhlas               │
│                                 │
├─────────────────────────────────┤
│                                 │
│                                 │
│  Reset all data                 │
│                                 │
│                                 │
└─────────────────────────────────┘
```

### Section Details

#### Prayer Debts Section
Each prayer shows two numbers:
- **Offered** (read-only) — how many they've completed
- **Total debt** (editable) — the original debt number

Tapping **Edit** opens an inline number editor — just the total debt field becomes editable with a numeric keyboard. Not a new screen, not a modal. Inline, fast, done.

**"Recalculate from dates"** — opens the same year-picker from onboarding (Screen 3A). When confirmed, it overwrites all 5 total debt values equally. Confirmation alert first: *"This will update your total debt for all prayers. Your completed count won't change."*

**Critical rule: editing total debt never touches the completed count.** If someone adjusts their debt from 365 down to 300, their 248 offered stays at 248. The progress percentage recalculates, the remaining count adjusts. No completed prayers are ever lost.

#### iCloud Section
Minimal — just two things:
- **Status**: Synced / Syncing... / Not synced
- **Last sync timestamp**: "just now" / "2 minutes ago" / "today at 14:32"

No toggle to enable/disable — iCloud sync is always on if the user is signed into iCloud. If they're not signed in, this section shows: *"Sign in to iCloud in Settings to sync your data across devices."*

No manual "sync now" button. It's automatic. The fewer controls, the less anxiety.

#### About Section
Two lines:
- **Version 1.0**
- **"Made with ikhlas"** — ikhlas (sincerity) is an Islamic concept meaning doing something purely for Allah's sake. A quiet signature. No company name, no website, no social links.

#### Reset All Data
- At the very bottom, in **muted red text** (`#C86A6A` in dark mode — not aggressive red, dusty and muted)
- Small font, no icon, no card around it — visually de-emphasized on purpose
- Two-step confirmation:
  1. *"This will permanently delete all your prayer data. This cannot be undone."* → Cancel / Continue
  2. *"Are you sure? All your progress will be lost."* → Cancel / **Delete Everything**
- The second "Delete Everything" button is in red
- Two confirmations because losing years of tracked prayers would be devastating

---

## History / Progress Screen

**Intentionally omitted for v1.** The main dashboard already serves as the progress view — the number going up *is* the history. A separate screen with calendars and stats adds complexity without serving the core emotional need. This isn't a fitness app where you analyze trends. The goal is simple: get the number to zero.

The prayer log data model supports adding history later if needed.

**App structure:**
```
Onboarding (4 screens, once) → Dashboard ← → Settings
```

---

## Technical Architecture

| Concern | Solution |
|---------|----------|
| Storage | SwiftData models |
| iCloud sync | SwiftData + CloudKit (already configured in entitlements) |
| No backend | Everything on-device, synced via iCloud |
| Architecture | Simple MVVM with SwiftUI |
| Min target | iOS 17+ (SwiftData requirement) |

---

## Key UX Principles

1. **Per-prayer logging** — tapping a card logs that specific prayer type, not a generic prayer
2. **One-tap per prayer type** — no confirmation dialogs, no drill-down needed. Undo appears briefly instead.
3. **Progress framing** — the biggest number is always what you've accomplished, never what remains
4. **Motivation without pressure** — progress bars and stats to encourage, never guilt
5. **Simplicity** — the app does one thing well
6. **Haptic feedback** on prayer completion for satisfying physical acknowledgment
