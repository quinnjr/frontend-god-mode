# Svelte / SvelteKit Implementation

Load this when `package.json` has `svelte` or `@sveltejs/kit`. The design rules come from the shared references; this file is *how* to implement them in Svelte. Targets Svelte 5 (runes) and attachments (`{@attach}`, Svelte 5.29+). Check the installed version before using any API below.

## Rendering Model

- **Runes only** in new code: `$state`, `$derived`, `$props`, `$effect`. Never `export let` / `$:` in Svelte 5 projects.
- **SSR-safe DOM work:** SvelteKit renders on the server. Anything that touches `window`, `matchMedia`, `getBoundingClientRect` or starts an animation goes in an attachment, `$effect`, or `onMount`. All three run only in the browser.
- **Fine-grained reactivity** means a state change updates only the DOM that reads it. No `memo` needed, but timers and loops still live in their own leaf component.
- **Svelte 4 projects:** use `onMount` (return cleanup) and `use:` actions (return `{ destroy }`) in place of `$effect` and attachments.

## Motion Library

- **Mount/unmount (`{#if}`, `{#each}`):** built-in `in:` / `out:` transitions with spring easings (below).
- **Reorder:** built-in `animate:flip`.
- **Spring physics, stagger, scroll, pointer:** the vanilla `motion` package via the shared helpers in `motion.md` (put them in `src/lib/motion.ts`), applied with `{@attach}`.
- **Perpetual loops:** CSS keyframes from `motion.md`.

Svelte transitions take an easing function, not spring config. Add the same springs as easings to `src/lib/motion.ts`:

```ts
/** Spring physics as an easing for Svelte transitions. Pair with the matching duration. */
function springEasing(stiffness: number, damping: number, duration: number): (t: number) => number {
  const w0 = Math.sqrt(stiffness);
  const z = damping / (2 * w0);
  const x = (s: number) => {
    if (z < 1) {
      const wd = w0 * Math.sqrt(1 - z * z);
      return 1 - Math.exp(-z * w0 * s) * (Math.cos(wd * s) + ((z * w0) / wd) * Math.sin(wd * s));
    }
    if (z === 1) return 1 - Math.exp(-w0 * s) * (1 + w0 * s);
    const d = Math.sqrt(z * z - 1);
    const r1 = -w0 * (z - d), r2 = -w0 * (z + d);
    return 1 - (r2 * Math.exp(r1 * s) - r1 * Math.exp(r2 * s)) / (r2 - r1);
  };
  return (t) => (t >= 1 ? 1 : x((t * duration) / 1000));
}

export const smooth = { duration: 750, easing: springEasing(100, 20, 750) };
export const snappy = { duration: 410, easing: springEasing(400, 30, 410) };
export const dramatic = { duration: 1290, easing: springEasing(60, 18, 1290) };
export const overshoot = { duration: 920, easing: springEasing(300, 12, 920) };
```

### Staggered reveal

`reveal` from `motion.md` is already attachment-shaped: it takes the element and returns teardown.

```svelte
<script lang="ts">
  import { reveal } from '$lib/motion';
  let { items } = $props();
</script>

<div {@attach reveal} class="grid gap-4">
  {#each items as item (item.id)}
    <div data-reveal>{item.title}</div>
  {/each}
</div>
```

Add the `[data-reveal]` CSS gate from `motion.md` to `src/app.css`. Don't use `in:fly` for page-load reveals: Svelte transitions don't play on the initial render, so SSR'd content would never animate.

### Magnetic button

Never put pointer position in `$state`. The helper writes transforms directly.

```svelte
<script lang="ts">
  import { magnetic } from '$lib/motion';
</script>

<button {@attach magnetic} type="button" class="...">Book a tasting</button>
<!-- custom strength: {@attach (el) => magnetic(el, 0.2)} -->
```

### Tactile feedback

CSS `:active` from `motion.md`. Nothing Svelte-specific.

### Enter / leave (overshoot badge)

```svelte
<script lang="ts">
  import { fade, scale } from 'svelte/transition';
  import { prefersReducedMotion } from 'svelte/motion';
  import { overshoot } from '$lib/motion';
  let visible = $state(false);
</script>

{#if visible}
  <div
    in:scale={{ start: 0, ...(prefersReducedMotion.current ? { duration: 0 } : overshoot) }}
    out:fade={{ duration: prefersReducedMotion.current ? 0 : 200 }}
    class="absolute top-4 right-4 px-3 py-1 rounded-full bg-[var(--accent)] text-[var(--bg)] text-xs"
  >
    3 new
  </div>
{/if}
```

Svelte 5 runs transitions through the Web Animations API, which the reduced-motion CSS guard doesn't affect. Always gate durations on `prefersReducedMotion.current`.

