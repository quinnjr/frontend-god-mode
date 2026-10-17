# Accessibility Reference

Production-grade work means accessible work. This isn't optional. Generic AI output skips a11y entirely — don't.

## The Hard Floor

- **WCAG 2.2 AA contrast ratios:**
  - Body text on background: **≥ 4.5:1**
  - Large text (≥ 18pt or 14pt bold): **≥ 3:1**
  - UI components, focus indicators, graphical elements: **≥ 3:1**
- **All interactive elements** must be keyboard-reachable in a logical tab order.
- **Focus rings** must be visible. Never `outline: none` without a replacement.
- **Reduced motion** must be respected (see motion.md).

## Contrast Calibration

When using OKLCH neutrals:

Computed ratios (they hold for any neutral hue H):

| Pair                                          | Contrast | Verdict                     |
|-----------------------------------------------|----------|-----------------------------|
| `oklch(0.15 0.01 H)` on `oklch(0.99 0.005 H)` | 19.1:1   | Pass — AAA                  |
| `oklch(0.52 0.01 H)` on `oklch(0.965 0.005 H)` | 5.0:1   | Pass — AA body, even on a subtle surface |
| `oklch(0.55 0.01 H)` on `oklch(0.99 0.005 H)` | 4.7:1    | Pass — AA body on the page bg only |
| `oklch(0.65 0.01 H)` on `oklch(0.99 0.005 H)` | 3.1:1    | Large text only             |
| `oklch(0.75 0.01 H)` on `oklch(0.99 0.005 H)` | 2.2:1    | Fail                        |
| `oklch(0.70 0.01 H)` on `oklch(0.12 0.005 H)` | 7.6:1    | Pass — dark-mode muted text |

Rule of thumb for neutral text: on light backgrounds keep L ≤ 0.52; on dark (L ≈ 0.12–0.18) keep L ≥ 0.70. Saturated colors vary by hue — compute them.

**Test with real values:** use https://oklch.com/ or https://www.tpgi.com/color-contrast-checker/ before shipping.

## Focus Rings (Critical)

A focus ring must reach **≥ 3:1** against the colors around it, so it has to be opaque. Point `--ring` at the accent (its light/dark values in `color.md` pass):

```css
:root {
  --ring: var(--accent);
}

*:focus-visible {
  outline: 2px solid var(--ring);
  outline-offset: 2px;
}
```

shadcn (and its ports shadcn-vue, shadcn-svelte, Spartan) draws its own ring: `focus-visible:ring-ring/50 ring-[3px]`, a box-shadow driven by `--ring` at 50% opacity, with a neutral-gray `--ring` by default. That is usually under 3:1. Either set `--ring` to the opaque accent **and** change `ring-ring/50` to `ring-ring` in the copied components, or remove their ring classes and use the outline above. Never both — you'll get two rings.

Use `:focus-visible` (not `:focus`) so mouse clicks don't show rings, but keyboard tab does.

Don't animate the ring. It should appear instantly when focus moves.

## Keyboard Navigation Checklist

- [ ] Every clickable element is `<button>`, `<a>`, or has `role="button"` + `tabIndex={0}` + key handler
- [ ] Tab order matches visual order
- [ ] Modal traps focus inside until dismissed (native `<dialog>` with `showModal()`, or the primitives library: Radix, Reka UI, Bits UI, Spartan / Angular CDK)
- [ ] Esc closes modals, popovers, dropdowns
- [ ] Arrow keys navigate within radio groups, menus, tabs
- [ ] No keyboard trap (you can always Tab out)

## Semantic HTML

Don't use `<div>` for everything.

| Element        | Use for                                      |
|----------------|----------------------------------------------|
| `<button>`     | Triggers actions in-page                     |
| `<a href>`     | Navigation, opens new view/page              |
| `<nav>`        | Site navigation                              |
| `<main>`       | Primary page content (one per page)          |
| `<article>`    | Self-contained piece (blog post, product)    |
| `<section>`    | Thematic grouping                            |
| `<aside>`      | Tangential content (sidebar)                 |
| `<header>`     | Page or section intro                        |
| `<footer>`     | Page or section outro                        |
| `<h1>`–`<h6>`  | Sequential heading hierarchy (no skipping)   |
| `<dialog>`     | Modals (or Radix / Bits UI / Spartan dialog with proper roles) |

## Screen Reader Hygiene

- **Images:** `alt` text describes purpose, not appearance. Decorative images get `alt=""`.
- **Icons in buttons:** wrap in `<span class="sr-only">Add to cart</span>` or use `aria-label`.
- **Form inputs:** ALWAYS associate with `<label for>` (`htmlFor` in JSX) or `aria-labelledby`. Placeholders are NOT labels.
- **Loading states:** `aria-busy="true"` + `aria-live="polite"` on the parent.
- **Toasts / notifications:** `role="status"` + `aria-live="polite"` for non-urgent, `role="alert"` for urgent.

## Form Accessibility

- Label above input (mandatory)
- Helper text under input, linked via `aria-describedby`
- Error text under input, linked via `aria-describedby` AND `aria-invalid="true"`
- Required fields use the HTML `required` attribute on native inputs (`aria-required="true"` only on custom ARIA widgets), plus a visible text indicator — not just color
- Don't use color alone to indicate state — pair with icon or text

## Touch Targets

- Mobile interactive elements: **44×44px** tap area — this skill's standard (WCAG 2.2 AAA 2.5.5 / Apple HIG). The WCAG 2.2 AA floor (2.5.8) is 24×24px; never go below it anywhere.
- Pad small buttons with extra `padding` to reach 44px without growing visible size
- Spacing between adjacent tap targets: **at least 8px**

## Reduced Motion

Already covered in motion.md, but double-check that JS-driven motion checks the preference:

- **React:** `useReducedMotion()` from `motion/react`
- **Vue / Angular / Astro:** `prefersReducedMotion()` from the shared motion helpers
- **Svelte:** `prefersReducedMotion.current` from `svelte/motion`

Disable or shorten animations when it's true.

## Common AI Accessibility Failures

- Bad: `<div onClick>` instead of `<button>`
- Bad: Placeholder used as the only label
- Bad: Skipped heading levels (`<h1>` then `<h3>`, no `<h2>`)
- Bad: `outline: none` on focus, no replacement
- Bad: Color-only error indication (red text, no icon, no label)
- Bad: `<a>` tags with no `href` (or `href="#"`)
- Bad: Modal that doesn't trap focus
- Bad: Animations that don't respect `prefers-reduced-motion`
- Bad: Insufficient contrast on muted text (`text-gray-400` on white ≈ 2.5:1 — fails even large text)
- Bad: Touch targets under 44px on mobile

## Quick Audit Tools

Recommend the user run:

- **axe DevTools** browser extension — flags WCAG violations
- **Lighthouse** in Chrome DevTools — Accessibility score
- **WAVE** browser extension — visual feedback layer

## Accessibility Checks

The core items are in **Final Pre-Flight** (`anti-slop.md`). Also check:

- All interactive elements keyboard-reachable; modals trap focus and Esc dismisses
- Errors aren't color-only
- Decorative images have `alt=""`, meaningful images have descriptive alt
