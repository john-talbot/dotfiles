---
name: test-driven-development
description: Use when implementing any new feature or bugfix, before writing implementation code. Drives the Canon TDD cycle with port-level behavior tests.
---

# Test-Driven Development

Canon TDD, port-level. Write a test list. Turn one item at a time into a failing test, then pass it, then refactor, then repeat.

**Core principle:** Test the observable contract of the capability you are changing, not the internals of the classes that happen to implement it today.

Invoke `writing-good-tests` once at the start of a TDD session. Invoke `testing-boundaries` the first time your feature crosses a collaborator you do not own. Do not re-invoke siblings per test — consult from context.

## The Loop

```
1. Write a test list.
2. Turn one item into a concrete, runnable test.
3. Change code to make the test pass (and all previous tests).
4. Optionally refactor. No new tests in this step.
5. Repeat. Add newly discovered cases to the list as you go.
```

### Loop Health

Wall time is the loop's oxygen. If the whole unit suite doesn't finish in the time you'd glance away from the screen, the cycle dies — you batch, you skip runs, discipline erodes. When that happens, the fix is not in this skill: consult `testing-boundaries` (what doesn't belong in the unit tier) and `writing-good-tests` (how a fast test looks).

## Rule 0 — Write the Test List First

Before any test, list the behavioral cases you intend to cover. The list is the design artifact; individual tests are its execution.

- One item = one observable behavior.
- No implementation decisions on the list. `OrderValidator.validate rejects empty customer` is wrong. `Submitting an order with no customer is rejected` is right.
- A test list of one is still a test list. Write it down.
- Add to the list when new cases surface mid-implementation. Do not silently expand scope.

**Python example:**

```text
Feature: rate limiter — at most N calls per window

Test list:
- calls under the limit are allowed
- the (N+1)th call in the same window is rejected
- after the window elapses, the counter resets
- concurrent calls from distinct keys do not share a counter
- invalid window size (zero, negative) is rejected at construction
```

Extended per-language examples: `references/test-list-examples.md`. **Read that reference only when stuck on list shape.**

## Rule 1 — Test Behavior, Not Implementation

The unit is the **highest-stable public boundary for the capability under change** — typically the port / use-case / public API — not a class.

**Decision rule:**

> Default to port-level. Drop to class-level only when a class has algorithmic logic (loops, branches, state machines) whose exhaustive port-level coverage would require combinatorial blowup.

<Good>
```python
# Port-level — tests the capability, not the decomposition.
def test_order_with_no_customer_is_rejected():
    outcome = place_order(OrderRequest(items=[Item("book", 1)], customer=None))
    assert outcome.rejected
    assert outcome.reason == "customer required"
```
</Good>

<Bad>
```python
# Class-level — couples the test to today's internal decomposition.
def test_order_validator_rejects_empty_customer():
    v = OrderValidator()
    assert v.validate(customer=None).errors == ["customer required"]
```
Rename `OrderValidator` or inline it and this test breaks without any observable behavior changing.
</Bad>

## Rule 2 — Don't Mock What You Don't Own

- Mock your own abstractions.
- Wrap third-party libraries (HTTP clients, DB drivers, OS calls, clocks) in thin adapters you own; mock those.
- If a "test" mostly verifies how a library behaves, delete it — the library maintainers already tested it.

Full treatment of the adapter pattern, boundary testing, and where integration tests live: sibling skill `testing-boundaries`. Invoke lazily the first time the feature crosses a boundary.

## Rule 3 — Tests Must Be FIRST

- **Fast** — sub-second per unit test. Feedback governs the loop.
- **Independent** — no shared state; any order, any subset.
- **Repeatable** — same result offline, in CI, on a Tuesday.
- **Self-Validating** — pass or fail; no "look at the log and see if it seems right".
- **Timely** — written immediately before the code that makes them pass.

## Rule 4 — Respond to Behavior Changes, Not Structure Changes

