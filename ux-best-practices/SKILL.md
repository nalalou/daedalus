---
name: ux-best-practices
description: Use when designing or reviewing a screen, flow, form, paywall, onboarding, checkout, or landing page for usability — whether people can find things, understand them, and finish the task. Triggers on "usability review", "UX review", "is this easy to use", "why are people dropping off", "review this flow", "heuristic evaluation", "check this form", "check this checkout". Applies Nielsen Norman Group's usability heuristics and well-established research findings.
---

# UX Best Practices

Usability rules from Nielsen Norman Group's published research. This skill is about whether people can use the thing, not whether it looks good.

Every rule here was checked against NN/g's free articles on 2026-11-24. The articles are listed under Sources at the bottom. Rules are paraphrased, not copied. If a question goes beyond what is written here, read the relevant article on nngroup.com rather than guessing, and do not quote a number that is not on this page or in an article you have read in this session.

## How to use this

**When designing:** build to the rules below from the start. Before showing the work, walk through the main task as a first-time user and fix anything that breaks a rule.

**When reviewing:** walk through the real task step by step, on the real screen or a screenshot, not from the code alone. For each problem, report:

1. What the person is trying to do and where they get stuck
2. Which rule it breaks
3. How bad it is (scale below)
4. The specific fix

Lead with the worst problems. Skip anything cosmetic unless asked. Do not pad the list: three real problems beat fifteen nitpicks.

