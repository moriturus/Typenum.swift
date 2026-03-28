import Testing
@testable import Typenum

private let bitExpectations: [BitExpectation] = [
    .init(label: "B0", actualBit: { B0.bitValue }, actualBool: { B0.boolValue }, actualInt: { B0.intValue }, expectedBit: 0, expectedBool: false),
    .init(label: "B1", actualBit: { B1.bitValue }, actualBool: { B1.boolValue }, actualInt: { B1.intValue }, expectedBit: 1, expectedBool: true),
]

private let comparisonExpectations: [ComparisonExpectation] = [
    .init(label: "Less", actual: { Less.ordering }, expected: TypeOrdering.less),
    .init(label: "Equal", actual: { Equal.ordering }, expected: TypeOrdering.equal),
    .init(label: "Greater", actual: { Greater.ordering }, expected: TypeOrdering.greater),
]

private let unsignedAliasExpectations: [IntegerExpectation] = [
    .init(label: "U0", actual: { U0.intValue }, expected: 0),
    .init(label: "U1", actual: { U1.intValue }, expected: 1),
    .init(label: "U2", actual: { U2.intValue }, expected: 2),
    .init(label: "U3", actual: { U3.intValue }, expected: 3),
    .init(label: "U4", actual: { U4.intValue }, expected: 4),
    .init(label: "U5", actual: { U5.intValue }, expected: 5),
    .init(label: "U6", actual: { U6.intValue }, expected: 6),
    .init(label: "U7", actual: { U7.intValue }, expected: 7),
    .init(label: "U8", actual: { U8.intValue }, expected: 8),
    .init(label: "U9", actual: { U9.intValue }, expected: 9),
    .init(label: "U10", actual: { U10.intValue }, expected: 10),
    .init(label: "U11", actual: { U11.intValue }, expected: 11),
    .init(label: "U12", actual: { U12.intValue }, expected: 12),
    .init(label: "U13", actual: { U13.intValue }, expected: 13),
    .init(label: "U14", actual: { U14.intValue }, expected: 14),
    .init(label: "U15", actual: { U15.intValue }, expected: 15),
    .init(label: "U16", actual: { U16.intValue }, expected: 16),
    .init(label: "U255", actual: { U255.intValue }, expected: 255),
    .init(label: "U1024", actual: { U1024.intValue }, expected: 1024),
]

private let signedAliasExpectations: [IntegerExpectation] = [
    .init(label: "Z0", actual: { Z0.intValue }, expected: 0),
    .init(label: "P1", actual: { P1.intValue }, expected: 1),
    .init(label: "P4", actual: { P4.intValue }, expected: 4),
    .init(label: "P16", actual: { P16.intValue }, expected: 16),
    .init(label: "P255", actual: { P255.intValue }, expected: 255),
    .init(label: "N1", actual: { N1.intValue }, expected: -1),
    .init(label: "N4", actual: { N4.intValue }, expected: -4),
    .init(label: "N16", actual: { N16.intValue }, expected: -16),
    .init(label: "N255", actual: { N255.intValue }, expected: -255),
]

@Suite(.tags(.core))
struct BitTests {
    @Test("Bit singleton initializers are reachable")
    func bitInitializers() {
        let _: B0 = .init()
        let _: B1 = .init()
    }

    @Test("Bits bridge into runtime values", arguments: bitExpectations)
    func runtimeBitValues(_ expectation: BitExpectation) {
        expectBitValue(expectation)
    }

    @Test("Bitwise aliases work on bits")
    func bitOperators() {
        #expect(And<B0, B0>.intValue == 0)
        #expect(And<B0, B1>.intValue == 0)
        #expect(And<B1, B1>.intValue == 1)
        #expect(Or<B0, B1>.intValue == 1)
        #expect(Xor<B1, B1>.intValue == 0)
        #expect(Xor<B1, B0>.intValue == 1)
    }
}

@Suite(.tags(.core))
struct CoreTests {
    @Test("Integer conversion helpers bridge to exact fixed-width values")
    func integerConversions() {
        #expect(U16.toInt() == 16)
        #expect(P4.toInt() == 4)
        #expect(N4.toInt() == -4)
        #expect(U16.to(UInt8.self) == 16)
        #expect(U255.to(UInt8.self) == 255)
        #expect(P4.to(Int8.self) == 4)
        #expect(P127.to(Int8.self) == 127)
        #expect(N4.to(Int8.self) == -4)
        #expect(N128.to(Int8.self) == -128)
    }

    @Test("Integer conversion returns nil when value is not exactly representable")
    func integerConversionFailure() {
        #expect(U256.to(UInt8.self) == nil)
        #expect(P128.to(Int8.self) == nil)
        #expect(N129.to(Int8.self) == nil)
    }

    @Test("Comparison result types expose the expected ordering", arguments: comparisonExpectations)
    func comparisonResultTypes(_ expectation: ComparisonExpectation) {
        let _: Less = .init()
        let _: Equal = .init()
        let _: Greater = .init()
        expectOrdering(expectation)
    }

    @Test("Compile-time and runtime metatype equality helpers are reachable")
    func equalityHelpers() {
        assertTypeEqual(U1.self, UOne.self)
        assertMetatypeEqual(U1.self, UOne.self)
    }
}

@Suite(.tags(.core, .edgeCase))
struct IntegerInvariantTests {
    @Test("Canonical integer singleton initializers are reachable")
    func integerInitializers() {
        let _: UTerm = .init()
        let _: UOne = .init()
        let _: UInt<UOne, B0> = .init()
        let _: Z0 = .init()
        let _: PInt<U3> = .init()
        let _: NInt<U3> = .init()
    }

    @Test("Unsigned aliases map to their expected values", arguments: unsignedAliasExpectations)
    func unsignedAliases(_ expectation: IntegerExpectation) {
        expectIntegerValue(expectation)
    }

    @Test("Signed aliases map to their expected values", arguments: signedAliasExpectations)
    func signedAliases(_ expectation: IntegerExpectation) {
        expectIntegerValue(expectation)
    }

    @Test("Zero and non-zero marker protocols match canonical integer types")
    func zeroAndNonZeroMarkers() {
        acceptZero(UTerm.self)
        acceptZero(Z0.self)
        acceptZero(B0.self)
        acceptNonZero(UOne.self)
        acceptNonZero(UInt<UOne, B0>.self)
        acceptNonZero(UInt<UOne, B1>.self)
        acceptNonZero(U4.self)
        acceptNonZero(U16.self)
        acceptNonZero(U1024.self)
        #expect((UTerm() is any NonZero) == false)
    }

    @Test("Signed wrappers require non-zero unsigned magnitudes")
    func signedMagnitudeInvariants() {
        let _: PInt<UOne> = .init()
        let _: NInt<UOne> = .init()
        let _: PInt<U4> = .init()
        let _: NInt<U4> = .init()
        #expect(PInt<UOne>.intValue == 1)
        #expect(NInt<UOne>.intValue == -1)
    }
}
