# Angular Implementation

Load this when `package.json` has `@angular/core`. The design rules come from the shared references; this file is *how* to implement them in Angular. Targets Angular 20.2+ (standalone components, signals, built-in control flow, `animate.enter` / `animate.leave`). Check the installed version before using any API below.

## Rendering Model

- **Standalone components only.** No NgModules in new code.
- **`ChangeDetectionStrategy.OnPush` on every component.** This is Angular's equivalent of React `memo` for perpetual-motion leaves.
- **Signals for state** (`signal`, `computed`, `input()`, `viewChild()`). Built-in control flow (`@if`, `@for` with `track`), never `*ngIf` / `*ngFor` in new code.
- **SSR-safe DOM work:** anything that touches `window`, `matchMedia`, `getBoundingClientRect` or starts an animation goes in `afterNextRender`. Never in the constructor or `ngOnInit`. It runs only in the browser, after hydration.
- **Zone.js apps** (check for `zone.js` in `polyfills` / `provideZoneChangeDetection`): register pointer/scroll animation work inside `NgZone.runOutsideAngular` so mouse moves don't trigger change detection. In zoneless apps the call is a harmless no-op, so always use it.
- **Defer heavy animated sections** below the fold: `@defer (on viewport) { <app-bento /> }` (and `hydrate on viewport` with incremental hydration).

## Motion Library

- **Enter/leave:** native `animate.enter` / `animate.leave` with CSS classes using the `--spring-*` tokens from `motion.md`. Do not add `@angular/animations` to new code. It is deprecated since v20.2. If a project already depends on it, match the existing usage rather than mixing systems in one component.
- **Spring physics, stagger, scroll, pointer:** the vanilla `motion` package via the shared helpers in `motion.md` (put them in `src/app/lib/motion.ts`).
- **Perpetual loops:** CSS keyframes from `motion.md`. Zero change detection.

### The motion bridge

One function connects any helper to the component lifecycle: browser-only, outside the zone, torn down on destroy.

```ts
// src/app/lib/attach-motion.ts
import { DestroyRef, ElementRef, NgZone, afterNextRender, inject } from '@angular/core';

export function attachMotion(setup: (el: HTMLElement) => () => void): void {
  const el = inject<ElementRef<HTMLElement>>(ElementRef).nativeElement;
  const zone = inject(NgZone);
  const destroyRef = inject(DestroyRef);
  afterNextRender(() => destroyRef.onDestroy(zone.runOutsideAngular(() => setup(el))));
}
```

### Staggered reveal

```ts
// src/app/lib/reveal.directive.ts
import { Directive } from '@angular/core';
import { attachMotion } from './attach-motion';
import { reveal } from './motion';

@Directive({ selector: '[appReveal]' })
export class Reveal {
  constructor() { attachMotion(reveal); }
}
```

```html
<div appReveal class="grid gap-4">
  @for (item of items(); track item.id) {
    <div data-reveal>{{ item.title }}</div>
  }
</div>
```

Add the `[data-reveal]` CSS gate from `motion.md` to the global `styles.css`.

### Magnetic button

Never bind pointer position to a signal or `[style]`. The helper writes transforms directly.

```ts
@Directive({ selector: '[appMagnetic]' })
export class Magnetic {
  constructor() { attachMotion(magnetic); }
}
```

```html
<button appMagnetic type="button" class="...">Book a tasting</button>
```

### Tactile feedback

CSS `:active` from `motion.md`. Nothing Angular-specific.

### Enter / leave (overshoot badge)

