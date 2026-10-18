# Astro Implementation

Load this when `package.json` has `astro`. The design rules come from the shared references; this file is *how* to implement them in `.astro` components. Targets Astro 5+. Check the installed version before using any API below.

## Rendering Model

- **`.astro` components render to HTML with zero JS by default.** Keep it that way: everything static (layout, typography, bento shells, marquees, perpetual CSS loops) is plain `.astro` + Tailwind + CSS.
- **Interactive motion in `.astro` uses custom elements.** A `<script>` in an `.astro` component is bundled and runs once per page. Wrap behavior in a custom element so `connectedCallback` / `disconnectedCallback` give you a real mount/teardown lifecycle. That lifecycle also survives `<ClientRouter />` page swaps, where plain top-level scripts don't re-run.
- **Islands follow their own framework guide.** A component from an integration (`@astrojs/react`, `@astrojs/svelte`, `@astrojs/vue`) is an island: load `frameworks/react.md` / `svelte.md` / `vue.md` for its code. Pick the hydration directive deliberately: `client:visible` for below-the-fold motion, `client:idle` for non-urgent widgets, `client:load` only for above-the-fold interaction the user touches immediately. Never hydrate a component that only does CSS motion.
- **Choose custom element vs island by state:** pointer/scroll/reveal effects and DOM-only FLIP → custom element in `.astro`. Real component state (forms, filters with derived data, data-bound lists) → an island in the project's existing integration. Don't add a UI framework only to animate something.

## Motion Library

- **Spring physics, stagger, scroll, pointer, FLIP:** the vanilla `motion` package via the shared helpers in `motion.md` (put them in `src/lib/motion.ts`), driven from custom elements.
- **Enter/leave:** `animate()` with the spring presets, then toggle `hidden` when the exit finishes.
- **Perpetual loops:** CSS keyframes from `motion.md`. Zero JS.
- **Page transitions and shared elements across pages:** Astro view transitions (`<ClientRouter />` in the layout `<head>`, `transition:name` on matching elements). This is Astro's equivalent of React's `layoutId` across routes. Astro disables view-transition animations under `prefers-reduced-motion`.

### Custom element pattern

Give every custom element `class="block"` (or `contents`, or a grid class): custom elements are `display: inline` by default.

### Staggered reveal

```astro
---
// src/components/RevealGroup.astro
---
<reveal-group class="block">
  <slot />
</reveal-group>

<script>
  import { reveal } from '../lib/motion';

  class RevealGroup extends HTMLElement {
    #teardown?: () => void;
    connectedCallback() { this.#teardown = reveal(this); }
    disconnectedCallback() { this.#teardown?.(); }
  }
  customElements.define('reveal-group', RevealGroup);
</script>
```

```astro
<RevealGroup>
  <div class="grid gap-4">
    {items.map((item) => <div data-reveal>{item.title}</div>)}
  </div>
</RevealGroup>
```

Add the `[data-reveal]` CSS gate from `motion.md` to the global stylesheet.

### Magnetic button

```astro
---
// src/components/MagneticButton.astro
---
<magnetic-button class="inline-block">
  <slot />
</magnetic-button>

<script>
  import { magnetic } from '../lib/motion';

  class MagneticButton extends HTMLElement {
    #teardown?: () => void;
    connectedCallback() {
      const target = this.querySelector<HTMLElement>('button, a');
      if (target) this.#teardown = magnetic(target);
    }
    disconnectedCallback() { this.#teardown?.(); }
  }
  customElements.define('magnetic-button', MagneticButton);
</script>
```

```astro
<MagneticButton><button type="button" class="...">Book a tasting</button></MagneticButton>
```

### Tactile feedback

CSS `:active` from `motion.md`. Nothing Astro-specific.

### Enter / leave (overshoot badge)

