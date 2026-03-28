import Testing
@testable import Typenum

private let unsignedOperatorExpectations: [IntegerExpectation] = [
    .init(label: "Sum<U3, U4>", actual: { Sum<U3, U4>.intValue }, expected: 7),
    .init(label: "Prod<U3, U4>", actual: { Prod<U3, U4>.intValue }, expected: 12),
    .init(label: "Diff<U9, U4>", actual: { Diff<U9, U4>.intValue }, expected: 5),
    .init(label: "Quot<U9, U4>", actual: { Quot<U9, U4>.intValue }, expected: 2),
    .init(label: "Rem<U9, U4>", actual: { Rem<U9, U4>.intValue }, expected: 1),
    .init(label: "Pow<U2, U4>", actual: { Pow<U2, U4>.intValue }, expected: 16),
    .init(label: "Pow<U5, U0>", actual: { Pow<U5, U0>.intValue }, expected: 1),
    .init(label: "And<U6, U3>", actual: { And<U6, U3>.intValue }, expected: 2),
    .init(label: "Or<U6, U3>", actual: { Or<U6, U3>.intValue }, expected: 7),
    .init(label: "Xor<U6, U3>", actual: { Xor<U6, U3>.intValue }, expected: 5),
    .init(label: "Shleft<U3, U0>", actual: { Shleft<U3, U0>.intValue }, expected: 3),
    .init(label: "Shleft<U3, U2>", actual: { Shleft<U3, U2>.intValue }, expected: 12),
    .init(label: "Shright<U12, U0>", actual: { Shright<U12, U0>.intValue }, expected: 12),
    .init(label: "Shright<U12, U2>", actual: { Shright<U12, U2>.intValue }, expected: 3),
]

private let signedOperatorExpectations: [IntegerExpectation] = [
    .init(label: "Sum<P3, P4>", actual: { Sum<P3, P4>.intValue }, expected: 7),
    .init(label: "Sum<P3, N4>", actual: { Sum<P3, N4>.intValue }, expected: -1),
    .init(label: "Diff<N3, P2>", actual: { Diff<N3, P2>.intValue }, expected: -5),
    .init(label: "Prod<N3, P2>", actual: { Prod<N3, P2>.intValue }, expected: -6),
    .init(label: "Quot<N3, P2>", actual: { Quot<N3, P2>.intValue }, expected: -1),
    .init(label: "Rem<N3, P2>", actual: { Rem<N3, P2>.intValue }, expected: -1),
    .init(label: "Exp<N2, U3>", actual: { Exp<N2, U3>.intValue }, expected: -8),
    .init(label: "Exp<N2, U2>", actual: { Exp<N2, U2>.intValue }, expected: 4),
    .init(label: "Sum<Z0, N4>", actual: { Sum<Z0, N4>.intValue }, expected: -4),
    .init(label: "Prod<Z0, P4>", actual: { Prod<Z0, P4>.intValue }, expected: 0),
]

private let comparisonExpectations: [ComparisonExpectation] = [
    .init(label: "Compare<U2, U3>", actual: { Compare<U2, U3>.ordering }, expected: TypeOrdering.less),
    .init(label: "Compare<U3, U3>", actual: { Compare<U3, U3>.ordering }, expected: TypeOrdering.equal),
    .init(label: "Compare<P3, N2>", actual: { Compare<P3, N2>.ordering }, expected: TypeOrdering.greater),
    .init(label: "Compare<N4, N2>", actual: { Compare<N4, N2>.ordering }, expected: TypeOrdering.less),
]

