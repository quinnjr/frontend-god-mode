# React / Next.js Implementation

Load this when `package.json` has `react` (Next.js, Vite + React, Remix / React Router, Astro islands). The design rules come from the shared references; this file is *how* to implement them in React.

## Rendering Model

- **Next.js App Router:** default to Server Components. Isolate motion and state into leaf Client Components with `'use client'` at the top of the file.
- **Never** put `'use client'` on a component that could stay a Server Component. Push the boundary down to the smallest animated leaf.
- **Vite / SPA React:** no RSC boundary, but the same leaf-isolation rule applies for re-renders.

## Motion Library

Use `motion` (`import { motion } from 'motion/react'`). `framer-motion` is the same API under the old package name. Match whichever is already in `package.json`; never install both.

### Staggered reveal

```tsx
'use client';
import { motion } from 'motion/react';

const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.08, delayChildren: 0.1 }
  }
};

const item = {
  hidden: { opacity: 0, y: 20 },
  show: { opacity: 1, y: 0, transition: { type: 'spring', stiffness: 100, damping: 20 } }
};

export function StaggeredGrid({ items }) {
  return (
    <motion.div variants={container} initial="hidden" animate="show" className="grid gap-4">
      {items.map((it) => (
        <motion.div key={it.id} variants={item}>{it.title}</motion.div>
      ))}
    </motion.div>
  );
}
```

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
  className="w-2 h-2 rounded-full bg-emerald-500"
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
const reduced = useReducedMotion();
const transition = reduced ? { duration: 0 } : springSmooth;
```

Or wrap the app in `<MotionConfig reducedMotion="user">`.

## Bento Card Archetypes

### Intelligent List (auto-sorting)

```tsx
'use client';
import { motion, LayoutGroup } from 'motion/react';
import { memo, useEffect, useState } from 'react';

const tasks = [
  { id: 1, label: 'Draft Q3 launch plan', priority: 'high' },
  { id: 2, label: 'Review onboarding flow', priority: 'med' },
  { id: 3, label: 'Sync with marketing', priority: 'low' },
  { id: 4, label: 'Update docs site', priority: 'med' },
];

export const IntelligentList = memo(function IntelligentList() {
  const [items, setItems] = useState(tasks);
  useEffect(() => {
    const t = setInterval(() => {
      setItems((prev) => [...prev].sort(() => Math.random() - 0.5));
    }, 3000);
    return () => clearInterval(t);
  }, []);

  return (
    <LayoutGroup>
      <ul className="space-y-3">
        {items.map((task) => (
          <motion.li
            key={task.id}
            layout
            layoutId={`task-${task.id}`}
            transition={{ type: 'spring', stiffness: 100, damping: 20 }}
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
<AnimatePresence>
  {visible && (
    <motion.div
      initial={{ scale: 0, opacity: 0 }}
      animate={{ scale: 1, opacity: 1 }}
      exit={{ scale: 0, opacity: 0 }}
      transition={{ type: 'spring', stiffness: 300, damping: 12 }}
      className="absolute top-4 right-4 px-3 py-1 rounded-full bg-[var(--accent)] text-[var(--bg)] text-xs"
    >
      3 new
    </motion.div>
  )}
</AnimatePresence>
```

### Wide Data Stream

Use the CSS `.marquee` from `motion.md` with `{[...metrics, ...metrics].map(...)}`. No JS needed.

## Fonts (Next.js)

```ts
// app/layout.tsx
import { Geist, Geist_Mono } from 'next/font/google';
// or for non-Google fonts, use a self-hosted local font
import localFont from 'next/font/local';

const geist = Geist({ subsets: ['latin'], variable: '--font-sans' });
const geistMono = Geist_Mono({ subsets: ['latin'], variable: '--font-mono' });
```

Non-Next React: use Fontsource (`@fontsource-variable/geist`) imported in the entry CSS, as in the Svelte file.

## Icons

`@phosphor-icons/react` or `@radix-ui/react-icons`. In Server Components, import Phosphor from `@phosphor-icons/react/dist/ssr`.

## Component Libraries

- **shadcn/ui** — structural primitives (`shadcn@latest init`, `shadcn@latest add button dialog`).
- **React Bits** — animated text/backgrounds via the shadcn registry (`shadcn@latest add @react-bits/BlurText-TS-TW`).
- **21st.dev Magic** — production components via MCP.

See `components.md` for when to use which and how to retokenize.

## Tailwind

Next.js uses `@tailwindcss/postcss` for v4. Vite + React uses `@tailwindcss/vite`.

## Setup Install

```bash
<pm> add motion
```

`<pm>` is the project's package manager: the lockfile decides it (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock` → bun, else npm). Use `<pm> dlx` / `npx` accordingly for `shadcn`.

## React Pre-Flight

- [ ] `'use client'` only on leaf components that need it — nothing that could be RSC
- [ ] Every `motion.*` component lives in a `'use client'` file
- [ ] No `useState` for pointer/scroll position (use motion values)
- [ ] Every `useEffect` that starts an animation, interval, or listener returns cleanup
- [ ] Perpetual-motion components are `memo`ized leaves
- [ ] Reordering/unmounting lists use `layout` + `<AnimatePresence mode="popLayout">`
- [ ] Only one of `motion` / `framer-motion` installed