```ts
import { animate } from 'motion';
import { prefersReducedMotion, springOvershoot } from '../lib/motion';

export async function showBadge(el: HTMLElement) {
  el.hidden = false;
  if (prefersReducedMotion()) return;
  await animate(el, { scale: [0, 1], opacity: [0, 1] }, springOvershoot);
}

export async function hideBadge(el: HTMLElement) {
  if (!prefersReducedMotion()) await animate(el, { scale: 0, opacity: 0 }, { duration: 0.2, ease: [0.16, 1, 0.3, 1] });
  el.hidden = true;
}
```

### Layout transitions (FLIP reorder)

No framework re-renders the list, so the custom element moves the DOM nodes itself: measure, reorder, play the inverse transform.

```astro
---
// src/components/IntelligentList.astro
const tasks = [
  { id: 1, label: 'Draft Q3 launch plan', priority: 'high' },
  { id: 2, label: 'Review onboarding flow', priority: 'med' },
  { id: 3, label: 'Sync with marketing', priority: 'low' },
  { id: 4, label: 'Update docs site', priority: 'med' },
];
---
<intelligent-list class="block">
  <ul class="space-y-3">
    {tasks.map((task) => (
      <li class="rounded-2xl bg-[var(--bg-subtle)] p-4 flex items-center gap-3">
        <span class="w-2 h-2 rounded-full bg-[var(--accent)]"></span>
        <span class="text-sm">{task.label}</span>
      </li>
    ))}
  </ul>
</intelligent-list>

<script>
  import { animate } from 'motion';
  import { prefersReducedMotion, springSmooth } from '../lib/motion';

  class IntelligentList extends HTMLElement {
    #timer?: ReturnType<typeof setInterval>;

    connectedCallback() {
      if (prefersReducedMotion()) return;
      this.#timer = setInterval(() => this.#shuffle(), 3000);
    }

    disconnectedCallback() { clearInterval(this.#timer); }

    #shuffle() {
      const list = this.querySelector('ul')!;
      const rows = [...list.children] as HTMLElement[];
      const first = new Map(rows.map((el) => [el, el.getBoundingClientRect().top]));
      rows.sort(() => Math.random() - 0.5).forEach((el) => list.append(el));
      for (const el of rows) {
        const dy = first.get(el)! - el.getBoundingClientRect().top;
        if (dy) animate(el, { y: [dy, 0] }, springSmooth);
      }
    }
  }
  customElements.define('intelligent-list', IntelligentList);
</script>
```

### Scroll-driven

```ts
import { animate, scroll } from 'motion';

class ParallaxLayer extends HTMLElement {
  #teardown?: () => void;
  connectedCallback() {
    this.#teardown = scroll(animate(this, { y: [0, -100] }), { target: this, offset: ['start end', 'end start'] });
  }
  disconnectedCallback() { this.#teardown?.(); }
}
customElements.define('parallax-layer', ParallaxLayer);
```

### GSAP isolation

Same custom element shape: create `gsap.context(() => { /* ... */ }, this)` in `connectedCallback`, call `ctx.revert()` in `disconnectedCallback`.

### Reduced motion

CSS guard from `motion.md` in the global stylesheet, plus `prefersReducedMotion()` before starting any JS loop. The shared helpers already check it.

## Bento Card Archetypes

- **Intelligent List:** `IntelligentList.astro` above.
- **Live Status:** a custom element that calls `showBadge` / `hideBadge` from an interval started in `connectedCallback` and cleared in `disconnectedCallback`.
- **Wide Data Stream:** CSS `.marquee` from `motion.md` with two identical groups — `<div class="flex gap-4 pr-4">{metrics.map((m) => <MetricCard {...m} />)}</div>` and the same group again with `aria-hidden="true"`. No JS.
- **Command Input typewriter:** a custom element that writes `textContent` from a timer, cleared in `disconnectedCallback`.
- **Contextual UI:** a `<reveal-group>` over the highlight spans plus a custom element that shows the toolbar with `animate()` and `springSnappy`.

## Theme Script

The pre-paint theme script from `color.md` (Theme Follows Content) goes inline in the document `<head>`, before any stylesheet. Never load it as a module or from a component — by then the page has already painted in the wrong mode.

