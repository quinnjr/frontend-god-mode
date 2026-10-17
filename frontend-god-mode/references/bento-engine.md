# Bento 2.0 — The Motion-Engine Paradigm

For marketing feature sections only — never application or analytics dashboards (those use Dashboard Hardening in `layout.md`). Animated, asymmetric, product-forward.

## When to Use This

- Modern SaaS landing page "feature row"
- Product page showcasing 4-6 capabilities
- A landing-page hero panel showcasing "what the product does"
- Anywhere the brief says: "show off the product features in a modern, animated way"

## The Aesthetic

**Use the project's tokens from `DESIGN.md` — never hardcode Zinc/Slate/Stone.** Token values live in `color.md`.

- **Background:** `var(--bg-subtle)`
- **Card surface:** `var(--surface)`
- **Card border:** `border border-[var(--border)]` — token, not literal `border-zinc-200`
- **Card radius:** `rounded-[var(--radius)]` — the project's one radius, chosen per aesthetic; not the default `rounded-2xl`
- **Diffusion shadow:** wide + low-opacity + tinted toward bg hue (see `color.md`). NOT `rgba(0,0,0,...)`.
- **Internal padding:** `p-6 md:p-8` for cards, `p-6 md:p-10` for the hero card
- **Title placement:** outside and below the cards (gallery-style, editorial) or inside (product) — one choice per project

## The Grid

Markup is shown as plain HTML. In JSX write `className`; in Vue, Svelte, Angular and Astro templates it's `class` as shown. Card contents are framework components (see `frameworks/<framework>.md`).

```html
<section class="bg-[var(--bg-subtle)] py-24">
  <div class="max-w-7xl mx-auto px-6 md:px-10">
    <!-- Eyebrow + heading -->
    <div class="mb-16 max-w-2xl">
      <p class="text-sm tracking-wide uppercase text-[var(--muted)] mb-3">What's inside</p>
      <h2 class="text-4xl md:text-5xl tracking-tighter">
        The motion engine, fully realized.
      </h2>
    </div>

    <!-- Bento grid — 3 cols, 2 rows, asymmetric spans -->
    <div class="grid grid-cols-1 md:grid-cols-3 md:grid-rows-2 gap-4">
      <article class="md:col-span-2 md:row-span-2 ..."><!-- Intelligent List --></article>
      <article class="..."><!-- Command Input --></article>
      <article class="..."><!-- Live Status --></article>
    </div>
  </div>
</section>
```

## The 5 Card Archetypes

At MOTION_INTENSITY ≥ 6, each card carries one perpetual micro-animation (below that, a staggered reveal is enough). These are the proven five:

### 1. The Intelligent List

A vertical stack of items with infinite auto-sorting. Items swap positions with a spring layout animation (FLIP), never a jump. Simulates an AI prioritizing tasks.

Implementation: React `layoutId`, Vue `<TransitionGroup>`, Svelte `animate:flip`, Angular and Astro measure-and-play FLIP. Full component in `frameworks/<framework>.md`.

### 2. The Command Input

Search/AI bar with multi-step typewriter cycling through realistic prompts. Includes blinking cursor and shimmer "processing" state.

Loops through 3-4 prompts:
- "Draft a launch announcement..."
- "Find churn signals from last quarter..."
- "Suggest pricing for the enterprise tier..."

Each prompt: 2.5s typing → 1s pause → shimmer for 0.8s → fade out → next prompt.

### 3. The Live Status

Scheduling / calendar interface with breathing status indicators. Notification badge pops in with overshoot spring (`damping: 12`), holds for 3s, vanishes.

Implementation: React `<AnimatePresence>` + spring, Vue `<Transition>` and Angular `animate.enter` with `--spring-overshoot`, Svelte `in:scale` with the `overshoot` easing, Astro `animate()` with `springOvershoot`. Full component in `frameworks/<framework>.md`.

### 4. The Wide Data Stream

Horizontal infinite carousel of metric cards. Seamless loop: render the metrics twice as two identical groups (trailing padding equal to the gap, so `-50%` lands exactly) and translate by `-50%` with linear timing. Hide the duplicate group from assistive tech. Pure CSS (`.marquee` in `motion.md`) — identical in every framework:

```html
<div class="overflow-hidden">
  <div class="marquee">
    <div class="flex gap-4 pr-4"><!-- metrics --></div>
    <div class="flex gap-4 pr-4" aria-hidden="true"><!-- the same metrics again --></div>
  </div>
</div>
```

### 5. The Contextual UI (Focus Mode)

A document/text view that animates a staggered highlight sweeping across a paragraph, followed by a floating action toolbar that floats in with micro-icons (highlight, comment, summarize).

Implementation: compose it from two patterns in your framework file — the staggered reveal (mark each highlighted span `data-reveal`, animate a `scaleX` underline from 0 to 1) and enter/leave (the toolbar, with `springSnappy`).

## Performance — Critical Rules

- **Isolate every animated card** so it never re-renders the layout: React `memo` + its own Client Component, Vue / Svelte its own component, Angular `OnPush` component, Astro custom element or CSS-only
- **Each card lives in its OWN tiny component** — never put 3 perpetual loops in one component
- **Dynamic lists animate exit and reorder** (React `<AnimatePresence mode="popLayout">`, Vue `<TransitionGroup>`, Svelte `out:` + `animate:flip`, Angular `animate.leave`, Astro custom-element FLIP)
- **No re-renders on the parent layout** when cards animate
- **Clear every interval on teardown** (React `useEffect` return, Vue `onBeforeUnmount`, Svelte `$effect` return, Angular `DestroyRef`, Astro `disconnectedCallback`)

## Spring Defaults for Bento

```ts
const springSmooth = { type: 'spring', stiffness: 100, damping: 20 };  // standard
const springSnappy = { type: 'spring', stiffness: 400, damping: 30 };  // taps
const springOvershoot = { type: 'spring', stiffness: 300, damping: 12 }; // notifications, badges
```

## Common Bento Mistakes

- Bad: all cards the same size (1:1:1) — must be asymmetric
- Bad: no motion in any card at MOTION_INTENSITY ≥ 6 — must be alive
- Bad: mixing inside and outside titles in one grid
- Bad: default `rounded-2xl` — use the project's `--radius`
- Bad: `shadow-md` — use a diffusion shadow
- Bad: padding under `p-6` — needs to breathe
- Bad: all 5 archetypes in one section — pick 3-4 max
- Bad: the same archetype on every card — vary them

## Mobile Behavior

Below `md:`, the bento grid collapses:
- All `col-span` becomes 1
- Stack vertically
- Disable horizontal carousels (use static grid)
- Reduce padding to `p-6`
- Keep perpetual motion ONLY on the most prominent card (performance)
