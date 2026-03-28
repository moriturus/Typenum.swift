# Architecture

This document describes the internal structure of Typenum.swift and captures the
canonical type normalization roadmap for core operators.

## Type Representation

Unsigned integers are encoded as recursive binary types:

| Type | Value |
|------|-------|
| `UTerm` | 0 |
| `UOne` | 1 |
| `UInt<MostSignificant, LeastSignificant>` | ≥ 2 |

`MostSignificant` must itself be `Unsigned & NonZero`; `LeastSignificant` is a `Bit`
(`B0` or `B1`). Together these form a big-endian binary encoding, e.g. the value 5
is `UInt<UInt<UOne, B0>, B1>` (binary `101`).

Signed integers wrap an unsigned magnitude:

| Type | Value |
|------|-------|
| `Z0` | 0 |
| `PInt<Magnitude>` | positive |
| `NInt<Magnitude>` | negative |

Bits are their own leaf types: `B0` (0) and `B1` (1), both conforming to `Bit`,
which refines `Unsigned`.

## Protocol Hierarchy

```
Integer
├── Unsigned
│   ├── Bit (B0, B1)
│   ├── UTerm, UOne, UInt<M, L>
│   └── operator result types that are always non-negative
└── Signed
    ├── Z0, PInt<M>, NInt<M>
    └── most operator result types
```

Orthogonal marker protocols `Zero` and `NonZero` are also available for
proof-style constraints on type-level identities.

## Runtime Bridge

Every `Integer` type exposes `static var intValue: Int`, providing a runtime
projection of its type-level value. All current operator types delegate their
entire computation to `intValue`:

```swift
public struct Addition<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public static var intValue: Int { LHS.intValue + RHS.intValue }
}
```

This approach is sufficient for value-extraction use cases, but it leaves a
significant structural gap: `Addition<P3, P2>` and `P5` are different types
even though `Addition<P3, P2>.intValue == P5.intValue == 5`. The type system
cannot treat them as interchangeable, so proof-style composition is not possible.

---

## Normalization Gaps

A type-level operation is *canonically normalized* when its result type is
structurally identical to the canonical representation of the computed value.
For example, a fully normalized `Sum<P3, P2>` would resolve to exactly `P5`
(`PInt<UInt<UInt<UOne, B0>, B1>>`), not to the `Addition<P3, P2>` wrapper.

The four core operators listed below currently lack canonical normalization.

### Gap 1 — `Sum` / `Addition`

```swift
// Current behaviour (runtime projection only):
Sum<U3, U2>.intValue == 5   // ✓ correct value
Sum<U3, U2> == U5           // ✗ not the same type
```

Because `Addition<LHS, RHS>` is a distinct nominal type for every pair of
operands, the compiler cannot unify `Sum<A, B>` with `Sum<B, A>`, with
`Sum<Sum<A, B>, C>` with `Sum<A, Sum<B, C>>`, or with any other equivalent
expression. Proof-style theorems about addition (commutativity, associativity,
identity) are therefore not expressible as type constraints.

### Gap 2 — `Diff` / `Difference`

```swift
// Current behaviour (runtime projection only):
Diff<U5, U3>.intValue == 2  // ✓ correct value
Diff<U5, U3> == U2          // ✗ not the same type
```

Without normalization, a constraint such as `Diff<N, U1> == Sub1<N>` cannot be
stated or checked by the type system. This also prevents encoding invariants like
"if `A == B` then `Diff<A, B> == U0`" as types.

### Gap 3 — `Prod` / `Product`

```swift
// Current behaviour (runtime projection only):
Prod<U2, U3>.intValue == 6  // ✓ correct value
Prod<U2, U3> == U6          // ✗ not the same type
```

Algebraic identities for multiplication (commutativity, distributivity over
addition, identity element `U1`) are not expressible without normalized results.
Deriving that `Prod<N, U0> == U0` for any `N` requires a type-level proof, not
a runtime check.

