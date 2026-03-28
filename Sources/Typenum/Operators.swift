/// Computes the type-level ordering of two integers.
///
/// Produces ``Less``, ``Equal``, or ``Greater`` depending on the
/// runtime values of `LHS` and `RHS`.
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
public struct Addition<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        LHS.intValue + RHS.intValue
    }
}

/// Computes the type-level difference `LHS − RHS`.
public struct Difference<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        LHS.intValue - RHS.intValue
    }
}

/// Computes the type-level product of two integers.
///
/// Conforms to ``Unsigned`` when both operands are unsigned.
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
