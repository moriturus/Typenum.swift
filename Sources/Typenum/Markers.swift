/// A marker protocol for types whose compile-time value is a power of two.
///
/// Conforming types declare at the type level that they represent a power-of-two
/// integer. Use ``Pow2Proof`` when a runtime-verified witness is needed instead
/// of a protocol conformance.
public protocol PowerOfTwo {}

/// A proof witness certifying that `T` is a power of two.
///
/// Construction succeeds only when `T.intValue` is a positive power of two;
/// otherwise a precondition failure is raised at runtime.
///
/// ```swift
/// let _ = Pow2Proof<U8>()   // ✓ succeeds (8 = 2³)
/// let _ = Pow2Proof<U7>()   // ✗ precondition failure
/// ```
///
/// This runtime check is intentional — see ADR-0003 for the rationale behind
/// proof-driven constraints versus marker-only approaches.
///
/// - SeeAlso: `docs/adr/ADR-0003-proof-driven-constraints.md`
public struct Pow2Proof<T: Integer>: Sendable {
    public init() {
        precondition(T.intValue > 0, "Pow2Proof: value must be positive, got \(T.intValue)")
        precondition(
            (T.intValue & (T.intValue - 1)) == 0,
            "Pow2Proof: \(T.intValue) is not a power of two"
        )
    }
}

extension B1: PowerOfTwo {}
