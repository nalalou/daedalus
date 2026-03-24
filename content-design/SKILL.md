---
name: content-design
description: Guides Claude through content design system work — creating content standards, auditing existing content, writing component-level content guidelines, or evaluating copy against a design system. Use when the user says "content standards", "content design system", "audit our copy", "write content guidelines", "UX writing standards", "style guide for components", "content for our design system", "voice and tone", or "review our content consistency".
---

# Content Design System Skill

Based on Nielsen Norman Group's framework for content standards in design systems.

## When Invoked: Run This Workflow

Ask the user which mode they need, then follow that branch exactly.

---

## Step 1: Identify the Mode

Ask: **What are you trying to do?**

1. **Create** — Build new content standards (for a product, team, or design system)
2. **Audit** — Review existing content for inconsistencies and gaps
3. **Component** — Write content guidelines for a specific UI component
4. **Evaluate** — Check a piece of copy against existing content standards

Do not proceed until you know the mode.

---

## Mode 1: Create Content Standards

### 1A. Scope the work

Ask:
- What product or surface is this for? (app, marketing site, onboarding flow, etc.)
- Do you have an existing design system? If so, are content standards currently part of it?
- What's the biggest content pain point right now? (inconsistency, slow review cycles, off-brand copy, AI misuse)

### 1B. Establish the two categories

Build standards in this order:

**Content-Strategy & Process Standards** (the rules for how content gets made):
- Content goals and principles (2–4 sentences max)
- Team roles: who writes, who reviews, who approves
- Workflow: draft → review → publish → maintain
- Tooling: where content lives, how it's versioned, AI platform guidelines

**Content-Creation & Design Standards** (the rules for what content looks like):
- Voice and tone: what words and feeling represent the brand
- Editorial guidelines: grammar, punctuation, capitalization conventions
- Readability targets: reading level, sentence length, plain language rules
- Accessibility: alt text, link text, error messages, form labels
- Format: heading hierarchy, list rules, button label patterns

### 1C. Global vs. component-specific split

Produce a **global standards** section first — rules that apply everywhere. Then flag which standards need component-specific variants (e.g., empty states, CTAs, tooltips, error messages get their own guidance).

### 1D. Output format

Deliver as a structured document:

```
# Content Standards: [Product/Team Name]

## 1. Content Goals & Principles
## 2. Roles & Workflow
## 3. Voice & Tone
## 4. Editorial Guidelines
## 5. Accessibility & Inclusivity
## 6. AI Usage Guidelines
## 7. Component-Specific Standards
   - Buttons & CTAs
   - Error Messages
   - Empty States
   - Tooltips & Helper Text
   - Form Labels & Placeholders
## 8. Governance: How to Update These Standards
```

Include **Do / Don't** examples for every rule that could be misinterpreted.

---

## Mode 2: Audit Existing Content

### 2A. Get the content

Ask the user to paste or describe the content to audit. If it's a product, ask for representative samples from: onboarding, error states, empty states, navigation labels, CTAs, and notifications.

### 2B. Evaluate against these dimensions

For each content area, score: **Consistent / Inconsistent / Missing**

| Dimension | What to check |
|-----------|--------------|
| Voice consistency | Same brand personality across all surfaces? |
| Terminology | Same words used for the same things? |
| Reading level | Plain language? No jargon? |
| Accessibility | Alt text, link text, labels present and descriptive? |
| Button/CTA patterns | Action verbs? Parallel structure? |
| Error messages | Explain what went wrong + how to fix it? |
| Empty states | Tell users what to do, not just "nothing here"? |
| Tone-context fit | Playful where it should be, serious where needed? |

### 2C. Deliver findings

Structure the output as:
1. **Summary**: 3 biggest consistency issues
2. **Inventory table**: each content area → status → example of the problem
3. **Priority fixes**: top 5 changes with before/after rewrites
4. **Gaps**: what standards are missing that would prevent these issues

---

## Mode 3: Component Content Guidelines

### 3A. Identify the component

Ask: Which component? (Button, tooltip, error message, empty state, modal, notification, form label, placeholder, etc.)

### 3B. Write guidelines using this structure for every component

```
## [Component Name] Content Guidelines

### Purpose
What job does this component do for the user?

### Writing Rules
- Rule 1 (with rationale)
- Rule 2 (with rationale)

### Do / Don't Examples
| Do | Don't |
|----|-------|
| "Save changes" | "Click here" |

### Accessibility Notes
What content requirements exist for screen readers, keyboard nav, etc.?

### AI Usage Note
If AI generates content for this component, what guardrails apply?
```

### 3C. Ask if they need multiple components

After delivering one, ask: "Want me to do another component, or should I add these to a full standards doc?"

---

## Mode 4: Evaluate Copy Against Standards

### 4A. Get both inputs

Ask for:
1. The copy to evaluate (paste it)
2. The content standards to evaluate against (paste them, or describe the key rules)

If they don't have written standards, ask them to describe the brand voice and key rules informally — use that as the benchmark.

### 4B. Evaluate systematically

Check the copy against:
- Voice & tone match
- Plain language and readability
- Accessibility (labels, alt text, error clarity)
- Terminology consistency
- CTA/button pattern adherence
- Grammar/punctuation conventions

### 4C. Deliver a verdict + rewrite

- **Pass / Needs Work / Rewrite** verdict with reasoning
- Specific line-by-line notes
- Rewritten version that passes all checks

---

## Principles to Apply in Every Mode

**Standards enable creativity, they don't restrict it.** Frame standards as decisions already made so writers can focus on the hard creative work.

**Global before specific.** Always establish global rules before component exceptions. Component guidance should reference, not repeat, global rules.

**Concrete over abstract.** Every rule needs a Do/Don't example. "Write clearly" is not a rule. "Keep button labels under 4 words and lead with a verb" is a rule.

**AI-aware.** For any product using AI-generated content, explicitly address what the AI can/cannot do within the content standards. This is now a required section, not optional.

**Governance is not optional.** Every set of standards needs: who owns it, how to update it, and when to review it (minimum annually, plus when major components change).
