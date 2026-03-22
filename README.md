# daedalus

A collection of Claude skills built from real research and documentation — ready to drop into Claude Code or Claude.ai.

---

## What's inside

### `ux-best-practices`

Everything you need to make confident UX decisions, backed by actual research instead of vibes.

This skill draws from 487 Nielsen Norman Group reports — the result of usability testing across 57+ organizations, 350+ ecommerce sites, and studies in 8 countries spanning 2001–2023. It covers:

- **Navigation & Information Architecture** — menus, breadcrumbs, labeling, depth vs. breadth
- **Search** — placement, autocomplete, faceted filtering, zero-results handling
- **Forms** — layout, validation, error messages, required fields, mobile keyboards
- **Ecommerce** — cart design, checkout flow, guest checkout, trust signals, payment UX
- **Mobile & Tablet** — touch targets, thumb zones, gestures, performance
- **Intranets & Enterprise** — content governance, employee search, personalization
- **Accessibility** — WCAG 2.1 AA, color contrast, keyboard nav, focus indicators, ARIA
- **Children's UX (ages 3–12)** — age-appropriate patterns tested in the US, China, and Israel
- **UX Research Methods** — usability testing, card sorting, tree testing, A/B, diary studies

---

## Installing a skill

**Option A — Claude.ai:**
1. Download the skill folder and zip it
2. Go to Claude.ai → Settings → Capabilities → Skills
3. Upload the zip

**Option B — Claude Code:**
```bash
cp -r ux-best-practices ~/.claude/skills/
```

That's it. Restart Claude Code and the skill is live.

---

## Using the skills

Once installed, skills load automatically. If you're designing a checkout flow, auditing a navigation menu, or asking about touch target sizes — the relevant skill will kick in without you having to think about it.

---

## Sources

All UX guidelines come from [Nielsen Norman Group](https://www.nngroup.com/reports/) research. NN/g has been running usability studies since the 90s and their reports are about as close to ground truth as UX research gets.

---

## More skills coming

This repo will grow. If you want to suggest a source worth turning into a skill, open an issue.
