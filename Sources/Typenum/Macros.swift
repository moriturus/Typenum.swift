/// Expands an integer literal into its unsigned type-level representation.
///
/// ```swift
/// let t = #typeUInt(5) // UInt<UInt<UOne, B0>, B1> i.e. U5
/// ```
@freestanding(expression)
public macro typeUInt(_ value: Int) -> Any.Type =
    #externalMacro(
        module: "TypenumMacros",
        type: "TypeUIntMacro"
    )

/// Expands a positive integer literal into its signed type-level representation.
///
/// ```swift
/// let t = #typePositive(3) // PInt<UInt<UOne, B1>> i.e. P3
/// ```
@freestanding(expression)
public macro typePositive(_ value: Int) -> Any.Type =
    #externalMacro(
        module: "TypenumMacros",
        type: "TypePositiveMacro"
    )

/// Expands a positive integer literal into a negative signed type-level representation.
///
/// ```swift
/// let t = #typeNegative(3) // NInt<UInt<UOne, B1>> i.e. N3
/// ```
@freestanding(expression)
public macro typeNegative(_ value: Int) -> Any.Type =
    #externalMacro(
        module: "TypenumMacros",
        type: "TypeNegativeMacro"
    )

/// Expands a variadic list of type-level integers into a ``TArr``/``ATerm`` chain.
///
/// ```swift
/// let t = #typeArray(U1.self, U2.self) // TArr<U2, TArr<U1, ATerm>>
/// ```
@freestanding(expression)
public macro typeArray(_ values: Any.Type...) -> Any.Type =
    #externalMacro(
        module: "TypenumMacros",
        type: "TypeArrayMacro"
    )

/// Asserts at compile time that two type-level expressions resolve to the same type.
///
/// The macro expands to ``assertTypeEqual(_:_:)`` which requires both
/// arguments to share the same generic type parameter `T`.  If the two
/// metatypes refer to different concrete types, the compiler rejects the
/// call — no runtime check is involved.
@freestanding(expression)
public macro typenumAssertEqual(_ lhs: Any.Type, _ rhs: Any.Type) =
    #externalMacro(
        module: "TypenumMacros",
        type: "TypenumAssertEqualMacro"
    )