**Severity scale (Nielsen's):**

- 4 — People cannot finish the task. Fix before release.
- 3 — Major: many people will struggle or give up. High priority.
- 2 — Minor: slows people down or annoys them. Low priority.
- 1 — Cosmetic: fix if there is time.

Judge severity by how many people hit it, how hard it is to get past, and whether it trips them every time or only once. Also weigh how much it could hurt the product's reputation or sales.

## The 10 usability heuristics

1. **Show what is happening.** Every action gets a visible response quickly. Loading, saving, success, and failure are all shown.
2. **Speak the user's language.** Words and concepts the person already uses, not internal or technical terms. Information appears in a natural order.
3. **Give an exit.** Undo, cancel, back, and close are always available and obvious. Nobody gets trapped in a flow.
4. **Be consistent and follow conventions.** The same word and the same control mean the same thing everywhere. People spend most of their time in other apps, so match what those do.
5. **Prevent errors.** Remove error-prone conditions, use sensible defaults and constraints, and confirm before anything destructive.
6. **Recognition over recall.** Show the options instead of making people remember them. Never make someone carry information from one screen to the next.
7. **Shortcuts for regulars.** Let frequent users go faster without getting in the way of new ones.
8. **Keep it minimal.** Every extra element competes with the ones that matter. Remove what does not help the task.
9. **Help people recover from errors.** Error messages say in plain words what went wrong and how to fix it. No codes, no blame.
10. **Help where it is needed.** Best if no instructions are needed. If they are, put them at the point of need, short and task-focused.

## Speed and feedback

- About 0.1 second feels instant. No feedback needed beyond the result.
- About 1 second: the person notices the delay but stays on track.
- About 10 seconds is the limit of attention. Anything longer needs a progress indicator and a way to cancel.
- For any wait over a second, show that something is happening. For waits over ten, show real progress (a bar or steps), not only a spinner. A spinner alone is the last resort, for when the length cannot be known.
- Disable or change a button after it is tapped so the person knows it registered and cannot double-submit.

## Reading and writing

- People scan, they do not read. On an average page they read about 20% of the words, 28% at most.
- Put the most important words first in headings, paragraphs, links, and buttons. Start with the conclusion. If the first few words do not catch the eye, the rest is skipped.
- Use headings that make sense on their own, short paragraphs, and lists for parallel items.
- Plain words. Cut marketing fluff and welcome text. In NN/g's test, a version with half the words scored 58% better on usability.
- Link and button text says what happens next. Never "click here", "learn more", or "submit" when a specific label is possible.
- Anything that looks like an ad or a promo gets ignored, even when it is real content. Do not style important content like a banner.

## Navigation and finding things

- Visible navigation beats hidden navigation. Menus tucked behind an icon get used about half as often and make content harder to discover. On a phone, if there are four or fewer main sections, show them all as visible links. On a desktop-size screen, never hide the main navigation behind an icon.
- Always show where the person is and how to get back.
- Label menu items with the words users would search for, not clever or brand names.
- Organise by how users think about the content, not by how the company or the code is structured.
- If there is search, make it a visible box, tolerate typos, and never return a dead-end empty result. Offer a next step.
- Auto-rotating carousels are skipped and annoy people. Use a static hero or let the person control it.

## Forms

- Ask for as little as possible. Every field costs completions. Remove optional fields or mark them clearly as optional.
- One column. Labels directly above the fields. Labels beside the fields only for very long desktop forms.
- Do not use placeholder text as the label. It disappears when typing starts, strains memory, and makes filled and empty fields look alike.
- Size and type the field to match the answer. On a phone, bring up the right keyboard and support autofill.
- Check a field once the person has finished with it, not while they are still typing. The exception is a field with strict rules, such as a new password, where checking as they type helps. Do not rely only on a list of errors after submit.
- Put the error next to the field, in plain words, saying how to fix it. Use more than colour to mark it. Never wipe what the person already typed.
- Show passwords as they are typed, or offer a show/hide control. Hiding them causes more errors than it prevents.
- One clear primary button. If there is a secondary action, make it visibly less prominent.

## Phones and touch

- Touch targets at least 1 cm by 1 cm (44 by 44 points on iOS), with space between them.
- Cut controls and decoration that do not help the task, but do not hide the main navigation just to save space. A screen with more room for content is not better if people can no longer find their way around.
- Swipes and long-presses are invisible, so people do not discover them. Never put a key action behind a gesture alone.
- Skip onboarding screens whenever possible. People swipe past them and do not remember them. Teach in context at the moment the feature is needed.
- Ask for a permission at the moment it is needed, after explaining what the person gets for it. At first launch, ask only for permissions the app cannot work without.
- Do not demand sign-up before showing any value. Let people try first. The exception is an app that is personal by nature, such as email or banking.
- Typing on a phone is slow and error-prone. Prefer pickers, defaults, and remembered values.

## Buying, paywalls, and sign-up

- Show unusual fees and delivery costs early, before checkout. Ordinary tax and shipping can appear at checkout, but nothing should be a surprise at the last step.
- Allow purchase without creating an account. Offer the account as an optional extra during or after checkout, framed as a benefit.
- State plainly what is being bought, what it costs, how often it bills, and how to cancel.
- Make declining as easy to see and tap as accepting. No guilt-trip wording on the "no" option, no close button tucked out of the way, no rushing the decision, no false claims that something is scarce or ending.
- Never show a popup before the person has got some value. Ask for an email, a rating, or an upgrade after they finish a task. Legally required consent is the only exception.
- Confirm success clearly and say what happens next.

## Empty, error, and edge states

Check each screen in these states, not only the happy one:

- Empty: never leave it blank. Say what will appear here and give a direct link or button to add the first thing.
- Loading: show something within a second.
- Error: plain words, what to do next, a way to retry.
- No connection, a very long name, a very large number, one item, thousands of items.

## Testing with people

- Watching five people try the task finds about 85% of the problems. Three small tests of five people, with fixes in between, beat one test of fifteen.
- Watch what people do, not what they say they would do. Give a task and stay quiet.
- Opinions and satisfaction scores do not tell you whether people can finish the task.

## Sources

All free articles on nngroup.com, read 2026-11-24.

- Heuristics: https://www.nngroup.com/articles/ten-usability-heuristics/
- Severity scale: https://www.nngroup.com/articles/how-to-rate-the-severity-of-usability-problems/
- Response times: https://www.nngroup.com/articles/response-times-3-important-limits/
- Reading: https://www.nngroup.com/articles/how-users-read-on-the-web/ and https://www.nngroup.com/articles/how-little-do-users-read/
- Concise writing: https://www.nngroup.com/articles/concise-scannable-and-objective-how-to-write-for-the-web/
- Ad-like content ignored: https://www.nngroup.com/articles/banner-blindness-old-and-new-findings/
- Hidden navigation: https://www.nngroup.com/articles/hamburger-menus/
- Carousels: https://www.nngroup.com/articles/auto-forwarding/
- Placeholders: https://www.nngroup.com/articles/form-design-placeholders/
- Forms: https://www.nngroup.com/articles/web-form-design/
- Form errors: https://www.nngroup.com/articles/errors-forms-design-guidelines/
- Passwords: https://www.nngroup.com/articles/stop-password-masking/
- Touch targets: https://www.nngroup.com/articles/touch-target-size/
- Content vs controls: https://www.nngroup.com/articles/content-chrome-ratio/
- Swipe gestures: https://www.nngroup.com/articles/contextual-swipe/
- Onboarding: https://www.nngroup.com/articles/mobile-app-onboarding/
- Permissions: https://www.nngroup.com/articles/permission-requests/
- Sign-up walls: https://www.nngroup.com/articles/login-walls/
- Buying without an account: https://www.nngroup.com/articles/optional-registration/
- Fees and shipping: https://www.nngroup.com/articles/ecommerce-taxes-fees/
- Mobile checkout: https://www.nngroup.com/articles/mobile-checkout-ux/
- Popups: https://www.nngroup.com/articles/popups/
- Manipulative design: https://www.nngroup.com/articles/deceptive-patterns/
- Empty screens: https://www.nngroup.com/articles/empty-state-interface-design/
- Testing with five people: https://www.nngroup.com/articles/why-you-only-need-to-test-with-5-users/
- Watch, don't ask: https://www.nngroup.com/articles/first-rule-of-usability-dont-listen-to-users/

Not covered by these articles, general good practice only: the right phone keyboard and autofill, disabling a button after tap, the list of edge cases to check, and search behaviour.
