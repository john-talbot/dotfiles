---
name: testing-boundaries
description: Use when a feature first touches a collaborator you do not own — HTTP, DB, filesystem, OS, clock, randomness, 3rd-party SDK, message broker, or another bounded context. Owns the adapter pattern, the test pyramid, tier placement, and tooling notes. Invoke lazily — skip entirely if the feature is pure logic.
---

# Testing Boundaries

## Purpose

This skill is loaded **lazily** — only when the feature you are implementing first touches a collaborator you do not own. It owns the adapter pattern, the test pyramid framed as boundary-placement, tier decisions, and Python-first tooling notes.

Sibling skills: `test-driven-development` drives the cycle, `writing-good-tests` shapes each test. Do not duplicate their content here — cross-reference them.

## What Is a Boundary?

A boundary is any collaborator you do not own. Standard cases:

- HTTP / network clients
- Databases
- Filesystem
- OS / subprocess / environment variables
- Clock (wall time, monotonic time)
- Randomness
- 3rd-party SDKs (cloud providers, payment processors, auth)
- Message brokers / queues
- Other bounded contexts within your own system with independent lifecycle

If the test needs one of these to work, the test sits at a boundary.

## Don't Mock What You Don't Own

Mock your own abstractions. Never mock a 3rd-party library's call surface directly.

<Bad>
```python
from unittest.mock import patch

def test_fetches_forecast():
    with patch("requests.get") as m:
        m.return_value.json.return_value = {"temp": 72}
        assert fetch_forecast("NYC") == 72
```
The test is coupled to `requests`'s internals. Swap to `httpx` and every test breaks despite no behavior change. The test also grows every time the library's shape changes.
</Bad>

<Good>
```python
class FakeWeatherHttp:
    def __init__(self, responses: dict[str, Forecast]) -> None:
        self._responses = responses
    def get_forecast(self, city: str) -> Forecast:
        return self._responses[city]

def test_fetches_forecast():
    http = FakeWeatherHttp({"NYC": Forecast(temp=72)})
    assert fetch_forecast("NYC", http=http).temp == 72
```
Test talks to an interface you own. The 3rd-party library is an implementation detail of the adapter that backs the real `http`.
</Good>

## The Default Adapter Shape

One prescribed pattern that handles ~90% of cases:

1. A thin class (or module) in your codebase wraps the 3rd-party type.
2. The adapter's public interface speaks **domain types**, never library types.
3. The adapter is the only place in your codebase that imports the 3rd-party library.
4. Business logic depends on the adapter's interface, not the 3rd-party.

**Python example** — an adapter wrapping `httpx`:

```python
# adapters/weather_http.py  -- the ONLY file that imports httpx.
import httpx
from domain.weather import Forecast

class WeatherHttpClient:
    def __init__(self, base_url: str, http: httpx.Client | None = None) -> None:
        self._base_url = base_url
        self._http = http or httpx.Client(timeout=5.0)

    def get_forecast(self, city: str) -> Forecast:
        response = self._http.get(f"{self._base_url}/forecast", params={"city": city})
        response.raise_for_status()
        data = response.json()
        return Forecast(temp=data["temp"], conditions=data["conditions"])
```

Note that `Forecast` is a domain type — no `httpx.Response` leaks out. Business-logic code depends on a `WeatherHttpClient` (or its protocol), never on `httpx`.

**C++ note:** adapter as an abstract base class with a concrete implementation; domain types returned by value. Full worked adapters for DB, clock, filesystem, subprocess, and C++ live in `references/adapter-examples.md` — read only when stuck on adapter shape for a specific boundary.

## The Test Pyramid, Located

The pyramid is a placement rule, not a shape in the sky:

- **Unit tier** — pure business logic. No adapter is exercised against its real external. Hand-rolled fakes stand in for your own adapters. ~70% by default.
- **Integration tier** — the adapter itself is tested against the real external (or a trustworthy stand-in like testcontainers, a local process, or a recorded HTTP response). ~20%.
- **E2E tier** — whole system through its outermost entry point (HTTP, CLI, UI). ~10%.

Ratios are defaults, not laws. The load-bearing rules:

- Unit tests MUST NOT need the real external.
- Integration tests MUST NOT assert business logic — they assert adapter behavior against the real thing.

## Which Tier Does This Test Belong In?

Decision procedure:

1. Does the test exercise one of your adapters against its real external? → **Integration.**
2. Does the test exercise business logic with fakes for adapters? → **Unit.**
3. Does the test enter through the outermost HTTP/CLI/UI and cross multiple layers? → **E2E.**

**Tie-breaker:** if the test would break when the real external is briefly down, it's integration or worse. Move it.

## When the Default Adapter Isn't Enough

Reach for ports-and-adapters (hexagonal) only when one of these is true:

- Multiple backends must be swappable at runtime (e.g., a payment service with Stripe and Adyen implementations).
- Business logic must be testable without ever constructing any adapter (pure ports, no default-backed thin wrapper).
- The bounded context owns a nontrivial lifecycle (outbox pattern, saga, event sourcing).

Otherwise: do not reach for hexagonal preemptively. The default adapter handles the other 90%.

Full treatment: `references/hexagonal-aside.md` — read only when one of the triggers above actually applies.

## Tooling Notes (Python-first)

One line each.

- **testcontainers-python** — real DB or service in an ephemeral container. Integration tier.
- **respx** / **httpx.MockTransport** — intercept httpx requests at the transport layer. Integration tier for HTTP adapters.
- **freezegun** / hand-rolled **FakeClock** — time in unit tier. Prefer the hand-rolled fake — freezegun is global magic that bleeds across tests.
- **`random.Random(seed)`** or an injected `RandomSource` — randomness in unit tier.
- **vcr.py** — record HTTP and replay. Use sparingly; recordings drift into snapshot-style tests that assert on structure.
- **wiremock** — standalone HTTP stub; integration tier when respx is insufficient.
- **hypothesis** — property-based coverage; works well over adapter interfaces to exercise domain types thoroughly.

## When the 3rd-Party Has Poor Test Support

Some externals are genuinely hostile: no sandbox, no stub mode, rate-limited, or proprietary auth.

- Define the adapter interface based on what **you** need, not the library's shape.
- Build a hand-rolled fake against that interface. Use it for the bulk of your coverage (unit tier).
- Write a small integration suite that hits the real external. Run it pre-release or nightly — not on every commit.
- Never mock the library's internals to work around poor test support — that grows a test suite of lies.

## Red Flags

| Flag | Violates |
|---|---|
| Mocking `requests`, `httpx`, `boto3`, or similar directly | Don't Mock What You Don't Own |
| Integration test asserting business logic | Which Tier — integration asserts adapter behavior |
| Adapter returns library types (`httpx.Response`, `psycopg.Row`) | Default Adapter Shape — adapter speaks domain |
| Every test touches a real DB | Pyramid — unit tier has no real externals |
| Test needs network to run offline | Pyramid + tier — wrong tier |
| Reaching for hexagonal for a single-backend feature | When the Default Isn't Enough — default handles 90% |

## Load Discipline

Consult from context after first invocation. Do not re-invoke per adapter.
