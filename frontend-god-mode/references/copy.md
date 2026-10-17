# Copy & Microcopy Reference

Bad copy gives away AI output as fast as Inter does. "Elevate your seamless next-gen experience" is the textual equivalent of a purple gradient. This reference fixes that.

## The Banned Vocabulary

These words signal AI output. Replace every instance:

| Banned word        | Why it sucks                          | Use instead                                |
|--------------------|---------------------------------------|--------------------------------------------|
| Elevate            | Empty buzzword                        | Concrete verb (improve, refine, ship)      |
| Seamless           | Means nothing, used everywhere        | Cut, or describe what's actually smooth    |
| Unleash            | Sales-speak                           | Cut, or use a verb tied to user benefit    |
| Next-gen           | Generic                               | Be specific about what makes it new        |
| Game-changing      | Cliché                                | State the actual change                    |
| Revolutionary      | Almost never true                     | Cut, describe the difference               |
| Cutting-edge       | Self-congratulatory                   | Show, don't tell                           |
| Robust             | Vague                                 | Specific quality (handles 1.2M req/s, etc.)  |
| Powerful           | Says nothing                          | Specific capability                        |
| Innovative         | Self-applied is suspicious            | Concrete novel behavior                    |
| Streamline         | Corporate-speak                       | Specific shortcut/improvement              |
| Empower            | HR-speak                              | Concrete verb                              |
| Best-in-class      | Marketing slop                        | Cite actual benchmark or cut               |
| World-class        | Same                                  | Same                                       |
| Solution           | Generic                               | Name the specific tool/feature             |
| Holistic           | Hollow                                | Describe what's covered                    |
| Synergy            | 2002 corporate                        | Cut entirely                               |
| Leverage (verb)    | Consultant-speak                      | "Use" — works fine                         |
| In the realm of... | AI tone                               | State the topic directly                   |
| Whether you're...  | Listicle opener                       | State who it's for plainly                 |
| From X to Y        | Lazy spectrum                         | Specific examples                          |

## Hero Headline Patterns

### What works
- **Specific outcome:** "Catch p99 spikes before PagerDuty does."
- **Anti-cliché twist:** "We don't make the dashboard prettier. We make it stop lying."
- **Plainspoken benefit:** "Receipts. In your inbox. Within 90 seconds."
- **Confident understatement:** "Logs that don't ruin your weekend."
- **Direct address:** "You ship faster with fewer bugs."

### What doesn't
- Bad: "Elevate your business with our seamless solution"
- Bad: "Unleash the power of next-gen analytics"
- Bad: "Revolutionary platform for modern teams"
- Bad: "From idea to launch — we've got you covered"

## Subhead Patterns

Always concrete. Often specific numbers or named technologies.

Good: "Drop-in replacement for Datadog logs. 1/4 the price."
Good: "TypeScript SDK, REST API, and a CLI. No SDK lock-in."
Good: "Tested at 47.3M events/day. Production since 2024."

Bad: "A comprehensive solution for all your observability needs"
Bad: "Built for the modern enterprise"
Bad: "Powering teams worldwide"

## Button Labels

### Always (good defaults)
- "Get started" — for free signups
- "Start free trial" — when there IS a trial
- "See pricing" — for SaaS that won't show pricing inline
- "Talk to sales" — only if you're enterprise-only
- "Read the docs" — for dev-tooling
- "Watch demo (90s)" — include the duration

### Specific over generic
- Good: "Send invoice" → not "Submit"
- Good: "Save draft" → not "Save"
- Good: "Cancel reservation" → not "Cancel"
- Good: "Delete project" → not "Delete"

### Banned
- Bad: "Click here"
- Bad: "Submit" (always more specific)
- Bad: "Learn more" (use "See how it works" or specific)
- Bad: "Sign up now" (the "now" is filler)
- Bad: ALL CAPS (unless brand intentional)

## Empty States

The default AI empty state is "No results found." Don't.

### Pattern
```
[Title] - what's missing, in plain language
[Body] - one short line explaining how to populate it
[Action button] - the verb to fix it
```

### Examples

Good: **Good:**
> **No invoices yet.**
> Once you create your first invoice, it'll show up here.
> [Create invoice]

Good: **Good:**
> **You're all caught up.**
> No new mentions. We'll notify you when something needs your attention.

Bad: **Bad:**
> No items found
> Try adjusting your filters
> [Clear filters]

## Error Messages

Errors should be honest, specific, and actionable.

### Pattern
```
[What broke, plainly]. [How to fix it, if known].
```

### Examples

Good: **Good:**
> "We couldn't reach the payment processor. Check your connection and try again — we didn't charge you."

Good: **Good:**
> "Email format looks off. Should be like name@example.com."

Good: **Good:**
> "Project deleted. Undo within 30 seconds."

Bad: **Bad:**
> "Something went wrong. Please try again."
> "Error: 500 Internal Server Error"
> "Invalid input"

## Loading States

Don't say "Loading..." Show what's happening.

Good: "Fetching the last 30 days..."
Good: "Compiling your TypeScript (47 files)..."
Good: "Sending invoice to accounts@example.com..."

Bad: "Loading..."
Bad: "Please wait..."

## Microcopy in Forms

### Field labels
- Concrete: "Email" not "Email address"
- Noun labels: "Project name", not imperative "Name your project"

### Placeholders (NOT labels — use real labels)
- Show format: `name@company.com`, not `Enter email`
- Show example: `Q3 launch plan`, not `Enter project name`

### Helper text (under field, before user types)
- One short line max
- Anticipates the question they'd ask

Good: "We'll only use this to send the receipt."
Good: "8+ characters, including a number."

### Validation errors (under field, after submit)
- Lead with what's wrong
- Then how to fix

Good: "Password too short. Add 4 more characters."
Good: "That email's already in use. Sign in instead?"

## Brand / Product Names (When Inventing Placeholders)

The skill bans "Acme", "Nexus", "SmartFlow." Invent names from the product's own domain instead, and check the name isn't a well-known real company before using it (Lattice, Fathom, Linear, Notion are real).

Patterns that work:

- **Two concrete nouns joined:** `<material> & <tool>` — e.g. "Cinder & Spar"
- **A craft or trade term:** a word from the domain's own vocabulary — e.g. "Halftone" for a print magazine
- **Place + function:** a fictional or minor place name + what it does — e.g. "Westmark Tools"
- **A precise verb or noun, slightly unusual:** e.g. "Threadwell"

Never reuse these examples — they show the pattern, not names to copy.

### People names

Varied by culture and context, full names, a few with hyphens or particles, matched to the product's market. Never "John Doe", "Jane Smith", "Sarah Chen", "Mike Wilson", or any name copied from this skill.

## Copy Checks

The shared copy items are in **Final Pre-Flight** (`anti-slop.md`). Also check:

- Hero headline is specific and concrete (not a generic benefit)
- Button labels use specific verbs (not "Submit" / "Click here")
- Error messages explain what broke and how to fix it
- Loading states show progress detail
- Form placeholders show format, not a duplicate of the label
