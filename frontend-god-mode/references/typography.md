# Typography Reference

Typography is the single highest-leverage design choice. Get it right and everything else looks expensive. Get it wrong and the whole thing looks like a default ChatGPT artifact.

## The Banned List

Never use these as the primary face unless the user or brand requires them (see Precedence in SKILL.md):

- **Inter** (regular cut) — the AI tell. Banned everywhere; `Inter Tight` / `Inter Display` are allowed as body cuts only.
- **Roboto, Arial, Helvetica, system-ui** — generic, lifeless.
- **Times New Roman, Georgia** as body — dated.
- **Comic Sans, Papyrus, Lobster** — unless explicitly requested for ironic/playful contexts.

## The Approved Stack — Pick One Pairing Per Project

Match the pairing to the aesthetic direction. **Do not cross pairings.** Vary your picks across projects — the first option in each list is not a default, and no single family (Geist, Space Grotesk, Satoshi) should become your house font.

### For premium SaaS / dashboards / software UIs
- **Display + body, mono:** Geist, Geist Mono
- **Display + body, mono:** Satoshi, JetBrains Mono
- **Display / body:** Cabinet Grotesk / Inter Tight (only Tight, never plain Inter)
- **Display + body, mono:** Hanken Grotesk, IBM Plex Mono
- Tabular numbers are mandatory for data (`tabular-nums`, or `font-mono` on metrics).

### For creative / editorial / agency
- **Display:** PP Editorial New (italic), Reckless, Tiempos Headline, Söhne Breit
- **Body:** Söhne (Buch weight), Inter Display (the display cut, NOT regular Inter)
- **Accent:** Italic serif eyebrow + sans body for editorial pop

### For brutalist / industrial
- **Display:** Neue Haas Grotesk, Akkurat Mono, IBM Plex Mono
- **Body:** Inter Tight, Söhne Mono
- **All-caps with tight tracking** for headers

### For luxury / refined
- **Display:** GT Sectra, Canela, PP Editorial New
- **Body:** Söhne (Buch weight), Inter Display, Cormorant Garamond (body italic)

### For playful / toy
- **Display:** Cooper BT, Fraunces (weight 800–900, `'SOFT' 100`), Bagel Fat One, Outfit at heavy weights
- **Body:** Outfit, Plus Jakarta Sans

### For retro-futuristic / tech
- **Display:** Space Grotesk (use sparingly — overused), Departure Mono, JetBrains Mono
- **Body:** Inter Tight, Söhne Mono

## Hierarchy Rules

- **Display H1:** `text-4xl md:text-6xl lg:text-7xl tracking-tighter leading-[0.95]`
- **H2:** `text-2xl md:text-4xl tracking-tight leading-tight`
- **H3:** `text-xl md:text-2xl tracking-tight`
- **Body:** `text-base leading-relaxed max-w-[65ch]` — never wider than 65 characters
- **Small / caption:** `text-sm text-[var(--muted)] tracking-wide uppercase` (uppercase only for labels under 4 words)

## Anti-Patterns

- **Oversized H1 that screams.** Control hierarchy with weight + color, not just scale.
- **Serif on a dashboard.** Banned. Dashboards = clean sans-serif only.
- **Gradient text fill on large headers.** Cliché. Use solid color with tight tracking instead.
- **All-caps body copy.** Never. All-caps is for labels < 4 words.
- **`text-center` on long paragraphs.** Left-aligned is more readable. Center only short hero copy or eyebrows.
- **Ignoring optical kerning.** Display headers need `tracking-tighter` or `tracking-tight`.

## Loading Fonts

Always self-host. Never ship a Google Fonts `<link>` as the production loading strategy.

- **Next.js:** `next/font` — see `frameworks/react.md`.
- **Everything else (Vue, Nuxt, SvelteKit, Angular, Astro, Vite):** Fontsource packages imported in the global stylesheet, mapped to `--font-sans` / `--font-mono` in Tailwind's `@theme` — see `frameworks/<framework>.md`.
- **Paid / non-Fontsource fonts:** `@font-face` with `font-display: swap` pointing at self-hosted `woff2` files.

## Font Licensing & Free Fallbacks

Some recommended fonts are paid/licensed. Use these free fallbacks if the user can't or won't license:

| Paid font            | Free fallback                                           |
|----------------------|---------------------------------------------------------|
| PP Editorial New     | Instrument Serif (Google Fonts)                         |
| Söhne                | Inter Tight (Google) — only the Tight cut, never plain  |
| Söhne Breit          | Archivo at an expanded width (Google, `wdth` axis)      |
| GT Sectra            | Fraunces (Google), or Cormorant Garamond                |
| Canela               | Gloock or Fraunces (Google)                             |
| Reckless             | Newsreader (Google)                                     |
| Tiempos Headline     | Source Serif 4 (Google)                                 |
| Neue Haas Grotesk    | Archivo (display) + Inter Tight (body), both Google     |
| Akkurat Mono         | JetBrains Mono (Google)                                 |
| Cooper BT            | Fraunces (Google), weight 800–900, `font-variation-settings: 'SOFT' 100` |
| Söhne Mono           | JetBrains Mono                                          |

**Free from Fontshare (ITF Free Font License, commercial use OK):** Satoshi, Cabinet Grotesk. They aren't on Google Fonts or Fontsource — download the woff2 and self-host with `@font-face` (`next/font/local` in Next.js).

**Free on Google Fonts and Fontsource:** Geist + Geist Mono, Hanken Grotesk, Archivo, JetBrains Mono, IBM Plex Mono, Outfit, Plus Jakarta Sans, Instrument Serif, Fraunces, Gloock, Newsreader, Source Serif 4, Cormorant Garamond, Space Grotesk, Bagel Fat One.

**Free, self-host only:** Departure Mono (OFL, from departuremono.com — not on Google Fonts or Fontsource).

Paid fonts are always self-hosted: `next/font/local` in Next.js, `@font-face` + woff2 everywhere else.

## Font Pairing Examples That Always Work

| Aesthetic        | Display          | Body             | Mono           |
|------------------|------------------|------------------|----------------|
| Premium SaaS     | Geist            | Geist            | Geist Mono     |
| Precise SaaS     | Hanken Grotesk   | Hanken Grotesk   | IBM Plex Mono  |
| Editorial agency | PP Editorial New | Söhne            | —              |
| Brutalist        | Neue Haas Grotesk| Inter Tight      | IBM Plex Mono  |
| Luxury           | GT Sectra        | Söhne            | —              |
| Playful          | Outfit (Heavy)   | Plus Jakarta Sans| —              |
| Retro tech       | Departure Mono   | Inter Tight      | JetBrains Mono |

## OpenType Tips

- Tabular numbers for data: `font-variant-numeric: tabular-nums` (Tailwind `tabular-nums`)
- Stylistic sets / character variants on display type (font-specific — check what the font ships): `font-feature-settings: 'ss01', 'cv01'`
- For italic serif eyebrows above headers: works wonders on editorial layouts

## Final Check

Typography items are in **Final Pre-Flight** (`anti-slop.md`). Also confirm the hierarchy reads in three glances: title, subtitle, body.
