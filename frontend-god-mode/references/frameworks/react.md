# React / Next.js Implementation

Load this when `package.json` has `react` (Next.js, Vite + React, Remix / React Router, Astro islands). The design rules come from the shared references; this file is *how* to implement them in React.

## Rendering Model

- **Next.js App Router:** default to Server Components. Isolate motion and state into leaf Client Components with `'use client'` at the top of the file.
- **Never** put `'use client'` on a component that could stay a Server Component. Push the boundary down to the smallest animated leaf.
- **Vite / SPA React:** no RSC boundary, but the same leaf-isolation rule applies for re-renders.

## Motion Library

Use `motion` (`import { motion } from 'motion/react'`). `framer-motion` is the same API under the old package name. Match whichever is already in `package.json`; never install both.

Put the spring presets from `motion.md` in one module and import them everywhere:

```ts
// lib/springs.ts
export const springSnappy = { type: 'spring', stiffness: 400, damping: 30 } as const;
export const springSmooth = { type: 'spring', stiffness: 100, damping: 20 } as const;
export const springDramatic = { type: 'spring', stiffness: 60, damping: 18 } as const;
export const springOvershoot = { type: 'spring', stiffness: 300, damping: 12 } as const;
```

### Staggered reveal

```tsx
'use client';
import { motion } from 'motion/react';
import { springSmooth } from '@/lib/springs';

const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.08, delayChildren: 0.1 }
  }
};

const item = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0, transition: springSmooth }
};

export function StaggeredGrid({ items }: { items: { id: string; title: string }[] }) {
  return (
    <motion.div variants={container} initial="hidden" whileInView="show" viewport={{ once: true, amount: 0.2 }} className="grid gap-4">
      {items.map((it) => (
        <motion.div key={it.id} variants={item}>{it.title}</motion.div>
      ))}
    </motion.div>
  );
}
```

`whileInView` matches the shared `reveal()` helper (fires once at 20% visibility). For content above the fold, `animate="show"` is fine.

**Critical:** Parent variants and children MUST live in the same Client Component tree. If data is fetched async, pass it into a centralized motion wrapper.

### Magnetic button

Use `useMotionValue` + `useSpring`. Never `useState` — it triggers re-renders on every mouse move.

```tsx
'use client';
import { useRef } from 'react';
import { motion, useMotionValue, useSpring } from 'motion/react';

export function MagneticButton({ children }: { children: React.ReactNode }) {
  const ref = useRef<HTMLButtonElement>(null);
  const x = useMotionValue(0);
  const y = useMotionValue(0);
  const sx = useSpring(x, { stiffness: 200, damping: 20 });
  const sy = useSpring(y, { stiffness: 200, damping: 20 });

  function handleMove(e: React.MouseEvent) {
    const rect = ref.current?.getBoundingClientRect();
    if (!rect) return;
    x.set((e.clientX - rect.left - rect.width / 2) * 0.3);
    y.set((e.clientY - rect.top - rect.height / 2) * 0.3);
  }

  function handleLeave() { x.set(0); y.set(0); }

  return (
    <motion.button
      ref={ref}
      onMouseMove={handleMove}
      onMouseLeave={handleLeave}
      style={{ x: sx, y: sy }}
      className="..."
    >
      {children}
    </motion.button>
  );
}
```

### Tactile feedback

```tsx
<motion.button whileTap={{ scale: 0.98, y: 1 }}>...</motion.button>
```

### Layout transitions

```tsx
<motion.div layout layoutId={`card-${id}`} transition={springSmooth}>
  {content}
</motion.div>
```

This handles list reordering, expand-to-modal morphs, and shared element transitions. Wrap lists whose items mount/unmount in `<AnimatePresence mode="popLayout">`.

### Perpetual loops

Prefer the CSS keyframes in `motion.md`. When a loop needs motion values (keyframe arrays, synced springs):

```tsx
<motion.div
  animate={{ scale: [1, 1.15, 1], opacity: [1, 0.7, 1] }}
  transition={{ repeat: Infinity, duration: 2, ease: 'easeInOut' }}
  className="w-2 h-2 rounded-full bg-[var(--accent)]"
/>
```

Wrap every perpetual-motion component in `memo` and keep it a leaf.

### Scroll-driven

```tsx
const { scrollYProgress } = useScroll({ target: ref, offset: ['start end', 'end start'] });
const y = useTransform(scrollYProgress, [0, 1], [0, -100]);
return <motion.div style={{ y }} />;
```

### GSAP isolation

```tsx
useEffect(() => {
  const ctx = gsap.context(() => { /* ... */ }, ref);
  return () => ctx.revert();
}, []);
```

### Reduced motion

```tsx
import { useReducedMotion } from 'motion/react';
import { springSmooth } from '@/lib/springs';
const reduced = useReducedMotion();
const transition = reduced ? { duration: 0 } : springSmooth;
```

Or wrap the app in `<MotionConfig reducedMotion="user">`.

## Bento Card Archetypes

### Intelligent List (auto-sorting)