### Layout transitions (reorder)

```svelte
<script lang="ts">
  import { flip } from 'svelte/animate';
  import { prefersReducedMotion } from 'svelte/motion';
  import { smooth } from '$lib/motion';

  let items = $state([
    { id: 1, label: 'Draft Q3 launch plan', priority: 'high' },
    { id: 2, label: 'Review onboarding flow', priority: 'med' },
    { id: 3, label: 'Sync with marketing', priority: 'low' },
    { id: 4, label: 'Update docs site', priority: 'med' },
  ]);

  $effect(() => {
    if (prefersReducedMotion.current) return;
    const t = setInterval(() => {
      items = [...items].sort(() => Math.random() - 0.5);
    }, 3000);
    return () => clearInterval(t);
  });
</script>

<ul class="space-y-3">
  {#each items as task (task.id)}
    <li animate:flip={smooth} class="rounded-2xl bg-[var(--bg-subtle)] p-4 flex items-center gap-3">
      <span class="w-2 h-2 rounded-full bg-[var(--accent)]"></span>
      <span class="text-sm">{task.label}</span>
    </li>
  {/each}
</ul>
```

`animate:flip` requires a keyed `{#each}` and must sit on the block's direct child.

### Scroll-driven

```svelte
<script lang="ts">
  import { animate, scroll } from 'motion';
</script>

<div {@attach (el) => scroll(animate(el, { y: [0, -100] }), { target: el, offset: ['start end', 'end start'] })}></div>
```

### GSAP isolation

```svelte
<section {@attach (el) => {
  const ctx = gsap.context(() => { /* ... */ }, el);
  return () => ctx.revert();
}}></section>
```

### Reduced motion

CSS guard from `motion.md` in `src/app.css`, `prefersReducedMotion.current` (from `svelte/motion`) for transitions and JS loops. The shared helpers already check it.

## Bento Card Archetypes

- **Intelligent List:** reorder example above.
- **Live Status:** badge example above, toggled from an interval in `$effect` that returns `clearInterval`.
- **Wide Data Stream:** CSS `.marquee` from `motion.md` with `{#each [...metrics, ...metrics] as m, i (i)}`.
- **Command Input typewriter:** `$state` for the visible text, advanced by a timer in `$effect` with cleanup, in its own leaf component.

## Fonts

Self-host with Fontsource:

```bash
<pm> add @fontsource-variable/geist @fontsource-variable/geist-mono
```

```css
/* src/app.css */
@import 'tailwindcss';
@import '@fontsource-variable/geist';
@import '@fontsource-variable/geist-mono';

@theme {
  --font-sans: 'Geist Variable', sans-serif;
  --font-mono: 'Geist Mono Variable', monospace;
}
```

## Icons

`phosphor-svelte` (or `svelte-radix`):

```svelte
<script lang="ts">
  import { ArrowRight } from 'phosphor-svelte';
</script>

<ArrowRight size={20} aria-hidden="true" />
```

## Component Libraries

- **shadcn-svelte** — the Svelte port of shadcn/ui, built on Bits UI (`shadcn-svelte@latest init`, `shadcn-svelte@latest add button dialog`). Retokenize exactly like shadcn (see `components.md`).
- **Bits UI** — headless primitives under shadcn-svelte. Use it directly for custom-styled dialogs, menus, comboboxes.
- **React Bits / 21st.dev** — React-only output. Use them as design references and port: Tailwind classes transfer 1:1; replace JSX with Svelte markup, hooks with runes, `motion.*` props with the helpers and transitions above.

## Tailwind

Tailwind v4 in SvelteKit uses the Vite plugin, not PostCSS:

```ts
// vite.config.ts
import tailwindcss from '@tailwindcss/vite';
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({ plugins: [tailwindcss(), sveltekit()] });
```

## Setup Install

```bash
<pm> add motion @fontsource-variable/geist phosphor-svelte
```

`<pm>` is the project's package manager: the lockfile decides it (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock` → bun, else npm).

## Svelte Pre-Flight

- [ ] Runes syntax throughout (Svelte 5)
- [ ] No DOM / `window` access outside attachments, `$effect`, or `onMount` (SSR-safe)
- [ ] No pointer/scroll position in `$state`
- [ ] Every attachment and `$effect` that starts a timer, listener or animation returns cleanup
- [ ] Every `in:` / `out:` / `animate:` duration gated on `prefersReducedMotion.current`
- [ ] Page-load reveals use `reveal`, not `in:` transitions
- [ ] Reorderable `{#each}` blocks are keyed by a stable id
- [ ] Icons `aria-hidden="true"` when decorative
