---
name: grill-me
description: A relentless interview to sharpen a plan, design or idea before committing to it. User-invoked with /grill-me.
disable-model-invocation: true
---

# Grill me

Interview me relentlessly about every aspect of this plan until we reach a shared understanding.
Walk down each branch of the design tree, resolving dependencies between decisions one by one.
If a question can be answered by exploring the codebase, explore the codebase instead.
For each question, provide your recommended answer.

- Ask in rounds. Each round is the frontier: every open question whose prerequisites I have already settled. Never ask a question that depends on an answer you have not heard yet.
- Number the questions in a round so I can answer them by number.
- Weigh maintainability, performance and correctness over development cost.
- Some questions cannot be answered by talking, such as how an interaction should feel or which of two layouts reads better. When you hit one, stop grilling it and suggest a throwaway prototype to react to, then pick it up again once I have seen it.
- Push back when my answer contradicts an earlier one or skips a branch. "I don't know" is a valid answer: record it as an open question rather than filling it in.
- The subject may not be code. With no repo involved, skip codebase exploration and grill the idea on its own terms.
- Keep a running list of resolved decisions and open questions, and show it at the end of each round.
- Stop when the frontier is empty. If the subject is software, offer to write it up as `docs/specs/<feature>.md` using the spec template from the global instructions, with unresolved items under Open questions. Follow the global spec rules for the rest: add it to the repo's `AGENTS.md` under Planned, and to `docs/specs/roadmap.md` if the repo has more than one spec.