Refactoring without changing behavior must not break tests. If it does, the test was coupled to structure (message sequences, private method names, internal types). Rewrite the test to assert on the observable contract.

<Good>
```rust
// Port-level test. Survives splitting `charge` into `authorize` + `capture`.
#[test]
fn charges_are_idempotent_per_request_id() {
    let gateway = PaymentGateway::new(in_memory_ledger());
    let a = gateway.charge(Request::new("req-1", cents(500)));
    let b = gateway.charge(Request::new("req-1", cents(500)));
    assert_eq!(a.status, Status::Captured);
    assert_eq!(b.status, Status::AlreadyApplied);
}
```
</Good>

<Bad>
```rust
// Structure-coupled. Breaks when `authorize_then_capture` becomes two methods.
#[test]
fn charge_calls_authorize_then_capture_in_order() {
    let gateway = PaymentGateway::new(recording_backend());
    gateway.charge(Request::new("req-1", cents(500)));
    assert_eq!(gateway.backend.calls(), vec!["authorize", "capture"]);
}
```
</Bad>

## The Cycle — Red / Green / Refactor

Inside step 3 of The Loop, each test goes through this cycle.

### Red — write test, watch it fail

**Mandatory gate.** Never skip.

- If the test passes immediately, you were testing existing behavior. Either remove it or rewrite against the behavior you intend to add.
- If the test errors instead of fails, fix the error (typo, missing import, setup glitch) and re-run until it fails for the expected reason — *feature not yet implemented*.

### Green — minimal code to pass

Write the simplest code that makes the failing test pass plus keeps prior tests green.

- No features not demanded by a test on the list.
- No refactors in this step. No renames. No extracts. Green first.

### Refactor — clean up, stay green

- Remove duplication, improve names, extract helpers.
- **Do not add new tests in this phase.** New cases go on the test list and become their own cycle.
- Run the suite after each refactor. If anything turns red, undo the refactor or fix the bug you just introduced.

## Spikes Are Allowed. Kept Code Is Not.

Exploration is legitimate. Keeping the exploration is not.

- A spike lives in a clearly-marked location: `spike/` directory, or `_spike.py` / `_spike.cpp` / `_spike.rs` / `_spike.c` / `_spike.ts` suffix.
- Spike code is not committed to main.
- TDD begins with **deleting the spike file**. Deletion is a step, not an intention.
- You may copy nothing across the deletion. You may consult memory.
- Keeping any line is a violation — back to Rule 0.

Decision procedure and per-language spike patterns: `references/spike-and-delete.md`. **Read that reference only when about to spike.**

## When Writing Each Test

See sibling skill `writing-good-tests` for naming, 4-phase structure, and the shape rubric. Invoke that skill **once** at the start of a TDD session — content stays in context. Do not re-invoke per test.

## When a Collaborator Crosses a Boundary

When the feature first touches I/O, a 3rd-party library, a DB, another bounded context, a clock, or randomness: invoke `testing-boundaries`. Lazy-load — if the feature is pure logic, never invoke it.

## Retrofitting Existing Untested Code Is Not TDD

This skill governs code you are about to write. Retrofitting tests onto existing untested code is characterization testing and uses a different procedure. Do not apply this skill's cycle discipline to it.

## Red Flags

| Flag | Violates |
|---|---|
| No test list written | Rule 0 |
| Test asserts on a mock of code you don't own | Rule 2 |
| Unit test takes >100ms | Rule 3 (Fast) — investigate via Loop Health |
| Refactor with no behavior change breaks a test | Rule 4 |
| New test written during refactor phase | The Cycle (Refactor) |
| Spike code kept "for reference" | Spikes section |
| Claimed done before watching a test fail | The Cycle (Red gate) |

## Final Rule

```
Production code ↔ a test that ran, failed, then passed because of this code.
Otherwise: not TDD.
```
