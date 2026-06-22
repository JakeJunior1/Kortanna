---
name: design-md-reference
description: >-
  When building or restyling a frontend UI to match a SPECIFIC named brand or a
  concrete named aesthetic — e.g. "make it look like Linear / Stripe / Airbnb /
  Ferrari", "match our Vercel-style dashboard", "use Coinbase's design language" —
  fetch that brand's ready-made DESIGN.md from the VoltAgent/awesome-design-md
  library and use it as the style source (pairs with the ui-ux-pro-max skill). Do
  NOT use for generic frontend work where no particular brand or reference look is
  requested.
---

# design-md-reference

A drop-in style source for **brand-matched** UI work. `VoltAgent/awesome-design-md`
(MIT, ~74 brands) is a library of ready-made `DESIGN.md` files reverse-engineered
from popular brand design systems — color tokens, type scale, spacing, component
language. Each file is the style contract: feed it to the UI generator so the
result matches the target brand instead of looking generic.

## When this applies
- The user wants a UI to look like a **specific brand** (Linear, Stripe, Airbnb,
  Vercel, Ferrari, Coinbase, Figma, Cohere, …) or names a concrete reference look.
- **Skip it** when the request is generic ("build a dashboard") with no brand or
  reference aesthetic in mind — forcing an unrelated brand's system on it is wrong.

## Steps
1. **Identify the target brand / aesthetic** from the request. If it's ambiguous
   which brand to match, ask before fetching.
2. **Confirm it's in the library — read the list live, never hardcode it** (the
   repo adds brands over time):
   ```bash
   gh api repos/VoltAgent/awesome-design-md/contents/design-md --paginate \
     --jq '.[] | select(.type=="dir") | .name'
   ```
   No `gh`? Public, no-auth fallback:
   ```bash
   curl -sS https://api.github.com/repos/VoltAgent/awesome-design-md/contents/design-md \
     | jq -r '.[] | select(.type=="dir") | .name'
   ```
   Folder names are slugs (e.g. `linear.app`, `bmw-m`, `clickhouse`). If there's no
   match, surface the closest options or proceed without — **never substitute a
   different brand silently.**
3. **Fetch that brand's DESIGN.md** (raw, default branch `main`):
   ```bash
   curl -sS https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/<brand>/DESIGN.md
   ```
4. **Use it as the style source.** Read it as the design contract and hand it to
   `ui-ux-pro-max` when generating or refactoring the UI. If the user wants it kept
   around, vendor a copy into the project (e.g. `design/<brand>.DESIGN.md`);
   otherwise just use it as in-context reference. Only the file(s) you need are
   pulled, per task — nothing is installed up front.

## Related
- `bergside/design-md-chrome` is the **inverse** tool — a Chrome extension that
  *generates* a fresh DESIGN.md from a live website you point it at. Reach for that
  (manually) when the look you want is a specific site that isn't in this library.
