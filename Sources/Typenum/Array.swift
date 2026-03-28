/// A type-level array whose length is known at compile time.
public protocol TypeArray {
    /// The type-level integer representing this array's length.
    associatedtype Length: Integer
    /// The runtime length of this array.
    static var length: Int { get }
    /// Creates a singleton witness value for this array type.
    init()
}

/// A ``TypeArray`` whose elements are type-level integers.
public protocol IntegerArray: TypeArray {
    /// The runtime integer values of all elements in order.
    static var intValues: [Int] { get }
}

/// The empty type-level integer array, analogous to ``UTerm`` for numbers.
public struct ATerm: IntegerArray, Sendable {
    public init() {}
    public typealias Length = U0
    public static let length = 0
    public static let intValues: [Int] = []
}

/// A type-level integer array node holding `Value` appended to `Rest`.
public struct TArr<Value: Integer, Rest: IntegerArray>: IntegerArray, Sendable {
    public init() {}

    public typealias Length = Addition<Rest.Length, B1>

    public static var length: Int {
        Rest.length + 1
    }

    public static var intValues: [Int] {
        Rest.intValues + [Value.intValue]
    }
}

/// Extracts the compile-time length of a type-level array.
public typealias LengthOp<Arr: TypeArray> = Arr.Length
/// Sums all elements of a type-level integer array.
public typealias FoldAddOp<Arr: IntegerArray & ArrayFoldSum> = Arr.FoldedSum
/// Multiplies all elements of a type-level integer array.
public typealias FoldMulOp<Arr: IntegerArray & ArrayFoldProd> = Arr.FoldedProduct

/// Provides a type-level sum over the elements of an integer array.
public protocol ArrayFoldSum {
    /// The type-level integer representing the sum of all elements.
    associatedtype FoldedSum: Integer
}

/// Provides a type-level product over the elements of an integer array.
public protocol ArrayFoldProd {
    /// The type-level integer representing the product of all elements.
    associatedtype FoldedProduct: Integer
}

extension ATerm: ArrayFoldSum {
    public typealias FoldedSum = U0
}

extension ATerm: ArrayFoldProd {
    public typealias FoldedProduct = U1
}

extension TArr: ArrayFoldSum where Rest: ArrayFoldSum {
    public typealias FoldedSum = Addition<Value, Rest.FoldedSum>
}

extension TArr: ArrayFoldProd where Rest: ArrayFoldProd {
    public typealias FoldedProduct = Product<Value, Rest.FoldedProduct>
}

/// Element-wise sum of two equal-length type-level integer arrays.
public struct ArrayAddition<LHS: IntegerArray, RHS: IntegerArray>: IntegerArray, Sendable
where LHS.Length == RHS.Length {
    public init() {}
    public typealias Length = LHS.Length
    public static var length: Int { LHS.length }
    public static var intValues: [Int] { zip(LHS.intValues, RHS.intValues).map(+) }
}

/// Element-wise difference of two equal-length type-level integer arrays.
public struct ArrayDifference<LHS: IntegerArray, RHS: IntegerArray>: IntegerArray, Sendable
where LHS.Length == RHS.Length {
    public init() {}
    public typealias Length = LHS.Length
    public static var length: Int { LHS.length }
    public static var intValues: [Int] { zip(LHS.intValues, RHS.intValues).map(-) }
}

/// Element-wise product of two equal-length type-level integer arrays.
public struct ArrayProduct<LHS: IntegerArray, RHS: IntegerArray>: IntegerArray, Sendable
where LHS.Length == RHS.Length {
    public init() {}
    public typealias Length = LHS.Length
    public static var length: Int { LHS.length }
    public static var intValues: [Int] { zip(LHS.intValues, RHS.intValues).map(*) }
}

/// Element-wise truncating quotient of two equal-length type-level integer arrays.
///
/// Traps at runtime if any element of `RHS` is zero.
public struct ArrayQuotient<LHS: IntegerArray, RHS: IntegerArray>: IntegerArray, Sendable
where LHS.Length == RHS.Length {
    public init() {}
    public typealias Length = LHS.Length
    public static var length: Int { LHS.length }
    public static var intValues: [Int] {
        precondition(
            !RHS.intValues.contains(0),
            "ArrayQuotient: divisor array contains a zero element"
        )
        return zip(LHS.intValues, RHS.intValues).map(/)
    }
}

/// Element-wise remainder of two equal-length type-level integer arrays.
///
/// Traps at runtime if any element of `RHS` is zero.
public struct ArrayRemainder<LHS: IntegerArray, RHS: IntegerArray>: IntegerArray, Sendable
where LHS.Length == RHS.Length {
    public init() {}
    public typealias Length = LHS.Length
    public static var length: Int { LHS.length }
    public static var intValues: [Int] {
        precondition(
            !RHS.intValues.contains(0),
            "ArrayRemainder: divisor array contains a zero element"
        )
        return zip(LHS.intValues, RHS.intValues).map(%)
    }
}

/// Negates every element of a type-level integer array.
public struct ArrayNegation<Arr: IntegerArray>: IntegerArray, Sendable {
    public init() {}
    public typealias Length = Arr.Length
    public static var length: Int { Arr.length }
    public static var intValues: [Int] { Arr.intValues.map(-) }
}

/// Multiplies every element of a type-level integer array by a scalar.
public struct ArrayScalarProduct<Scalar: Integer, Arr: IntegerArray>: IntegerArray, Sendable {
    public init() {}
    public typealias Length = Arr.Length
    public static var length: Int { Arr.length }
    public static var intValues: [Int] { Arr.intValues.map { $0 * Scalar.intValue } }
}
