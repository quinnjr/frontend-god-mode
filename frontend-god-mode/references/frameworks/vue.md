# Vue / Nuxt Implementation

Load this when `package.json` has `vue` or `nuxt`. The design rules come from the shared references; this file is *how* to implement them in Vue. Targets Vue 3.5+ (Composition API, `<script setup>`, `useTemplateRef`) and Nuxt 3+. Check the installed version before using any API below.

## Rendering Model

- **`<script setup lang="ts">` + Composition API only** in new code. No Options API, no Vue 2 patterns.
- **SSR-safe DOM work:** Nuxt renders on the server. Anything that touches `window`, `matchMedia`, `getBoundingClientRect` or starts an animation goes in `onMounted` (or a directive's `mounted` hook). Both run only in the browser. Never in `<script setup>` top level.
- **Re-render scope is the component.** A reactive change re-renders the whole component that reads it, so timers and loops live in their own leaf component, never in the section that holds the layout.
- **Lazy-hydrate heavy animated sections** below the fold in Nuxt: `<LazyBentoSection hydrate-on-visible />`.

## Motion Library

- **Enter/leave:** built-in `<Transition>` with CSS classes using the `--spring-*` tokens from `motion.md`.
- **Reorder:** built-in `<TransitionGroup>` with a `move` class. Vue does the FLIP measurement for you.
- **Spring physics, stagger, scroll, pointer:** the vanilla `motion` package via the shared helpers in `motion.md` (put them in `src/lib/motion.ts`; Nuxt: `lib/motion.ts` at the project root), wrapped in directives.
- **Perpetual loops:** CSS keyframes from `motion.md`.

Both built-ins are CSS-driven, so the global reduced-motion guard covers them.

### The motion directives

One factory connects any helper to the element lifecycle: browser-only (`mounted` never runs during SSR), torn down before unmount.

```ts
// src/lib/motion-directives.ts
import type { Directive } from 'vue';
import { magnetic, reveal } from './motion';

const teardowns = new WeakMap<HTMLElement, () => void>();

export function motionDirective(setup: (el: HTMLElement) => () => void): Directive<HTMLElement> {
  return {
    mounted: (el) => teardowns.set(el, setup(el)),
    beforeUnmount: (el) => {
      teardowns.get(el)?.();
      teardowns.delete(el);
    },
  };
}

export const vReveal = motionDirective(reveal);
export const vMagnetic = motionDirective(magnetic);
```

Any `vName` imported in `<script setup>` is usable as `v-name` in the template. No global registration needed.

### Staggered reveal

```vue
<script setup lang="ts">
import { vReveal } from '@/lib/motion-directives';
defineProps<{ items: { id: number; title: string }[] }>();
</script>

<template>
  <div v-reveal class="grid gap-4">
    <div v-for="item in items" :key="item.id" data-reveal>{{ item.title }}</div>
  </div>
</template>
```

Add the `[data-reveal]` CSS gate from `motion.md` to the global stylesheet.

### Magnetic button

Never put pointer position in a `ref` bound to `:style`. The helper writes transforms directly.

```vue
<script setup lang="ts">
import { vMagnetic } from '@/lib/motion-directives';
</script>

<template>
  <button v-magnetic type="button" class="...">Book a tasting</button>
</template>
```

### Tactile feedback

CSS `:active` from `motion.md`. Nothing Vue-specific.

### Enter / leave (overshoot badge)

```vue
<script setup lang="ts">
import { ref } from 'vue';
const visible = ref(false);
</script>

<template>
  <Transition enter-active-class="badge-in" leave-active-class="badge-out">
    <div v-if="visible" class="absolute top-4 right-4 px-3 py-1 rounded-full bg-[var(--accent)] text-[var(--accent-fg)] text-xs">
      3 new
    </div>
  </Transition>
</template>

<style scoped>
.badge-in { animation: badge-pop var(--spring-overshoot-duration) var(--spring-overshoot); }
.badge-out { animation: badge-pop 200ms cubic-bezier(0.16, 1, 0.3, 1) reverse; }
@keyframes badge-pop { from { transform: scale(0); opacity: 0; } }
</style>
```

Vue removes the element only after the leave animation ends.

### Layout transitions (reorder)

```vue
<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue';
import { prefersReducedMotion } from '@/lib/motion';

const items = ref([
  { id: 1, label: 'Draft Q3 launch plan', priority: 'high' },
  { id: 2, label: 'Review onboarding flow', priority: 'med' },
  { id: 3, label: 'Sync with marketing', priority: 'low' },
  { id: 4, label: 'Update docs site', priority: 'med' },
]);

let timer: ReturnType<typeof setInterval> | undefined;
onMounted(() => {
  if (prefersReducedMotion()) return;
  timer = setInterval(() => {
    items.value = [...items.value].sort(() => Math.random() - 0.5);
  }, 3000);
});
onBeforeUnmount(() => clearInterval(timer));
</script>

<template>
  <TransitionGroup tag="ul" name="task" class="space-y-3">
    <li v-for="task in items" :key="task.id" class="rounded-2xl bg-[var(--bg-subtle)] p-4 flex items-center gap-3">
      <span class="w-2 h-2 rounded-full bg-[var(--accent)]"></span>
      <span class="text-sm">{{ task.label }}</span>
    </li>
  </TransitionGroup>
</template>

<style scoped>
.task-move { transition: transform var(--spring-smooth-duration) var(--spring-smooth); }
</style>
```

`<TransitionGroup>` children need a stable `:key`. Add `.task-enter-active` / `.task-leave-active` classes the same way if items mount or unmount; give leaving items `position: absolute` so the others can move into place.

### Scroll-driven

```vue
<script setup lang="ts">
import { animate, scroll } from 'motion';
import { motionDirective } from '@/lib/motion-directives';

const vParallax = motionDirective((el) =>
  scroll(animate(el, { y: [0, -100] }), { target: el, offset: ['start end', 'end start'] }),
);
</script>

<template>
  <div v-parallax></div>
</template>
```

### GSAP isolation

```ts
// in <script setup lang="ts">, with <section ref="section"> in the template
import gsap from 'gsap';
import { onBeforeUnmount, onMounted, useTemplateRef } from 'vue';

const section = useTemplateRef<HTMLElement>('section');
let ctx: gsap.Context | undefined;
onMounted(() => { ctx = gsap.context(() => { /* ... */ }, section.value!); });
onBeforeUnmount(() => ctx?.revert());
```

### Reduced motion

CSS guard from `motion.md` in the global stylesheet (covers `<Transition>` and `<TransitionGroup>`), plus `prefersReducedMotion()` before starting any JS loop. The shared helpers already check it.

## Bento Card Archetypes

- **Intelligent List:** reorder example above.
- **Live Status:** badge example above, toggled from an interval started in `onMounted` and cleared in `onBeforeUnmount`.
- **Wide Data Stream:** CSS `.marquee` from `motion.md` with two identical groups — `<div class="flex gap-4 pr-4"><MetricCard v-for="m in metrics" :key="m.id" v-bind="m" /></div>` and the same group again with `aria-hidden="true"`.
- **Command Input typewriter:** a `ref` for the visible text, advanced by a timer started in `onMounted` and cleared in `onBeforeUnmount`, in its own leaf component.
- **Contextual UI:** compose `v-reveal` over the highlight spans with a `<Transition>` toolbar (`--spring-snappy`).

## Theme Script

The pre-paint theme script from `color.md` (Theme Follows Content) goes inline in the document `<head>`, before any stylesheet. Never load it as a module or from a component — by then the page has already painted in the wrong mode.

**Vite / SPA Vue:** paste the script into `index.html`'s `<head>` as-is.

**Nuxt:** register it in `nuxt.config`. Never set `data-theme` through `useHead({ htmlAttrs })` — the server has no access to `localStorage`, so it renders the wrong value and overwrites the script's choice.

```ts
// nuxt.config.ts
export default defineNuxtConfig({
  app: {
    head: {
      meta: [{ name: 'color-scheme', content: 'light dark' }],
      script: [{
        tagPosition: 'head',
        innerHTML: `try{const t=localStorage.getItem("theme");if(t==="light"||t==="dark")document.documentElement.dataset.theme=t}catch{}`,
      }],
    },
  },
});
```

## Fonts

Self-host with Fontsource. The example uses Geist — install and import the pairing you actually chose from `typography.md` (Fontsource package names are `@fontsource-variable/<family>` for variable fonts, `@fontsource/<family>` otherwise). Fontshare and paid fonts: self-host the woff2 with `@font-face`.

```bash
<pm> add @fontsource-variable/geist @fontsource-variable/geist-mono
```

```css
/* src/assets/main.css (Nuxt: assets/css/main.css, listed in nuxt.config `css`) */
@import 'tailwindcss';
@import '@fontsource-variable/geist';
@import '@fontsource-variable/geist-mono';

@theme {
  --font-sans: 'Geist Variable', sans-serif;
  --font-mono: 'Geist Mono Variable', monospace;
}
```

## Icons

`@phosphor-icons/vue` (or `@radix-icons/vue`):

```vue
<script setup lang="ts">
import { PhArrowRight } from '@phosphor-icons/vue';
</script>

<template>
  <PhArrowRight :size="20" aria-hidden="true" />
</template>
```

## Component Libraries

- **shadcn-vue** — the Vue port of shadcn/ui, built on Reka UI (`shadcn-vue@latest init`, `shadcn-vue@latest add button dialog`). Retokenize exactly like shadcn (see `components.md`).
- **Reka UI** — headless primitives under shadcn-vue. Use it directly for custom-styled dialogs, menus, comboboxes.
- **React Bits / 21st.dev** — React-only output. Use them as design references and port: Tailwind classes transfer 1:1; replace JSX with Vue templates, hooks with refs and lifecycle hooks, `motion.*` props with the directives and built-ins above.

## Tailwind

Tailwind v4 in Vue and Nuxt uses the Vite plugin, not PostCSS:

```ts
// vite.config.ts
import tailwindcss from '@tailwindcss/vite';
import vue from '@vitejs/plugin-vue';
import { defineConfig } from 'vite';

export default defineConfig({ plugins: [vue(), tailwindcss()] });
```

Nuxt: add `tailwindcss()` to `vite.plugins` in `nuxt.config.ts`.

**Tailwind v3 projects:** keep the existing `tailwind.config.*` + PostCSS setup; put tokens in `theme.extend` instead of `@theme` (`colors: { accent: 'var(--accent)' }`). For opacity modifiers, store the channels (`--accent: 0.52 0.17 258`) and map `accent: 'oklch(var(--accent) / <alpha-value>)'`.

## Setup Install

```bash
<pm> add motion @phosphor-icons/vue
```

Fonts are installed separately, after the pairing is chosen (see Fonts).

`<pm>` is the project's package manager: the lockfile decides it (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock` → bun, else npm).

## Vue Pre-Flight

- [ ] `<script setup lang="ts">` + Composition API throughout
- [ ] No DOM / `window` access outside `onMounted` or directive `mounted` (SSR-safe)
- [ ] No pointer/scroll position in a `ref`
- [ ] Every interval, listener, observer and animation torn down in `onBeforeUnmount` / directive `beforeUnmount`
- [ ] Enter/leave via `<Transition>` and reorder via `<TransitionGroup>` with `--spring-*` CSS
- [ ] `v-for` lists keyed by a stable id (never the index on reorderable lists)
- [ ] Timers and loops in their own leaf components
- [ ] Icons `aria-hidden="true"` when decorative
