# Example: Dimensioned Units

## Motivation

One of the canonical applications of `typenum` in Rust is *dimensioned*, a library that attaches physical dimensions to numeric values at the type level.
The same idea is directly applicable in Swift using `Typenum.swift`: encode dimension exponents as type-level integers, then let the type-checker verify that operations such as multiplication and division produce the correctly dimensioned result.

This example shows how to build a minimal, zero-overhead dimension-tagged quantity type that catches unit errors at compile time.

## Overview

A physical dimension can be described by the exponents of the SI base dimensions:

| Dimension | Symbol |
|---|---|
| Length (metres) | L |
| Time (seconds) | T |
| Mass (kilograms) | M |

For example:
- **Velocity** has dimension L¹ T⁻¹ M⁰  
- **Acceleration** has dimension L¹ T⁻² M⁰  
- **Force** has dimension L¹ T⁻² M¹

By recording each exponent as a type-level integer, we can express the arithmetic rule that multiplying two quantities adds their exponents, and dividing subtracts them — and have the Swift compiler verify this automatically.

## Implementation

```swift
import Typenum

// A quantity whose value has physical dimensions described by
// exponents on Length (L), Time (T), and Mass (M).
//
// All three exponent type parameters are Integer (signed type-level integers).
struct Quantity<Value: BinaryFloatingPoint, L: Integer, T: Integer, M: Integer>: Sendable {
    let value: Value
}

// Multiply two quantities: exponents add.
func multiply<V: BinaryFloatingPoint, L1: Integer, T1: Integer, M1: Integer,
                                       L2: Integer, T2: Integer, M2: Integer>(
    _ lhs: Quantity<V, L1, T1, M1>,
    _ rhs: Quantity<V, L2, T2, M2>
) -> Quantity<V, Sum<L1, L2>, Sum<T1, T2>, Sum<M1, M2>> {
    Quantity(value: lhs.value * rhs.value)
}

// Divide two quantities: exponents subtract.
func divide<V: BinaryFloatingPoint, L1: Integer, T1: Integer, M1: Integer,
                                     L2: Integer, T2: Integer, M2: Integer>(
    _ lhs: Quantity<V, L1, T1, M1>,
    _ rhs: Quantity<V, L2, T2, M2>
) -> Quantity<V, Diff<L1, L2>, Diff<T1, T2>, Diff<M1, M2>> {
    Quantity(value: lhs.value / rhs.value)
}
```

### Concrete dimension aliases

```swift
// Dimensionless (all exponents zero)
typealias Scalar<V: BinaryFloatingPoint> = Quantity<V, Z0, Z0, Z0>

// Length: L¹ T⁰ M⁰
typealias Length<V: BinaryFloatingPoint> = Quantity<V, P1, Z0, Z0>

// Time: L⁰ T¹ M⁰
typealias Time<V: BinaryFloatingPoint> = Quantity<V, Z0, P1, Z0>

// Mass: L⁰ T⁰ M¹
typealias Mass<V: BinaryFloatingPoint> = Quantity<V, Z0, Z0, P1>

// Velocity: L¹ T⁻¹ M⁰
typealias Velocity<V: BinaryFloatingPoint> = Quantity<V, P1, N1, Z0>

// Acceleration: L¹ T⁻² M⁰
typealias Acceleration<V: BinaryFloatingPoint> = Quantity<V, P1, N2, Z0>

// Force: L¹ T⁻² M¹
typealias Force<V: BinaryFloatingPoint> = Quantity<V, P1, N2, P1>
```

### Usage

```swift
let distance = Length<Double>(value: 100.0)   // 100 m
let duration = Time<Double>(value: 9.58)      // 9.58 s
let mass     = Mass<Double>(value: 80.0)      // 80 kg

// velocity: Quantity<Double, P1, N1, Z0>  ✓ compiles
let velocity: Velocity<Double> = divide(distance, duration)

// force = mass * acceleration
let acceleration = Acceleration<Double>(value: 9.81)
let force: Force<Double> = multiply(mass, acceleration)

// Attempting to assign a velocity to a force variable:
//   let wrongForce: Force<Double> = velocity   // ✗ compile-time error
// The compiler rejects this because Quantity<…,P1,N1,Z0> ≠ Quantity<…,P1,N2,P1>.
```

## Type-Level Benefit

The dimension exponents are part of the type — not runtime metadata.
There is no overhead for carrying a dimension tag, and there is no way to silently assign a velocity to a force variable.
The Swift type-checker resolves `Sum<P1, N1>` to `Z0` at compile time, so the resulting `Quantity` type precisely describes the physical dimension of every intermediate result.

## Relationship to the Public API

| Typenum.swift construct | Role in this example |
|---|---|
| `P1 … N2` | Dimension exponent type-level integers |
| `Sum<L1, L2>` | Exponent addition under multiplication |
| `Diff<L1, L2>` | Exponent subtraction under division |
| `Z0` | Zero exponent (dimensionless axis) |
| `Integer` protocol | Constraint on exponent type parameters |
