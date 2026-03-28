# Example: Generic Array Constraints

## Motivation

A second canonical `typenum` use case in Rust is *generic arrays* — fixed-size arrays whose length is a type parameter rather than a runtime value.
`Typenum.swift` exposes the same capability: the `TArr` / `ATerm` type-level array infrastructure already carries a compile-time `Length` associated type, so you can build APIs that accept or return fixed-length collections and have the Swift compiler verify size compatibility without any runtime bounds checking.

## Overview

This example demonstrates two related patterns:

1. **Compile-time fixed-size buffers** — a `FixedBuffer` struct whose capacity is a type parameter, so that filling or slicing the buffer can only be expressed when the sizes match.
2. **Statically-sized vector operations** — reusing the `TArr`-based type arrays to perform element-wise arithmetic that is rejected by the compiler if the two operands have different lengths.

## Pattern 1 — Fixed-Size Buffer

```swift
import Typenum

// A contiguous buffer whose Capacity is encoded as a type-level unsigned integer.
// The compiler knows the capacity at the type level and can enforce
// that two buffers are the same size before certain operations are allowed.
struct FixedBuffer<Element, Capacity: Unsigned>: Sendable {
    private var storage: [Element]

    // Only allow initialization when exactly `Capacity` elements are provided.
    init?(_ elements: [Element]) {
        guard elements.count == Capacity.intValue else { return nil }
        storage = elements
    }

    // The capacity is readable without accessing any instance storage.
    static var capacity: Int { Capacity.intValue }

    // Returns a new buffer whose capacity is the sum of both capacities.
    // The return type Sum<C1, C2> is resolved by the Swift type-checker;
    // no runtime addition is needed.
    func concatenate<OtherCapacity: Unsigned>(
        _ other: FixedBuffer<Element, OtherCapacity>
    ) -> FixedBuffer<Element, Sum<Capacity, OtherCapacity>>? {
        FixedBuffer<Element, Sum<Capacity, OtherCapacity>>(storage + other.storage)
    }
}
```

### Usage

```swift
// Build two buffers whose sizes are known statically.
let a = FixedBuffer<Int, U4>([1, 2, 3, 4])!           // capacity = 4
let b = FixedBuffer<Int, U4>([5, 6, 7, 8])!           // capacity = 4

// The concatenated buffer has compile-time capacity Sum<U4, U4> == U8.
let c: FixedBuffer<Int, U8>? = a.concatenate(b)        // capacity = 8

// An incorrectly-sized initialiser returns nil at runtime, but the type
// still prevents you from passing a U4-buffer where a U8-buffer is expected.
// let wrong: FixedBuffer<Int, U8> = a  // ✗ type mismatch — won't compile
```

## Pattern 2 — Statically-Sized Vector Arithmetic

`TArr<Value, Rest>` already tracks its length as `LengthOp<Arr>`, and `ArrayAddition` / `ArrayDifference` / `ArrayProduct` enforce equal-length constraints via `where LHS.Length == RHS.Length`.
You can alias concrete array types to named vector dimensions and let the compiler reject shape mismatches without writing any guard code.

```swift
import Typenum

// A 3-element type-level integer vector (e.g. an RGB colour).
typealias Vec3<A: Integer, B: Integer, C: Integer> =
    TArr<A, TArr<B, TArr<C, ATerm>>>

// A 4-element type-level integer vector (e.g. RGBA).
typealias Vec4<A: Integer, B: Integer, C: Integer, D: Integer> =
    TArr<A, TArr<B, TArr<C, TArr<D, ATerm>>>>
```

### Usage

```swift
// Two RGB colours represented as type-level integer arrays.
typealias Red   = Vec3<U255, U0,   U0>
typealias Green = Vec3<U0,   U255, U0>

// Element-wise addition — the result length is checked at compile time.
let mix = ArrayAddition<Red, Green>.intValues      // [255, 255, 0]

// Scalar multiply every channel by 2.
let doubled = ArrayScalarProduct<U2, Red>.intValues // [510, 0, 0]

// Attempting to add a Vec3 and a Vec4 is a compile-time error:
//   typealias Bad = ArrayAddition<Red, Vec4<U1, U2, U3, U4>>
// The compiler rejects this because Red.Length (U3) ≠ Vec4.Length (U4).
```

### Size-Guarded Matrix Multiplication Sketch

The same length-as-type pattern scales to a matrix type where row and column counts are type parameters.
A multiplication overload can express that you can only multiply an `M × N` matrix by an `N × P` matrix:

```swift
struct Matrix<Rows: Unsigned, Cols: Unsigned>: Sendable {
    let values: [[Double]]

    // rows × cols → rows × otherCols
    // The shared dimension N must match: Cols == OtherRows.
    func matMul<OtherRows: Unsigned, OtherCols: Unsigned>(
        _ other: Matrix<OtherRows, OtherCols>
    ) -> Matrix<Rows, OtherCols> where Cols == OtherRows {
        // naive implementation for illustration
        var result = Array(
            repeating: Array(repeating: 0.0, count: OtherCols.intValue),
            count: Rows.intValue
        )
        for i in 0..<Rows.intValue {
            for j in 0..<OtherCols.intValue {
                for k in 0..<Cols.intValue {
                    result[i][j] += values[i][k] * other.values[k][j]
                }
            }
        }
        return Matrix<Rows, OtherCols>(values: result)
    }
}
```

Calling `a.matMul(b)` where `a` is `Matrix<U3, U4>` and `b` is `Matrix<U5, U2>` is a compile-time error because `U4 != U5`.
No runtime guard or assertion is required.

## Type-Level Benefit

| Typenum.swift construct | Role in this example |
|---|---|
| `U0 … U1024` | Compile-time capacity / dimension tags |
| `Sum<C1, C2>` | Buffer length after concatenation |
| `TArr` / `ATerm` | Typed element sequences with static length |
| `ArrayAddition` / `ArrayProduct` / … | Equal-length-enforced element-wise ops |
| `ArrayScalarProduct` | Uniform scaling of all elements |
| `LengthOp<Arr>` | Extract length as an `Integer` type |
| `Unsigned` protocol | Constraint on capacity / dimension parameters |
