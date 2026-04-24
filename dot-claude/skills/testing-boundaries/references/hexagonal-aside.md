# Hexagonal Aside

**Read only when the default adapter is insufficient per the main skill's "When the Default Adapter Isn't Enough" section.**

This reference assumes you know what ports-and-adapters is. Cockburn's 2005 essay is authoritative; this is the agent-facing summary for when the default thin adapter earns a full hexagonal arrangement.

## Ports vs adapters

- **Port** — an interface **owned by the domain**. It says what the domain needs from the outside world in domain terms. A `PaymentProcessor` port might expose `charge(customer, amount) -> ChargeOutcome`.
- **Adapter** — an infrastructure implementation of a port. `StripeAdapter`, `AdyenAdapter`. Multiple adapters can satisfy one port.

The default adapter pattern (main skill) is one adapter per 3rd-party. Hexagonal promotes the adapter's interface into a domain-owned port, then has multiple adapters implement it.

## Primary vs secondary adapters

- **Primary (driving)** — something from the outside drives the domain. HTTP controllers, CLI commands, message consumers. They call into the domain.
- **Secondary (driven)** — the domain drives something on the outside. Payment processors, DBs, email senders. They are called by the domain.

Most "I have a 3rd-party" cases are secondary adapters, which is where hexagonal earns its keep.

## When the indirection earns its keep

1. **Multiple backends at runtime.** Stripe + Adyen, postgres + DynamoDB, SMTP + SES. Selecting at construction time (or by tenant) requires a port with multiple implementations.
2. **Business logic must be testable without any adapter instance.** Pure-domain tests that take the port's protocol directly, never a thin default.
3. **Lifecycle concerns that span adapters.** Outbox pattern: one database write + one message publish must be transactionally atomic from the domain's perspective. A port that encapsulates the whole unit-of-work is clearer than two separate adapters.

## When it does not

- Single backend, no plausible swap. You are paying indirection cost for nothing.
- Small CLI tool, internal script, short-lived. The default thin adapter ships sooner.
- You "might need hexagonal later". Build the default; promote to a port the day you add a second adapter. Promotion is mechanical once the thin adapter's interface already speaks domain types.

## The test shape under hexagonal

- Unit tests of business logic depend on the port (interface), not on any adapter. Fakes implement the port.
- Integration tests of each adapter against its real external — one suite per adapter.
- No change to E2E.

The pyramid still holds. The only difference is the unit tier is even more decoupled: tests can be written before any adapter exists.
