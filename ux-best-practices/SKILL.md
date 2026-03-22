---
name: ux-best-practices
description: Use when designing or evaluating user interfaces — covers usability heuristics, information architecture, navigation, search, e-commerce checkout flows, intranet design, mobile/tablet UX, and UX for special populations (children, seniors). Source: Nielsen Norman Group empirical research reports.
doc_version: NN/g 4th Edition (2023)
---

# UX Best Practices Skill

Evidence-based UX design guidelines drawn from Nielsen Norman Group (NN/g) empirical research — usability testing across 57+ organizations, 350+ e-commerce sites, and studies in 8+ countries.

**Source:** `references/reports.md` — 487 pages of NN/g research reports covering intranet design, e-commerce UX, mobile/tablet UX, and design for children.

---

## When to Use This Skill

Trigger this skill when:

- **Designing UI components** — navigation menus, search bars, shopping carts, checkout flows, forms
- **Reviewing existing designs** — auditing for usability, findability, or conversion issues
- **Building intranet or enterprise tools** — employee portals, content management, workplace search
- **Designing e-commerce experiences** — product pages, cart, checkout, registration flows
- **Designing for mobile or tablet** — responsive design decisions, touch targets, layout adaptation
- **Designing for children (ages 3–12)** — age-appropriate interfaces, educational apps
- **Improving information architecture** — site structure, labeling, categorization, wayfinding
- **Writing UX audit criteria** — generating heuristics or review checklists backed by research

---

## Key Concepts

### The NN/g Research Methodology
All guidelines in `references/reports.md` are based on empirical user testing (not opinion):
- **Usability testing** — task-based studies with representative users
- **Field studies** — in-context observation of real workflows
- **Expert reviews** — structured heuristic evaluation
- **Eye-tracking and click studies** — attention and interaction patterns

Confidence is proportional to sample size. Guidelines from 57-organization intranet studies or 350+ e-commerce sites carry high confidence.

### Guideline Categories
The source reports organize guidelines into four main domains:

| Domain | Source Report | Guidelines |
|---|---|---|
| Intranet content & governance | Intranet Usability Guidelines Vol. 1 | 73 |
| Intranet navigation & IA | Intranet Usability Guidelines Vol. 2 | 82 |
| Intranet search | Intranet Usability Guidelines Vol. 3 | 82 |
| Intranet branding & interaction | Intranet Usability Guidelines Vol. 4 | 61 |
| E-commerce checkout & cart | Ecommerce UX Vol. 04 | 137 |
| Tablet UX | Tablet Website and Application UX | 126 |
| Children's UX (ages 3–12) | UX Design for Children, 4th Ed. | 156 |

---

## Quick Reference

### 1. Intranet Usability — Core Principles
*From: NN/g Intranet Usability Guidelines (4th Edition, 57 organizations tested)*

```
CONTENT MANAGEMENT (73 guidelines)
- Align content with both employee information needs AND org communication goals
- Establish clear content ownership and governance workflows
- Use plain language; avoid internal jargon for cross-department content

INFORMATION ARCHITECTURE & NAVIGATION (82 guidelines)
- Design menus based on user mental models, not org chart structure
- Provide consistent global navigation; avoid deep nesting (>3 levels)
- Use descriptive link labels — avoid "click here" and generic terms
- Support both browsing AND search as co-equal entry points

SEARCH (82 guidelines)
- Surface search prominently; users expect it in the top-right or center-top
- Return results with clear source attribution (department, date, file type)
- Support faceted filtering by content type, date, and author

BRANDING & INTERACTION (61 guidelines)
- Visual design sets trust expectations — inconsistent UI reduces confidence
- Use the organization's brand to create a familiar, trusted environment
- Ensure interactive elements are visually distinct from static content
```

### 2. E-Commerce Checkout & Cart
*From: NN/g Ecommerce UX Vol. 04 — 137 guidelines, 350+ sites tested in US/UK/DK/IN/CN*

```
SHOPPING CART
- Show cart contents, prices, and totals without requiring navigation away
- Allow quantity editing and item removal directly in the cart
- Persist cart contents across sessions (logged-in and guest users)
- Display estimated shipping cost early — surprises at checkout cause abandonment

CHECKOUT FLOW
- Minimize required fields — only collect what is necessary to complete purchase
- Support guest checkout without mandatory account creation
- Provide inline validation (not just end-of-form errors)
- Show a clear progress indicator for multi-step checkout
- Offer multiple payment options (card, PayPal, digital wallets)

REGISTRATION
- Delay registration prompts until after purchase completion
- Frame account creation as a benefit ("Save your order history") not a gate
```

### 3. Tablet UX
*From: NN/g Tablet Website and Application UX — 126 guidelines, 6 rounds of studies*

```
- Tablets are NOT scaled-up phones — users browse and read more than on phones
- Many standard websites work adequately on tablets with minor adjustments
- Touch targets must be at minimum 44×44 points (no hover-only interactions)
- Support both portrait and landscape orientations with meaningful layout shifts
- Avoid flash, complex hover states, and cursor-dependent interactions
- Users treat tablets as browsing/consumption devices, not creation tools
```

