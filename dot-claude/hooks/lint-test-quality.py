#!/usr/bin/env python3
"""PostToolUse hook: mechanical test-quality lint.

Companion to the writing-good-tests / testing-boundaries skills. Catches
the pattern-matchable violations of FIRST, naming, and "don't mock what
you don't own" so those rules don't need to sit in context for judgment
calls a regex can make instead. Never fails the tool call — findings are
surfaced via hookSpecificOutput.additionalContext, not a blocking error.
"""
import json
import re
import sys
from pathlib import Path

TEST_FILE_RE = re.compile(
    r"(^|/)("
    r"test_[^/]+\.py|[^/]+_test\.py"
    r"|[^/]+\.(test|spec)\.(js|jsx|ts|tsx)"
    r"|[^/]+_test\.go"
    r"|Test[^/]+\.java|[^/]+Test\.java"
    r"|test_[^/]+\.(cc|cpp)|[^/]+_test\.(cc|cpp)"
    r")$"
)

VAGUE_NAME_RE = re.compile(
    r"(?:def\s+test_|it\(\s*[\"']|fn\s+test_)"
    r"(?:happy_path|it_works|validate|1\s*\(|2\s*\()",
    re.IGNORECASE,
)

CHECKS = [
    (
        "FIRST:Fast",
        re.compile(r"\btime\.sleep\(|std::this_thread::sleep_for|Thread\.sleep\("),
        "real sleep call — push to integration tier or fake the clock (testing-boundaries)",
    ),
    (
        "FIRST:Repeatable",
        re.compile(r"\btime\.time\(\)|\bdatetime\.now\(\)|\brandom\.(random|randint)\("),
        "unseeded clock/RNG call — inject a fake clock or seeded RandomSource instead",
    ),
    (
        "FIRST:Self-Validating",
        re.compile(r"^\s*print\(", re.MULTILINE),
        "print() in a test — replace with an assertion",
    ),
    (
        "Rule2:DontMockWhatYouDontOwn",
        re.compile(r"(?:mock\.)?patch\((\"|')(requests|httpx|boto3|psycopg|sqlalchemy|subprocess)"),
        "mocking a 3rd-party library directly — wrap it in an adapter and mock that (testing-boundaries)",
    ),
    (
        "Doubles:PreferFakeOverMock",
        re.compile(r"\.assert_called_(once_with|with)\("),
        "mock expectation on call shape — consider a fake or spy asserting on outcome instead (writing-good-tests: Doubles Taxonomy)",
    ),
]


def find_test_file_path(payload):
    tool_input = payload.get("tool_input", {})
    path = tool_input.get("file_path")
    if path and TEST_FILE_RE.search(path):
        return path
    return None


def lint(path_str):
    path = Path(path_str)
    try:
        text = path.read_text()
    except OSError:
        return []
    warnings = []
    for name, pattern, message in CHECKS:
        if pattern.search(text):
            warnings.append(f"[{name}] {path.name}: {message}")
    if VAGUE_NAME_RE.search(text):
        warnings.append(
            f"[Naming] {path.name}: test name looks vague (happy_path/validate/it_works/numbered) — name the observable behavior instead"
        )
    return warnings


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0
    path = find_test_file_path(payload)
    if not path:
        return 0
    warnings = lint(path)
    if warnings:
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PostToolUse",
                "additionalContext": "test-quality-lint found mechanical issues:\n"
                + "\n".join(f"- {w}" for w in warnings),
            }
        }
        print(json.dumps(output))
    return 0


if __name__ == "__main__":
    sys.exit(main())
