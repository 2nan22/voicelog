# Design System: Intelligent Serenity

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Digital Sanctuary."** Unlike traditional productivity apps that feel rigid and transactional, this system treats the interface as a living, breathing editorial space. It is designed to facilitate reflection, utilizing the quiet confidence of Korean minimalist aesthetics—inspired by the likes of Toss and KakaoWorks—to create a sense of professional calm.

We break the "template" look through **Intentional Asymmetry** and **Tonal Depth**. By moving away from centered, boxed-in layouts, we use breathing room (whitespace) as a functional element that guides the eye. Large typography scales and overlapping "glass" surfaces create a premium, curated feel that honors the intimacy of a personal voice diary.

---

## 2. Colors
Our palette is rooted in a sophisticated interplay of light and depth. The primary Indigo (`#0d46d1`) acts as a tether of intelligence and trust against a serene, multi-layered neutral background.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section off content. Traditional dividers are "visual noise." Boundaries must be defined solely through:
*   **Background Color Shifts:** Placing a `surface-container-low` (`#f0f4f8`) card on a `surface` (`#f6fafe`) background.
*   **Soft Transitions:** Using negative space to imply a break in content.

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked sheets. 
*   **Base:** `surface` (`#f6fafe`)
*   **Sub-sections:** `surface-container-low` (`#f0f4f8`)
*   **Primary Interaction Cards:** `surface-container-lowest` (`#ffffff`) 

This nesting creates "Tonal Elevation." An inner card should always feel physically closer to the user by being lighter and "purer" in color than its parent container.

### The "Glass & Gradient" Rule
To elevate the app beyond a standard flat UI:
*   **Glassmorphism:** Floating elements (like the Bottom Navigation or Recording Modals) should use semi-transparent `surface` colors with a `backdrop-blur` (20px-40px). 
*   **Signature Textures:** Main CTAs (Primary Buttons) should utilize a subtle linear gradient from `primary` (`#0d46d1`) to `primary-container` (`#3761ea`) at a 135° angle to provide a "vivid" soul that feels high-end.

---

## 3. Typography
We utilize a dual-font strategy to balance character and readability.
*   **Display & Headlines:** **Manrope.** Its geometric yet warm curves provide a modern, "tech-forward" voice.
*   **Body & Titles:** **Inter** (or **Pretendard** for optimized Korean rendering). These are chosen for their exceptional legibility in dense text blocks.

The hierarchy is intentionally dramatic. A `display-lg` headline at 3.5rem should feel like a bold editorial statement, while `body-md` remains humble and functional. This contrast ensures that the "AI" aspect feels authoritative while the "Diary" aspect feels personal.

---

## 4. Elevation & Depth
Depth in this system is a result of light physics, not artificial outlines.

*   **Tonal Layering:** Avoid shadows for static cards. Instead, use the `surface-container` tiers to create a soft, natural lift.
*   **Ambient Shadows:** For interactive, floating elements (e.g., the Voice Recording button), use **Extra-Diffused Shadows**:
    *   *Blur:* 32px to 64px.
    *   *Opacity:* 4% to 8%.
    *   *Color:* Use a tinted version of `on-surface` (`#171c1f`) rather than pure black to keep the "serenity" intact.
*   **The "Ghost Border" Fallback:** If high-contrast accessibility is required, use the `outline-variant` (`#c3c6d7`) at **15% opacity**. Never use 100% opaque borders.

---

## 5. Components

### Buttons
*   **Primary:** High-radius (`xl`: 3rem), Indigo gradient, `on-primary` text. Use for "Save" or "Start Recording."
*   **Secondary:** `surface-container-highest` background with `primary` text. No border.
*   **Floating Action (Voice):** Large circular button with Glassmorphism and a pulse animation to signify AI listening.

### Cards & Lists
*   **Diary Entry Card:** Use `surface-container-lowest` (#ffffff). Forbid divider lines between list items. Use 24px of vertical spacing (`md`) to separate logs.
*   **Emotion Chips:** Rounded-full (`9999px`). 
    *   *Joy:* Soft Yellow (Text on `primary-fixed`).
    *   *Calm:* Muted Green (`tertiary-container`).
    *   *Sad:* Soft Blue (`secondary-fixed`).
    *   *Angry:* Faded Red (`error-container`).

### Input Fields
*   **Text Areas:** Subtle `surface-container-low` background. When focused, the background shifts to `surface-container-lowest` with a "Ghost Border" of 20% Indigo.

### Specialized AI Component: The "Breath" Visualizer
A fluid, morphing SVG wave using `primary` and `secondary` tints. This replaces the standard progress bar, representing the AI's "Intelligent Serenity" as it processes the user's voice.

---

## 6. Do's and Don'ts

### Do
*   **DO** use the `xl` (3rem) corner radius for main containers to evoke a "friendly, pebble-like" feel.
*   **DO** leave at least 24pt of padding on the sides of the screen; the interface should never feel crowded.
*   **DO** use "Pretendard" for all Korean text to ensure proper kerning and weight distribution.

### Don't
*   **DON'T** use 1px solid black or grey borders. This immediately destroys the "premium" aesthetic.
*   **DON'T** use standard Material Design "Drop Shadows." They are too heavy for a sanctuary-themed app.
*   **DON'T** center-align long blocks of text. Keep editorial layouts left-aligned or use intentional asymmetry for a more high-end feel.