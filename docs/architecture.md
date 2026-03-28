# Typenum.swift — Architecture Overview

`Typenum.swift` is an experimental Swift port of ideas from Rust's [`typenum`](https://github.com/paholg/typenum) crate.
The library encodes integers as distinct Swift types so that numeric relationships become compiler-checked constraints rather than runtime values.

## Module Layout

| Target | Role |
|---|---|
| `Typenum` | Public library — types, operators, macros, generated aliases |
| `TypenumCodegen` | Build tool executable — generates `GeneratedConsts.swift` at build time |
| `TypenumPlugin` | SPM build tool plugin — drives `TypenumCodegen` as a pre-build step |
| `TypenumMacros` | Macro implementation target — `#typeUInt`, `#typePositive`, `#typeNegative`, `#typeArray`, `#typenumAssertEqual` |

## Core Type Model

### Unsigned integers

Unsigned values use a binary (radix-2) recursive representation:

```
UTerm          →  0
UOne           →  1
UInt<M, B1>    →  2 * M + 1   (odd values > 1)
UInt<M, B0>    →  2 * M       (even values > 1)
```

`B0` and `B1` are the least-significant-bit carriers.
All unsigned types conform to `Unsigned` and `Integer`.

### Signed integers

```
Z0             →   0
PInt<U>        →  +U   (U: Unsigned, U ≥ 1)
NInt<U>        →  -U   (U: Unsigned, U ≥ 1)
```

All signed types conform to `Integer`.

## Operator Machinery

Type-level arithmetic is expressed as `typealias` wrappers around protocol associated-type chains.
For example, `Addition<A, B>` is a `typealias` whose concrete type is resolved by the Swift type-checker following `Add` protocol conformances on `UTerm`, `UOne`, `UInt`, `Z0`, `PInt`, and `NInt`.

Public surface aliases (`Sum`, `Diff`, `Prod`, …) re-export the underlying operator types under shorter names.

## Generated Aliases

`TypenumCodegen` emits `GeneratedConsts.swift` containing:

- `U0 … U1024` — unsigned canonical names
- `P1 … P1024` — positive signed canonical names
- `N1 … N1024` — negative signed canonical names

These names are generated rather than hand-written to keep the library maintainable and to allow the upper bound to change without manual edits.

## Proof API

`Pow2Proof<T>` is the current proof-style entry point.
It accepts a type parameter and validates at runtime that the corresponding integer is a positive power of two.
The design rationale for the runtime-verified proof approach is documented in [`docs/adr/ADR-0003-proof-driven-constraints.md`](adr/ADR-0003-proof-driven-constraints.md).

## Type-Level Arrays

`ATerm` / `TArr<Value, Rest>` form a singly-linked list of type-level integers.
Array operators (`ArrayAddition`, `ArrayDifference`, …) enforce equal-length constraints via `where LHS.Length == RHS.Length`, turning length mismatches into compile-time errors.

## Real-World Examples

Two annotated examples show how to connect the library to realistic use cases:

- [Dimensioned units — type-safe physical quantities](examples/dimensioned-units.md)
- [Generic array constraints — compile-time buffer sizing](examples/generic-array-constraints.md)
