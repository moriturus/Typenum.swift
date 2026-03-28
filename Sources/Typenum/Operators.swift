/// Computes the type-level ordering of two integers.
///
/// Produces ``Less``, ``Equal``, or ``Greater`` depending on the
/// runtime values of `LHS` and `RHS`.
///
/// > Note: **Normalization gap.** `Comparison<LHS, RHS>` is a distinct nominal
/// > type for every operand pair and is not automatically unified with the
/// > canonical result types ``Less``, ``Equal``, or ``Greater``.
/// > For example, `Compare<U3, U2>` is *not* the same type as ``Greater``, even
/// > though `Compare<U3, U2>.ordering == TypeOrdering.greater`.
/// > Structural normalization is tracked as **SLICE-7** in `docs/architecture.md`.
public struct Comparison<LHS: Integer, RHS: Integer>: ComparisonResult, Sendable {
    public init() {}

    public static var ordering: TypeOrdering {
        if LHS.intValue < RHS.intValue {
            return .less
        }
        if LHS.intValue > RHS.intValue {
            return .greater
        }
        return .equal
    }
}

/// Computes the type-level sum of two integers.
///
/// Conforms to ``Unsigned`` when both operands are unsigned.
///
/// > Note: **Normalization gap.** `Addition<LHS, RHS>` is a distinct nominal
/// > type and is not automatically reduced to the canonical representation of
/// > the result value.  For example, `Sum<U3, U2>` is *not* the same type as
/// > `U5`, even though `Sum<U3, U2>.intValue == 5`.  Algebraic identities such
/// > as commutativity or associativity are therefore not expressible as type
/// > constraints.  Structural normalization is tracked as **SLICE-1 / SLICE-2**
/// > in `docs/architecture.md`.
public struct Addition<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        LHS.intValue + RHS.intValue
    }
}

/// Computes the type-level difference `LHS − RHS`.
///
/// > Note: **Normalization gap.** `Difference<LHS, RHS>` is a distinct nominal
/// > type and is not automatically reduced to the canonical representation of
/// > the result value.  For example, `Diff<U5, U3>` is *not* the same type as
/// > `U2`, even though `Diff<U5, U3>.intValue == 2`.  Invariants such as
/// > `Diff<A, A> == U0` are not expressible as type constraints.  Structural
/// > normalization is tracked as **SLICE-3 / SLICE-4** in `docs/architecture.md`.
public struct Difference<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        LHS.intValue - RHS.intValue
    }
}

/// Computes the type-level product of two integers.
///
/// Conforms to ``Unsigned`` when both operands are unsigned.
///
/// > Note: **Normalization gap.** `Product<LHS, RHS>` is a distinct nominal
/// > type and is not automatically reduced to the canonical representation of
/// > the result value.  For example, `Prod<U2, U3>` is *not* the same type as
/// > `U6`, even though `Prod<U2, U3>.intValue == 6`.  Algebraic identities such
/// > as commutativity, distributivity, or the zero-annihilation law
/// > `Prod<N, U0> == U0` are therefore not expressible as type constraints.
/// > Structural normalization is tracked as **SLICE-5 / SLICE-6** in
/// > `docs/architecture.md`.
public struct Product<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        LHS.intValue * RHS.intValue
    }
}

/// Computes the type-level truncating integer quotient `LHS / RHS`.
///
/// Traps at runtime if `RHS` is zero.
/// Conforms to ``Unsigned`` when both operands are unsigned.
public struct Quotient<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        precondition(RHS.intValue != 0, "Quotient: division by zero")
        return LHS.intValue / RHS.intValue
    }
}

/// Computes the type-level remainder `LHS % RHS`.
///
/// Traps at runtime if `RHS` is zero.
/// Conforms to ``Unsigned`` when both operands are unsigned.
public struct Remainder<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        precondition(RHS.intValue != 0, "Remainder: division by zero")
        return LHS.intValue % RHS.intValue
    }
}

