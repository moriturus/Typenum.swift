/// Yields ``B1`` when `LHS < RHS`. Alias for ``LessPredicate``.
public typealias IsLessOp<LHS: Integer, RHS: Integer> =
    LessPredicate<LHS, RHS>
/// Yields ``B1`` when `LHS == RHS`. Alias for ``EqualPredicate``.
public typealias IsEqualOp<LHS: Integer, RHS: Integer> =
    EqualPredicate<LHS, RHS>
/// Yields ``B1`` when `LHS > RHS`. Alias for ``GreaterPredicate``.
public typealias IsGreaterOp<LHS: Integer, RHS: Integer> =
    GreaterPredicate<LHS, RHS>
/// Yields ``B1`` when `LHS <= RHS`. Alias for ``LessOrEqualPredicate``.
public typealias IsLessOrEqualOp<LHS: Integer, RHS: Integer> =
    LessOrEqualPredicate<LHS, RHS>
/// Yields ``B1`` when `LHS != RHS`. Alias for ``NotEqualPredicate``.
public typealias IsNotEqualOp<LHS: Integer, RHS: Integer> =
    NotEqualPredicate<LHS, RHS>
/// Yields ``B1`` when `LHS >= RHS`. Alias for ``GreaterOrEqualPredicate``.
public typealias IsGreaterOrEqualOp<LHS: Integer, RHS: Integer> =
    GreaterOrEqualPredicate<LHS, RHS>
