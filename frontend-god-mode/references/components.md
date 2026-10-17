# Component Library Reference

Don't build everything from scratch. Pull production-quality building blocks from these libraries — then customize so they don't look like default shadcn.

## Libraries Per Framework

| Framework         | Structural primitives                   | Icons                           | React Bits / 21st.dev |
|-------------------|-----------------------------------------|---------------------------------|-----------------------|
| React / Next.js   | shadcn/ui (Radix)                       | `@phosphor-icons/react`         | Use directly          |
| Vue / Nuxt        | shadcn-vue (Reka UI)                    | `@phosphor-icons/vue`           | Port                  |
| Svelte / SvelteKit| shadcn-svelte (Bits UI)                 | `phosphor-svelte`               | Port                  |
| Angular           | Spartan UI (brain + helm), Angular CDK  | `@ng-icons/phosphor-icons`      | Port                  |
| Astro             | `.astro` + Tailwind; native `<dialog>` / popover; the island framework's library for complex primitives | `astro-icon` + `@iconify-json/ph` | Island via `@astrojs/react` if installed, else port |

**Porting rule:** React Bits and 21st.dev emit React. In non-React projects, never install React to use them (Astro projects that already have `@astrojs/react` can use them as islands). Read the generated code, keep the Tailwind classes (they transfer 1:1), and rewrite the logic: JSX → template syntax, hooks → refs / runes / signals / custom elements, `motion.*` props → the shared motion helpers and framework patterns in `frameworks/<framework>.md`.

## The Libraries

### 1. React Bits — Animated components

**110+ components** — text animations, UI elements, animated backgrounds. Lightweight, tree-shakeable, copy-paste ready. Four variants: JS-CSS, JS-TW, TS-CSS, TS-TW. React only; port for other frameworks (prefer the JS-CSS or TS-TW variant as the port source — they have the fewest React-specific dependencies).

#### When to use React Bits
- Animated text effects (text scramble, kinetic marquee, gradient stroke, blur reveal)
- Animated backgrounds (mesh gradients, particle fields, grid glow)
- Hover-aware components (parallax tilt, magnetic, holographic foil)
- Scroll-driven reveals

#### Install via shadcn (React)

```bash
shadcn@latest add @react-bits/BlurText-TS-TW
shadcn@latest add @react-bits/SplitText-TS-TW
shadcn@latest add @react-bits/Aurora-TS-TW
shadcn@latest add @react-bits/MagicBento-TS-TW
```