### Gap 4 — `Compare` / `Comparison`

```swift
// Current behaviour (runtime projection only):
Compare<U3, U2>.ordering == .greater  // ✓ correct ordering
Compare<U3, U2> == Greater            // ✗ not the same type
```

Without structural normalization, a generic constraint such as
`Compare<A, B> == Less` cannot be used as a type-level witness in downstream
APIs. Predicates (`Eq`, `Le`, `Gr`, …) face the same gap: `Eq<A, A>` could
be proven equal to `B1` at the type level, but today it is only evaluated at
runtime.

---

## Staged Migration Plan

The migration is intentionally staged to preserve backward compatibility at each
step. Each stage builds on the previous one and can be shipped independently.

### Stage 1 — Current State *(complete)*

- Core types defined: `UTerm`, `UOne`, `UInt`, `Z0`, `PInt`, `NInt`, `B0`, `B1`.
- Runtime value projection via `intValue` on all `Integer` conformers.
- Operator wrapper types: `Addition`, `Difference`, `Product`, `Comparison`, and
  the full suite of secondary operators.
- Public short aliases: `Sum`, `Diff`, `Prod`, `Compare`, etc.
- Canonical aliases `U0…U1024`, `P1…P1024`, `N1…N1024` generated at build time.
- `Pow2Proof<T>` as the initial proof-style construct.

### Stage 2 — Unsigned Addition Normalization *(planned: SLICE-1, SLICE-2)*

Introduce a `UnsignedAddition` associated-type protocol and implement carry-
propagating type-level addition recursively on `UTerm`, `UOne`, and
`UInt<M, L>`.

Core recursion (sketch):

| LHS | RHS | Result |
|-----|-----|--------|
| `UTerm` | any `U` | `U` |
| any `U` | `UTerm` | `U` |
| `UOne` | `UOne` | `UInt<UOne, B0>` |
| `UInt<M, B0>` | `UInt<N, B0>` | `UInt<NormalSum<M,N>, B0>` |
| `UInt<M, B0>` | `UInt<N, B1>` | `UInt<NormalSum<M,N>, B1>` |
| `UInt<M, B1>` | `UInt<N, B0>` | `UInt<NormalSum<M,N>, B1>` |
| `UInt<M, B1>` | `UInt<N, B1>` | `UInt<NormalSum<M, Add1<N>>, B0>` (carry) |

Once the unsigned case is complete, extend to signed integers via case analysis
on `PInt`, `NInt`, and `Z0`.

Alias migration: change `Sum` from a typealias of `Addition` to a typealias of
the normalized result type. Because the normalized type still conforms to
`Integer` (and `Unsigned` where applicable), all call sites that only use
`intValue` continue to work unmodified.

### Stage 3 — Unsigned Subtraction Normalization *(planned: SLICE-3, SLICE-4)*

Implement borrow-propagating type-level subtraction on unsigned types. Subtraction
that would produce a negative result under unsigned semantics must be caught as a
compile-time error via an unsatisfied constraint.

Migrate `Diff` to point to the normalized result type using the same backward-
compatible pattern as Stage 2.

### Stage 4 — Unsigned Multiplication Normalization *(planned: SLICE-5, SLICE-6)*

Implement shift-and-add type-level multiplication. Given that multiplication is
the most expensive operation in the type-checker's reduction budget, a lazy or
memoized encoding should be considered to avoid compiler timeouts on large values.

Migrate `Prod` to point to the normalized result type.

### Stage 5 — Comparison Normalization *(planned: SLICE-7)*

Derive the `ComparisonResult` conformance (`Less`, `Equal`, `Greater`) from the
type structure of the operands rather than from a runtime `intValue` comparison.
This unlocks type-level predicates: `Eq<A, A>` can be proven equal to `B1`
without evaluating `intValue`.

Migrate `Compare` to point to the structurally-derived result type.

