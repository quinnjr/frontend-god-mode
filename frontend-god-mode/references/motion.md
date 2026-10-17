# Motion & Animation Reference

Static AI sites are obvious; animated ones with linear easing and bounce everywhere are worse. This reference enforces premium motion.

The rules and numbers here apply to every framework. The framework-specific implementation of each pattern (React, Vue, Svelte, Angular, Astro) lives in `references/frameworks/<framework>.md` — load it alongside this file.

## The Four Hard Rules

1. **No linear easing on UI motion.** Use spring physics or premium cubic-bezier. **Exception:** infinite seamless carousels and shimmer/marquee loops use linear timing — they need constant velocity to feel right. Linear is banned only for entrance, exit, hover, and tap motion. (The CSS `linear()` *function* used to encode springs below is not linear easing.)
2. **No `width`/`height`/`top`/`left` animation.** Only `transform` and `opacity` — they're hardware-accelerated.
3. **No bounce/elastic easing.** It's dated. Use the springs below; `springOvershoot` (damping 12) when you want a pop, `springSnappy` (damping 30) for a slight settle. `springSmooth` (damping 20) is critically damped — no overshoot.
4. **Perpetual animations live in their own isolated leaf component.** They must never cause the parent (or the framework's change detection) to re-render. Prefer CSS keyframes for loops — they cost zero framework work.

## The Spring Defaults

Every framework uses these exact physics. In JS, pass them to `motion` (React: `motion/react`; Vue, Svelte, Angular, Astro: the vanilla `motion` package):

```ts
const springSnappy = { type: 'spring', stiffness: 400, damping: 30 };  // buttons, taps
const springSmooth = { type: 'spring', stiffness: 100, damping: 20 };  // standard motion
const springDramatic = { type: 'spring', stiffness: 60, damping: 18 }; // hero reveals
const springOvershoot = { type: 'spring', stiffness: 300, damping: 12 }; // badges, notifications
```

### CSS springs (same physics, zero JS)

For CSS transitions, keyframes, Vue `<Transition>`/`<TransitionGroup>`, and Angular `animate.enter`/`animate.leave`, use the same springs pre-sampled into `linear()` curves. Put these in the global stylesheet:

```css
:root {
  --spring-smooth: linear(0, 0.028, 0.089, 0.169, 0.256, 0.344, 0.432, 0.509, 0.58, 0.642, 0.697, 0.745, 0.786, 0.821, 0.851, 0.876, 0.898, 0.916, 0.931, 0.943, 0.953, 0.961, 0.968, 0.974, 0.979, 0.983, 0.986, 0.989, 0.991, 0.992, 0.994, 1);
  --spring-smooth-duration: 750ms;
  --spring-snappy: linear(0, 0.037, 0.115, 0.218, 0.332, 0.446, 0.561, 0.658, 0.743, 0.814, 0.873, 0.919, 0.955, 0.982, 1.001, 1.013, 1.022, 1.026, 1.027, 1.026, 1.024, 1.021, 1.018, 1.015, 1.012, 1.01, 1.007, 1.005, 1.004, 1.002, 1.001, 1);
  --spring-snappy-duration: 410ms;
  --spring-dramatic: linear(0, 0.044, 0.133, 0.24, 0.346, 0.441, 0.529, 0.604, 0.667, 0.722, 0.767, 0.806, 0.839, 0.865, 0.888, 0.907, 0.922, 0.935, 0.946, 0.955, 0.963, 0.969, 0.974, 0.978, 0.982, 0.985, 0.988, 0.99, 0.991, 0.993, 0.994, 1);
  --spring-dramatic-duration: 1290ms;
  --spring-overshoot: linear(0, 0.129, 0.402, 0.731, 1.011, 1.211, 1.302, 1.301, 1.234, 1.138, 1.039, 0.963, 0.916, 0.903, 0.914, 0.941, 0.972, 1, 1.02, 1.029, 1.029, 1.023, 1.014, 1.004, 0.997, 0.992, 0.99, 0.992, 0.994, 0.997, 1, 1);
  --spring-overshoot-duration: 920ms;
}

.card { transition: transform var(--spring-smooth-duration) var(--spring-smooth); }
```

The durations are the time each spring takes to settle within 0.5% of its target; the visible motion finishes well before that.

For simple hover/state transitions, the premium cubic-bezier is fine:

```css
.interactive {
  transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.3s cubic-bezier(0.16, 1, 0.3, 1);  /* "easeOutExpo" */
}
```

## Shared Motion Helpers (Vue, Svelte, Angular, Astro, vanilla)

React uses `motion/react` components directly (see `frameworks/react.md`). Every other framework uses these framework-free helpers built on the vanilla `motion` package, wrapped in the framework's lifecycle (Vue directive, Svelte attachment, Angular directive, Astro custom element). Create `motion.ts` (Vue, SvelteKit, Astro: `src/lib/motion.ts`; Nuxt: `lib/motion.ts`; Angular: `src/app/lib/motion.ts`):

```ts
import { animate, inView, stagger } from 'motion';

export const springSnappy = { type: 'spring', stiffness: 400, damping: 30 } as const;
export const springSmooth = { type: 'spring', stiffness: 100, damping: 20 } as const;
export const springDramatic = { type: 'spring', stiffness: 60, damping: 18 } as const;
export const springOvershoot = { type: 'spring', stiffness: 300, damping: 12 } as const;

export function prefersReducedMotion(): boolean {
  return typeof window !== 'undefined' && matchMedia('(prefers-reduced-motion: reduce)').matches;
}

/** Staggered reveal of every [data-reveal] child when `root` scrolls into view. Returns teardown. */
export function reveal(root: Element): () => void {
  const items = root.querySelectorAll<HTMLElement>('[data-reveal]');
  if (!items.length || prefersReducedMotion()) return () => {};
  let controls: ReturnType<typeof animate> | undefined;
  const stop = inView(root, () => {
    controls = animate(items, { opacity: [0, 1], y: [20, 0] }, { ...springSmooth, delay: stagger(0.08, { startDelay: 0.1 }) });
  }, { amount: 0.2 });
  return () => { stop(); controls?.stop(); };
}

/** Magnetic pull toward the cursor. Writes transforms directly — never framework state. Returns teardown. */
export function magnetic(el: HTMLElement, strength = 0.3): () => void {
  if (prefersReducedMotion()) return () => {};
  const spring = { type: 'spring', stiffness: 200, damping: 20 } as const;
  const move = (e: PointerEvent) => {
    if (e.pointerType !== 'mouse') return;
    const r = el.getBoundingClientRect();
    animate(el, { x: (e.clientX - r.left - r.width / 2) * strength, y: (e.clientY - r.top - r.height / 2) * strength }, spring);
  };
  const leave = () => animate(el, { x: 0, y: 0 }, spring);
  el.addEventListener('pointermove', move);
  el.addEventListener('pointerleave', leave);
  return () => {
    el.removeEventListener('pointermove', move);
    el.removeEventListener('pointerleave', leave);
  };
}
```

Pair `reveal()` with this CSS so items start hidden only when JS will actually reveal them (no flash, no invisible content without JS or with reduced motion):

```css
@media (scripting: enabled) and (prefers-reduced-motion: no-preference) {
  [data-reveal] { opacity: 0; }
}
```

## Page Load — Staggered Orchestration

Never mount lists or grids instantly. Stagger them: `0.08s` between children, `0.1s` initial delay, `springSmooth`, rising `20px`.

- **React:** parent/child `variants` with `staggerChildren` — see `frameworks/react.md`.
- **Vue / Svelte / Angular / Astro:** mark children `data-reveal` and run `reveal()` on the parent (directive / attachment / directive / custom element) — see the framework file.

### CSS-only fallback

```css
.stagger-item {
  opacity: 0;
  transform: translateY(20px);
  animation: rise var(--spring-smooth-duration) var(--spring-smooth) forwards;
  animation-delay: calc(var(--index, 0) * 80ms);
}

@keyframes rise {
  to { opacity: 1; transform: none; }
}
```

## Magnetic Button Pattern

Buttons that pull subtly toward the cursor. **CRITICAL:** the pointer position must never go through framework state (React `useState`, a Vue `ref` bound to `:style`, a Svelte `$state`, an Angular signal bound in a template). Write transforms directly via motion values or `animate()`. State updates on every mouse move collapse mobile performance.

- **React:** `useMotionValue` + `useSpring` — see `frameworks/react.md`.
- **Vue / Svelte / Angular / Astro:** `magnetic()` helper above, wrapped in a directive / attachment / directive / custom element.

## Tactile Feedback (`:active`)

Every interactive element needs a physical "push" feel. This works in every framework:

```css
button:active { transform: translateY(1px) scale(0.98); }
```

React can use `whileTap={{ scale: 0.98, y: 1 }}` instead.

## Layout Transitions

Re-ordering lists, expand-to-modal morphs, and shared elements must animate position (FLIP: measure → update → invert → play with `transform`). Never let items teleport.

- **React:** `layout` / `layoutId`.
- **Vue:** `<TransitionGroup>` with a `move` class.
- **Svelte:** `animate:flip` on keyed `{#each}` children.
- **Angular:** measure-and-play FLIP with `afterNextRender` + `animate()`.
- **Astro:** measure-and-play FLIP inside a custom element; `transition:name` for shared elements across pages.

Each pattern is in its framework file.

## Perpetual Micro-Interactions

When `MOTION_INTENSITY > 5`, embed continuous loops in standard components. Write them as CSS keyframes. That makes them framework-agnostic and free (no JS, no re-renders, no change detection):

```css
/* Pulse status dot */
@keyframes pulse { 50% { transform: scale(1.15); opacity: 0.7; } }
.pulse { animation: pulse 2s ease-in-out infinite; }

/* Float */
@keyframes float { 50% { transform: translateY(-8px); } }
.float { animation: float 3s ease-in-out infinite; }

/* Shimmer loading — linear is correct here (constant velocity) */
@keyframes shimmer { to { background-position: -200% 0; } }
.shimmer {
  background: linear-gradient(90deg, transparent, oklch(1 0 0 / 0.1), transparent) 0 0 / 200% 100%;
  animation: shimmer 1.5s linear infinite;
}

/* Carousel / marquee (infinite seamless) — render the items twice, translate by -50% */
@keyframes marquee { to { transform: translateX(-50%); } }
.marquee { display: flex; width: max-content; animation: marquee 30s linear infinite; }
.marquee:hover { animation-play-state: paused; }
```

### Typewriter (multi-prompt cycling)

Cycle through 3-4 prompts with a blinking cursor. Timing per prompt: 2.5s typing → 1s pause → 0.8s shimmer → fade out → next. Used in hero search bars or AI command inputs.

JS timers are allowed only for loops that change content or order (typewriter, list reorder, badge toggle) — everything purely visual is CSS. Keep each timer in its own leaf component and clear it on teardown.

## Scroll-Driven Effects

Use motion's `scroll()` (vanilla) or `useScroll` (React). Both use the native ScrollTimeline where available. Never `window.addEventListener('scroll')` — kills performance.

```ts
import { animate, scroll } from 'motion';
const stop = scroll(animate(el, { y: [0, -100] }), { target: el, offset: ['start end', 'end start'] });
// call stop() on teardown
```

For complex scrolltelling beyond motion (parallax sequences, ScrollTrigger pinning), use **GSAP**. **Never mix GSAP and motion on the same element tree.** Isolate GSAP to full-page sections or canvas backgrounds, create it in a `gsap.context()` scoped to the section root, and call `ctx.revert()` on teardown.

## Performance Guards

- **DOM cost:** Apply grain/noise filters only to fixed `pointer-events-none` overlays. Never on scrolling containers.
- **`will-change: transform`** sparingly — only on elements actively animating.
- **Teardown everything.** Every `animate()` / `inView()` / `scroll()` / interval / listener / GSAP context is undone when its component is destroyed. React: `useEffect` return. Vue: `onBeforeUnmount` / directive `beforeUnmount`. Svelte: return from the attachment / `$effect` / `onMount`. Angular: `DestroyRef.onDestroy`. Astro: `disconnectedCallback`.
- **Browser-only code runs after mount.** Never touch `window`, `matchMedia`, or `getBoundingClientRect` during SSR. React: client components + effects. Vue: `onMounted` / directive `mounted`. Svelte: attachments / `$effect` / `onMount`. Angular: `afterNextRender`. Astro: custom element `connectedCallback`.
- **Isolate perpetual-motion components** so they never re-render their parents (React `memo`, Angular `OnPush`, Vue leaf components, Svelte gets this for free with fine-grained reactivity, Astro ships no framework re-renders at all).
- **Exit animations** for items that unmount: React `<AnimatePresence mode="popLayout">`, Vue `<Transition>`, Svelte `out:` transitions, Angular `animate.leave`, Astro `animate()` then `hidden`.

## Reduced Motion

Always respect it. The global CSS guard covers CSS transitions, keyframes, Vue `<Transition>`/`<TransitionGroup>` and Angular `animate.enter`/`animate.leave`:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

JS-driven motion runs through the Web Animations API or inline styles, which that guard doesn't touch, so it must check the preference itself. React: `useReducedMotion()`. Vue, Angular, Astro: `prefersReducedMotion()` from the shared helpers. Svelte: `prefersReducedMotion.current` from `svelte/motion`.

## Anti-Patterns

- Bad: Animating `width`, `height`, `top`, `left` — repaints, not GPU
- Bad: Framework state for hover/pointer position — re-renders kill mobile
- Bad: Linear easing on UI — feels robotic
- Bad: Bounce / elastic — feels dated (2014 mobile vibes)
- Bad: Custom mouse cursor replacements — outdated, breaks accessibility
- Bad: Mixing GSAP + motion on the same element tree
- Bad: `scroll` listeners on window — use `scroll()` / `useScroll`
- Bad: JS timers for loops CSS keyframes can do
- Bad: Perceived UI motion longer than ~600ms (heroes can go longer). The `--spring-*-duration` values are settle times — most of the visible movement is done in the first half, so they're within the budget.

## Final Check

Motion items are in **Final Pre-Flight** (`anti-slop.md`), plus your framework file's pre-flight. Also confirm no custom mouse cursors.
