# Typenum.swift

`Typenum.swift` is an experimental Swift port of Rust's [`typenum`](https://github.com/paholg/typenum) ideas.
It models integers at the type level using recursive integer types, generated canonical aliases, and freestanding macros that help construct metatype expressions.

The package targets Swift 6.3 and ships as a Swift Package Manager library.

## Status

This project is currently **Experimental**.

The current implementation is useful for exploring type-level integer modeling in Swift, but parts of the surface still rely on runtime projections and precondition failures where Swift does not yet offer stronger compile-time expression mechanisms.

## Highlights

- Canonical aliases for unsigned and signed integers: `U0...U1024`, `P1...P1024`, `N1...N1024`
- Recursive integer model built from `UTerm`, `UOne`, `UInt`, `Z0`, `PInt`, and `NInt`
- Typed arithmetic and comparison aliases such as `Sum`, `Diff`, `Prod`, `Quot`, `Rem`, `Pow`, and `Compare`
- Additional operators including `Negate`, `AbsVal`, `Sqrt`, `Log2`, `Gcf`, `BitLen`, and `PartialQuot`
- Type-level comparison predicates such as `Eq`, `Le`, `Gr`, `LeEq`, `NotEq`, and `GrEq`
- Type-level integer arrays with length, fold, and element-wise arithmetic support
- Freestanding macros for metatype construction and compile-time type equality assertions
- Build-time code generation for canonical aliases via the package build tool plugin

## Requirements

- Swift 6.3
- Swift Package Manager
- Supported platforms follow [`Package.swift`](Package.swift):
  - macOS 10.15+
  - iOS 13+
  - tvOS 13+
  - watchOS 6+
  - visionOS 1+
  - DriverKit 19+

## Installation

Add `Typenum` as a SwiftPM dependency:

```swift
dependencies: [
    .package(url: "https://github.com/moriturus/Typenum.swift.git", branch: "develop")
]
```

Replace the URL above with the published repository location you intend to use.

Then add the library product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Typenum", package: "Typenum.swift")
    ]
)
```

Import the module where needed:

```swift
import Typenum
```

The package includes:

- the `Typenum` library target
- a build tool plugin that generates canonical aliases during builds
- freestanding expression macros exposed through the library target

As a consumer, you only need to depend on and import `Typenum`; the generated aliases and macros are surfaced through the library.

## Real-World Examples

Two annotated examples show how to apply `Typenum.swift` to realistic problems:

- [Dimensioned units — type-safe physical quantities](docs/examples/dimensioned-units.md):
  encode SI dimension exponents as type-level integers so that the compiler verifies unit correctness in arithmetic expressions.
- [Generic array constraints — compile-time buffer sizing](docs/examples/generic-array-constraints.md):
  use `TArr`-based type arrays and unsigned integer type parameters to enforce fixed-size and equal-length constraints without any runtime guard code.

See [`docs/architecture.md`](docs/architecture.md) for a broader overview of the module layout and design decisions.

## Quick Example

```swift
import Testing
import Typenum

#expect(Sum<U3, U4>.intValue == 7)
#expect(Prod<U3, U4>.intValue == 12)
#expect(Compare<U3, U4>.ordering == .less)

#typenumAssertEqual(#typeUInt(7), U7.self)
#typenumAssertEqual(
    #typeArray(P1.self, P2.self, P3.self),
    TArr<P3, TArr<P2, TArr<P1, ATerm>>>.self
)
```

## Core Model

Unsigned integers are represented with recursive binary types:

- `UTerm` for `0`
- `UOne` for `1`
- `UInt<MostSignificant, LeastSignificant>` for values `>= 2`

Signed integers are represented as:

- `Z0` for `0`
- `PInt<Magnitude>` for positive values
- `NInt<Magnitude>` for negative values

The generated aliases provide canonical names for common values:

```swift
let seven = U7.intValue
let positive = P4.intValue
let negative = N4.intValue
```

All integer types conform to `Integer`, which provides a small runtime bridge:

```swift
#expect(U16.toInt() == 16)
#expect(P4.to(Int8.self) == 4)
#expect(N4.to(Int8.self) == -4)
#expect(U256.to(UInt8.self) == nil)
```

## Arithmetic And Comparison

Basic arithmetic and comparison wrappers are available as public aliases:

```swift
#expect(Sum<U3, U4>.intValue == 7)
#expect(Diff<U9, U4>.intValue == 5)
#expect(Prod<U3, U4>.intValue == 12)
#expect(Quot<U9, U4>.intValue == 2)
#expect(Rem<U9, U4>.intValue == 1)
#expect(Pow<U2, U4>.intValue == 16)