private let predicateExpectations: [BitExpectation] = [
    .init(label: "Eq<U2, U2>", actualBit: { Eq<U2, U2>.bitValue }, actualBool: { Eq<U2, U2>.boolValue }, actualInt: { Eq<U2, U2>.intValue }, expectedBit: 1, expectedBool: true),
    .init(label: "Eq<U2, U3>", actualBit: { Eq<U2, U3>.bitValue }, actualBool: { Eq<U2, U3>.boolValue }, actualInt: { Eq<U2, U3>.intValue }, expectedBit: 0, expectedBool: false),
    .init(label: "NotEq<U2, U3>", actualBit: { NotEq<U2, U3>.bitValue }, actualBool: { NotEq<U2, U3>.boolValue }, actualInt: { NotEq<U2, U3>.intValue }, expectedBit: 1, expectedBool: true),
    .init(label: "NotEq<U2, U2>", actualBit: { NotEq<U2, U2>.bitValue }, actualBool: { NotEq<U2, U2>.boolValue }, actualInt: { NotEq<U2, U2>.intValue }, expectedBit: 0, expectedBool: false),
    .init(label: "Le<U2, U3>", actualBit: { Le<U2, U3>.bitValue }, actualBool: { Le<U2, U3>.boolValue }, actualInt: { Le<U2, U3>.intValue }, expectedBit: 1, expectedBool: true),
    .init(label: "Le<U3, U2>", actualBit: { Le<U3, U2>.bitValue }, actualBool: { Le<U3, U2>.boolValue }, actualInt: { Le<U3, U2>.intValue }, expectedBit: 0, expectedBool: false),
    .init(label: "LeEq<U2, U2>", actualBit: { LeEq<U2, U2>.bitValue }, actualBool: { LeEq<U2, U2>.boolValue }, actualInt: { LeEq<U2, U2>.intValue }, expectedBit: 1, expectedBool: true),
    .init(label: "LeEq<U3, U2>", actualBit: { LeEq<U3, U2>.bitValue }, actualBool: { LeEq<U3, U2>.boolValue }, actualInt: { LeEq<U3, U2>.intValue }, expectedBit: 0, expectedBool: false),
    .init(label: "Gr<U3, U2>", actualBit: { Gr<U3, U2>.bitValue }, actualBool: { Gr<U3, U2>.boolValue }, actualInt: { Gr<U3, U2>.intValue }, expectedBit: 1, expectedBool: true),
    .init(label: "Gr<U2, U3>", actualBit: { Gr<U2, U3>.bitValue }, actualBool: { Gr<U2, U3>.boolValue }, actualInt: { Gr<U2, U3>.intValue }, expectedBit: 0, expectedBool: false),
    .init(label: "GrEq<U3, U3>", actualBit: { GrEq<U3, U3>.bitValue }, actualBool: { GrEq<U3, U3>.boolValue }, actualInt: { GrEq<U3, U3>.intValue }, expectedBit: 1, expectedBool: true),
    .init(label: "GrEq<U2, U3>", actualBit: { GrEq<U2, U3>.bitValue }, actualBool: { GrEq<U2, U3>.boolValue }, actualInt: { GrEq<U2, U3>.intValue }, expectedBit: 0, expectedBool: false),
]

@Suite(.tags(.operators))
struct OperatorTests {
    @Test("Operator singleton initializers are reachable")
    func operatorInitializers() {
        let _: Comparison<U2, U3> = .init()
        let _: Addition<U1, U2> = .init()
        let _: Difference<U5, U3> = .init()
        let _: Product<U3, U4> = .init()
        let _: Quotient<U8, U2> = .init()
        let _: Remainder<U9, U4> = .init()
        let _: Exponentiation<U2, U4> = .init()
        let _: BitwiseAnd<U6, U3> = .init()
        let _: BitwiseOr<U6, U3> = .init()
        let _: BitwiseXor<U6, U3> = .init()
        let _: ShiftLeft<U3, U2> = .init()
        let _: ShiftRight<U12, U2> = .init()
        let _: EqualPredicate<U1, U1> = .init()
        let _: NotEqualPredicate<U1, U2> = .init()
        let _: LessPredicate<U1, U2> = .init()
        let _: LessOrEqualPredicate<U1, U1> = .init()
        let _: GreaterPredicate<U2, U1> = .init()
        let _: GreaterOrEqualPredicate<U2, U2> = .init()
    }

    @Test("Unsigned operations preserve unsigned conformance")
    func unsignedConformance() {
        acceptUnsigned(Sum<U3, U4>.self)
        acceptUnsigned(Prod<U3, U4>.self)
        acceptUnsigned(Quot<U8, U2>.self)
        acceptUnsigned(Rem<U9, U4>.self)
        acceptUnsigned(Pow<U2, U4>.self)
        acceptUnsigned(Shleft<U3, U1>.self)
        acceptUnsigned(Shright<U8, U1>.self)
    }

    @Test("Arithmetic operators evaluate correctly for unsigned integers", arguments: unsignedOperatorExpectations)
    func unsignedOperators(_ expectation: IntegerExpectation) {
        expectIntegerValue(expectation)
    }

    @Test("Arithmetic operators evaluate correctly for signed integers", arguments: signedOperatorExpectations)
    func signedOperators(_ expectation: IntegerExpectation) {
        expectIntegerValue(expectation)
    }
}

@Suite(.tags(.operators))
struct ComparisonTests {
    @Test("Comparison reports less, equal, and greater correctly", arguments: comparisonExpectations)
    func comparisons(_ expectation: ComparisonExpectation) {
        expectOrdering(expectation)
    }
}

@Suite(.tags(.operators, .edgeCase))
struct PredicateTests {
    @Test("Predicate aliases cover equality and ordering relations", arguments: predicateExpectations)
    func predicateAliases(_ expectation: BitExpectation) {
        expectBitValue(expectation)
    }
}
