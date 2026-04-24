---
name: writing-good-tests
description: Use when writing individual tests during TDD. Owns the shape of a single test — 4-phase structure, FIRST, naming, behavior vs implementation, doubles taxonomy, and when to delete a test. Invoke once per TDD session alongside test-driven-development.
---

# Writing Good Tests

## Purpose

This skill is loaded once per TDD session and stays in context. It does **not** drive the cycle (`test-driven-development` does) and does **not** cover 3rd-party or I/O boundaries (`testing-boundaries` does). Its job is to tell you how each individual test should be shaped.

Read top-to-bottom the first time. Afterward, the [Terminal Checklist](#terminal-checklist) is the repeat-use surface — run through it after writing each test.

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

In C++, Cleanup is typically RAII — the phase is present even though no code is written for it:

```cpp
TEST(RateLimiter, CallsUnderTheLimitAreAllowed) {
    // Setup
    RateLimiter limiter(/*limit=*/3, /*window=*/std::chrono::seconds(60));

    // Exercise
    bool a = limiter.Allow("user-1");
    bool b = limiter.Allow("user-1");
    bool c = limiter.Allow("user-1");

    // Verify
    EXPECT_TRUE(a); EXPECT_TRUE(b); EXPECT_TRUE(c);

    // Cleanup — destructor runs on scope exit.
}
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
- `given_when_then_` — when the setup context is non-obvious and naming it prevents confusion.
- `it_does_X_when_Y` (TypeScript/JavaScript, Ruby) — per ecosystem convention.

Stuck on a name? Read `references/naming-patterns.md`.

## FIRST — Operational

`test-driven-development` Rule 3 names these. Here is the depth.

### Fast — sub-second per unit test

**Violation signs:** reads the real clock (`time.sleep`, `datetime.now()` without injection), opens sockets, touches the filesystem, spawns a subprocess, hits a real DB.

**Fix:** push the collaborator to the integration tier (see `testing-boundaries`), or replace it with a fake. If the whole suite drifts slow, you are not writing slow tests — you are writing the wrong *kind* of test in the unit tier.

### Independent — any order, any subset

**Violation signs:** module-level mutable state, fixtures that persist across tests, files written to a shared path, database rows left behind.

**Fix:** move state into per-test fixtures (pytest function scope, GoogleTest `SetUp` per test). Never rely on one test having set up state for another.

### Repeatable — same result offline, in CI, on a Tuesday

**Violation signs:** `time.time()`, `random.random()` without a seed, environment variables read at runtime, network reachability assumed, timezone dependence.

**Fix:** inject the clock and RNG as collaborators (and fake them). Pin env with fixtures. A test that is not repeatable is not a test.

### Self-Validating — pass or fail, never "look and see"

**Violation signs:** `print()` statements the test expects you to read, `assert True` with a comment "checked manually once", logs that a human is supposed to scan.

**Fix:** replace the print with an assertion. If you cannot write an assertion for the thing you want to check, you have not identified the observable behavior — go back to the behavior-vs-structure section.

### Timely — written immediately before the code that makes them pass

**Violation signs:** tests added in a PR review cycle, "I'll add tests at the end", tests stapled on after the code works.

**Fix:** if you catch this pattern, the failure is not in *this* skill — it is in the TDD cycle itself. See `test-driven-development`.

## Behavior vs Structure — What Is "Observable"?

The single hardest distinction in testing. The rule that settles most cases:

> **Observable** = anything a user of the capability can see from outside it. Return values, persisted state they can query, errors they receive, side effects they rely on.
>
> **Not observable** = internal decomposition. Message sequences between private collaborators, call counts on internal methods, log lines (usually), internal types, order-of-operations when the external outcome does not depend on it.

### Worked example

Capability: `place_order(request) -> Outcome`.

<Good>
```python
def test_order_with_no_customer_is_rejected():
    outcome = place_order(OrderRequest(items=[Item("book", 1)], customer=None))
    assert outcome.rejected
    assert outcome.reason == "customer required"
```
Survives a refactor that splits `OrderValidator` into `CustomerCheck` + `ItemCheck`, renames either, or fuses them back together.
</Good>

<Bad>
```python
def test_customer_check_is_called_before_item_check():
    recorder = CallRecorder()
    place_order(OrderRequest(items=[Item("book", 1)], customer=None), recorder=recorder)
    assert recorder.calls == ["CustomerCheck.run", "ItemCheck.run"]
```
Breaks the instant someone renames a class, fuses the checks, or parallelizes them — without any observable behavior changing.
</Bad>

### Anti-patterns that live here

**The structure-coupled test.** Asserts `collaborator.method was called with X`. The call is an implementation detail; the outcome of the call is the behavior. Fix: assert on the outcome.

**The snapshot-asserting test.** Compares a whole output blob to a stored snapshot, failing when any field changes — including fields nobody cares about. Fix: assert on the specific fields that encode behavior; let the rest vary. If the snapshot is load-bearing, it's a structure-coupled test in disguise.

## Beck's Additional Principles

Beyond FIRST, three more:

- **Cheap to read** — tests are read far more often than they are written. A test whose intent is unclear fails its documentation role and will be deleted-or-rewritten by the next person.
- **Cheap to change** — a single behavior change should not cascade across many tests. If it does, your tests are coupled to structure. Go back to the behavior-vs-structure section.
- **Behavior-sensitive, structure-insensitive** — stated again because it is where these principles most directly contradict common practice.

## Doubles Taxonomy

You will use doubles. Which kind matters.

- **Dummy** — passed through, never exercised. An argument the production code requires but this test does not care about.
- **Stub** — returns canned answers to queries. Use for read-only collaborators whose responses you are scripting.
- **Fake** — a simplified working implementation (in-memory repository, fake clock that advances on demand). Prefer over stubs and mocks when the collaborator is stateful.
- **Spy** — records calls for later verification. Use when the *call itself* is the observable behavior — e.g., "did we publish an event?"
- **Mock** — pre-programmed expectations verified at the end of the test. Strongest coupling to structure — prefer spies or fakes first.

**Preference order when you own the collaborator:**

```
fake > stub > spy > mock
```

The further right, the more the test knows about *how* the production code uses the collaborator, and the more it will break during refactors.

**Python inline example — prefer a fake clock over mocking `time`:**

```python
class FakeClock:
    def __init__(self, start_seconds: float = 0.0):
        self._now = start_seconds
    def now(self) -> float:
        return self._now
    def advance(self, seconds: float) -> None:
        self._now += seconds

def test_counter_resets_after_window_elapses():
    clock = FakeClock()
    limiter = RateLimiter(limit=1, window_seconds=60, clock=clock)
    assert limiter.allow("user-1") is True
    assert limiter.allow("user-1") is False
    clock.advance(61)
    assert limiter.allow("user-1") is True
```

No mock of the real clock. No `time.sleep`. Test is fast, repeatable, and reads as prose.

Full taxonomy, language notes, and edge cases: `references/doubles-taxonomy.md`.

### Anti-pattern that lives here

**The over-mocked test.** Mock setup is longer than the test logic. Fix: replace mocks with a fake of the same collaborator. If no fake is feasible because the collaborator's interface is sprawling, the signal is not about testing — the production design itself is over-coupled. Simplify the interface.

## When to Delete a Test

Deletion is part of the job. Five criteria; each paired with the question you ask yourself.

1. **Duplicate coverage** — *"Does another test already cover this behavior with equal or greater fidelity?"* If yes, delete the weaker one.
2. **Asserts only on structure** — *"Does this test fail when behavior changes but pass when structure changes, or the reverse?"* If reverse, delete.
3. **Asserts only on a mock** — *"If I remove the assertion and re-run, is the test still testing anything?"* If no, delete.
4. **Flaky after genuine fix attempts** — *"Have I found a root cause and still cannot stabilize it?"* Delete. Unreliable coverage is worse than no coverage — it trains you to ignore failures.
5. **Tests code you don't own** — *"Am I verifying that a library behaves as its documentation claims?"* Delete. The library maintainers already wrote that test.

A test that fails any of these produces noise, not signal. Delete it and the suite gets faster, the signal gets louder, and the remaining tests earn their keep.

## Terminal Checklist

Run through this after writing each test. All yes, or a documented exception.

```
- [ ] Test name is a sentence describing observable behavior
- [ ] All 4 phases present (Cleanup may be language-implicit)
- [ ] Single Exercise step — not interleaved calls and assertions
- [ ] Assertions check observable outcomes, not call sequences or private state
- [ ] Run time <100ms (Fast)
- [ ] No shared state with other tests (Independent)
- [ ] Passes offline, in CI, on a Tuesday (Repeatable)
- [ ] Pass/fail is unambiguous — no human inspection needed (Self-Validating)
- [ ] No mock of code you don't own — if tempted, see testing-boundaries
- [ ] If you deleted this test today, what would you lose? Is that answer non-trivial?
```

Any "no" is a test to fix or delete before moving on.

## Load Discipline

Do not re-invoke this skill per test. Consult the checklist from context.
