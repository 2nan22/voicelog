# Design System Specification: High-End Digital Editorial

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Curated Breath."** 

Moving away from the cluttered density of traditional utility apps, this system draws inspiration from the premium Korean "Soft Minimalist" movement (seen in pioneers like Toss and Kakao). We treat the screen not as a container to be filled, but as a digital canvas that breathes. We reject "standard" layouts in favor of high-contrast editorial hierarchy, intentional asymmetry, and tactile depth. 

The goal is an **Emotional Experience**: every interaction should feel like turning the page of a high-end magazine—smooth, intentional, and expensive. We achieve this by prioritizing white space as a functional element and using "Vivid Blue" not just as a color, but as a beacon of trust and momentum.

---

## 2. Colors: Tonal Depth over Borders
Our palette moves beyond simple hex codes into a logic of **Atmospheric Layering**.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section content. Boundaries must be defined solely through background color shifts. For example, a `surface-container-low` section sitting on a `background` provides all the definition a user needs. Lines create visual noise; tonal shifts create "soul."

### Signature Palette
*   **Primary (`#0059b9` / `#3182F6`):** Our "Vivid Blue." Use this for high-impact moments.
*   **The "Glass & Gradient" Rule:** To avoid a flat, "templated" look, main CTAs and hero backgrounds should utilize a subtle linear gradient from `primary` to `primary_container`. This adds a 3D "sheen" that feels premium.
*   **Glassmorphism:** For floating elements (Modals, Navigation Bars), use `surface_container_lowest` at 80% opacity with a 20px-32px `backdrop-blur`.

### Surface Hierarchy (Light Mode Example)
*   **Base Layer:** `surface` (#f8f9fb)
*   **Secondary Content Area:** `surface_container_low` (#f2f4f6)
*   **Interactive Cards:** `surface_container_lowest` (#ffffff)
*   **Deep Hierarchy (Nested):** `surface_container_high` (#e6e8ea)

---

## 3. Typography: Editorial Authority
We utilize **Manrope** for its geometric precision and modern "Korean-tech" aesthetic. The hierarchy is extreme to ensure immediate scanability.

*   **Display & Headlines:** Use `display-lg` (3.5rem) and `headline-lg` (2rem) with negative letter-spacing (-0.02em) to create a "tight," authoritative editorial feel. Headlines should be bold and unapologetic.
*   **Body Text:** `body-lg` (1rem) is the workhorse. Maintain a generous line-height (1.6) to ensure the "Clean & Simple" vibe isn't compromised by dense text blocks.
*   **Labels:** Use `label-md` for metadata. These should be tracked out (+0.05em) and set in `on_surface_variant` to recede visually, allowing the headlines to shine.

---

## 4. Elevation & Depth: Tonal Layering
We do not use structural lines. We use physics.

*   **The Layering Principle:** Depth is achieved by "stacking" tiers. A `surface_container_lowest` card (White) placed on a `surface_container_low` background (#F2F4F6) creates a natural lift.
*   **Ambient Shadows:** If an element must float (e.g., a FAB or a sticky header), use a "Whisper Shadow":
    *   *Y: 12px, Blur: 24px, Color: `on_surface` at 6% opacity.*
    *   The shadow should feel like a soft glow, not a dark smudge.
*   **The "Ghost Border" Fallback:** In rare cases where accessibility requires a container edge (like high-contrast dark mode), use `outline_variant` at **15% opacity**. Never 100%.

---

## 5. Components: Softness & Intention

### Buttons
*   **Primary:** `primary` fill, `on_primary` text. Border radius: `md` (1.5rem). Apply a subtle inner-top white glow (1px) to simulate a physical edge.
*   **Secondary:** `surface_container_high` fill with `primary` text. No border.

### Input Fields
*   **Style:** Background-filled using `surface_container_low`. 
*   **Shape:** `md` (1.5rem) radius.
*   **Active State:** Transition to a "Ghost Border" of `primary` at 40% opacity. Forbid the "standard" 2px solid stroke.

### Cards & Lists
*   **The "No-Divider" Rule:** Forbid the use of horizontal rules (`<hr>`). Separate list items using `1.5rem` of vertical white space or by placing each item in a unique `surface_container_lowest` tile with a `DEFAULT` (1rem) radius.

### Signature Component: The "Glass Header"
*   A top navigation bar using 70% `surface` opacity with a heavy blur. It allows content to "melt" into the status bar as the user scrolls, creating an "Emotional Experience" of continuity.

---

## 6. Do’s and Don’ts

### Do
*   **Do** use asymmetrical padding (e.g., more padding at the top of a card than the bottom) to create an editorial look.
*   **Do** use `primary_fixed_dim` for subtle background accents behind iconography.
*   **Do** favor `xl` (3rem) corner radius for large hero images to emphasize the "Friendly & Professional" vibe.

### Don’t
*   **Don’t** use black (`#000000`). Use `on_surface` (#191c1e) for text to maintain softness.
*   **Don’t** use standard "Material" shadows. If it looks like a default shadow, it’s too dark.
*   **Don’t** crowd the edges. If a component feels "okay," add another 8px of padding. Premium is defined by the space you *don't* use.