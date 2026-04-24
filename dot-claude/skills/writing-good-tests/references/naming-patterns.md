# Naming Patterns

**Read only when stuck on a test name.**

A test name is a sentence about observable behavior. When the obvious name feels insufficient, use one of these patterns.

## Plain English vs `given_when_then`

Default: **plain English** with the test framework's required prefix.

- Python: `def test_<sentence>():`
- Rust: `#[test] fn <sentence>()`
- TypeScript (vitest/jest): `it("<sentence>", ...)`

Switch to `given_when_then` (or framework-native `describe`/`context` nesting) when:

- The setup is non-obvious and omitting it leaves the name vague.
  - Plain: `test_rejects_call_over_limit` — fine if the limit is obvious in context.
  - GWT: `test_given_limit_of_three_when_fourth_call_in_window_then_rejected` — when multiple limits or windows are possible and the specific one matters.
- Two tests would have the same plain-English name distinguished only by setup.

## Parameterized tests

When the same behavior is exercised over a data table, name the table entry, not the test function.

```python
@pytest.mark.parametrize(
    "window_size, valid",
    [(60, True), (0, False), (-1, False)],
    ids=["positive_window_is_valid", "zero_window_is_invalid", "negative_window_is_invalid"],
)
def test_window_size_validation(window_size, valid):
    ...
```

The function name describes the general behavior. The `ids` describe the specific case.

## Error paths vs happy paths

Never collapse them into one test. Name error-path tests with the failure mode:

- `test_rejects_empty_email` — good, names the rejection.
- `test_submit_form` with branches inside — bad, the name hides half the behavior.

If an error carries a message the caller depends on, include it:

- `test_rejects_empty_email_with_message_email_required`.

## Disambiguating two tests that want the same name

If you catch yourself writing the same name twice, ask what actually differs:

- Different **inputs** same behavior → parameterize (above).
- Different **contexts** producing the same outcome → add the context to the name: `test_rejects_empty_email_on_signup`, `test_rejects_empty_email_on_password_reset`.
- Different **outcomes** from the same inputs → you have a nondeterministic behavior; test is likely wrong. Fix the test or the code.

## When the name gets long

A 15-word test name is acceptable. A test with no clear name is not. If you cannot write a sentence describing what behavior the test verifies, the test is probably asserting on structure — go back to the behavior-vs-structure section of the main skill.