### Stage 6 — Signed Arithmetic Normalization *(planned: SLICE-8)*

Extend all normalized operations from Stages 2–5 to cover the full signed-integer
lattice (`Z0`, `PInt`, `NInt`). Sign propagation rules:

| `LHS` | `RHS` | `Sum` result |
|-------|-------|-------------|
| `PInt<M>` | `PInt<N>` | `PInt<NormalSum<M,N>>` |
| `NInt<M>` | `NInt<N>` | `NInt<NormalSum<M,N>>` |
| `PInt<M>` | `NInt<N>` | depends on `Compare<M,N>` |
| `NInt<M>` | `PInt<N>` | depends on `Compare<M,N>` |
| `Z0` | any | the other operand |

### Stage 7 — Advanced Operator Normalization *(planned: SLICE-9)*

Revisit `Sqrt`, `Log2`, `Gcf`, `BitLen`, `PartialQuot`, and the array operators
to determine which can be normalized without an unacceptable increase in
type-checker complexity.

---

## Public API Implications

### Non-Breaking Changes (Stages 2–5)

The public aliases (`Sum`, `Diff`, `Prod`, `Compare`) remain valid names.
Consumers who only call `.intValue` see no observable change. The underlying
concrete type resolves to the canonical form rather than the wrapper struct, but
that is an implementation detail not reflected in the public API surface.

Conditional `Unsigned` conformances are preserved: if `LHS: Unsigned` and
`RHS: Unsigned`, the normalized `Sum<LHS, RHS>` will still conform to `Unsigned`.

### Potentially Breaking Changes (Stage 6–7)

- Code that explicitly spells the full wrapper type (e.g., `Addition<P3, P2>`)
  rather than the `Sum` alias will observe a type identity change. Users should
  be migrated to the public aliases before Stage 6 lands.
- Generic constraints such as `T == Addition<A, B>` will need to be updated to
  `T == Sum<A, B>` or the canonical expanded form.
- The `Signed` conformance on `Addition`, `Difference`, and `Product` will be
  superseded by the protocol conformances of the canonical types.

### New Proof-Style Capabilities (all stages)

After full normalization the following patterns become expressible as static
constraints:

```swift
// Commutativity
func commute<A: Unsigned, B: Unsigned>() where Sum<A, B> == Sum<B, A> {}

// Associativity
func assoc<A: Unsigned, B: Unsigned, C: Unsigned>()
    where Sum<Sum<A, B>, C> == Sum<A, Sum<B, C>> {}

// Identity
func identity<A: Unsigned>() where Sum<A, UTerm> == A {}

// Comparison-driven branching
func ifLess<A: Unsigned, B: Unsigned>() where Compare<A, B> == Less {}
```

---

## Follow-Up Slices

| Slice | Scope | Depends On |
|-------|-------|-----------|
| SLICE-1 | Implement `NormalizedSum` associated type on `Unsigned` | Stage 1 |
| SLICE-2 | Migrate `Sum` / `Addition` to normalized result | SLICE-1 |
| SLICE-3 | Implement `NormalizedDiff` associated type on `Unsigned` | SLICE-1 |
| SLICE-4 | Migrate `Diff` / `Difference` to normalized result | SLICE-3 |
| SLICE-5 | Implement `NormalizedProd` associated type on `Unsigned` | SLICE-1 |
| SLICE-6 | Migrate `Prod` / `Product` to normalized result | SLICE-5 |
| SLICE-7 | Implement structural `NormalizedCompare` and migrate `Compare` | SLICE-1 |
| SLICE-8 | Extend all normalized operations to signed types | SLICE-2, SLICE-4, SLICE-6, SLICE-7 |
| SLICE-9 | Evaluate normalization of advanced operators | SLICE-8 |

Each slice should be gated behind a feature-flag branch and accompanied by tests
that assert type identity (`assertTypeEqual`) in addition to value equality
(`intValue`).
