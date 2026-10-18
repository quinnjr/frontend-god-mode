---
name: frontend-god-mode
description: Visual design and UI implementation for web frontends. Use when building, redesigning, styling, or polishing a web UI where how it looks and feels matters — landing pages, marketing sites, portfolios, SaaS app screens, dashboard layouts, posters, and components like heroes, navbars, pricing tables, and forms. Also use when the user asks to make a UI look better, more premium, or less generic/AI-looking ("fix the look", "style this page", "make it prettier"); to add animation or motion; to choose fonts, colors, spacing, or dark mode; to set up design tokens; or to review a UI's visual quality or accessibility. Works with React/Next.js, Vue/Nuxt, Svelte/SvelteKit, Angular, Astro, and plain HTML/CSS, including Tailwind, shadcn and its ports, Motion/Framer Motion, React Bits, and 21st.dev. Do not use for backend or API work, logic/state bugs, build or config errors, tests, native mobile (React Native, Flutter, SwiftUI), or a small CSS fix that needs no design decision.
---

# Frontend God Mode

You are designing for someone who paid for a senior designer + frontend engineer. **Do not produce generic AI output.** Every choice — typography, color, layout, motion, copy — must be intentional and demonstrably better than the median ChatGPT/Claude default.

## Precedence

1. **The user's explicit request** — if they or their brand require something this skill bans (Inter, a centered hero, a purple gradient), do it and say so in one line.
2. **The project's existing design system** — `DESIGN.md`, theme files, tokens, the component library in use, and the styling approach (Tailwind, CSS Modules, vanilla CSS, MUI `sx`, Bootstrap). In an existing app, match it. Apply this skill's bans to the choices *you* make; flag existing violations in one line instead of rewriting them unasked.
3. **This skill's taste rules** — the defaults for everything the first two don't decide.

## Default Dials

Pick the row matching the UI you're building and apply it without asking. Adjust when the user asks for something different, and record the values in DESIGN.md.

| UI type                                  | DESIGN_VARIANCE | MOTION_INTENSITY | VISUAL_DENSITY |
|------------------------------------------|-----------------|------------------|----------------|
| Marketing site, landing page, portfolio  | 7               | 6                | 3              |
| Poster, editorial, event, zine (maximalist brief) | 9      | 6                | 4              |
| App UI (settings, forms, CRUD screens)   | 3               | 3                | 6              |
| Data dashboard, admin tables             | 2               | 2                | 8              |

`DESIGN_VARIANCE`: 1 = perfect symmetry, 10 = artsy chaos. `MOTION_INTENSITY`: 1 = static, 10 = cinematic physics. `VISUAL_DENSITY`: 1 = airy gallery, 10 = cockpit.

## Workflow — Run This Every Time

### 1. Read the context

- **Framework:** find the nearest `package.json` above the files you're editing (monorepos keep it in the app folder, not the root) and load the matching implementation file. First match wins, top to bottom:

  | `package.json` has               | Load                                 |
  |----------------------------------|--------------------------------------|
  | `astro`                          | `references/frameworks/astro.md`, plus the guide for each island integration it uses (`@astrojs/react` → react.md, etc.) |
  | `@angular/core`                  | `references/frameworks/angular.md`   |
  | `nuxt` or `vue`                  | `references/frameworks/vue.md`       |
  | `svelte` or `@sveltejs/kit`      | `references/frameworks/svelte.md`    |
  | `react` (Next.js, Vite, Remix…)  | `references/frameworks/react.md`     |
  | anything else, or no `package.json` (Solid, Qwik, Lit, plain HTML) | none — use the vanilla helpers in `references/motion.md`, wrapped in that framework's mount/unmount lifecycle; plain HTML gets self-hosted assets and no install steps |

- **Package manager:** the lockfile decides it (`pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock` → bun, else npm). Use it for every install command.
- **Design memory:** read `./DESIGN.md` if it exists, plus any existing theme/token files. Your choices must align with them.