### 4. Children's UX (Ages 3–12)
*From: NN/g UX Design for Children, 4th Edition — 156 guidelines, studies in US/CN/IL*

```
AGES 3–5 (Pre-readers)
- Use large touch targets; fine motor control is still developing
- Rely on audio cues and icons rather than text labels
- Avoid time pressure; children disengage from timed tasks quickly

AGES 6–8 (Early readers)
- Support both reading and audio — literacy varies within age group
- Keep navigation extremely simple; breadcrumbs are too abstract
- Use rewards and positive feedback consistently

AGES 9–12 (Competent digital users)
- More tolerant of complexity, but still prefer clear, direct IA
- Social features become relevant (sharing, commenting)
- Respect privacy expectations — avoid personal data collection dark patterns

GENERAL (all ages)
- Children are selective; they abandon experiences that don't quickly reward them
- Test with real children — adult proxies are unreliable predictors of child behavior
- Mobile and tablet testing is essential since 4th edition (2023)
```

### 5. Intranet Design Annual — Award-Winning Patterns
*From: NN/g Intranet Design Annual 2020 — 10 best intranets, 189 before/after screenshots*

```
- Winning intranets prioritize employee task completion over organizational announcements
- Before/after redesigns consistently show reduction in navigation depth
- Personalization (role-based or department-based homepages) appears in most winners
- Search is always prominently placed and returns relevant, filterable results
- Mobile access is a standard feature, not an enhancement, in winning designs
```

---

## Working with This Skill

### For Beginners
Start with the **Quick Reference** above for the domain most relevant to your task. The NN/g guidelines are organized by domain — pick the closest match (intranet, e-commerce, tablet, or children's UX).

### For Specific Design Decisions
Read `references/reports.md` for the relevant report section. Each report entry includes:
- Research scope (number of sites/orgs tested, countries)
- Number of design guidelines
- Topics covered

Look up the specific topic area in the report that matches your design question.

### For Design Audits / Heuristic Reviews
Use the guideline counts as a checklist framework:
1. Identify which domain applies (intranet, e-commerce, tablet, children's)
2. Reference the corresponding guideline set
3. For each heuristic, evaluate whether your design satisfies, partially satisfies, or violates it
4. Prioritize violations by frequency and severity (how often users encounter it, how much it impairs success)

### For Advanced Users
Cross-reference multiple domain reports when designs span contexts (e.g., an intranet with embedded e-commerce, or a tablet app for children). Conflicts between domain-specific guidelines are rare but should be resolved by prioritizing the guideline from the most closely matched research context.

---

## Reference Files

### `references/reports.md`
**Source:** Nielsen Norman Group official report catalog (NN/g)
**Confidence:** Medium (report summaries and abstracts; full guidelines require report purchase)
**Coverage:** 487 pages of report metadata and key findings across:

| Report | Guidelines | Screenshots | Method |
|---|---|---|---|
| Intranet Usability Guidelines (all 4 vols.) | 300+ | 800 | Usability testing, field studies, 57 orgs |
| Ecommerce UX Vol. 04: Shopping Carts | 137 | 412 | 5 rounds of usability testing, 350+ sites |
| Tablet Website and Application UX | 126 | 226 | 6 rounds, real users with own devices |
| UX Design for Children, 4th Edition | 156 | 288 | 3 rounds in US, China, Israel |
| Intranet Design Annual 2020 | N/A | 189 | Expert review of 10 winning intranets |

**How to use:** Search for the relevant report by topic, read its scope and findings summary, then apply the guideline principles to your design decisions.

---

## Key Terminology

| Term | Definition |
|---|---|
| **Usability testing** | Task-based sessions where representative users attempt real tasks while observed |
| **Information architecture (IA)** | How content is organized, labeled, and made navigable |
| **Findability** | Ease with which users can locate specific content via browsing or search |
| **Design guideline** | A specific, actionable recommendation derived from empirical research |
| **Expert review** | Structured heuristic evaluation by UX specialists (not user testing) |
| **Abandonment** | When a user stops a task (e.g., checkout) without completing it |
| **Dark pattern** | UI design that manipulates users into unintended actions |

---

## Notes

- Source data is from NN/g report abstracts and summaries — the full guideline details require purchasing the reports directly
- Guidelines reflect research conducted between 2001–2023; the most recent edition (4th) was published 2023
- Research contexts: US, UK, Finland, Netherlands, Switzerland, Canada, UAE, China, Denmark, India, Israel
- No codebase-derived examples exist (this is a design/UX domain, not a code library)
- When guidelines conflict with product constraints, use the research rationale to make informed trade-offs rather than discarding the guideline entirely

## Updating

To refresh this skill with updated NN/g research:
1. Re-run the scraper targeting the NN/g reports catalog
2. The skill will be rebuilt with the latest report summaries
