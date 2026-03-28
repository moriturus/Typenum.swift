import Testing
@testable import Typenum

@Suite(.tags(.macros, .edgeCase))
struct MacroTests {
    @Test("typeUInt macro synthesizes correct types across small and larger values")
    func typeUInt() {
        #typenumAssertEqual(#typeUInt(0), UTerm.self)
        #typenumAssertEqual(#typeUInt(1), UOne.self)
        #typenumAssertEqual(#typeUInt(7), U7.self)
        #typenumAssertEqual(#typeUInt(16), U16.self)
        #typenumAssertEqual(#typeUInt(255), U255.self)
        #typenumAssertEqual(#typeUInt(1024), U1024.self)
    }

    @Test("Signed literal macros synthesize correct types")
    func signedTypeMacros() {
        #typenumAssertEqual(#typePositive(1), P1.self)
        #typenumAssertEqual(#typePositive(4), P4.self)
        #typenumAssertEqual(#typePositive(255), P255.self)
        #typenumAssertEqual(#typeNegative(1), N1.self)
        #typenumAssertEqual(#typeNegative(4), N4.self)
        #typenumAssertEqual(#typeNegative(255), N255.self)
    }

    @Test("typeArray macro handles empty, singleton, and longer arrays")
    func typeArrayMacro() {
        #typenumAssertEqual(#typeArray(), ATerm.self)
        #typenumAssertEqual(#typeArray(U1.self), TArr<U1, ATerm>.self)
        #typenumAssertEqual(#typeArray(N1.self, Z0.self), TArr<Z0, TArr<N1, ATerm>>.self)
        #typenumAssertEqual(
            #typeArray(P1.self, P2.self, P3.self),
            TArr<P3, TArr<P2, TArr<P1, ATerm>>>.self
        )
    }

    @Test("typenumAssertEqual remains a compile-time type check")
    func assertEqualCompileTime() {
        #typenumAssertEqual(#typeUInt(5), U5.self)
        #typenumAssertEqual(U1.self, UOne.self)
        assertMetatypeEqual(#typeNegative(4), N4.self)
    }
}
