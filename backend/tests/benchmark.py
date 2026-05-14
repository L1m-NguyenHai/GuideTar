from __future__ import annotations

import asyncio
import json
import statistics
import time
import uuid
from dataclasses import dataclass, field
from typing import Any

import httpx

BASE = "http://127.0.0.1:8000"
SAMPLES_FAST = 30
SAMPLES_MEDIUM = 20
SAMPLES_SLOW = 10


@dataclass
class EndpointResult:
    name: str
    method: str
    path: str
    samples: list[float] = field(default_factory=list)

    def add(self, elapsed: float) -> None:
        self.samples.append(elapsed)

    @property
    def count(self) -> int:
        return len(self.samples)

    @property
    def mean(self) -> float:
        return statistics.mean(self.samples) if self.samples else 0.0

    @property
    def p50(self) -> float:
        s = sorted(self.samples)
        return s[int(len(s) * 0.5)] if s else 0.0

    @property
    def p90(self) -> float:
        s = sorted(self.samples)
        return s[int(len(s) * 0.9)] if s else 0.0

    @property
    def p95(self) -> float:
        s = sorted(self.samples)
        return s[int(len(s) * 0.95)] if s else 0.0

    @property
    def p99(self) -> float:
        s = sorted(self.samples)
        return s[int(len(s) * 0.99)] if s else 0.0

    @property
    def min(self) -> float:
        return min(self.samples) if self.samples else 0.0

    @property
    def max(self) -> float:
        return max(self.samples) if self.samples else 0.0

    def to_dict(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "method": self.method,
            "path": self.path,
            "samples": self.count,
            "mean_ms": round(self.mean * 1000, 2),
            "p50_ms": round(self.p50 * 1000, 2),
            "p90_ms": round(self.p90 * 1000, 2),
            "p95_ms": round(self.p95 * 1000, 2),
            "p99_ms": round(self.p99 * 1000, 2),
            "min_ms": round(self.min * 1000, 2),
            "max_ms": round(self.max * 1000, 2),
        }


def table(results: list[EndpointResult]) -> str:
    lines = [
        f"{'Endpoint':<50} {'#':>5} {'Mean':>8} {'P50':>8} {'P90':>8} {'P95':>8} {'P99':>8} {'Max':>8} {'Status':>8}",
        "-" * 111,
    ]
    for r in results:
        d = r.to_dict()
        name = f"{d['method']} {d['path']}"
        fail = d["samples"] == 0
        status = "❌ FAIL" if fail else "OK"
        if fail:
            lines.append(f"{name:<50} {d['samples']:>5} {'-':>8} {'-':>8} {'-':>8} {'-':>8} {'-':>8} {'-':>8} {status:>8}")
        else:
            lines.append(
                f"{name:<50} {d['samples']:>5} {d['mean_ms']:>8.1f} {d['p50_ms']:>8.1f} {d['p90_ms']:>8.1f} "
                f"{d['p95_ms']:>8.1f} {d['p99_ms']:>8.1f} {d['max_ms']:>8.1f} {status:>8}"
            )
    return "\n".join(lines)


async def bench_n(
    client: httpx.AsyncClient,
    result: EndpointResult,
    method: str,
    path: str,
    n: int,
    **kwargs: Any,
) -> None:
    for _ in range(n):
        try:
            r = await client.request(method, f"{BASE}{path}", **kwargs)
            result.add(r.elapsed.total_seconds())
            if r.status_code >= 400:
                print(f"  WARN: {method} {path} -> {r.status_code} {r.text[:120]}")
        except Exception as e:
            print(f"  ERROR: {method} {path} -> {e}")


