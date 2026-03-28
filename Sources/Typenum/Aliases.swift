// MARK: - Arithmetic aliases

/// Alias for ``Comparison``.
public typealias Compare<LHS: Integer, RHS: Integer> =
    Comparison<LHS, RHS>
/// Alias for ``Addition``.
public typealias Sum<LHS: Integer, RHS: Integer> =
    Addition<LHS, RHS>
/// Alias for ``Difference``.
public typealias Diff<LHS: Integer, RHS: Integer> =
    Difference<LHS, RHS>
/// Alias for ``Product``.
public typealias Prod<LHS: Integer, RHS: Integer> =
    Product<LHS, RHS>
/// Alias for ``Quotient``.
public typealias Quot<LHS: Integer, RHS: Integer> =
    Quotient<LHS, RHS>
/// Alias for ``Remainder``.
public typealias Rem<LHS: Integer, RHS: Integer> =
    Remainder<LHS, RHS>
/// Alias for ``Remainder`` (modulo).
public typealias Mod<LHS: Integer, RHS: Integer> = Rem<LHS, RHS>
/// Alias for ``Exponentiation``.
public typealias Pow<Base: Integer, Exponent: Unsigned> =
    Exponentiation<Base, Exponent>
/// Alias for ``Exponentiation``.
public typealias Exp<Base: Integer, Exponent: Unsigned> = Pow<Base, Exponent>

// MARK: - Bitwise aliases

/// Alias for ``BitwiseAnd``.
public typealias And<LHS: Unsigned, RHS: Unsigned> =
    BitwiseAnd<LHS, RHS>
/// Alias for ``BitwiseOr``.
public typealias Or<LHS: Unsigned, RHS: Unsigned> =
    BitwiseOr<LHS, RHS>
/// Alias for ``BitwiseXor``.
public typealias Xor<LHS: Unsigned, RHS: Unsigned> =
    BitwiseXor<LHS, RHS>
/// Alias for ``ShiftLeft``.
public typealias Shleft<Value: Unsigned, Amount: Unsigned> =
    ShiftLeft<Value, Amount>
/// Alias for ``ShiftRight``.
public typealias Shright<Value: Unsigned, Amount: Unsigned> =
    ShiftRight<Value, Amount>

// MARK: - Unary aliases

/// Alias for ``Negation``.
public typealias Negate<A: Integer> =
    Negation<A>
/// Alias for ``AbsoluteValue``.
public typealias AbsVal<A: Integer> =
    AbsoluteValue<A>
/// Alias for ``BitwiseNot``.
public typealias Not<A: Unsigned> =
    BitwiseNot<A>

// MARK: - Convenience compound aliases

/// Increment: `A + 1`.
public typealias Add1<A: Integer> = Sum<A, B1>
/// Decrement: `A − 1`.
public typealias Sub1<A: Integer> = Diff<A, B1>
/// Double: `A << 1`.
public typealias Double<A: Unsigned> = Shleft<A, B1>
/// Square: `A × A`.
public typealias Square<A: Integer> = Prod<A, A>
/// Cube: `A × A × A`.
public typealias Cube<A: Integer> = Prod<Prod<A, A>, A>

// MARK: - Advanced operation aliases

/// Alias for ``SquareRootOp``.
public typealias Sqrt<A: Unsigned> =
    SquareRootOp<A>
/// Alias for ``Logarithm2Op``.
public typealias Log2<A: Unsigned> =
    Logarithm2Op<A>
/// Alias for ``GreatestCommonDivisor``.
public typealias Gcf<A: Unsigned, B: Unsigned> =
    GreatestCommonDivisor<A, B>
/// Alias for ``MinOp``.
public typealias Minimum<A: Integer, B: Integer> =
    MinOp<A, B>
/// Alias for ``MaxOp``.
public typealias Maximum<A: Integer, B: Integer> =
    MaxOp<A, B>
/// Alias for ``PartialQuotient``.
public typealias PartialQuot<A: Integer, B: Integer> =
    PartialQuotient<A, B>
/// Alias for ``BitLengthOp``.
public typealias BitLen<A: Unsigned> =
    BitLengthOp<A>

// MARK: - Predicate aliases

/// Alias for ``IsEqualOp``.
public typealias Eq<A: Integer, B: Integer> = IsEqualOp<A, B>
/// Alias for ``IsLessOp``.
public typealias Le<A: Integer, B: Integer> = IsLessOp<A, B>
/// Alias for ``IsGreaterOp``.
public typealias Gr<A: Integer, B: Integer> = IsGreaterOp<A, B>
/// Alias for ``IsLessOrEqualOp``.
public typealias LeEq<A: Integer, B: Integer> = IsLessOrEqualOp<A, B>
/// Alias for ``IsNotEqualOp``.
public typealias NotEq<A: Integer, B: Integer> = IsNotEqualOp<A, B>
/// Alias for ``IsGreaterOrEqualOp``.
public typealias GrEq<A: Integer, B: Integer> = IsGreaterOrEqualOp<A, B>
