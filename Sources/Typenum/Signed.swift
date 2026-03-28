/// The type-level integer `0`.
public struct Z0: Signed, Zero, Sendable {
    public init() {}
    public static let intValue = 0
}

/// A strictly positive type-level integer.
public struct PInt<Magnitude: Unsigned & NonZero>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        Magnitude.intValue
    }
}

/// A strictly negative type-level integer.
public struct NInt<Magnitude: Unsigned & NonZero>: Signed, Sendable {
    public init() {}

    public static var intValue: Int {
        -Magnitude.intValue
    }
}
