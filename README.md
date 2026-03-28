# daedalus

Tools for your agent.

***

## Skills

### `ux-best-practices`

Guidelines from 487 Nielsen Norman Group reports — usability testing across 57+ organizations, 350+ ecommerce sites, and studies in 8 countries over two decades. Covers navigation, search, forms, ecommerce, mobile, intranets, accessibility, children's UX, and research methods.

### `jobs-to-be-done`

Walks you through a JTBD analysis step by step. Surfaces the struggling moment, writes job statements in the right format, maps functional/social/emotional dimensions, and identifies real competition — including nonconsumption. One rule is baked in: jobs describe what customers are trying to accomplish, not what the business wants to achieve.

### `content-design`

Content design system work in four modes: create content standards from scratch, audit existing content for inconsistencies, write component-level guidelines (buttons, error messages, empty states), or evaluate copy against existing standards. Based on Nielsen Norman Group's content design systems framework.

### `skill-optimizer`

Reviews a skill and tells you what's wrong with it. Catches the most common failure mode first: skills that load as background context but don't actually change what Claude does.

### `test-agent`

Scaffolds a background test agent for any vitest/jest project. Auto-detects your framework, finds exemplar tests, and generates a tmux-based agent that continuously writes missing tests via Claude. Five quality gates — assertion lint, passes, coverage, mutation check, full suite — with retry-on-failure feedback. Prioritizes complex files (most branches first) and skips files it can't crack.

### `fowler-edit`

Copy editing against the full Fowler's Concise Dictionary of Modern English Usage. Returns corrected text with each change cited to the Fowler entry that justifies it.

***

## Installing

**Claude Code:**

```bash
cp -r <skill-folder> ~/.claude/skills/
```

**Claude.ai:**
Zip the folder → Settings → Capabilities → Skills → Upload

***

## Sources

* UX: [Nielsen Norman Group](https://www.nngroup.com/reports/)

* Content design: [Nielsen Norman Group — Content Standards in Design Systems](https://www.nngroup.com/articles/content-design-systems/)

* JTBD: Christensen, Hall, Dillon & Duncan — HBR

* Skill structure: Anthropic's Complete Guide to Building Skills for Claude

* Copy editing: Fowler's Concise Dictionary of Modern English Usage

