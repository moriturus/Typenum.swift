import Testing

private let harnessFailureExpectations: [FailureHarnessExpectation] = [
    .init(
        label: "Quotient by zero",
        name: "quotient-zero",
        expectedMessage: "Quotient: division by zero"
    ),
    .init(
        label: "Remainder by zero",
        name: "remainder-zero",
        expectedMessage: "Remainder: division by zero"
    ),
    .init(
        label: "Exponentiation overflow",
        name: "exponentiation-overflow",
        expectedMessage: "Exponentiation: overflow computing"
    ),
    .init(
        label: "Partial quotient zero divisor",
        name: "partial-quotient-zero",
        expectedMessage: "PartialQuotient: divisor cannot be zero"
    ),
    .init(
        label: "Partial quotient inexact division",
        name: "partial-quotient-inexact",
        expectedMessage: "PartialQuotient: 5 is not evenly divisible by 2"
    ),
    .init(
        label: "Log2 zero",
        name: "log2-zero",
        expectedMessage: "Logarithm2Op: value must be positive"
    ),
    .init(
        label: "Pow2Proof zero",
        name: "pow2-zero",
        expectedMessage: "Pow2Proof: value must be positive"
    ),
    .init(
        label: "Pow2Proof non-power-of-two",
        name: "pow2-non-power",
        expectedMessage: "Pow2Proof: 6 is not a power of two"
    ),
    .init(
        label: "Array quotient zero divisor element",
        name: "array-quotient-zero",
        expectedMessage: "ArrayQuotient: divisor array contains a zero element"
    ),
    .init(
        label: "Array remainder zero divisor element",
        name: "array-remainder-zero",
        expectedMessage: "ArrayRemainder: divisor array contains a zero element"
    ),
]

@Suite(.tags(.failurePath, .edgeCase))
struct FailurePathTests {
    @Test("Failure paths trap with explicit messages", arguments: harnessFailureExpectations)
    func failurePaths(_ expectation: FailureHarnessExpectation) throws {
        try expectHarnessFailure(expectation)
    }
}
