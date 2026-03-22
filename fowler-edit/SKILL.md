---
name: fowler-edit
description: Use when the user wants their writing checked or edited against Fowler's rules — word choice, commonly confused pairs, spelling variants, punctuation, and usage. Trigger on requests like "edit this", "check my writing", "apply Fowler", or when text is pasted for review.
---

# Fowler Edit

## Overview

Apply *Fowler's Concise Dictionary of Modern English Usage* to user-submitted text by dispatching a subagent that has the full dictionary as context.

**Cleaned Fowler file:** `~/.claude/skills/fowler-edit/fowler-clean.md`

## Workflow

### 1. Take the user's text
If text was pasted or quoted in the message, use it directly. Don't ask clarifying questions first.

If no text was provided, ask: "Paste the text you'd like me to run through Fowler." Nothing else.

### 2. Dispatch a subagent with the full Fowler dictionary

Use the Agent tool to dispatch a `general-purpose` subagent. The subagent prompt must:
1. Read the full `fowler-clean.md` via the Read tool
2. Apply it to the user's text
3. Return corrected text + annotated changes

**Subagent prompt template:**

```
You are a copy editor with Fowler's Concise Dictionary of Modern English Usage
open in front of you.

Step 1: Read the full Fowler dictionary:
  File: ~/.claude/skills/fowler-edit/fowler-clean.md

Step 2: Read the user's text below carefully.

Step 3: Identify every word, phrase, or construct that Fowler addresses —
including but not limited to:
- Commonly confused pairs: affect/effect, that/which, fewer/less, who/whom,
  lie/lay, flaunt/flout, mitigate/militate, comprise/compose,
  disinterested/uninterested, flounder/founder
- Spelling variants: fledgling, focused, flotation, judgement
- Plurals: data, media, criteria, phenomena, agenda
- Punctuation: apostrophes, hyphens, commas before *and*
- Latinisms: i.e. vs e.g., etc., per se, split infinitives
- Prepositions: different from/to/than, compared to/with

Step 4: For each candidate, look up the relevant entry in the dictionary
(entries are formatted as **word** in bold). Check what Fowler says.

Step 5: Return two things:

a. The corrected text in full (with all changes applied, preserving the
   author's voice and style).

b. An annotated list of changes, one per line, in this format:
   - "original" → "correction" (Fowler: brief quoted reasoning)

   If Fowler has no entry for something you changed, note it as editorial
   judgment, not Fowler.

Important: Only change things Fowler actually flags. Don't change things
Fowler doesn't address. Preserve the author's voice.

---USER TEXT---
[INSERT USER TEXT HERE]
---END USER TEXT---
```

Replace `[INSERT USER TEXT HERE]` with the user's actual text before dispatching.

### 3. Return the subagent's output to the user

Present:
- **Edited text** (the corrected version)
- **Changes** (the annotated list with Fowler citations)