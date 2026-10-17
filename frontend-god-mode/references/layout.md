# Layout & Spatial Reference

Generic AI sites get caught here: centered hero + 3 equal feature cards + footer. Refuse this default. Layout is where you signal taste.

## The Layout Bans

- **The template hero: centered H1 + subtitle + 2 buttons.** Banned. Use split-screen, left-aligned content + right asset, asymmetric whitespace — or a centered composition only when it's deliberate (oversized type, an asset it frames, an asymmetric detail). Low-variance UIs (app screens, dashboards) don't need a hero at all.
- **3 equal cards in a row** as the features section. Use 2-col zig-zag, asymmetric bento, horizontal scroll, or `divide-y` rows.
- **Cards inside cards inside cards.** Pick the lowest depth that communicates the hierarchy.
- **`h-screen` / `100vh`.** Use `min-h-[100dvh]` for viewport-height sections, `h-dvh` for fixed app shells.
- **Flex math** like `w-[calc(33%-1rem)]`. Use CSS Grid: `grid-cols-3 gap-6`.
- **Containers wider than `max-w-[1400px]`** without intentional reason.
- **Default `gap-4`** on every grid. Vary spacing — tighter for data, looser for editorial.

## Hero Patterns That Don't Suck

### Split screen
- 50/50 or 60/40
- Text on left (left-aligned, NOT center), large image/video/visual on right
- Image bleeds to edge of viewport
- Subtle fade from image into bg color (top + bottom), darkening for dark mode, lightening for light

### Editorial / left-aligned
- Massive H1 left-aligned, breaking grid
- Body text starts at column 2 of a 4-col grid
- Image overlaps H1 by ~10% intentional collision

### Asymmetric whitespace
- H1 in upper-left
- Subtext in lower-right
- 60% of the canvas is empty
- Works for luxury, minimalist, gallery aesthetics

### Bento hero
- 60% main visual / 40% stacked metadata cards
- Mobile collapses metadata under main visual

### Diagonal flow
- Content + visuals zig-zag down the page on alternating sides
- Each row breaks the grid slightly
- Works for storytelling, longer-form pages

## Bento Grid (For Feature Sections)

The modern way to show "3-5 things" without 3 equal cards.

### Structure

Markup is shown as plain HTML (`className` in JSX).

```html
<div class="grid grid-cols-1 md:grid-cols-3 md:grid-rows-2 gap-4 max-w-7xl mx-auto p-6 md:p-8">
  <div class="md:col-span-2 md:row-span-2 rounded-[var(--radius)] bg-[var(--surface)] p-6 md:p-10 border border-[var(--border)]">
    <!-- Hero card — biggest -->
  </div>
  <div class="rounded-[var(--radius)] bg-[var(--surface)] p-6 md:p-8 border border-[var(--border)]">
    <!-- Top-right -->
  </div>
  <div class="rounded-[var(--radius)] bg-[var(--surface)] p-6 md:p-8 border border-[var(--border)]">
    <!-- Bottom-right -->
  </div>
</div>
```

`--radius` is the project's single card radius, chosen per aesthetic (sharp `0`, `14px`, soft `2.5rem`) and recorded in DESIGN.md.

```css
:root { --radius: 14px; }
```

### Bento principles

- **Asymmetric column / row spans** — never 1:1:1
- **Generous internal padding** — `p-6 md:p-8` for cards, `p-6 md:p-10` for the hero card
- **Subtle 1px border** in `var(--border)`
- **Diffusion shadow** — wide, low-opacity, tinted
- **One radius per project** (`var(--radius)`) — distinctive for the aesthetic, not the default `rounded-2xl`
- **Labels outside or inside** — gallery-style titles below the cards read editorial; titles inside read product. Pick one per project.

See `references/bento-engine.md` for the full Motion-Engine Bento spec.

## Spacing System

Use Tailwind's spacing scale, but vary purposefully:

| Density target  | Internal padding | Gap between blocks | Section gap     |
|-----------------|------------------|--------------------|-----------------|
| Airy (1-3)      | `p-12 md:p-16`   | `gap-8 md:gap-12`  | `py-24 md:py-32`|
| Daily (4-7)     | `p-6 md:p-8`     | `gap-4 md:gap-6`   | `py-16 md:py-24`|
| Cockpit (8-10)  | `p-3 md:p-4`     | `gap-2 md:gap-3`   | `py-8 md:py-12` |

## Containers

- **Page wrap:** `max-w-[1400px] mx-auto px-6 md:px-10` (default)
- **Reading width:** `max-w-prose` or `max-w-[65ch]` for body copy
- **Wide hero:** `w-full` (no max) for edge-to-edge visuals
- **Tight container:** `max-w-3xl mx-auto` for marketing copy

## Mobile Override (Critical)

Any asymmetric / high-variance layout MUST collapse cleanly below `md:`:

```html
<div class="grid grid-cols-1 md:grid-cols-3 md:grid-rows-2 gap-4 px-4 md:px-10 py-12 md:py-24">
```

- All `grid-cols-N` becomes `grid-cols-1`
- Padding drops to `px-4 py-8` minimum
- Display fonts scale down meaningfully (`text-4xl md:text-7xl`)
- No horizontal scroll allowed under any circumstances

## Dashboard Hardening (data dashboards — VISUAL_DENSITY ≥ 7)

Dense data UIs should not box every metric in a card.

### Use these instead of cards:

- **`divide-y divide-[var(--border)]`** between data rows
- **`border-t`** to separate sections
- **Negative space** with monospace numbers
- **Tabular columns** with `tabular-nums` and right-aligned numerics
- **Sparklines / trendlines inline** with the metric

### When to keep cards:

- Elevation has functional meaning (modal, popover, dropdown)
- Z-index communicates state (selected item)
- Visual grouping is genuinely needed

Otherwise: **delete the cards.**

## Z-Index Hygiene

Don't spam `z-50` and `z-10`. Use a system:

```css
:root {
  --z-base: 0;
  --z-sticky-nav: 30;
  --z-dropdown: 40;
  --z-overlay: 50;
  --z-modal: 60;
  --z-toast: 70;
  --z-tooltip: 80;
}
```

## Layout Checks

The shared layout items are in **Final Pre-Flight** (`anti-slop.md`). Also check:

- No page-level horizontal scroll on any viewport (intentional scroll rows and marquees inside `overflow-hidden` are fine)
- Spacing varies between sections (not `gap-4` everywhere)
- Z-index uses the token scale above, not random `z-50`s
