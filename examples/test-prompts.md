# Test Prompts

The skill is designed to pass these prompts without producing generic AI output. Run each in a fresh Claude Code session after installing the skill, then check the output against the pre-flight in `references/anti-slop.md`.

## 1. SaaS landing page

> "Build a SaaS landing page for a B2B observability product targeting platform engineers. Modern, slightly technical aesthetic."

**Expected behavior:**
- Picks aesthetic explicitly (e.g., "premium SaaS, Geist + Geist Mono, slate neutrals + electric blue accent")
- Asymmetric hero (split-screen or left-aligned)
- Bento 2.0 feature grid with perpetual motion
- Realistic data and names in any sample UI
- No Inter, no purple-to-blue gradient, no 3-card row

## 2. Analytics dashboard

> "Create a dashboard for analytics — revenue, churn, user activity. Should feel dense but readable."

**Expected behavior:**
- Picks `VISUAL_DENSITY > 7` automatically (cockpit mode)
- Drops cards in favor of `divide-y` rows + monospace numerics
- Tabular data in `font-mono`, right-aligned
- Tinted neutrals (Slate or Zinc), one accent
- Empty / loading / error states for charts
- No 3 equal stat cards in a row

## 3. Portfolio site

> "Make a portfolio site for a typographer who works with luxury brands."

**Expected behavior:**
- Picks editorial / luxury aesthetic
- PP Editorial New or GT Sectra display + Söhne body
- Stone or warm neutral palette
- Asymmetric whitespace, generous gaps
- Italic serif eyebrows above sections
- Custom rounded radii (likely sharp `rounded-none` or `rounded-[2px]` — editorial feel)
- Scroll-triggered reveals, kinetic marquee for project list
- No generic 3-column project grid

## 4. Add animations

> "Add animations to this hero component" (with a static React component pasted in)

**Expected behavior:**
- Identifies the component is server-rendered, isolates motion to a leaf Client Component with `'use client'`
- Spring physics on entry (no linear easing)
- Staggered children for any list elements
- Magnetic / tilt on CTA if `MOTION_INTENSITY > 5`
- `useMotionValue` for hover position (never `useState`)
- Reduced-motion respected
- Cleanup in any `useEffect`

## 5. Music festival poster

> "Design a poster for a music festival in Mexico City, 1970s feel."

**Expected behavior:**
- Picks bold, retro aesthetic (e.g., Cooper BT or Bagel Fat One display)
- Warm, saturated palette (terracotta, mustard, deep rose) — but ONE accent dominant
- Asymmetric, grid-breaking layout
- Texture overlay (grain / noise via `pointer-events-none` fixed layer)
- Strong type hierarchy with massive, character-driven display
- Placeholder lineup with realistic but messy names (no "John Doe")
- No clean SaaS card grid — this is a poster, not a feature row

## 6. Angular SaaS pricing page

> "Add a pricing page to this Angular app — three tiers, monthly/annual toggle." (run inside an Angular 20.2+ project)

**Expected behavior:**
- Detects `@angular/core`, loads `frameworks/angular.md`
- Standalone `OnPush` components, signals for the billing toggle, `@for` with a stable `track`
- Tiers are NOT three equal cards: one tier emphasized (larger span or offset), or a comparison table with `divide-y`
- Price change animates via `animate.enter` / `animate.leave` with `--spring-*` CSS (no new `@angular/animations`)
- No `window` / `matchMedia` access outside `afterNextRender`
- Icons via `ng-icon` (Phosphor), fonts via Fontsource — no Google Fonts `<link>`
- Install commands use the project's package manager

## 7. SvelteKit portfolio with reorderable work grid

> "Build a portfolio home page in this SvelteKit project with a filterable project grid." (run inside a Svelte 5 project)

**Expected behavior:**
- Detects `@sveltejs/kit`, loads `frameworks/svelte.md`
- Runes (`$state`, `$derived`, `$props`), no `export let`
- Filtered grid reorders with `animate:flip` on a keyed `{#each}`; removed items leave via `out:` with spring easing
- Page-load reveal uses `{@attach reveal}` + `data-reveal`, not `in:fly`
- Every transition duration gated on `prefersReducedMotion.current`
- Tailwind v4 via `@tailwindcss/vite`, not PostCSS
- No React dependencies pulled in for React Bits / 21st.dev effects — ported natively

## 8. Nuxt dashboard with live activity feed

> "Add an activity feed panel to this Nuxt dashboard — new events slide in at the top." (run inside a Nuxt 3+ project)

**Expected behavior:**
- Detects `nuxt`, loads `frameworks/vue.md`
- `<script setup lang="ts">`, Composition API, no Options API
- Feed uses `<TransitionGroup>` with `--spring-*` CSS enter/move classes, keyed by event id (not index)
- Rows separated with `divide-y`, not boxed in cards (dashboard hardening)
- Polling/timer started in `onMounted`, cleared in `onBeforeUnmount`; no `window` access at `<script setup>` top level
- Icons via `@phosphor-icons/vue`

## 9. Astro marketing site with a magnetic CTA

> "Build the landing page for this Astro site — bento feature row and a magnetic sign-up button." (run inside an Astro 5+ project with no UI framework integration)

**Expected behavior:**
- Detects `astro`, loads `frameworks/astro.md`
- Page is `.astro` components with zero client JS except the custom elements it needs
- Magnetic CTA and staggered reveal are custom elements (`connectedCallback` / `disconnectedCallback`), not a newly added React/Svelte integration
- Marquee and perpetual loops are pure CSS
- Icons via `astro-icon` with `@iconify-json/ph`; Tailwind v4 via `@tailwindcss/vite`

## How to verify pass/fail

After Claude finishes, ask: **"run the pre-flight checklist from anti-slop.md against what you just built."**

Claude should produce a checklist with each item ticked or flagged. Any unticked item is a fail.

Common failure modes to catch:
- Snuck in Inter via shadcn defaults
- Used `grid grid-cols-3` equal cards for features
- Used `h-screen` instead of `min-h-[100dvh]`
- Used "Acme" or "John Doe" in sample data
- Forgot empty / loading state on data UI
- Linear easing somewhere in CSS transitions
- Used the wrong framework's idioms (JSX hooks in Svelte, `useState`-style signals for pointer position in Angular, a hydrated island for CSS-only motion in Astro)