```tsx
'use client';
import { motion, LayoutGroup, useReducedMotion } from 'motion/react';
import { memo, useEffect, useState } from 'react';
import { springSmooth } from '@/lib/springs';

const tasks = [
  { id: 1, label: 'Draft Q3 launch plan', priority: 'high' },
  { id: 2, label: 'Review onboarding flow', priority: 'med' },
  { id: 3, label: 'Sync with marketing', priority: 'low' },
  { id: 4, label: 'Update docs site', priority: 'med' },
];

export const IntelligentList = memo(function IntelligentList() {
  const [items, setItems] = useState(tasks);
  const reduced = useReducedMotion();
  useEffect(() => {
    if (reduced) return;
    const t = setInterval(() => {
      setItems((prev) => [...prev].sort(() => Math.random() - 0.5));
    }, 3000);
    return () => clearInterval(t);
  }, [reduced]);

  return (
    <LayoutGroup>
      <ul className="space-y-3">
        {items.map((task) => (
          <motion.li
            key={task.id}
            layout
            layoutId={`task-${task.id}`}
            transition={springSmooth}
            className="rounded-2xl bg-[var(--bg-subtle)] p-4 flex items-center gap-3"
          >
            <span className="w-2 h-2 rounded-full bg-[var(--accent)]" />
            <span className="text-sm">{task.label}</span>
          </motion.li>
        ))}
      </ul>
    </LayoutGroup>
  );
});
```

### Live Status badge (overshoot pop)

```tsx
import { AnimatePresence, motion } from 'motion/react';
import { springOvershoot } from '@/lib/springs';

<AnimatePresence>
  {visible && (
    <motion.div
      initial={{ scale: 0, opacity: 0 }}
      animate={{ scale: 1, opacity: 1 }}
      exit={{ scale: 0, opacity: 0 }}
      transition={springOvershoot}
      className="absolute top-4 right-4 px-3 py-1 rounded-full bg-[var(--accent)] text-[var(--accent-fg)] text-xs"
    >
      3 new
    </motion.div>
  )}
</AnimatePresence>
```

### Wide Data Stream

Use the CSS `.marquee` from `motion.md` with two identical groups — `<div className="flex gap-4 pr-4">{metrics.map(...)}</div>` and the same group again with `aria-hidden="true"`. No JS needed.

### Command Input typewriter

A `useState` string for the visible text, advanced by a timer started in `useEffect` (cleared in its return, skipped when `useReducedMotion()` is true), in its own `memo` leaf. Timing per prompt is in `motion.md`.

### Contextual UI

Compose it from the staggered reveal (highlight spans) and `AnimatePresence` (the floating toolbar, `springSnappy`).

## Fonts

The example uses Geist — load the pairing you actually chose from `typography.md`.

**Next.js:** `next/font` (Google fonts) or `next/font/local` (Fontshare and paid fonts, self-hosted woff2):

```tsx
// app/layout.tsx
import { Geist, Geist_Mono } from 'next/font/google';

const sans = Geist({ subsets: ['latin'], variable: '--font-geist' });
const mono = Geist_Mono({ subsets: ['latin'], variable: '--font-geist-mono' });

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${sans.variable} ${mono.variable}`}>
      <body>{children}</body>
    </html>
  );
}
```

```css
/* app/globals.css */
@theme inline {
  --font-sans: var(--font-geist), sans-serif;
  --font-mono: var(--font-geist-mono), monospace;
}
```

**Non-Next React (Vite):** Fontsource packages imported in the entry CSS and mapped in `@theme`, as in `vue.md`.

## Icons

`@phosphor-icons/react` or `@radix-ui/react-icons`. In Server Components, import Phosphor from `@phosphor-icons/react/dist/ssr`.

## Component Libraries

- **shadcn/ui** — structural primitives (`shadcn@latest init`, `shadcn@latest add button dialog`).
- **React Bits** — animated text/backgrounds via the shadcn registry (`shadcn@latest add @react-bits/BlurText-TS-TW`).
- **21st.dev** — production components via the 21st MCP.

See `components.md` for when to use which and how to retokenize.

## Tailwind

Next.js uses `@tailwindcss/postcss` for v4. Vite + React uses `@tailwindcss/vite`.

**Tailwind v3 projects:** keep the existing `tailwind.config.*` + PostCSS setup; put tokens in `theme.extend` instead of `@theme` (`colors: { accent: 'var(--accent)' }`). For opacity modifiers, store the channels (`--accent: 0.52 0.17 258`) and map `accent: 'oklch(var(--accent) / <alpha-value>)'`.

## Setup Install

```bash
<pm> add motion @phosphor-icons/react
```

Fonts are installed separately, after the pairing is chosen (see Fonts).

`<pm>` is the project's package manager: the lockfile decides it (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock` → bun, else npm). Use `<pm> dlx` / `npx` accordingly for `shadcn`.

## React Pre-Flight

- [ ] `'use client'` only on leaf components that need it — nothing that could be RSC
- [ ] Every `motion.*` component lives in a `'use client'` file
- [ ] No `useState` for pointer/scroll position (use motion values)
- [ ] Every `useEffect` that starts an animation, interval, or listener returns cleanup, and JS loops skip when `useReducedMotion()` is true
- [ ] Perpetual-motion components are `memo`ized leaves
- [ ] Reordering/unmounting lists use `layout` + `<AnimatePresence mode="popLayout">`
- [ ] Only one of `motion` / `framer-motion` installed
