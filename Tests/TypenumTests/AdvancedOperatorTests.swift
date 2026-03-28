import Testing
@testable import Typenum

private let unaryAdvancedExpectations: [IntegerExpectation] = [
    .init(label: "Negate<P4>", actual: { Negate<P4>.intValue }, expected: -4),
    .init(label: "Negate<N4>", actual: { Negate<N4>.intValue }, expected: 4),
    .init(label: "Negate<Z0>", actual: { Negate<Z0>.intValue }, expected: 0),
    .init(label: "AbsVal<P4>", actual: { AbsVal<P4>.intValue }, expected: 4),
    .init(label: "AbsVal<N4>", actual: { AbsVal<N4>.intValue }, expected: 4),
    .init(label: "AbsVal<Z0>", actual: { AbsVal<Z0>.intValue }, expected: 0),
    .init(label: "Not<U0>", actual: { Not<U0>.intValue }, expected: 0),
    .init(label: "Not<U1>", actual: { Not<U1>.intValue }, expected: 0),
    .init(label: "Not<U2>", actual: { Not<U2>.intValue }, expected: 1),
    .init(label: "Not<U5>", actual: { Not<U5>.intValue }, expected: 2),
]

private let extremaExpectations: [IntegerExpectation] = [
    .init(label: "Minimum<P3, N2>", actual: { Minimum<P3, N2>.intValue }, expected: -2),
    .init(label: "Minimum<U2, U2>", actual: { Minimum<U2, U2>.intValue }, expected: 2),
    .init(label: "Maximum<P3, N2>", actual: { Maximum<P3, N2>.intValue }, expected: 3),
    .init(label: "Maximum<U2, U2>", actual: { Maximum<U2, U2>.intValue }, expected: 2),
    .init(label: "Minimum<N4, N9>", actual: { Minimum<N4, N9>.intValue }, expected: -9),
    .init(label: "Maximum<N4, N9>", actual: { Maximum<N4, N9>.intValue }, expected: -4),
]

private let squareRootExpectations: [IntegerExpectation] = [
    .init(label: "Sqrt<U0>", actual: { Sqrt<U0>.intValue }, expected: 0),
    .init(label: "Sqrt<U1>", actual: { Sqrt<U1>.intValue }, expected: 1),
    .init(label: "Sqrt<U4>", actual: { Sqrt<U4>.intValue }, expected: 2),
    .init(label: "Sqrt<U9>", actual: { Sqrt<U9>.intValue }, expected: 3),
    .init(label: "Sqrt<U15>", actual: { Sqrt<U15>.intValue }, expected: 3),
    .init(label: "Sqrt<U16>", actual: { Sqrt<U16>.intValue }, expected: 4),
    .init(label: "Sqrt<U17>", actual: { Sqrt<U17>.intValue }, expected: 4),
    .init(label: "Sqrt<U100>", actual: { Sqrt<U100>.intValue }, expected: 10),
]

private let logarithmExpectations: [IntegerExpectation] = [
    .init(label: "Log2<U1>", actual: { Log2<U1>.intValue }, expected: 0),
    .init(label: "Log2<U2>", actual: { Log2<U2>.intValue }, expected: 1),
    .init(label: "Log2<U8>", actual: { Log2<U8>.intValue }, expected: 3),
    .init(label: "Log2<U9>", actual: { Log2<U9>.intValue }, expected: 3),
    .init(label: "Log2<U1024>", actual: { Log2<U1024>.intValue }, expected: 10),
]

private let gcdAndBitLengthExpectations: [IntegerExpectation] = [
    .init(label: "Gcf<U54, U24>", actual: { Gcf<U54, U24>.intValue }, expected: 6),
    .init(label: "Gcf<U0, U24>", actual: { Gcf<U0, U24>.intValue }, expected: 24),
    .init(label: "Gcf<U24, U0>", actual: { Gcf<U24, U0>.intValue }, expected: 24),
    .init(label: "BitLen<U0>", actual: { BitLen<U0>.intValue }, expected: 0),
    .init(label: "BitLen<U1>", actual: { BitLen<U1>.intValue }, expected: 1),
    .init(label: "BitLen<U8>", actual: { BitLen<U8>.intValue }, expected: 4),
    .init(label: "BitLen<U9>", actual: { BitLen<U9>.intValue }, expected: 4),
    .init(label: "BitLen<U1024>", actual: { BitLen<U1024>.intValue }, expected: 11),
]

private let pow2ProofWitnesses: [IntegerExpectation] = [
    .init(label: "Pow2Proof<U1>", actual: { U1.intValue }, expected: 1),
    .init(label: "Pow2Proof<U2>", actual: { U2.intValue }, expected: 2),
    .init(label: "Pow2Proof<U4>", actual: { U4.intValue }, expected: 4),
    .init(label: "Pow2Proof<U8>", actual: { U8.intValue }, expected: 8),
    .init(label: "Pow2Proof<U16>", actual: { U16.intValue }, expected: 16),
]

@Suite(.tags(.operators, .edgeCase))
struct AdvancedOperatorTests {
    @Test("Advanced operator singleton initializers are reachable")
    func advancedInitializers() {
        let _: Negation<P1> = .init()
        let _: AbsoluteValue<N1> = .init()
        let _: BitwiseNot<U1> = .init()
        let _: MinOp<U1, U2> = .init()
        let _: MaxOp<U1, U2> = .init()
        let _: PartialQuotient<U8, U2> = .init()
        let _: SquareRootOp<U4> = .init()
        let _: Logarithm2Op<U8> = .init()
        let _: GreatestCommonDivisor<U8, U4> = .init()
        let _: BitLengthOp<U8> = .init()
    }

    @Test("Unary advanced operators evaluate correctly", arguments: unaryAdvancedExpectations)
    func unaryOperators(_ expectation: IntegerExpectation) {
        expectIntegerValue(expectation)
    }

    @Test("Min and max operations evaluate correctly", arguments: extremaExpectations)
    func extrema(_ expectation: IntegerExpectation) {
        expectIntegerValue(expectation)
    }

    @Test("Partial quotient succeeds for evenly divisible pairs")
    func partialQuotient() {
        #expect(PartialQuot<U8, U2>.intValue == 4)
        #expect(PartialQuot<U0, U4>.intValue == 0)
        #expect(PartialQuot<N8, P2>.intValue == -4)
    }

    @Test("Square root uses integer floor semantics", arguments: squareRootExpectations)
    func integerSquareRoot(_ expectation: IntegerExpectation) {
        expectIntegerValue(expectation)
    }

    @Test("Log base two returns floor semantics", arguments: logarithmExpectations)
    func logarithmBaseTwo(_ expectation: IntegerExpectation) {
        expectIntegerValue(expectation)
    }

    @Test("GCD and bit-length operators evaluate correctly", arguments: gcdAndBitLengthExpectations)
    func gcdAndBitLength(_ expectation: IntegerExpectation) {
        expectIntegerValue(expectation)
    }
}

@Suite(.tags(.operators, .edgeCase))
struct MarkerTests {
    @Test("Pow2Proof succeeds for powers of two", arguments: pow2ProofWitnesses)
    func pow2ProofValid(_ expectation: IntegerExpectation) {
        switch expectation.expected {
        case 1:
            let _ = Pow2Proof<U1>()
        case 2:
            let _ = Pow2Proof<U2>()
        case 4:
            let _ = Pow2Proof<U4>()
        case 8:
            let _ = Pow2Proof<U8>()
        case 16:
            let _ = Pow2Proof<U16>()
        default:
            Issue.record("Unexpected Pow2Proof witness: \(expectation.expected)")
        }
    }
}
