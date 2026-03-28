import Foundation
import Typenum

enum HarnessCase: String {
    case quotientZero = "quotient-zero"
    case remainderZero = "remainder-zero"
    case exponentiationOverflow = "exponentiation-overflow"
    case partialQuotientZero = "partial-quotient-zero"
    case partialQuotientInexact = "partial-quotient-inexact"
    case log2Zero = "log2-zero"
    case pow2Zero = "pow2-zero"
    case pow2NonPower = "pow2-non-power"
    case arrayQuotientZero = "array-quotient-zero"
    case arrayRemainderZero = "array-remainder-zero"
}

@main
struct TypenumFailureHarness {
    static func main() {
        guard
            CommandLine.arguments.count == 2,
            let harnessCase = HarnessCase(rawValue: CommandLine.arguments[1])
        else {
            fputs("usage: TypenumFailureHarness <case>\n", stderr)
            exit(2)
        }

        switch harnessCase {
        case .quotientZero:
            _ = Quot<U1, U0>.intValue
        case .remainderZero:
            _ = Rem<U1, U0>.intValue
        case .exponentiationOverflow:
            _ = Pow<U1024, U10>.intValue
        case .partialQuotientZero:
            _ = PartialQuot<U4, U0>.intValue
        case .partialQuotientInexact:
            _ = PartialQuot<U5, U2>.intValue
        case .log2Zero:
            _ = Log2<U0>.intValue
        case .pow2Zero:
            _ = Pow2Proof<U0>()
        case .pow2NonPower:
            _ = Pow2Proof<U6>()
        case .arrayQuotientZero:
            typealias LHS = TArr<U4, TArr<U2, ATerm>>
            typealias RHS = TArr<U0, TArr<U1, ATerm>>
            _ = ArrayQuotient<LHS, RHS>.intValues
        case .arrayRemainderZero:
            typealias LHS = TArr<U4, TArr<U2, ATerm>>
            typealias RHS = TArr<U1, TArr<U0, ATerm>>
            _ = ArrayRemainder<LHS, RHS>.intValues
        }
    }
}
