/// The terminating type for recursive unsigned integers.
public struct UTerm: Unsigned, Zero, Sendable {
    public init() {}
    public static let intValue = 0
}

/// The type-level unsigned integer `1`.
///
/// `UOne` is the base case for non-zero unsigned integers. All larger
/// values are built recursively using ``UInt``, whose most-significant
/// part must itself be non-zero — a constraint that ``UTerm`` cannot
/// satisfy.  Introducing `UOne` as a distinct type eliminates the
/// denormalized representation `UInt<UTerm, B0>` (which would equal 0
/// yet incorrectly carry ``NonZero`` conformance).
public struct UOne: Unsigned, NonZero, Sendable {
    public init() {}
    public static let intValue = 1
}

/// A recursive binary unsigned integer representing values ≥ 2.
///
/// The most-significant part is constrained to ``Unsigned`` & ``NonZero``,
/// which is satisfied by ``UOne`` or another ``UInt``.  This guarantees
/// that every ``UInt`` instance represents a positive value, so ``NonZero``
/// conformance is unconditional and sound.
public struct UInt<MostSignificant: Unsigned & NonZero, LeastSignificant: Bit>: Unsigned, NonZero, Sendable {
    public init() {}

    public static var intValue: Int {
        (MostSignificant.intValue << 1) | LeastSignificant.bitValue
    }
}