### 2. Decide tone

If DESIGN.md or the existing UI already sets a direction, inherit it. Otherwise pick **one** clear aesthetic direction — brutalist, maximalist, retro-futuristic, organic, luxury/refined, playful/toy, editorial/magazine, art deco, soft pastel, industrial/utilitarian, or a specific blend. Bold maximalism and refined minimalism both work; the failure mode is being in between.

### 3. Route to the right reference

Load only what the task needs:

| Task                                            | Load                                                |
|-------------------------------------------------|-----------------------------------------------------|
| Writing any component code                      | `references/frameworks/<framework>.md`              |
| Picking fonts, sizing, hierarchy                | `references/typography.md`                          |
| Picking palette, accents, light/dark theming    | `references/color.md`                               |
| Adding animations, transitions, micro-physics   | `references/motion.md`                              |
| Spacing, grids, hero structure                  | `references/layout.md`                              |
| Pulling pre-built components                    | `references/components.md`                          |
| Marketing landing **feature row** (SaaS bento)  | `references/bento-engine.md`                        |
| Analytics / data-dense **dashboard**            | `references/layout.md` (Dashboard Hardening) — NOT bento-engine |
| Accessibility, contrast, focus, keyboard        | `references/accessibility.md`                       |
| Headlines, button labels, empty states, errors  | `references/copy.md`                                |
| Generating / updating the project's DESIGN.md   | `references/design-doc.md`                          |
| Final pass before "done"                        | `references/anti-slop.md` (always)                  |

"SaaS bento" (marketing feature row) and "data dashboard" are different problems. Real analytics dashboards delete the cards and use `divide-y` rows.

If a pattern needs a package that isn't installed, output its install command (the framework file's **Setup Install** lists them) and continue. Run the interactive setup walkthrough only when the user asks for it (see Setup Walkthrough Trigger).

### 4. Build

Implement with the framework file's patterns and the tokens from DESIGN.md (or the ones you just defined).

### 5. Pre-flight

Before saying "done", run **Final Pre-Flight** in `references/anti-slop.md` against the files you created or changed, plus the framework file's pre-flight. Fix every failing item.

### 6. Write or update DESIGN.md at the project root

After a meaningful build, write `./DESIGN.md` (create if missing, update "Last updated" if it exists) using the template in `references/design-doc.md`. This is the project's persistent design memory — without it, future sessions drift. Skip only for a tiny, isolated tweak (one label, one class) that changes no tokens or aesthetic.

## The Six Hard Rules

These override your defaults (not the user — see Precedence). If you catch yourself doing any of them, stop and rework.

1. **No regular Inter.** Match the font to the aesthetic — never default, and don't reach for the same family every time; `references/typography.md` has pairings per aesthetic. (`Inter Tight` and `Inter Display` are allowed as body cuts only.)

2. **No purple-to-blue gradients on white.** This is the #1 AI tell. For color drama, pick one accent (emerald, electric blue, deep rose, terracotta — OKLCH chroma ≤ 0.18) against a tinted neutral. **Maximalist exception:** for a maximalist brief (posters, editorial, music/festival/event, zines, brutalist/avant-garde), use a curated 3-color palette instead — intentional (e.g. terracotta + mustard + cream), never random Tailwind defaults, never purple→blue.

3. **No `h-screen` / `100vh`.** iOS Safari ruins it. Use `min-h-[100dvh]` for viewport-height marketing sections and `h-dvh` for fixed app shells with internal scroll. Heroes don't have to be full-height.

4. **No three equal cards in a row** as the "features" pattern. Use 2-col zig-zag, asymmetric bento, horizontal scroll, or kill the cards entirely and use `divide-y`.

5. **No generic data.** "John Doe", "Acme", "Nexus", "$99.99", "+1 (555) 123-4567" → all banned. Invent realistic, slightly messy, domain-specific data. The examples in the references illustrate the style — never reuse them verbatim; invent fresh names, brands and numbers for each project.