async def main() -> None:
    test_email = f"bench_{uuid.uuid4().hex[:8]}@example.com"
    test_username = f"bench_{uuid.uuid4().hex[:8]}"
    test_password = "BenchPass123!"

    results: list[EndpointResult] = []
    token: str | None = None

    async with httpx.AsyncClient(timeout=300.0) as client:
        # ── health (sync, fastest) ──
        r = EndpointResult("health", "GET", "/health")
        results.append(r)
        await bench_n(client, r, "GET", "/health", SAMPLES_FAST)

        # ── register (1 call) ──
        r = EndpointResult("register", "POST", "/auth/register")
        results.append(r)
        resp = await client.post(f"{BASE}/auth/register", json={
            "email": test_email,
            "password": test_password,
            "username": test_username,
        })
        r.add(resp.elapsed.total_seconds())
        if resp.status_code == 201 or resp.status_code == 200:
            print(f"  Registered test user: {test_email}")
        elif resp.status_code == 409:
            print(f"  User already exists (409), continuing...")
        else:
            print(f"  WARN: register -> {resp.status_code} {resp.text[:200]}")

        # ── login ──
        r = EndpointResult("login", "POST", "/auth/login")
        results.append(r)
        await bench_n(client, r, "POST", "/auth/login", SAMPLES_FAST, json={
            "email": test_email,
            "password": test_password,
        })
        # Extract token
        login_resp = await client.post(f"{BASE}/auth/login", json={
            "email": test_email,
            "password": test_password,
        })
        if login_resp.status_code == 200:
            token = login_resp.json().get("access_token")
            print(f"  Token obtained: {token[:20]}...")
        else:
            print(f"  WARN: login (token) -> {login_resp.status_code} {login_resp.text[:200]}")
            print("  Auth-required endpoints will be skipped")

        headers = {"Authorization": f"Bearer {token}"} if token else {}

        # ── catalog (no auth, DB reads) ──
        r = EndpointResult("catalog/recommended", "GET", "/catalog/recommended")
        results.append(r)
        await bench_n(client, r, "GET", "/catalog/recommended", SAMPLES_MEDIUM)

        r = EndpointResult("catalog/artists", "GET", "/catalog/artists")
        results.append(r)
        await bench_n(client, r, "GET", "/catalog/artists", SAMPLES_MEDIUM)

        # ── billing (no auth) ──
        r = EndpointResult("billing/plans", "GET", "/billing/plans")
        results.append(r)
        await bench_n(client, r, "GET", "/billing/plans", SAMPLES_MEDIUM)

        # ── support (no auth) ──
        r = EndpointResult("support/categories", "GET", "/support/categories")
        results.append(r)
        await bench_n(client, r, "GET", "/support/categories", SAMPLES_MEDIUM)

        r = EndpointResult("support/faqs", "GET", "/support/faqs")
        results.append(r)
        await bench_n(client, r, "GET", "/support/faqs", SAMPLES_MEDIUM)

        # ── artists (no auth) ──
        r = EndpointResult("artists/{name}", "GET", "/artists/beatles")
        results.append(r)
        await bench_n(client, r, "GET", "/artists/beatles", SAMPLES_SLOW)

        # ── auth-required endpoints ──
        if token:
            r = EndpointResult("users/me", "GET", "/users/me")
            results.append(r)
            await bench_n(client, r, "GET", "/users/me", SAMPLES_FAST, headers=headers)

            r = EndpointResult("dechord/history", "GET", "/api/analyze/history")
            results.append(r)
            await bench_n(client, r, "GET", "/api/analyze/history", SAMPLES_SLOW, headers=headers)

            r = EndpointResult("favorites/songs", "GET", "/favorites/songs")
            results.append(r)
            await bench_n(client, r, "GET", "/favorites/songs", SAMPLES_SLOW, headers=headers)

            r = EndpointResult("favorites/lessons", "GET", "/favorites/lessons")
            results.append(r)
            await bench_n(client, r, "GET", "/favorites/lessons", SAMPLES_SLOW, headers=headers)

            r = EndpointResult("notes", "GET", "/notes/")
            results.append(r)
            await bench_n(client, r, "GET", "/notes/", SAMPLES_SLOW, headers=headers)

        # ── concurrency test ──
        print("\n  Concurrency test: 10x /catalog/recommended in parallel...")
        concur = EndpointResult("concurrent(10)", "GET", "/catalog/recommended")

        async def hit() -> None:
            try:
                r = await client.get(f"{BASE}/catalog/recommended")
                concur.add(r.elapsed.total_seconds())
            except Exception as e:
                print(f"    concurrent error: {e}")

        await asyncio.gather(*[hit() for _ in range(10)])
        results.append(concur)

    # ── Output ──
    print("\n" + "=" * 111)
    print("  LATENCY BENCHMARK RESULTS  (ms)")
    print("=" * 111)
    print(table(results))

    report = {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "base_url": BASE,
        "endpoints": [r.to_dict() for r in results],
    }
    with open("tests/benchmark_results.json", "w") as f:
        json.dump(report, f, indent=2)
    print(f"\n  Results saved to tests/benchmark_results.json")

    slow = [e for e in report["endpoints"] if e["samples"] > 0 and e["p95_ms"] > 500]
    if slow:
        print("  ⚠️  Endpoints with p95 > 500ms (may need optimization):")
        for e in slow:
            print(f"    - {e['method']} {e['path']}: p95={e['p95_ms']}ms")


if __name__ == "__main__":
    asyncio.run(main())
