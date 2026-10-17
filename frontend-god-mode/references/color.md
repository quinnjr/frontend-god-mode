# Color & Contrast Reference

Color is where the average AI design dies. Default purple gradients on white, washed-out grays, oversaturated CTAs — every one is a tell. This reference replaces those defaults with calibrated, intentional choices.

## The Core Rule

**Maximum ONE accent color, OKLCH chroma ≤ 0.18.**

Two accents = visual noise. Three = chaos. Pick one and let neutrals carry the rest.

### Exception: Maximalist / Editorial / Poster contexts

When the brief is maximalist — a poster, music/festival/event design, editorial layout, zine, or brutalist/avant-garde piece — you may use a **curated 3-color palette** instead of one accent. Rules for this exception:

- The palette must be intentional and named (e.g., "70s warm: terracotta + mustard + cream + charcoal text")
- One color is still dominant (~50%), one is secondary (~30%), one is accent (~15%), neutral text (~5%)
- Never random Tailwind defaults — pick the OKLCH values intentionally
- Still no purple→blue gradient. That ban is absolute.

Default behavior remains: ONE accent. Only relax for genuine maximalist contexts.

## The Forbidden Palettes

These scream "AI generated":

- **Purple → blue gradient on white.** The single biggest tell. Banned.
- **Pure black `#000000` on pure white `#FFFFFF`.** Use tinted off-black / off-white tokens (below).
- **Pastel purple + lavender + lilac combos** ("the lila cliché"). Banned.
- **Neon green / electric purple as primary.** Use as 1px accent only.
- **Gray text on a colored background.** Always tint gray with the background hue.
- **`bg-gray-100` everywhere as the default neutral.** Choose a neutral family once and express it as tokens.

## Approved Foundations

### Tinted neutrals — pick ONE family per project

The family sets the neutral hue `H` used in every neutral token:

- **Cool** (Zinc-like, H ≈ 260–285, chroma 0.005) — premium SaaS
- **Blue-gray** (Slate-like, H ≈ 250, chroma 0.01–0.02) — tech
- **Warm** (Stone-like, H ≈ 50–70, chroma 0.005–0.01) — editorial / luxury
- **True gray** (H any, chroma 0) — brutalist / industrial

**Never mix families** within a project. Write the family into tokens once (below) and use the tokens everywhere — never literal `zinc-*` / `stone-*` classes in components.

### Accent colors that don't suck

Pick ONE per project. Light-mode values pass 4.5:1 on an off-white bg (so they work as link/text color and behind off-white button text); dark-mode values pass 4.5:1 on an off-black bg. All are inside the sRGB gamut.

| Accent        | Light mode                          | Dark mode                           |
|---------------|-------------------------------------|-------------------------------------|
| Emerald       | `oklch(0.53 0.12 158)` `#0E8050`    | `oklch(0.72 0.14 160)` `#3FBF86`    |
| Electric blue | `oklch(0.52 0.17 258)` `#1C65C8`    | `oklch(0.70 0.13 255)` `#64A1EE`    |
| Deep rose     | `oklch(0.54 0.18 8)` `#BE2F5A`      | `oklch(0.70 0.15 10)` `#EB7289`     |
| Terracotta    | `oklch(0.55 0.13 38)` `#AF5234`     | `oklch(0.72 0.12 40)` `#E4896A`     |
| Mustard       | `oklch(0.70 0.14 85)` `#C69612` — fills and large type only; pair with dark text | `oklch(0.78 0.13 85)` `#DDB049` |
| Aubergine     | `oklch(0.38 0.12 305)` `#522D74`    | `oklch(0.72 0.11 305)` `#B593DC`    |

**Keep the accent hue away from the status hues** (success ~150, warning ~70, error ~25, info ~240). An emerald accent next to an emerald success badge reads as "success" everywhere: shift the success hue (e.g. to teal ~175) or pick a different accent.

## OKLCH Over HSL

Use OKLCH for color definition. It produces perceptually uniform colors and predictable adjustments.

The canonical token set (same names as the DESIGN.md template; warm neutral H = 60, blue accent):