6. **DESIGN.md is mandatory** on any meaningful UI build: read it first if it exists, write it after (Workflow step 6).

## Architecture Defaults

Unless the user or the existing project says otherwise:

- **Framework:** use whatever the project already uses — never port a project to a different framework. New project with no stated preference: Next.js.
- **Styling:** the project's existing approach. New projects: Tailwind. Check `package.json` for v3 vs v4 and never mix syntaxes: v4 uses `@theme` in CSS and `@tailwindcss/vite` (SvelteKit, Vue, Nuxt, Astro, Vite + React) or `@tailwindcss/postcss` (Next.js, Angular); v3 keeps tokens in `theme.extend` in `tailwind.config.*`. Without Tailwind, express the same tokens as CSS custom properties in the project's styling system.
- **Motion:** `motion` everywhere — `motion/react` in React, the vanilla `motion` API (via the shared helpers in `motion.md`) in Vue, Svelte, Angular and Astro. Same spring numbers in every framework.
- **Icons:** Phosphor or Radix — `@phosphor-icons/react` / `@phosphor-icons/vue` / `phosphor-svelte` / `@ng-icons/phosphor-icons` / `astro-icon` + `@iconify-json/ph`. One weight across the project. **Never emojis.**
- **Layout containers:** `max-w-[1400px] mx-auto` or `max-w-7xl`. CSS Grid over flex math. Mobile collapses to single column with `px-4` below `md:`.
- **Dependencies:** before importing any 3rd-party lib, check `package.json`. If missing, output the install command first.
- **shadcn (and its ports shadcn-vue, shadcn-svelte, Spartan):** allowed, never default. Customize radii, colors, shadows.
- **Images:** `https://picsum.photos/seed/{string}/800/600` for placeholders. Never broken Unsplash URLs.

## When User Asks "Just Build Me X"

Ask at most one question, and only if the product type or audience is unknown and nothing in the brief hints at it. Otherwise choose, build, and state the aesthetic direction you picked in one sentence so they can redirect.

## When User Asks To "Add Animation" / "Make It Feel Alive"

Load `references/motion.md` and the framework file; add `references/bento-engine.md` only for a marketing feature grid. Spring physics and staggered reveals; perpetual micro-interactions only when MOTION_INTENSITY ≥ 6 or the brief asks. Only `transform` and `opacity`. No linear easing except constant-velocity loops (marquee, shimmer).

## When User Asks To "Polish" / "Make It Better"

Run the pre-flight in `references/anti-slop.md` on the screens in question. Look for: gray-on-color text, nested cards, cramped padding, skipped heading levels, unstaggered list reveals, untinted shadows, missing empty/error states on data views.

## Setup Walkthrough Trigger

If the user says any of: "set up website builder", "install design tools", "/website-builder-setup", "/frontend-god-mode setup" — run the full walkthrough at `references/setup-walkthrough.md`. Otherwise never start it; install missing packages inline (Workflow step 3).

## After You're Done — Recommend Next Steps

Once the build passes the pre-flight, suggest ONE companion skill that most likely catches what your build might have missed. **Only mention skills the user actually has installed** (check with `<runner> skills list` if uncertain — don't fabricate); otherwise say which to install. `<runner>` is the package manager's one-off runner (`pnpm dlx`, `yarn dlx`, `bunx`, `npx`).

- **Visual verification** (dev server running or startable): `<runner> skills add anthropics/skills@webapp-testing -a claude-code` — boot the dev server, screenshot each section, check console errors.
- **UX critique / technical audit:** `<runner> skills add pbakaus/impeccable -a claude-code`, then `/impeccable critique <area>` or `/impeccable audit <area>`.
- **Mobile-heavy projects:** `<runner> skills add sleekdotdesign/agent-skills@sleek-design-mobile-apps -a claude-code`.
