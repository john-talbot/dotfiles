---
name: writing-good-tests
description: Use when writing individual tests during TDD. Owns the shape of a single test — 4-phase structure, FIRST, naming, behavior vs implementation, doubles taxonomy, and when to delete a test. Invoke once per TDD session alongside test-driven-development.
---

# Writing Good Tests

> **Load once per TDD session.** Do not re-invoke per test — consult the [Terminal Checklist](#terminal-checklist) from context instead.

## Start Here — The 4-Phase Test Structure

Every test has four phases, even when the language collapses one of them.

1. **Setup** — arrange inputs, construct collaborators.
2. **Exercise** — call the code under test, exactly once.
3. **Verify** — assert on observable outcomes.
4. **Cleanup** — release resources the language won't reclaim automatically.

```python
def test_calls_under_the_limit_are_allowed():
    # Setup
    limiter = RateLimiter(limit=3, window_seconds=60)

    # Exercise
    results = [limiter.allow("user-1") for _ in range(3)]

    # Verify
    assert results == [True, True, True]

    # Cleanup — none needed; GC handles it.
```

**One Exercise step.** If your test calls the system under test three times with three interleaved assertions, it is three tests pretending to be one.

## Naming

A test name is a sentence about **observable behavior**.

<Good>
- `test_calls_under_the_limit_are_allowed`
- `test_rejects_empty_email_with_message`
- `test_charge_is_idempotent_per_request_id`
</Good>

<Bad>
- `test_rate_limiter_1` — no behavior described
- `test_validate` — method name, not behavior
- `test_happy_path` — vague, non-specific
- `test_order_validator_rejects_empty_customer` — names a class, not a behavior
</Bad>

**Patterns:**
- Plain English with `test_` prefix (Python, C) — default.
- `given_when_then_` — when the setup context is non-obvious.
- `it_does_X_when_Y` (TypeScript/JavaScript, Ruby) — per ecosystem convention.

## FIRST — Operational

The `lint-test-quality.py` PostToolUse hook auto-flags the pattern-matchable violations below (sleep/real-clock calls, unseeded time/random, `print()`) on every test file write — its warnings surface as additional context, so treat one as an immediate signal rather than something to hunt for by re-reading the file.

| Property | Fix | Mechanically checked? |
|---|---|---|
| **Fast** | Push to integration tier (`testing-boundaries`) or replace with a fake | Yes — hook |
| **Independent** | Move state into per-test fixtures (pytest function scope, GoogleTest `SetUp`) — watch for module-level mutable state, fixtures persisting across tests, shared file paths, leftover DB rows | No — needs cross-test judgment |
| **Repeatable** | Inject clock and RNG as collaborators; pin env with fixtures | Yes — hook |
| **Self-Validating** | Replace print with assertion; if you can't assert it, you haven't found the observable behavior | Yes — hook |
| **Timely** | Tests added post-review means the failure is in the TDD cycle — see `test-driven-development` | No — process, not pattern |

## Behavior vs Structure — What Is "Observable"?

> **Observable** = anything a user of the capability can see from outside it: return values, persisted state, errors, side effects they rely on.
>
> **Not observable** = internal decomposition: message sequences between private collaborators, call counts on internal methods, log lines, internal types.

See `test-driven-development` Rule 1 for the canonical good/bad pair (`test_order_with_no_customer_is_rejected` vs. the class-coupled version). Same rule, applied here to call sequences instead of class names:

<Bad>
```python
def test_customer_check_is_called_before_item_check():
    recorder = CallRecorder()
    place_order(OrderRequest(items=[Item("book", 1)], customer=None), recorder=recorder)
    assert recorder.calls == ["CustomerCheck.run", "ItemCheck.run"]
```
Breaks on any rename or refactor without changing observable behavior.
</Bad>

**Anti-patterns:**

- **Structure-coupled test** — asserts `collaborator.method was called with X`. Fix: assert on the outcome, not the call.
- **Snapshot-asserting test** — compares a whole output blob; fails on irrelevant field changes. Fix: assert only fields that encode behavior.

## Doubles Taxonomy

| Type | What it does | When to use |
|---|---|---|
| **Dummy** | Passed through, never exercised | Required arg this test doesn't care about |
| **Stub** | Returns canned answers | Read-only collaborators whose responses you're scripting |
| **Fake** | Simplified working implementation (in-memory repo, fake clock) | Stateful collaborators — prefer over stubs/mocks |
| **Spy** | Records calls for later assertion | When the call itself is the observable behavior (e.g., "did we publish an event?") |
| **Mock** | Pre-programmed expectations verified at end | Avoid — strongest coupling to structure |

**Preference order when you own the collaborator:** `fake > stub > spy > mock`

See `references/doubles-taxonomy.md` for language-specific notes and the FakeClock pattern.

**Anti-pattern:** Mock setup longer than test logic → replace the mock with a fake. If no fake is feasible, the production interface is over-coupled — simplify it.

## When to Delete a Test

1. **Duplicate coverage** — another test covers this behavior with equal fidelity.
2. **Asserts only on structure** — fails on refactors, passes on behavior changes.
3. **Asserts only on a mock** — remove the assertion and the test tests nothing.
4. **Flaky after genuine fix attempts** — unreliable coverage is worse than none.
5. **Tests code you don't own** — the library maintainers already wrote that test.

## Terminal Checklist

Run through this after writing each test. All yes, or a documented exception.

```
- [ ] Test name is a sentence describing observable behavior
- [ ] All 4 phases present (Cleanup may be language-implicit)
- [ ] Single Exercise step — not interleaved calls and assertions
- [ ] Assertions check observable outcomes, not call sequences or private state
- [ ] No shared state with other tests (Independent — not hook-checked)
- [ ] Fast / Repeatable / Self-Validating / no direct 3rd-party mocking — hook flags violations on write; treat a warning as failing this item
- [ ] If you deleted this test today, what would you lose? Is that answer non-trivial?
```