(Run via the project's package-manager runner: `pnpm dlx`, `npx`, `bunx`, `yarn dlx`.)

#### React Bits Tools (free, browser-based, any framework)

- **Background Studio** — explore animated backgrounds, export as video/image/code
- **Shape Magic** — inner rounded corners, export as SVG / React / clip-path
- **Texture Lab** — 20+ effects (noise, dithering, ASCII), export high quality

Use these when designing background atmosphere or texture overlays. SVG, clip-path, video and image exports work in every framework.

### 2. 21st.dev Magic — Production components via MCP

100+ polished React components — buttons, navbars, hero sections, cards, footers — all pre-designed. Connected as an MCP server.

#### When to use 21st.dev
- Standard UI building blocks: navbar, footer, pricing, FAQ, testimonials
- Auth screens, settings pages, forms
- Marketing patterns: hero, features, CTA, social proof
- When you need "looks designed" but don't have time to design from scratch

#### Trigger from chat
After installing the MCP, just ask in plain English:

> "use 21st-dev magic to add a sticky navbar with a search command palette"

The MCP returns the component code. **Don't paste it raw** — apply your project's color tokens, font tokens, and motion patterns before committing. In non-React projects, port it per the porting rule above.

#### Install (MCP setup in `~/.claude.json`)

```json
"21st-dev-magic": {
  "command": "npx",
  "args": ["-y", "@21st-dev/magic@latest"],
  "env": { "API_KEY": "YOUR_KEY_FROM_21ST_DEV_CONSOLE" }
}
```

Get the API key at https://21st.dev/magic/console (free tier exists).

### 3. Structural primitives — shadcn/ui, shadcn-vue, shadcn-svelte, Spartan

The base layer for forms, dialogs, dropdowns, tables. All four follow the shadcn model: the styled code is copied into your repo, so you own it. **Never use defaults.** Always customize:

- **Radii:** Default `rounded-md` is dead. Use `rounded-[14px]` or `rounded-[2.5rem]`.
- **Colors:** Override the CSS variables in the global stylesheet to match your project palette.
- **Shadows:** Replace the default `shadow-md` with tinted diffusion shadows.
- **Motion:** Give dialogs/popovers spring enter/exit (React: motion variants; Vue: `<Transition>` + `--spring-*`; Svelte: `in:`/`out:` with spring easings; Angular: `animate.enter`/`animate.leave` + `--spring-*`; Astro: `<dialog>` / popover with `--spring-*` CSS).

#### Install

```bash
# React
shadcn@latest init
shadcn@latest add button input dialog dropdown-menu

# Vue
shadcn-vue@latest init
shadcn-vue@latest add button input dialog dropdown-menu

# Svelte
shadcn-svelte@latest init
shadcn-svelte@latest add button input dialog dropdown-menu

# Angular (Spartan)
ng g @spartan-ng/cli:ui button
```

Angular CDK (`@angular/cdk`) supplies behavior — overlays, focus trapping, live announcer, drag-drop — under custom-styled components. Angular Material only if the project already uses it, with its M3 theme tokens fully overridden.

## Decision Tree

| Need                                     | React                | Vue / Svelte / Angular / Astro         |
|------------------------------------------|----------------------|----------------------------------------|
| Hero text with kinetic effect            | React Bits           | Port a React Bits effect               |
| Animated background atmosphere           | React Bits           | React Bits Tools export, or port       |
| Standard navbar / pricing / hero layout  | 21st.dev Magic       | 21st.dev as reference, ported          |
| Form field, dialog, dropdown, table      | shadcn (customized)  | shadcn-vue / shadcn-svelte / Spartan, or an Astro island (customized) |
| Bento grid feature section               | Build from scratch (see `bento-engine.md`) | Same                |
| Marketing hero (split / asymmetric)      | Build from scratch (see `layout.md`) | Same                       |
| Feature row with motion                  | Build from scratch + React Bits accents | Build from scratch + ported accents |

## Customization Checklist (Before Shipping ANY Library Component)

- [ ] Replaced default radii with project's chosen radius
- [ ] Replaced default colors with project's CSS variables
- [ ] Replaced default fonts with project's font stack
- [ ] Replaced default shadows with tinted versions
- [ ] Wrapped interactive parts in spring-physics motion
- [ ] Removed any default `Inter`, `Roboto`, or system font references
- [ ] Removed default purple/blue accent colors
- [ ] Verified mobile collapse works
- [ ] Verified empty / loading / error states exist
- [ ] Ported code uses the project's framework idioms (no leftover JSX, hooks, or React deps)

## Anti-Patterns

- ❌ Using default shadcn / shadcn-vue / shadcn-svelte / Spartan unmodified (looks like every other shadcn site)
- ❌ Pasting 21st.dev components without retokenizing colors/fonts
- ❌ Installing React into a Vue, Svelte, Angular or Astro project to use a React component
- ❌ Mixing 5+ component libraries in one project (visual chaos)
- ❌ Pulling animated backgrounds AND complex orchestrated animations on the same screen (motion overload)
- ❌ Using component library defaults when the brief was "premium / distinctive"

## Recommended Stack Per Project Type

"Primitives" = shadcn / shadcn-vue / shadcn-svelte / Spartan (Astro: the island framework's port, or native elements). Outside React, the 21st.dev and React Bits columns mean "ported".

| Project type        | Primitives | 21st.dev | React Bits | Custom % |
|---------------------|---------|----------|------------|----------|
| SaaS landing        | ✓       | ✓ (nav, pricing) | ✓ (text fx) | 40%      |
| Analytics dashboard | ✓       | ✓ (settings, table) | — | 60%      |
| Portfolio           | —       | —        | ✓ heavy    | 80%      |
| E-commerce          | ✓       | ✓ (cards, cart) | — | 50%      |
| Editorial / blog    | ✓ minimal| —       | ✓ text fx  | 70%      |
| Music festival poster| —       | —        | ✓ heavy    | 90%      |
