/// The type-level bit `0`.
public struct B0: Bit, Zero, Sendable {
    public init() {}
    public static let bitValue = 0
}

/// The type-level bit `1`.
public struct B1: Bit, NonZero, Sendable {
    public init() {}
    public static let bitValue = 1
}

/// Boolean alias for ``B0``, representing `false` at the type level.
public typealias False = B0
/// Boolean alias for ``B1``, representing `true` at the type level.
public typealias True = B1