```ts
@Component({
  selector: 'app-live-status',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (visible()) {
      <div animate.enter="badge-in" animate.leave="badge-out"
           class="absolute top-4 right-4 px-3 py-1 rounded-full bg-[var(--accent)] text-[var(--accent-fg)] text-xs">
        3 new
      </div>
    }
  `,
  styles: `
    .badge-in { animation: badge-pop var(--spring-overshoot-duration) var(--spring-overshoot); }
    .badge-out { animation: badge-pop 200ms cubic-bezier(0.16, 1, 0.3, 1) reverse; }
    @keyframes badge-pop { from { transform: scale(0); opacity: 0; } }
  `,
})
export class LiveStatus {
  readonly visible = signal(false);
}
```

Angular removes the element only after the `animate.leave` animation ends. The global reduced-motion guard shortens both.

### Layout transitions (FLIP reorder)

Angular has no `layoutId`. Measure before the signal update, then play the inverse transform after the DOM re-renders:

```ts
import {
  ChangeDetectionStrategy, Component, DestroyRef, ElementRef, Injector,
  afterNextRender, inject, signal, viewChild,
} from '@angular/core';
import { animate } from 'motion';
import { prefersReducedMotion, springSmooth } from '../lib/motion';

const tasks = [
  { id: 1, label: 'Draft Q3 launch plan', priority: 'high' },
  { id: 2, label: 'Review onboarding flow', priority: 'med' },
  { id: 3, label: 'Sync with marketing', priority: 'low' },
  { id: 4, label: 'Update docs site', priority: 'med' },
];

