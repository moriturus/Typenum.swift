import Testing
@testable import Typenum

private typealias EmptyArray = ATerm
private typealias PairArray = TArr<U1, TArr<U2, ATerm>>
private typealias PairArrayAlt = TArr<U3, TArr<U4, ATerm>>
private typealias SignedPairArray = TArr<P1, TArr<N2, ATerm>>

private let arrayRuntimeExpectations: [ArrayExpectation] = [
    .init(label: "ATerm", actualLength: { ATerm.length }, actualValues: { ATerm.intValues }, expectedLength: 0, expectedValues: []),
    .init(label: "PairArray", actualLength: { PairArray.length }, actualValues: { PairArray.intValues }, expectedLength: 2, expectedValues: [2, 1]),
    .init(
        label: "SignedPairArray",
        actualLength: { SignedPairArray.length },
        actualValues: { SignedPairArray.intValues },
        expectedLength: 2,
        expectedValues: [-2, 1]
    ),
]

private let arrayArithmeticExpectations: [ArrayExpectation] = [
    .init(
        label: "ArrayAddition<PairArray, PairArrayAlt>",
        actualLength: { ArrayAddition<PairArray, PairArrayAlt>.length },
        actualValues: { ArrayAddition<PairArray, PairArrayAlt>.intValues },
        expectedLength: 2,
        expectedValues: [6, 4]
    ),
    .init(
        label: "ArrayDifference<PairArrayAlt, PairArray>",
        actualLength: { ArrayDifference<PairArrayAlt, PairArray>.length },
        actualValues: { ArrayDifference<PairArrayAlt, PairArray>.intValues },
        expectedLength: 2,
        expectedValues: [2, 2]
    ),
    .init(
        label: "ArrayProduct<PairArray, PairArrayAlt>",
        actualLength: { ArrayProduct<PairArray, PairArrayAlt>.length },
        actualValues: { ArrayProduct<PairArray, PairArrayAlt>.intValues },
        expectedLength: 2,
        expectedValues: [8, 3]
    ),
    .init(
        label: "ArrayQuotient<PairArrayAlt, PairArray>",
        actualLength: { ArrayQuotient<PairArrayAlt, PairArray>.length },
        actualValues: { ArrayQuotient<PairArrayAlt, PairArray>.intValues },
        expectedLength: 2,
        expectedValues: [2, 3]
    ),
    .init(
        label: "ArrayRemainder<PairArrayAlt, PairArray>",
        actualLength: { ArrayRemainder<PairArrayAlt, PairArray>.length },
        actualValues: { ArrayRemainder<PairArrayAlt, PairArray>.intValues },
        expectedLength: 2,
        expectedValues: [0, 0]
    ),
    .init(
        label: "ArrayAddition<ATerm, ATerm>",
        actualLength: { ArrayAddition<ATerm, ATerm>.length },
        actualValues: { ArrayAddition<ATerm, ATerm>.intValues },
        expectedLength: 0,
        expectedValues: []
    ),
]

private let arrayUnaryExpectations: [ArrayExpectation] = [
    .init(
        label: "ArrayNegation<SignedPairArray>",
        actualLength: { ArrayNegation<SignedPairArray>.length },
        actualValues: { ArrayNegation<SignedPairArray>.intValues },
        expectedLength: 2,
        expectedValues: [2, -1]
    ),
    .init(
        label: "ArrayScalarProduct<P3, PairArray>",
        actualLength: { ArrayScalarProduct<P3, PairArray>.length },
        actualValues: { ArrayScalarProduct<P3, PairArray>.intValues },
        expectedLength: 2,
        expectedValues: [6, 3]
    ),
    .init(
        label: "ArrayScalarProduct<N2, PairArray>",
        actualLength: { ArrayScalarProduct<N2, PairArray>.length },
        actualValues: { ArrayScalarProduct<N2, PairArray>.intValues },
        expectedLength: 2,
        expectedValues: [-4, -2]
    ),
]

@Suite(.tags(.arrays))
struct ArrayTests {
    @Test("Array operator singleton initializers are reachable")
    func arrayInitializers() {
        let _: ArrayAddition<PairArray, PairArrayAlt> = .init()
        let _: ArrayDifference<PairArrayAlt, PairArray> = .init()
        let _: ArrayProduct<PairArray, PairArrayAlt> = .init()
        let _: ArrayQuotient<PairArrayAlt, PairArray> = .init()
        let _: ArrayRemainder<PairArrayAlt, PairArray> = .init()
        let _: ArrayNegation<SignedPairArray> = .init()
        let _: ArrayScalarProduct<P3, PairArray> = .init()
    }

    @Test("ATerm and TArr expose runtime shape", arguments: arrayRuntimeExpectations)
    func runtimeShape(_ expectation: ArrayExpectation) {
        let _: ATerm = .init()
        let _: PairArray = .init()
        expectArrayValue(expectation)
    }

    @Test("Array fold aliases preserve type-level length and totals")
    func folds() {
        #expect(LengthOp<ATerm>.intValue == 0)
        #expect(LengthOp<PairArray>.intValue == 2)
        #expect(FoldAddOp<ATerm>.intValue == 0)
        #expect(FoldAddOp<PairArray>.intValue == 3)
        #expect(FoldMulOp<ATerm>.intValue == 1)
        #expect(FoldMulOp<PairArray>.intValue == 2)
    }

    @Test("Array arithmetic operators evaluate element-wise", arguments: arrayArithmeticExpectations)
    func arithmeticOperators(_ expectation: ArrayExpectation) {
        expectArrayValue(expectation)
    }

    @Test("Array unary and scalar operators evaluate correctly", arguments: arrayUnaryExpectations)
    func unaryAndScalarOperators(_ expectation: ArrayExpectation) {
        expectArrayValue(expectation)
    }
}
