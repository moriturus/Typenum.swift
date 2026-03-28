/// The three ordering outcomes produced by type-level comparisons.
public enum TypeOrdering: Sendable {
    case less
    case equal
    case greater
}

/// The common runtime bridge for type-level integers.
public protocol Integer {
    /// The runtime value represented by this type.
    static var intValue: Int { get }

    /// Creates a singleton witness value for the type.
    init()
}

extension Integer {
    /// Returns the runtime integer value of this type-level integer.
    @inlinable
    public static func toInt() -> Int {
        intValue
    }

    /// Converts the type-level integer to the given fixed-width integer type,
    /// returning `nil` if the value is not exactly representable.
    @inlinable
    public static func to<T: FixedWidthInteger>(_ type: T.Type = T.self) -> T? {
        T(exactly: intValue)
    }
}

/// A non-negative type-level integer.
public protocol Unsigned: Integer {}

/// A signed type-level integer.
public protocol Signed: Integer {}

/// A marker protocol for non-zero values.
public protocol NonZero {}

/// A marker protocol for zero values.
public protocol Zero {}

/// A type-level bit, representing either `0` or `1`.
///
/// Conforming types also satisfy ``Unsigned`` since a single bit
/// is inherently non-negative.
public protocol Bit: Unsigned {
    /// The integer value of this bit (`0` or `1`).
    static var bitValue: Int { get }
    /// The Boolean interpretation of this bit (`false` for 0, `true` for 1).
    static var boolValue: Bool { get }
}

extension Bit {
    @inlinable
    public static var intValue: Int {
        bitValue
    }

    @inlinable
    public static var boolValue: Bool {
        bitValue == 1
    }
}

/// A type-level comparison result encoding one of three orderings.
public protocol ComparisonResult {
    /// The ordering this type represents.
    static var ordering: TypeOrdering { get }
    /// Creates a singleton witness value for this comparison result.
    init()
}

/// The comparison result indicating that the left operand is less than the right.
public struct Less: ComparisonResult, Sendable {
    public init() {}
    public static let ordering: TypeOrdering = .less
}

/// The comparison result indicating that both operands are equal.
public struct Equal: ComparisonResult, Sendable {
    public init() {}
    public static let ordering: TypeOrdering = .equal
}

/// The comparison result indicating that the left operand is greater than the right.
public struct Greater: ComparisonResult, Sendable {
    public init() {}
    public static let ordering: TypeOrdering = .greater
}

/// Asserts that two metatypes are identical at compile time.
@inlinable
public func assertTypeEqual<T>(_ lhs: T.Type, _ rhs: T.Type) {
    _ = lhs
    _ = rhs
}

/// Asserts that two metatype values are identical.
@inlinable
public func assertMetatypeEqual(_ lhs: Any.Type, _ rhs: Any.Type) {
    precondition(String(reflecting: lhs) == String(reflecting: rhs))
}