@Component({
  selector: 'app-intelligent-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <ul #list class="space-y-3">
      @for (task of items(); track task.id) {
        <li [attr.data-id]="task.id" class="rounded-2xl bg-[var(--bg-subtle)] p-4 flex items-center gap-3">
          <span class="w-2 h-2 rounded-full bg-[var(--accent)]"></span>
          <span class="text-sm">{{ task.label }}</span>
        </li>
      }
    </ul>
  `,
})
export class IntelligentList {
  readonly items = signal(tasks);
  private readonly list = viewChild.required<ElementRef<HTMLUListElement>>('list');
  private readonly injector = inject(Injector);

  constructor() {
    const destroyRef = inject(DestroyRef);
    afterNextRender(() => {
      if (prefersReducedMotion()) return;
      const t = setInterval(() => this.shuffle(), 3000);
      destroyRef.onDestroy(() => clearInterval(t));
    });
  }

  private shuffle(): void {
    const first = new Map(this.rows().map(([id, el]) => [id, el.getBoundingClientRect()]));
    this.items.update((prev) => [...prev].sort(() => Math.random() - 0.5));
    afterNextRender(() => {
      for (const [id, el] of this.rows()) {
        const prev = first.get(id);
        if (!prev) continue;
        const dy = prev.top - el.getBoundingClientRect().top;
        if (dy) animate(el, { y: [dy, 0] }, springSmooth);
      }
    }, { injector: this.injector });
  }

  private rows(): [string, HTMLElement][] {
    return [...this.list().nativeElement.querySelectorAll<HTMLElement>('[data-id]')].map((el) => [el.dataset['id']!, el]);
  }
}
```

### Scroll-driven

```ts
@Directive({ selector: '[appParallax]' })
export class Parallax {
  constructor() {
    attachMotion((el) => scroll(animate(el, { y: [0, -100] }), { target: el, offset: ['start end', 'end start'] }));
  }
}
```

### GSAP isolation

```ts
attachMotion((el) => {
  const ctx = gsap.context(() => { /* ... */ }, el);
  return () => ctx.revert();
});
```

### Reduced motion

CSS guard from `motion.md` in `styles.css`, plus `prefersReducedMotion()` before starting any JS loop (as in `IntelligentList`). The shared helpers already check it.

## Bento Card Archetypes

- **Intelligent List:** `IntelligentList` above.
- **Live Status:** `LiveStatus` above. Toggle `visible` from an interval started in `afterNextRender`, cleared in `DestroyRef.onDestroy`.
- **Wide Data Stream:** CSS `.marquee` from `motion.md` with two identical groups — `<div class="flex gap-4 pr-4">@for (m of metrics(); track m.id) {…}</div>` and the same group again with `aria-hidden="true"`.
- **Command Input typewriter:** a signal for the visible text, advanced by a timer started in `afterNextRender` and cleared on destroy. It's the only archetype that updates a signal per tick; keep it in its own `OnPush` leaf.
- **Contextual UI:** compose `appReveal` over the highlight spans with an `animate.enter` toolbar (`--spring-snappy`).

## Fonts

Self-host with Fontsource. Never a Google Fonts `<link>` in `index.html` for production builds. The example uses Geist — install and import the pairing you actually chose from `typography.md` (Fontsource package names are `@fontsource-variable/<family>` for variable fonts, `@fontsource/<family>` otherwise). Fontshare and paid fonts: self-host the woff2 with `@font-face`.

```bash
<pm> add @fontsource-variable/geist @fontsource-variable/geist-mono
```

```css
/* src/styles.css */
@import 'tailwindcss';
@import '@fontsource-variable/geist';
@import '@fontsource-variable/geist-mono';

@theme {
  --font-sans: 'Geist Variable', sans-serif;
  --font-mono: 'Geist Mono Variable', monospace;
}
```

## Icons

`@ng-icons/core` with `@ng-icons/phosphor-icons` (or `@ng-icons/radix-icons`):

```ts
import { Component } from '@angular/core';
import { NgIcon, provideIcons } from '@ng-icons/core';
import { phosphorArrowRight } from '@ng-icons/phosphor-icons/regular';

@Component({
  imports: [NgIcon],
  viewProviders: [provideIcons({ phosphorArrowRight })],
  template: `<ng-icon name="phosphorArrowRight" size="20" aria-hidden="true" />`,
})
```

## Component Libraries

- **Spartan UI** — the Angular port of shadcn/ui. Headless `brain` primitives plus copy-in `helm` styles you own (`ng g @spartan-ng/cli:ui button`). Retokenize helm exactly like shadcn (see `components.md`).
- **Angular CDK** — overlays, `cdkTrapFocus`, `LiveAnnouncer`, drag-drop, virtual scroll. Use it for behavior under custom-styled components.
- **Angular Material** — only if the project already uses it. Its default look is as recognizable as default shadcn: override the M3 theme tokens (color, shape, typography) before shipping.
- **React Bits / 21st.dev** — React-only output. Use them as design references and port: Tailwind classes transfer 1:1; replace JSX with template syntax, hooks with signals, `motion.*` props with the helpers above.

## Tailwind

Tailwind v4 in Angular uses PostCSS. Add `.postcssrc.json` at the project root:

```json
{ "plugins": { "@tailwindcss/postcss": {} } }
```

**Tailwind v3 projects:** keep the existing `tailwind.config.*` + PostCSS setup; put tokens in `theme.extend` instead of `@theme` (`colors: { accent: 'var(--accent)' }`). For opacity modifiers, store the channels (`--accent: 0.52 0.17 258`) and map `accent: 'oklch(var(--accent) / <alpha-value>)'`.

## Setup Install

```bash
<pm> add motion @ng-icons/core @ng-icons/phosphor-icons
```

Fonts are installed separately, after the pairing is chosen (see Fonts).

`<pm>` is the project's package manager: the lockfile decides it (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock` → bun, else npm).

## Angular Pre-Flight

- [ ] Every component is standalone and `OnPush`
- [ ] No DOM / `window` access outside `afterNextRender` (SSR-safe)
- [ ] Pointer/scroll animation runs outside the zone (via `attachMotion`)
- [ ] No pointer position bound to a signal or `[style]`
- [ ] Every interval, listener, observer and animation torn down via `DestroyRef`
- [ ] Enter/leave via `animate.enter` / `animate.leave` + `--spring-*` CSS (no new `@angular/animations`)
- [ ] `@for` blocks have a stable `track` (never `track $index` on reorderable lists)
- [ ] Icons via `ng-icon` with `aria-hidden="true"` when decorative