```css
:root {
  --bg: oklch(0.985 0.005 60);         /* page — off-white, warm tint */
  --bg-subtle: oklch(0.965 0.005 60);  /* section bands, inset areas */
  --surface: oklch(0.995 0.003 60);    /* cards, popovers */
  --fg: oklch(0.15 0.01 60);           /* body text */
  --muted: oklch(0.52 0.01 60);        /* secondary text — ≥ 4.5:1 on bg, bg-subtle and surface */
  --border: oklch(0.90 0.005 60);
  --accent: oklch(0.52 0.17 258);
  --accent-fg: oklch(0.985 0.005 60);  /* text on accent fills */
  --ring: var(--accent);               /* opaque — focus rings need ≥ 3:1 */
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg: oklch(0.12 0.005 60);
    --bg-subtle: oklch(0.15 0.005 60);
    --surface: oklch(0.18 0.005 60);
    --fg: oklch(0.96 0.005 60);
    --muted: oklch(0.70 0.01 60);
    --border: oklch(0.26 0.005 60);
    --accent: oklch(0.70 0.13 255);
    --accent-fg: oklch(0.12 0.005 60);
  }
}
```

## Tinted Shadows

Default `box-shadow: 0 0 black` is dead. Tint shadows toward the background hue.

```css
/* Bad */
.card { box-shadow: 0 4px 12px rgba(0,0,0,0.1); }

/* Good — tinted toward warm bg */
.card { box-shadow: 0 4px 12px oklch(0.4 0.02 60 / 0.08); }

/* Diffusion shadow for premium feel */
.card { box-shadow: 0 20px 40px -15px oklch(0.2 0.02 60 / 0.05); }
```

## Color in Dark Mode

- **Don't use pure black backgrounds.** Use `oklch(0.12 0.005 H)` where H matches your hue family.
- **Borders need to lift.** `oklch(0.22 0.005 H)` is your `border` token in dark mode.
- **Accents get lighter in dark mode, not more saturated.** Raise lightness to ~0.70–0.78 and keep chroma ≤ 0.15 so the color stays in gamut (see the dark column above; check new values at oklch.com).
- **Avoid white-on-black.** Use `oklch(0.96 0.005 H)` for body text, matched to the background tint.

## Status Colors

Status text must pass 4.5:1 like any text, so each status has a light and a dark value. Use the same values for icons and fills.

| Status  | Light mode                          | Dark mode                           | Never      |
|---------|-------------------------------------|-------------------------------------|------------|
| Success | `oklch(0.50 0.12 150)` `#21763C`    | `oklch(0.75 0.14 150)` `#65C67D`    | lime       |
| Warning | `oklch(0.53 0.11 70)` `#945F0E`     | `oklch(0.80 0.13 80)` `#E9B452`     | yellow     |
| Error   | `oklch(0.52 0.17 25)` `#B63132`     | `oklch(0.70 0.16 25)` `#F2716A`     | pure red   |
| Info    | `oklch(0.50 0.10 240)` `#1F6A96`    | `oklch(0.75 0.10 240)` `#70B6E7`    | neon blue  |

## Anti-Slop Color Audit

Run through this before shipping:

- [ ] Is there a purple-blue gradient? Remove it.
- [ ] Is `#000` or `#FFF` used directly? Replace with tinted neutrals.
- [ ] Is gray text on a colored background? Tint the gray.
- [ ] Is the accent color used more than 3 times per screen? Reduce.
- [ ] Are shadows untinted? Add hue.
- [ ] Is success/error using the wrong palette family? Realign.
- [ ] Are borders pure gray? Tint to match background.
- [ ] Accent chroma ≤ 0.18, inside the sRGB gamut, and hue distinct from the status colors?

## Examples By Aesthetic

| Aesthetic        | Bg                          | Fg                          | Accent         |
|------------------|-----------------------------|-----------------------------|----------------|
| Premium SaaS     | Cool off-white `oklch(0.985 0.005 270)` | Cool off-black `oklch(0.15 0.01 270)` | Emerald |
| Brutalist        | True off-white `oklch(0.98 0 0)` | True off-black `oklch(0.13 0 0)` | Electric blue |
| Luxury           | Warm off-white `oklch(0.98 0.008 70)` | Warm off-black `oklch(0.16 0.01 70)` | Aubergine |
| Editorial        | Cream `oklch(0.96 0.015 85)` | Charcoal `oklch(0.22 0.01 60)` | Deep rose   |
| Retro-futuristic | Off-black `oklch(0.13 0.01 280)` | Off-white `oklch(0.96 0.01 90)` | Mustard (dark-mode value) |
| Industrial       | True gray `oklch(0.95 0 0)`  | `oklch(0.20 0 0)`           | Terracotta     |
