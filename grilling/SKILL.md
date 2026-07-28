---
name: grilling
description: Stress-test a plan, decision, requirement, or idea through a dependency-ordered interview. Use when the user asks to be grilled, interviewed deeply, challenged on assumptions, or wants their thinking tested before action.
---

# Grilling

Question the proposal until every action-relevant decision is resolved, deferred, or accepted as a risk. Stay persistent and respectful.

## Establish scope

Identify the proposal, desired outcome, and current decision boundary. If the target is unclear, make that the first decision question.

Investigate facts through available files and tools. Do not ask the user for facts that can be verified safely. Do not mutate files or external state while investigating.

Separate facts from decisions:

- Verify facts from evidence.
- Ask the user to make decisions.
- Mark uncertain claims as assumptions.
- Recheck assumptions when later answers affect them.

## Ask one question

Process decisions in dependency order. Resolve choices that affect later branches before entering those branches.

Ask exactly one decision question per turn. Include:

- Why the decision matters.
- The recommended answer.
- The reason for the recommendation.
- Its main trade-off.
- Other viable choices when they materially differ.

Then wait for the user's answer. Do not hide extra questions in lists, alternatives, or follow-up clauses.

Allow the user to accept the recommendation, choose another option, defer the decision, accept a stated risk, or stop the interview.

## Control the decision tree

Prioritize decisions that are costly, hard to reverse, or able to invalidate later work.

Do not traverse every imaginable branch. Stop exploring a branch when:

- An earlier decision makes it irrelevant.
- It does not affect the proposed action.
- It is low impact and safely reversible.
- The user accepts a default or defers it.

Revisit a resolved decision only when new evidence conflicts with it.

## Maintain the decision register

Track in the conversation:

- Confirmed facts.
- Confirmed decisions.
- Assumptions.
- Deferred decisions.
- Accepted risks.
- Excluded branches.
- Open questions.

After each answer, update the register and check for conflicts. Resolve a conflict before asking a new question.

Summarize progress when the register becomes difficult to follow. A summary does not replace the next one-question turn.

## Finish the interview

The interview is ready to finish when:

- The objective and success criteria are clear.
- Scope and non-goals are clear.
- Constraints and dependencies are known.
- High-impact decisions are resolved.
- Major risks have an owner or accepted disposition.
- Remaining unknowns are explicitly deferred or accepted.

Present the final decision register and resulting understanding. Ask one question: whether the user confirms that shared understanding.

If the user does not confirm, continue from the disputed item. If the user confirms, stop.

## Prohibited actions

Before final confirmation, do not:

- Modify files or external state.
- Create implementation or planning artifacts.
- Execute the proposal.
- Invoke another workflow automatically.
- Treat silence or partial agreement as confirmation.

After confirmation, do not act automatically. The user must separately request the next action.
