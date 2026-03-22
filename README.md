# daedalus

A collection of Claude skills built from real research and documentation — ready to drop into Claude Code or Claude.ai.

---

## What's inside

### `ux-best-practices`

Everything you need to make confident UX decisions, backed by actual research instead of vibes.

Draws from 487 Nielsen Norman Group reports — usability testing across 57+ organizations, 350+ ecommerce sites, and studies in 8 countries spanning 2001–2023. Covers navigation, search, forms, ecommerce checkout, mobile/tablet, intranets, accessibility, children's UX, and research methods.

### `jobs-to-be-done`

A 7-step workflow for running a proper JTBD analysis. Not just the theory — Claude will actually walk you through surfacing the struggling moment, writing job statements in the right format, mapping functional/social/emotional dimensions, and identifying real competition (including nonconsumption).

Based on Christensen et al., "Know Your Customers' Jobs to Be Done" (HBR). Built with one rule baked in: jobs are never business objectives.

### `skill-optimizer`

Reviews your Claude skills and tells you what's actually wrong with them. The most common problem — skills that load as context but don't change Claude's behavior — gets caught first.

Based on Anthropic's official Complete Guide to Building Skills for Claude.

### `fowler-edit`

A copy editor backed by the full Fowler's Concise Dictionary of Modern English Usage. Paste any text and get back a corrected version with annotated changes, each one cited to the specific Fowler entry that justifies it.

---

## Installing a skill

**Claude Code:**
```bash
cp -r <skill-folder> ~/.claude/skills/
```

**Claude.ai:**
1. Zip the skill folder
2. Go to Settings → Capabilities → Skills → Upload

That's it. Skills load automatically when relevant.

---

## Sources

- UX guidelines: [Nielsen Norman Group](https://www.nngroup.com/reports/)
- JTBD framework: Christensen, Hall, Dillon & Duncan — Harvard Business Review
- Skill structure: Anthropic's Complete Guide to Building Skills for Claude

---

## More skills coming

Open an issue if you have a source worth turning into one.
