# Spike and Delete

**Read this only when you are about to write exploratory code without a test.**

A spike is throwaway code that exists to learn something: how a library behaves, whether an API works the way the docs claim, whether an approach is viable at all. Spikes are legitimate. Keeping a spike is not.

## Legitimate reasons to spike

- You need to see how an unfamiliar third-party API actually responds.
- You are validating a hypothesis about external behavior you cannot predict from docs.
- You are prototyping a UX flow whose shape is not yet decided.

## Illegitimate reasons to spike

- Going faster. TDD is faster once the cycle is running.
- Avoiding the test list. The test list *is* the thinking.
- "I will write tests after." You will not. That is what the spike escape hatch is for — use the legitimate path instead.

## File layout

A spike file is visibly a spike. Non-negotiable:

- Python: `_spike.py` suffix or `spike/` directory.
- C++: `_spike.cpp` suffix or `spike/` directory.
- Rust: `examples/_spike_*.rs` or `spike/` directory.
- C: `_spike.c` suffix or `spike/` directory.
- TypeScript/JavaScript: `_spike.ts` / `_spike.js` or `spike/` directory.

Spike files are not committed to main. Use a branch or leave them uncommitted.

## Deletion procedure

TDD starts with `rm <spike_file>`. Literally.

- You may not copy lines from the deleted spike into the production code.
- You may not open the deleted spike in another window.
- You may consult your memory of what worked.
- If you find yourself re-typing the spike verbatim, that is fine — you remembered it. You are not reading it.

## Rationalization table

| What you're about to say | Why it's a violation |
|---|---|
| "I'll keep the spike as a reference." | You will write tests that match the spike, not the behavior. |
| "The spike already works, I'll just add tests." | Tests written for working code pass immediately and prove nothing. |
| "I'll delete it after I port the logic over." | "Port" = copy. The deletion contract forbids copying. |
| "It's fine, I marked it as `_spike`." | The suffix is a file-system marker, not a license to keep code. |

## When the spike reveals a boundary

If your spike shows the feature touches a third-party library, an I/O boundary, a clock, or a DB: delete the spike, then invoke `testing-boundaries` before writing your first test. The boundary decisions belong there, not here.
