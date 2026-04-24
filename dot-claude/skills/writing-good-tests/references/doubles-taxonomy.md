# Test Doubles — Full Taxonomy

**Read only when deciding between stub / fake / spy / mock for a specific test.**

Terminology here follows Gerard Meszaros, *xUnit Test Patterns*. The main skill gave one-liners; this file is the reference when one-liners are not enough.

## Formal definitions

### Dummy

An object that is passed through and never used. Satisfies a parameter that the production code requires but the current test does not exercise.

```python
def test_order_is_priced_from_catalog():
    _unused_logger = object()  # dummy
    order = price_order(cart, catalog=test_catalog, logger=_unused_logger)
    assert order.total == 1234
```

Never use a dummy to silently accept something the test actually depends on. If you find yourself inspecting the dummy, it is a spy and should be named one.

### Stub

Returns canned responses. Used for read-only collaborators whose output you are scripting.

```python
class StubClock:
    def now(self) -> float:
        return 1_700_000_000.0
```

A stub has no state transitions. If your "stub" needs to remember what was said to it, it is a fake.

### Fake

A simplified but working implementation. In-memory repository, fake clock that advances, fake event bus that records and replays.

```python
class InMemoryOrderRepository:
    def __init__(self) -> None:
        self._orders: dict[OrderId, Order] = {}
    def save(self, order: Order) -> None:
        self._orders[order.id] = order
    def get(self, id: OrderId) -> Order | None:
        return self._orders.get(id)
```

**Prefer fakes over stubs and mocks.** Fakes let tests be expressed in domain language ("save an order, then fetch it, then assert it came back") rather than "the `save` method was called with these arguments." Tests written against fakes survive refactors far better than tests written against mocks.

### Spy

Records calls for later verification. Use when the fact of the call is the observable behavior.

```python
class PublisherSpy:
    def __init__(self) -> None:
        self.published: list[Event] = []
    def publish(self, event: Event) -> None:
        self.published.append(event)

def test_placing_an_order_publishes_an_order_placed_event():
    publisher = PublisherSpy()
    place_order(request, publisher=publisher)
    assert len(publisher.published) == 1
    assert publisher.published[0].kind == "OrderPlaced"
```

Even here, the test asserts on *what was published* (observable behavior seen by downstream subscribers), not on *how many times `publish` was called in what order*.

### Mock

A double with pre-programmed expectations verified at the end of the test — the strongest coupling to structure.

```python
# Avoid unless nothing else works.
from unittest.mock import Mock
def test_places_order():
    publisher = Mock()
    place_order(request, publisher=publisher)
    publisher.publish.assert_called_once_with(expected_event)
```

Mock expectations say "this exact method will be called with these exact arguments in this exact order." If the production code later splits `publish` into `publish_header` + `publish_body`, the test breaks without any observable behavior changing. Prefer a spy or a fake.

## Preference order

```
fake > stub > spy > mock
```

Move right only when the option to your left does not fit.

- Need state? Fake.
- Need a canned read, no state? Stub.
- Need to see that something happened (fact of call is the behavior)? Spy.
- Need to enforce call shape because the call *is* the contract? Mock — reluctantly.

## Python-specific notes

- `unittest.mock.Mock` — produces mocks by default. Expressive but easy to overuse. Reach for it only when you have already tried a hand-rolled fake.
- `pytest-mock` — thin wrapper over `unittest.mock`. Same caveats.
- Hand-rolled fakes — prefer for anything stateful. Ten lines of fake read more clearly than ten lines of `mock.return_value = ...` setup.

## C++-specific note

GoogleMock makes mocks easy, which encourages mocks over fakes. Resist. A polymorphic fake (implementing the interface with an in-memory backing store) costs a small class definition and buys you tests that look like domain code:

```cpp
class InMemoryOrderRepository final : public OrderRepository {
public:
    void Save(const Order& o) override { orders_[o.Id()] = o; }
    std::optional<Order> Get(OrderId id) const override {
        auto it = orders_.find(id);
        return it == orders_.end() ? std::nullopt : std::optional{it->second};
    }
private:
    std::unordered_map<OrderId, Order> orders_;
};
```

Tests using this fake read as "save then get"; tests using a GoogleMock `EXPECT_CALL` read as "Save will be called with this argument once."

## When none of these is right

If you are reaching for a double to avoid touching real I/O, a DB, or a 3rd-party library: you are at a boundary. Invoke `testing-boundaries`. The adapter pattern, not a mock, is the answer there.
