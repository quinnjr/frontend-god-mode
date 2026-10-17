# DESIGN.md — Persistent Design System

When you finish a build (or a meaningful chunk of one), write or update a `DESIGN.md` at the project root. This is the project's persistent design memory: aesthetic direction, tokens, motion config, component inventory.

**Why this matters:** without DESIGN.md, every Claude session re-decides the design from scratch. Three sessions later, your fonts drift, your accent color shifts, your motion feels different. DESIGN.md prevents drift.

## When to write/update DESIGN.md

- **First build:** create it. Establish the aesthetic + tokens.
- **Subsequent builds in the same project:** read it FIRST, follow it, only update if a deliberate evolution.
- **User says "this is different from last time":** treat that as a bug and re-align with DESIGN.md.

## Where to put it

Project root: `./DESIGN.md`. Same level as `package.json`. Always there. Don't bury it in `/docs`.

## The template

Copy this structure and replace every `<placeholder>` with the project's actual choices. Never copy example values — they're there to show the shape:

```markdown
# Design

> Auto-generated and maintained by frontend-god-mode.
> Source of truth for typography, color, motion, layout, and component tokens.
> Read this BEFORE touching the UI in any subsequent session.

## Aesthetic direction

<One sentence describing the vibe — e.g. "Editorial luxury: typographer's portfolio, italic serif eyebrows, generous whitespace.">

## Stack

- Framework: <from package.json — e.g. "SvelteKit 2 / Svelte 5", "Next.js (App Router)", "Nuxt / Vue 3.5", "Angular (standalone, zoneless)", "Astro (+ Vue islands)">
- Styling: <e.g. Tailwind v4 / Tailwind v3 / CSS Modules>
- Package manager: <from the lockfile>

## Dials

- UI type: <marketing / maximalist / app UI / data dashboard — see SKILL.md Default Dials>
- DESIGN_VARIANCE: <n> / 10
- MOTION_INTENSITY: <n> / 10
- VISUAL_DENSITY: <n> / 10

## Type stack

- Display: <family, weights — chosen for this aesthetic from typography.md>
- Body: <family>
- Mono: <family, or "none">
- Loaded via: <`next/font` / Fontsource packages / self-hosted @font-face>
- Font features: <e.g. `font-variant-numeric: tabular-nums` on data; stylistic sets if the font has them>

Banned in this project: regular Inter, Roboto, Arial, system-ui as primary, serif on dashboards.

## Color tokens (OKLCH)

<Neutral family and hue H, accent name. Values below are the shape to fill in — compute contrast for your own values (body text ≥ 4.5:1 on bg, bg-subtle and surface).>

```css
:root {
  --bg: oklch(<L> <C> <H>);
  --bg-subtle: oklch(<L> <C> <H>);
  --surface: oklch(<L> <C> <H>);
  --fg: oklch(<L> <C> <H>);
  --muted: oklch(<L> <C> <H>);
  --border: oklch(<L> <C> <H>);
  --accent: oklch(<L> <C> <H>);
  --accent-fg: oklch(<L> <C> <H>);
  --ring: var(--accent);
  --radius: <one radius for this aesthetic>;
  --success: oklch(<L> <C> <H>);
  --warning: oklch(<L> <C> <H>);
  --error: oklch(<L> <C> <H>);
  --info: oklch(<L> <C> <H>);
}

@media (prefers-color-scheme: dark) {
  :root { /* same names, dark values */ }
}
```

Banned in this project:
- Pure #000 / #FFF (use the tinted neutrals above)
- Purple-to-blue gradients (the AI tell)
- More than ONE accent (a curated 3-color palette only for a maximalist brief)

## Shadows

```css
--shadow-card: <tinted toward the bg hue, e.g. 0 20px 40px -15px oklch(<L> <C> <H> / 0.08)>;
```

No pure-black drops.

## Motion

- Springs: smooth `{ stiffness: 100, damping: 20 }`, snappy `{ stiffness: 400, damping: 30 }`, dramatic `{ stiffness: 60, damping: 18 }`, overshoot `{ stiffness: 300, damping: 12 }`
- Stagger: `0.08s` between children, `0.1s` initial delay
- CSS springs: `--spring-*` tokens from motion.md
- Perpetual loops: <where, or "none" — per MOTION_INTENSITY>
- Library: motion@<major> (`motion/react` on React; vanilla `motion` helpers elsewhere)
- Banned: bounce/elastic, animating width/height, linear easing except constant-velocity loops

## Layout

- Container: <e.g. `max-w-[1400px] mx-auto px-6 md:px-10`>
- Reading width: `max-w-[65ch]`
- Section padding: <per density>
- Radius: <one choice for this aesthetic — e.g. sharp `rounded-none`, `rounded-[14px]`, soft `rounded-[2.5rem]`>
- Hero pattern: <e.g. split 60/40, oversized type over asset, editorial column — never the template centered H1 + subtitle + 2 CTAs>
- Feature row: <bento / zig-zag / divide-y list — never 3 equal cards>
- Mobile: collapse all `grid-cols-N` to `grid-cols-1` below `md:`

## Component inventory

- Primitives: <library + components in use, e.g. shadcn-svelte: Button, Dialog, Input>
- Pulled / ported: <e.g. React Bits BlurText (ported), 21st.dev pricing pattern (retokenized)>
- Custom: <project components>

## Project-specific bans

- <e.g. no round-number stats; no stock photography of people; icon weight "regular" only>

## Brand voice (copy)

- Tone: <e.g. direct, technical, slightly dry>
- Headline pattern: <e.g. specific outcome with a messy number>
- Button labels: specific verbs ("Send invoice", not "Submit")

## Accessibility floor

- WCAG 2.2 AA contrast on all body copy (≥ 4.5:1)
- Focus-visible rings on every interactive element
- `prefers-reduced-motion` respected
- 44×44px minimum touch targets on mobile

## Last updated

YYYY-MM-DD by [session description, e.g. "added pricing teaser"]
```

## Authoring rules

1. **Be specific.** "Geist" not "modern sans-serif." OKLCH values not "neutral gray."
2. **List bans inline** so any reader (human or AI) sees them immediately.
3. **Keep it ONE file.** Don't split into design/typography.md, design/color.md. One file is the point.
4. **Add to "Last updated"** every time you touch it, with a one-line description of what changed. Keep only the 5 most recent entries.
5. **Read it BEFORE building** in any subsequent session. Quote from it when explaining decisions.

## What NOT to put in DESIGN.md

- Marketing copy (lives in `/content` or actual pages)
- API contracts (lives in `/docs/api`)
- Long rationales for why a choice was made (one line is enough — "amber chosen for warmth against zinc")
- Anti-patterns from the global skill (those are in `references/anti-slop.md`, not project-specific)

## Anti-drift contract

If a future Claude session generates UI that violates DESIGN.md, the user can say:

> "this doesn't match DESIGN.md"

And Claude must:
1. Re-read DESIGN.md
2. Identify the specific token/rule that was violated
3. Fix the violation (don't update DESIGN.md to match the bad output)

DESIGN.md is the source of truth, not a rough guideline.