#expect(Sum<P3, N4>.intValue == -1)
#expect(Exp<N2, U3>.intValue == -8)
#expect(Compare<P3, N2>.ordering == .greater)
```

Comparison predicates return type-level bits:

```swift
#expect(Eq<U2, U2>.bitValue == 1)
#expect(Le<U2, U3>.bitValue == 1)
#expect(Gr<U2, U3>.bitValue == 0)
```

Additional operators cover common number-theoretic and bit-oriented operations:

```swift
#expect(Negate<P4>.intValue == -4)
#expect(AbsVal<N4>.intValue == 4)
#expect(Sqrt<U17>.intValue == 4)
#expect(Log2<U9>.intValue == 3)
#expect(Gcf<U54, U24>.intValue == 6)
#expect(BitLen<U9>.intValue == 4)
#expect(PartialQuot<U8, U2>.intValue == 4)
```

## Type-Level Arrays

`ATerm` is the empty array and `TArr<Value, Rest>` appends one integer element to the array tail.

```swift
typealias Pair = TArr<U1, TArr<U2, ATerm>>
typealias PairAlt = TArr<U3, TArr<U4, ATerm>>

#expect(LengthOp<Pair>.intValue == 2)
#expect(FoldAddOp<Pair>.intValue == 3)
#expect(FoldMulOp<Pair>.intValue == 2)

#expect(ArrayAddition<Pair, PairAlt>.intValues == [6, 4])
#expect(ArrayDifference<PairAlt, Pair>.intValues == [2, 2])
#expect(ArrayProduct<Pair, PairAlt>.intValues == [8, 3])
```

Equal-length constraints are enforced statically with generic `where` clauses on the array operator wrappers.

## Macros

Because Swift does not currently expose freestanding type-position macros, the macro API operates on metatype expressions.

```swift
#typenumAssertEqual(#typeUInt(0), UTerm.self)
#typenumAssertEqual(#typeUInt(16), U16.self)

#typenumAssertEqual(#typePositive(4), P4.self)
#typenumAssertEqual(#typeNegative(4), N4.self)

#typenumAssertEqual(#typeArray(), ATerm.self)
#typenumAssertEqual(#typeArray(U1.self), TArr<U1, ATerm>.self)
```

`#typenumAssertEqual(...)` expands to a compile-time type equality check. If the two metatypes do not resolve to the same concrete type, the compiler rejects the expression.

## Proofs And Constraints

`Pow2Proof<T>` is the primary proof-style public API today:

```swift
let _ = Pow2Proof<U8>()
```

It validates at runtime that `T` is a positive power of two. Generated proof-oriented scaffolding exists in the project, but the proof API surface is still intentionally small and should be considered immature.

## Current Limitations

- Many public wrappers project type-level values through `static var intValue: Int`
- Several failure paths are enforced with `precondition`, not with fully compile-time proofs
- `Quot` and `Rem` trap on division by zero
- `PartialQuot` traps on division by zero and on inexact division
- `Pow` traps on integer overflow
- `Log2` traps for zero
- `ArrayQuotient` and `ArrayRemainder` trap if the divisor array contains a zero element
- Freestanding macros work with metatype expressions, not in type position

These limitations are deliberate reflections of the current Swift feature set and the repository's current implementation stage.

## Development And Verification

The project uses [`swift-testing`](https://github.com/swiftlang/swift-testing) for tests.

Run the test suite with:

```bash
swift test
```

Collect code coverage with:

```bash
swift test --enable-code-coverage
```

## License

This project is licensed under the Apache License 2.0.
See [`LICENSE`](LICENSE) for details.

>    Copyright 2026 Henrique Sasaki Yuya
> 
>    Licensed under the Apache License, Version 2.0 (the "License");
>    you may not use this file except in compliance with the License.
>    You may obtain a copy of the License at
> 
>        http://www.apache.org/licenses/LICENSE-2.0
> 
>    Unless required by applicable law or agreed to in writing, software
>    distributed under the License is distributed on an "AS IS" BASIS,
>    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
