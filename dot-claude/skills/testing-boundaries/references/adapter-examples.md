# Adapter Examples

**Read only when stuck on adapter shape for a specific boundary.**

All Python examples. One C++ variant at the end. Each example shows the adapter, a hand-rolled fake, and one test using the fake.

## HTTP (httpx)

```python
# adapters/github_http.py
import httpx
from domain.repo import Repo

class GitHubHttpClient:
    def __init__(self, token: str, http: httpx.Client | None = None) -> None:
        self._headers = {"Authorization": f"Bearer {token}"}
        self._http = http or httpx.Client(base_url="https://api.github.com", timeout=5.0)

    def get_repo(self, owner: str, name: str) -> Repo:
        r = self._http.get(f"/repos/{owner}/{name}", headers=self._headers)
        r.raise_for_status()
        d = r.json()
        return Repo(id=d["id"], full_name=d["full_name"], stars=d["stargazers_count"])
```

```python
# tests/fakes/github.py
class FakeGitHub:
    def __init__(self, repos: dict[tuple[str, str], Repo]) -> None:
        self._repos = repos
    def get_repo(self, owner: str, name: str) -> Repo:
        return self._repos[(owner, name)]
```

```python
def test_returns_repo_stars_from_github():
    gh = FakeGitHub({("anthropic", "claude"): Repo(id=1, full_name="anthropic/claude", stars=42)})
    assert fetch_star_count(gh, "anthropic", "claude") == 42
```

## Database (psycopg)

```python
# adapters/order_repo.py
import psycopg
from domain.order import Order, OrderId

class PostgresOrderRepository:
    def __init__(self, dsn: str) -> None:
        self._dsn = dsn

    def save(self, order: Order) -> None:
        with psycopg.connect(self._dsn) as conn, conn.cursor() as cur:
            cur.execute("INSERT INTO orders (id, total) VALUES (%s, %s)", (order.id.value, order.total))

    def get(self, id: OrderId) -> Order | None:
        with psycopg.connect(self._dsn) as conn, conn.cursor() as cur:
            cur.execute("SELECT id, total FROM orders WHERE id = %s", (id.value,))
            row = cur.fetchone()
            return None if row is None else Order(id=OrderId(row[0]), total=row[1])
```

```python
# tests/fakes/order_repo.py
class InMemoryOrderRepository:
    def __init__(self) -> None:
        self._orders: dict[OrderId, Order] = {}
    def save(self, order: Order) -> None:
        self._orders[order.id] = order
    def get(self, id: OrderId) -> Order | None:
        return self._orders.get(id)
```

## Clock

```python
# adapters/clock.py
import time
from typing import Protocol

class Clock(Protocol):
    def now(self) -> float: ...

class SystemClock:
    def now(self) -> float:
        return time.monotonic()
```

```python
class FakeClock:
    def __init__(self, start: float = 0.0) -> None:
        self._now = start
    def now(self) -> float:
        return self._now
    def advance(self, seconds: float) -> None:
        self._now += seconds
```

## Randomness

```python
# adapters/rng.py
import random
from typing import Protocol

class RandomSource(Protocol):
    def uniform(self, low: float, high: float) -> float: ...

class SystemRandom:
    def __init__(self) -> None:
        self._r = random.SystemRandom()
    def uniform(self, low: float, high: float) -> float:
        return self._r.uniform(low, high)
```

```python
class SeededRandom:
    def __init__(self, seed: int) -> None:
        self._r = random.Random(seed)
    def uniform(self, low: float, high: float) -> float:
        return self._r.uniform(low, high)
```

## Filesystem

```python
# adapters/report_store.py
from pathlib import Path

class FilesystemReportStore:
    def __init__(self, root: Path) -> None:
        self._root = root
    def save(self, name: str, content: bytes) -> None:
        (self._root / name).write_bytes(content)
    def load(self, name: str) -> bytes:
        return (self._root / name).read_bytes()
```

```python
class InMemoryReportStore:
    def __init__(self) -> None:
        self._store: dict[str, bytes] = {}
    def save(self, name: str, content: bytes) -> None:
        self._store[name] = content
    def load(self, name: str) -> bytes:
        return self._store[name]
```

## Subprocess

```python
# adapters/git_cli.py
import subprocess

class GitCli:
    def current_branch(self, repo: str) -> str:
        r = subprocess.run(
            ["git", "-C", repo, "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, check=True,
        )
        return r.stdout.strip()
```

```python
class FakeGit:
    def __init__(self, branches: dict[str, str]) -> None:
        self._branches = branches
    def current_branch(self, repo: str) -> str:
        return self._branches[repo]
```

## C++ HTTP (CPR)

```cpp
// adapters/github_http.h
#pragma once
#include <string>
#include "domain/repo.h"

class GitHubHttpClient {
public:
    virtual ~GitHubHttpClient() = default;
    virtual Repo GetRepo(const std::string& owner, const std::string& name) = 0;
};

// adapters/github_http_cpr.cc
#include <cpr/cpr.h>
class GitHubHttpClientCpr final : public GitHubHttpClient {
public:
    explicit GitHubHttpClientCpr(std::string token) : token_(std::move(token)) {}
    Repo GetRepo(const std::string& owner, const std::string& name) override {
        cpr::Response r = cpr::Get(
            cpr::Url{"https://api.github.com/repos/" + owner + "/" + name},
            cpr::Bearer{token_});
        // ... parse r.text into Repo, throw on non-2xx ...
    }
private:
    std::string token_;
};
```

Fake: a `FakeGitHub` implementing `GitHubHttpClient` with an in-memory map. Domain types cross the interface; `cpr::Response` does not.
