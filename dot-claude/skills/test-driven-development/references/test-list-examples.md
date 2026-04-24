# Test List Examples

**Read this only when stuck on the shape of a test list or a test.**

Same feature across languages: a rate limiter that allows at most N calls per window. Each section shows the test list, then one concrete test realizing the first list item. No implementation code.

## Python (pytest)

Test list:

- calls under the limit are allowed
- the (N+1)th call in the same window is rejected
- after the window elapses, the counter resets
- concurrent calls from distinct keys do not share a counter
- invalid window size (zero, negative) is rejected at construction

First concrete test:

```python
def test_calls_under_the_limit_are_allowed():
    limiter = RateLimiter(limit=3, window_seconds=60)
    for _ in range(3):
        assert limiter.allow("user-1") is True
```

## C++ (GoogleTest)

Test list:

- calls under the limit are allowed
- the (N+1)th call in the same window is rejected
- after the window elapses, the counter resets
- distinct keys have independent counters
- construction with zero/negative limit is rejected

First concrete test:

```cpp
TEST(RateLimiter, CallsUnderTheLimitAreAllowed) {
    RateLimiter limiter(/*limit=*/3, /*window=*/std::chrono::seconds(60));
    for (int i = 0; i < 3; ++i) {
        EXPECT_TRUE(limiter.Allow("user-1"));
    }
}
```

## Rust

Test list:

- calls under the limit are allowed
- the (N+1)th call in the same window is rejected
- after the window elapses, the counter resets
- distinct keys have independent counters
- construction with zero/negative limit returns an error

First concrete test:

```rust
#[test]
fn calls_under_the_limit_are_allowed() {
    let mut limiter = RateLimiter::new(3, Duration::from_secs(60)).unwrap();
    for _ in 0..3 {
        assert!(limiter.allow("user-1"));
    }
}
```

## C (Unity)

Test list:

- calls under the limit are allowed
- the (N+1)th call in the same window is rejected
- after the window elapses, the counter resets
- distinct keys have independent counters
- construction with zero/negative limit returns RL_EINVAL

First concrete test:

```c
void test_calls_under_the_limit_are_allowed(void) {
    rate_limiter_t *rl;
    TEST_ASSERT_EQUAL(RL_OK, rate_limiter_new(&rl, /*limit=*/3, /*window_s=*/60));
    for (int i = 0; i < 3; ++i) {
        TEST_ASSERT_TRUE(rate_limiter_allow(rl, "user-1"));
    }
    rate_limiter_free(rl);
}
```

## TypeScript / JavaScript (vitest)

Test list:

- calls under the limit are allowed
- the (N+1)th call in the same window is rejected
- after the window elapses, the counter resets
- distinct keys have independent counters
- construction with zero/negative limit throws

First concrete test:

```typescript
import { describe, it, expect } from "vitest";

describe("RateLimiter", () => {
  it("allows calls under the limit", () => {
    const limiter = new RateLimiter({ limit: 3, windowMs: 60_000 });
    for (let i = 0; i < 3; i++) {
      expect(limiter.allow("user-1")).toBe(true);
    }
  });
});
```