/// Computes the type-level exponentiation `Base ^ Exponent`.
///
/// Traps at runtime on overflow. Conforms to ``Unsigned`` when `Base` is unsigned.
public struct Exponentiation<Base: Integer, Exponent: Unsigned>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        var result = 1
        for _ in 0..<Exponent.intValue {
            let (next, overflow) = result.multipliedReportingOverflow(by: Base.intValue)
            precondition(
                !overflow,
                "Exponentiation: overflow computing \(Base.intValue)^\(Exponent.intValue)"
            )
            result = next
        }
        return result
    }
}

extension Addition: Unsigned where LHS: Unsigned, RHS: Unsigned {}
extension Product: Unsigned where LHS: Unsigned, RHS: Unsigned {}
extension Quotient: Unsigned where LHS: Unsigned, RHS: Unsigned {}
extension Remainder: Unsigned where LHS: Unsigned, RHS: Unsigned {}
extension Exponentiation: Unsigned where Base: Unsigned {}

/// Computes the type-level bitwise AND of two unsigned integers.
public struct BitwiseAnd<LHS: Unsigned, RHS: Unsigned>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        LHS.intValue & RHS.intValue
    }
}

/// Computes the type-level bitwise OR of two unsigned integers.
public struct BitwiseOr<LHS: Unsigned, RHS: Unsigned>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        LHS.intValue | RHS.intValue
    }
}

/// Computes the type-level bitwise exclusive OR of two unsigned integers.
public struct BitwiseXor<LHS: Unsigned, RHS: Unsigned>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        LHS.intValue ^ RHS.intValue
    }
}

/// Computes the type-level left bit shift `Value << Amount`.
public struct ShiftLeft<Value: Unsigned, Amount: Unsigned>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        Value.intValue << Amount.intValue
    }
}

/// Computes the type-level right bit shift `Value >> Amount`.
public struct ShiftRight<Value: Unsigned, Amount: Unsigned>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        Value.intValue >> Amount.intValue
    }
}

/// A type-level predicate that yields ``B1`` when `LHS == RHS`, ``B0`` otherwise.
public struct EqualPredicate<LHS: Integer, RHS: Integer>: Bit, Sendable {
    public init() {}

    public static var bitValue: Int {
        LHS.intValue == RHS.intValue ? 1 : 0
    }
}

/// A type-level predicate that yields ``B1`` when `LHS != RHS`, ``B0`` otherwise.
public struct NotEqualPredicate<LHS: Integer, RHS: Integer>: Bit, Sendable {
    public init() {}

    public static var bitValue: Int {
        LHS.intValue == RHS.intValue ? 0 : 1
    }
}

/// A type-level predicate that yields ``B1`` when `LHS < RHS`, ``B0`` otherwise.
public struct LessPredicate<LHS: Integer, RHS: Integer>: Bit, Sendable {
    public init() {}

    public static var bitValue: Int {
        LHS.intValue < RHS.intValue ? 1 : 0
    }
}

/// A type-level predicate that yields ``B1`` when `LHS <= RHS`, ``B0`` otherwise.
public struct LessOrEqualPredicate<LHS: Integer, RHS: Integer>: Bit, Sendable {
    public init() {}

    public static var bitValue: Int {
        LHS.intValue <= RHS.intValue ? 1 : 0
    }
}

/// A type-level predicate that yields ``B1`` when `LHS > RHS`, ``B0`` otherwise.
public struct GreaterPredicate<LHS: Integer, RHS: Integer>: Bit, Sendable {
    public init() {}

    public static var bitValue: Int {
        LHS.intValue > RHS.intValue ? 1 : 0
    }
}

/// A type-level predicate that yields ``B1`` when `LHS >= RHS`, ``B0`` otherwise.
public struct GreaterOrEqualPredicate<LHS: Integer, RHS: Integer>: Bit, Sendable {
    public init() {}

    public static var bitValue: Int {
        LHS.intValue >= RHS.intValue ? 1 : 0
    }
}
