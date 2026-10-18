# Anti-Slop Reference (Pre-Flight Mandatory)

This is the final filter. Run **Final Pre-Flight** at the bottom against the files you created or changed before reporting "done". If a check fails, fix it.

## AI Tells

If your output has any of these, it screams "AI generated."

### Visual / CSS
1. **Inter font** (regular cut) as the primary face — banned. Pick a family that fits the aesthetic from `typography.md`.
2. **Purple-to-blue gradient** on white backgrounds (the #1 tell — banned outright)
3. **Pure `#000` / `#FFF`** without tint (use `oklch(0.12 0.005 H)` / `oklch(0.99 0.005 H)`)
4. **Default neon shadow** like `box-shadow: 0 0 20px rgba(120,80,255,0.5)` (banned)
5. **Untinted shadows** with pure black (`rgba(0,0,0,0.1)`) — must tint to bg hue
6. **Gradient text fill** on large H1s (cliché, use solid color + tracking)
7. **Custom mouse cursors** (outdated, breaks accessibility — banned)
8. **Side-tab borders** (`border-l-4 border-purple-500` on alerts) — banned
9. **Bounce / elastic easing** (feels dated) — use the spring presets in `motion.md`; `springOvershoot` when you want a pop
10. **Generic `rounded-md`** everywhere — choose the radius per aesthetic (sharp `rounded-none`, `rounded-[14px]`, soft `rounded-[2.5rem]`) and apply it consistently

### Typography
11. **Oversized H1 that screams** — control with weight + color, not just `text-9xl`
12. **Serif fonts on dashboards** — banned for software UIs
13. **All-caps body copy** (only labels < 4 words)
14. **Centered long paragraphs** — left-align everything past 2 lines
15. **Body width over 65 characters** — caps reading comfort
16. **`font-sans` defaulting to system-ui** — must explicitly load a non-system font

### Layout
17. **The template hero** — centered H1 + subtitle + 2 CTAs. A centered hero is fine when it's a deliberate composition (oversized type, an asset, an asymmetric detail); the stock template is banned.
18. **3 equal cards in a row** as the features pattern (banned)
19. **Cards inside cards** — flatten the depth
20. **`h-screen` / `100vh`** — `min-h-[100dvh]` for viewport sections, `h-dvh` for app shells
21. **Flex percentage math** (`w-[calc(33%-1rem)]`) — use Grid

### Content / Data
22. **Generic names** — "John Doe", "Jane Smith", "Sarah Chen" (banned). Use specific, culturally varied names that fit the domain.
23. **Round-number fake data** — `99.99%`, `$50.00`, `1,000 users`, `+1 (555) 123-4567` (banned). Use messy figures (`47.2%`, `$47.20`, `1,128 users`). Phone numbers use the fictional range `555-0100`–`555-0199`; emails use `example.com`.
24. **Startup slop names** — "Acme", "Nexus", "SmartFlow", "Apex" (banned). Invent names that fit the product's domain and check they aren't a well-known real company.

Examples in this skill illustrate the style. Never reuse them verbatim — invent fresh ones per project.

### Copy
- **Filler words:** "Elevate", "Seamless", "Unleash", "Next-Gen", "Revolutionary", "Game-Changing" — all banned. Use concrete verbs.
- **"Lorem ipsum"** in shipped output — banned. Write actual placeholder copy that matches the aesthetic.
- **AI-tone phrases:** "In the realm of...", "Whether you're...", "From X to Y" — banned.

### Images
- **Broken Unsplash links** — banned. Use `https://picsum.photos/seed/{string}/800/600` for deterministic placeholders, or specific stock URLs you've verified.
- **Generic SVG "egg" avatars** or Lucide user icons as user profile pics — banned. Use named, varied placeholder portraits or stylized initials.
- **Emojis** anywhere in the UI — banned. Use Phosphor or Radix icons.

## Forbidden CSS Patterns

```css
/* Bad — all banned */
.bad-1 { font-family: Inter, sans-serif; }
.bad-2 { background: linear-gradient(135deg, #a855f7, #3b82f6); }
.bad-3 { color: #000; background: #fff; }
.bad-4 { box-shadow: 0 0 30px rgba(168, 85, 247, 0.4); }
.bad-5 { box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
.bad-6 { animation: bounce 1s infinite; }
.bad-7 { cursor: url('custom.png'), auto; }
.bad-8 { border-left: 4px solid purple; }
.bad-9 { transition: all 0.3s ease; }  /* list the properties; use a spring or cubic-bezier */
.bad-10 { height: 100vh; }  /* use 100dvh */
```

## Forbidden Framework Patterns

```html
<!-- Bad in every framework -->
<div class="grid grid-cols-3 gap-4">  <!-- banned for "features" sections -->
  <Card /> <Card /> <Card />
</div>
```

```ts
window.addEventListener('scroll', ...)  // use motion's scroll() / useScroll
animate(el, { width: '100%' })           // animate transform/opacity only
```

```tsx
// Bad: React
const [mouseX, setMouseX] = useState(0);  // re-renders kill mobile — use useMotionValue
```

```ts
// Bad: Angular
readonly mouseX = signal(0);              // pointer position in a signal — use the magnetic() helper
constructor() { matchMedia('...'); }      // DOM access outside afterNextRender breaks SSR
@for (item of items(); track $index)      // reorderable lists need a stable track key
```

```svelte
<!-- Bad: Svelte -->
<script>
  let mouseX = $state(0);  // pointer position in state — use the magnetic() helper
</script>

<li in:fly={{ y: 20 }}>    <!-- page-load reveal via transition never plays on SSR'd content -->
{#each items as item}      <!-- unkeyed each can't animate:flip -->
```

```vue
<!-- Bad: Vue -->
<script setup>
const mouseX = ref(0)                    // pointer position in a ref — use the v-magnetic directive
const w = window.innerWidth              // top-level DOM access breaks SSR — use onMounted
</script>

<li v-for="(item, i) in items" :key="i"> <!-- index keys break <TransitionGroup> reorder -->
```

```astro
<!-- Bad: Astro -->
<Hero client:load />                     <!-- hydrating a component that only does CSS motion -->
<script>document.querySelector('.x')</script>  <!-- top-level script: no teardown, dies after a <ClientRouter /> swap — use a custom element -->
```

## State Coverage

Every component that fetches or mutates data MUST have:

- **Loading state** — skeleton matching layout sizes (NOT generic spinners)
- **Empty state** — composed, tells the user how to populate it
- **Error state** — clear, inline, actionable
- **Success state** — feedback after mutations

Static content (a marketing section, a hero) needs none of these — don't invent them.

## Final Pre-Flight

The one canonical checklist. Check the files you created or changed; mark an item N/A when it can't apply (no data, no motion, no forms) rather than inventing work. Then run the framework file's pre-flight.

```
TYPOGRAPHY
[ ] No regular Inter / Roboto / Arial / system-ui as the primary face
[ ] At most two families (display + body), plus an optional mono
[ ] Body line-height ≥ 1.5, body width ≤ 65ch, display tracking tightened

COLOR
[ ] No purple→blue gradient; no pure #000 / #FFF
[ ] One accent (OKLCH chroma ≤ 0.18), or a curated 3-color palette for a maximalist brief
[ ] Accent hue distinct from the status colors; shadows tinted, never pure black
[ ] Body text ≥ 4.5:1 — on a light bg, body text L ≤ 0.55; on dark, L ≥ 0.70 (accessibility.md)
[ ] Both modes ship with a Light / Dark / System toggle and no flash; images, code, embeds and charts checked in both (color.md)

LAYOUT
[ ] No template hero, no 3 equal feature cards, no cards nested past depth 1
[ ] No h-screen / 100vh; Grid instead of flex percentage math
[ ] Collapses to one column with px-4 minimum below md:

MOTION
[ ] Springs or premium cubic-bezier; no bounce / elastic; linear only for constant-velocity loops
[ ] Only transform / opacity animated; list reveals staggered
[ ] Reduced motion respected (CSS guard + JS check)
[ ] Every animation, interval, listener and observer is torn down; no browser APIs during SSR

ACCESSIBILITY
[ ] Visible focus ring (≥ 3:1, opaque) on every interactive element
[ ] Touch targets ≥ 44×44px on mobile
[ ] Real labels on inputs; sequential heading levels; icon-only buttons labelled

CONTENT & STATE
[ ] Realistic, fresh data and names (none copied from this skill's examples)
[ ] No filler copy, no lorem ipsum, no emojis, no broken image URLs
[ ] Data components have loading / empty / error / success states

PROJECT
[ ] Followed the existing design system and DESIGN.md (Precedence in SKILL.md)
[ ] Tailwind version syntax matches package.json; new dependencies have install commands
[ ] Stated the aesthetic direction in one line
[ ] DESIGN.md read first (if present) and written/updated after
```

If an item fails, **don't say done.** Fix it and re-check.
