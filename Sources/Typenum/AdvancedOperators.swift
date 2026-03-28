/// Computes the type-level arithmetic negation of an integer.
public struct Negation<Value: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        -Value.intValue
    }
}

/// Computes the type-level absolute value of an integer.
public struct AbsoluteValue<Value: Integer>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        abs(Value.intValue)
    }
}

/// Computes the type-level bitwise NOT of an unsigned integer.
///
/// The inversion is applied within the minimal bit width that can
/// represent `Value`, so `BitwiseNot<U0>` evaluates to `0`.
public struct BitwiseNot<Value: Unsigned>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        guard Value.intValue > 0 else { return 0 }
        let width = Int.bitWidth - Value.intValue.leadingZeroBitCount
        let mask = (1 << width) - 1
        return Value.intValue ^ mask
    }
}

/// Returns the smaller of two type-level integers.
public struct MinOp<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        min(LHS.intValue, RHS.intValue)
    }
}

/// Returns the larger of two type-level integers.
public struct MaxOp<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        max(LHS.intValue, RHS.intValue)
    }
}

/// Computes the type-level quotient `LHS / RHS`, trapping if the division
/// is not exact or `RHS` is zero.
public struct PartialQuotient<LHS: Integer, RHS: Integer>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        precondition(RHS.intValue != 0, "PartialQuotient: divisor cannot be zero")
        precondition(LHS.intValue.isMultiple(of: RHS.intValue), "PartialQuotient: \(LHS.intValue) is not evenly divisible by \(RHS.intValue)")
        return LHS.intValue / RHS.intValue
    }
}

/// Computes the integer square root of a type-level unsigned integer
/// using Newton's method (integer variant).
///
/// Returns the largest integer `r` such that `r * r <= Value`.
/// Returns `0` when `Value` is zero.
public struct SquareRootOp<Value: Unsigned>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        let n = Value.intValue
        guard n > 0 else { return 0 }
        var x = n
        var y = (x + 1) / 2
        while y < x {
            x = y
            y = (x + n / x) / 2
        }
        return x
    }
}

/// Computes the type-level floor of the base-2 logarithm.
///
/// Traps at runtime if `Value` is zero.
public struct Logarithm2Op<Value: Unsigned>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        precondition(Value.intValue > 0, "Logarithm2Op: value must be positive, got \(Value.intValue)")
        return Int.bitWidth - Value.intValue.leadingZeroBitCount - 1
    }
}

/// Computes the greatest common divisor of two unsigned type-level integers
/// using the Euclidean algorithm.
public struct GreatestCommonDivisor<LHS: Unsigned, RHS: Unsigned>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        var lhs = LHS.intValue
        var rhs = RHS.intValue
        while rhs != 0 {
            (lhs, rhs) = (rhs, lhs % rhs)
        }
        return abs(lhs)
    }
}

/// Computes the number of bits required to represent an unsigned type-level
/// integer, returning `0` for ``UTerm``.
public struct BitLengthOp<Value: Unsigned>: Unsigned, Sendable {
    public init() {}

    public static var intValue: Int {
        Value.intValue == 0 ? 0 : (Int.bitWidth - Value.intValue.leadingZeroBitCount)
    }
}