Put it in the base layout's `<head>` with `is:inline` so Astro doesn't bundle and defer it. With `<ClientRouter />`, each navigation swaps in the new page's `<html>` attributes and drops `data-theme`, so re-apply it on `astro:after-swap`:

```astro
<!-- src/layouts/Base.astro -->
<head>
  <meta name="color-scheme" content="light dark" />
  <script is:inline>
    function applyTheme() {
      try {
        const t = localStorage.getItem('theme');
        if (t === 'light' || t === 'dark') document.documentElement.dataset.theme = t;
      } catch {}
    }
    applyTheme();
    document.addEventListener('astro:after-swap', applyTheme);
  </script>
</head>
```

## Fonts

Self-host with Fontsource. The example uses Geist — install and import the pairing you actually chose from `typography.md` (Fontsource package names are `@fontsource-variable/<family>` for variable fonts, `@fontsource/<family>` otherwise). Fontshare and paid fonts: self-host the woff2 with `@font-face`.

```bash
<pm> add @fontsource-variable/geist @fontsource-variable/geist-mono
```

```css
/* src/styles/global.css, imported once in the base layout */
@import 'tailwindcss';
@import '@fontsource-variable/geist';
@import '@fontsource-variable/geist-mono';

@theme {
  --font-sans: 'Geist Variable', sans-serif;
  --font-mono: 'Geist Mono Variable', monospace;
}
```

## Icons

`astro-icon` with the Phosphor (or Radix) Iconify set. Icons render as inline SVG at build time, with no JS:

```bash
<pm> add astro-icon @iconify-json/ph
```

```astro
---
import { Icon } from 'astro-icon/components';
---
<Icon name="ph:arrow-right" size={20} aria-hidden="true" />
```

Add `icon()` from `astro-icon` to `integrations` in `astro.config.mjs`.

## Component Libraries

- **Static UI** (cards, heroes, nav, footers, pricing): build in `.astro` with Tailwind. shadcn's markup and Tailwind classes port directly into `.astro` for anything that doesn't need behavior.
- **Simple overlays:** native `<dialog>` and the Popover API (`popover` / `popovertarget`) before reaching for an island. Give them spring enter/exit with `--spring-*` CSS.
- **Complex primitives** (combobox, data table, date picker): an island using the project's integration and its library (shadcn/ui, shadcn-svelte, shadcn-vue).
- **React Bits / 21st.dev** — React output. With `@astrojs/react` installed they can be islands as-is; otherwise port the effect to a custom element or to the project's integration.

## Tailwind

Tailwind v4 in Astro uses the Vite plugin, not PostCSS:

```js
// astro.config.mjs
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({ vite: { plugins: [tailwindcss()] } });
```

**Tailwind v3 projects:** keep the existing `tailwind.config.*` + PostCSS setup; put tokens in `theme.extend` instead of `@theme` (`colors: { accent: 'var(--accent)' }`). For opacity modifiers, store the channels (`--accent: 0.52 0.17 258`) and map `accent: 'oklch(var(--accent) / <alpha-value>)'`.

## Setup Install

```bash
<pm> add motion astro-icon @iconify-json/ph
```

Fonts are installed separately, after the pairing is chosen (see Fonts).

`<pm>` is the project's package manager: the lockfile decides it (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock` → bun, else npm).

## Astro Pre-Flight

- [ ] Static sections ship zero JS (no island where CSS or a custom element would do)
- [ ] Every island has a deliberate `client:*` directive (`client:visible` for below-the-fold motion)
- [ ] Islands pass their own framework's pre-flight (`frameworks/<framework>.md`)
- [ ] Interactive `.astro` motion lives in custom elements with teardown in `disconnectedCallback`
- [ ] No top-level `<script>` logic that breaks after a `<ClientRouter />` page swap
- [ ] Custom elements have an explicit `display` class
- [ ] No UI framework added only to animate something
- [ ] Icons via `astro-icon` with `aria-hidden="true"` when decorative
