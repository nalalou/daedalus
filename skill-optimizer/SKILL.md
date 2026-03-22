---
name: skill-optimizer
description: Use when building, reviewing, or improving Claude skills — covers skill structure, YAML frontmatter, trigger optimization, testing strategies, MCP integration, distribution, and troubleshooting under/over-triggering. Also use when asked about skill design patterns, success criteria, or the skill-creator tool.
---

# Skill Optimizer

Based on Anthropic's official Complete Guide to Building Skills for Claude.

**IMPORTANT: When this skill loads, execute the workflow below. Do not default to your own judgment. Do not just run a checklist. Follow these steps.**

---

## When Invoked: Run This Workflow

### Step 1: Get the skill

Ask the user to paste the SKILL.md content or point you to the file. Read it in full before doing anything else. Do not proceed without reading it.

### Step 2: Diagnose the fundamental problem first

Before checking anything else, answer this question:

**Is this skill a reference doc or a workflow?**

A reference doc explains what something is. A workflow tells Claude what to DO when invoked.

Ask: Does this skill have a "When Invoked: Run This Workflow" section or equivalent that gives Claude step-by-step instructions to execute?

- If NO → the skill is a reference doc. **This is the most common and most damaging failure.** Rewrite it as a workflow before checking anything else. A skill that Claude reads but doesn't act on is useless.
- If YES → proceed to Step 3.

**The test:** When a user triggers this skill, will Claude know exactly what to do next — or will it just have more background knowledge and keep doing whatever felt natural?

### Step 3: Check the description

Read the description field. Evaluate:

1. **Does it include specific trigger phrases a user would actually say?** Not just topics — actual words. "JTBD", "run a jobs analysis", "why are users churning" are trigger phrases. "Customer needs" is a topic, not a trigger phrase.
2. **Does it say both WHAT and WHEN?** What the skill does + when to invoke it.
3. **Is it under 1024 characters?** Count if unsure.
4. **No XML tags** (`<` or `>`)?
5. **Third person** (it's injected into the system prompt)?

If description fails any of these → fix it.

### Step 4: Check the structure

- `name` field in kebab-case, no capitals, no spaces?
- File is `SKILL.md` (exact)?
- YAML frontmatter has `---` on both sides?
- No `README.md` inside the skill folder?

### Step 5: Check the content quality

Read the instructions. For each section ask:

- **Is it specific or vague?** "Make sure to validate things properly" = bad. "Before calling X, verify Y is non-empty" = good.
- **Does it tell Claude what to DO or just what to KNOW?** Knowledge without action steps = reference doc problem again.
- **Are examples concrete?** One real example beats three abstract descriptions.
- **Is it under 5,000 words?** Longer = slower responses and more likely to be ignored.

### Step 6: Identify the skill category and check fit

Anthropic identifies three patterns. Diagnose which this skill is — and whether it's written correctly for that category:

**Category 1: Document & Asset Creation**
Skill produces a consistent output artifact (document, code, design).
Needs: output template, quality checklist, style standards.

**Category 2: Workflow Automation**
Skill walks Claude through a multi-step process.
Needs: numbered steps, validation gates, clear "when done" condition.

**Category 3: MCP Enhancement**
Skill coordinates tool calls with embedded domain expertise.
Needs: explicit tool call sequences, error handling for MCP failures.

If the skill is written as Category 1 (reference) but should be Category 2 (workflow) → rewrite it.

### Step 7: Deliver a verdict and fix

Say clearly:
- What the biggest problem is (usually: reference doc, not a workflow)
- What needs to change
- Then make the changes — don't just describe them

Don't just validate and move on. If the skill has a fundamental architectural problem, fix it.

---

## Key Principles

### Skills vs Reference Docs

A reference doc: explains concepts, gives background, answers "what is X?"

A skill: tells Claude exactly what to do when invoked, answers "what do I do now?"

**The failure mode:** Skills that load as context but don't change Claude's behavior. Claude reads the skill, gains knowledge, and still does whatever felt natural. This is the most common problem and the hardest to notice because it looks like the skill "worked."

**The fix:** Every skill needs a "When Invoked: Run This Workflow" section with numbered steps Claude must follow.

### Description = Trigger, Not Summary

The description is how Claude decides whether to load the skill. It's read in every conversation. It must answer: "Should I load this skill right now?"

Write trigger phrases, not summaries. Users won't say "I need customer needs analysis" — they'll say "why are users churning" or "run a JTBD analysis." Those exact phrases belong in the description.

### The Workflow Architecture Test

For any skill, ask: if a user triggers this skill and Claude does nothing but follow its instructions, will the user get value?

If Claude needs to improvise, interpret, or fill gaps — the skill isn't done yet.

---

## YAML Frontmatter Rules

```yaml
---
name: your-skill-name          # kebab-case only, no capitals
description: [WHAT it does]. Use when user [specific trigger phrases].
---
```

**Description must have:**
- What the skill does
- Specific phrases users would say to trigger it
- Under 1024 characters
- No XML tags, written in third person

---

## Common Failure Modes

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| Skill loads but Claude ignores it | No workflow section — skill is a reference doc | Add "When Invoked: Run This Workflow" with numbered steps |
| Skill doesn't trigger | Description has topics, not trigger phrases | Add exact words users would say |
| Skill triggers too broadly | Description is too vague | Add specific context, add negative triggers |
| Skill gives inconsistent results | Instructions are vague ("make sure to validate") | Rewrite instructions as specific steps |
| Responses are slow | SKILL.md too large | Move docs to `references/`, keep SKILL.md under 5,000 words |

---

## Structure Reference

```
your-skill-name/
├── SKILL.md          # Required — instructions with YAML frontmatter
├── references/       # Optional — heavy docs loaded on demand
├── scripts/          # Optional — executable tools
└── assets/           # Optional — templates, icons
```

---

## Distribution

**Claude Code:** Copy folder to `~/.claude/skills/`

**Claude.ai:** Zip the folder → Settings → Capabilities → Skills → Upload

**API:** Use `container.skills` parameter in Messages API requests

---

*Source: Anthropic's Complete Guide to Building Skills for Claude*
