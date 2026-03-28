import Foundation
import Testing
@testable import Typenum

extension Tag {
    @Tag static var arrays: Self
    @Tag static var core: Self
    @Tag static var edgeCase: Self
    @Tag static var failurePath: Self
    @Tag static var macros: Self
    @Tag static var operators: Self
}

func acceptUnsigned<T: Unsigned>(_: T.Type) {}
func acceptNonZero<T: NonZero>(_: T.Type) {}
func acceptZero<T: Zero>(_: T.Type) {}

struct IntegerExpectation: Sendable, CustomTestStringConvertible {
    let label: String
    let actual: @Sendable () -> Int
    let expected: Int

    var testDescription: String {
        label
    }
}

struct BitExpectation: Sendable, CustomTestStringConvertible {
    let label: String
    let actualBit: @Sendable () -> Int
    let actualBool: @Sendable () -> Bool
    let actualInt: @Sendable () -> Int
    let expectedBit: Int
    let expectedBool: Bool

    var testDescription: String {
        label
    }
}

struct ComparisonExpectation: Sendable, CustomTestStringConvertible {
    let label: String
    let actual: @Sendable () -> TypeOrdering
    let expected: TypeOrdering

    var testDescription: String {
        label
    }
}

struct ArrayExpectation: Sendable, CustomTestStringConvertible {
    let label: String
    let actualLength: @Sendable () -> Int
    let actualValues: @Sendable () -> [Int]
    let expectedLength: Int
    let expectedValues: [Int]

    var testDescription: String {
        label
    }
}

struct ProcessResult {
    let status: Int32
    let stderr: String
}

struct FailureHarnessExpectation: Sendable, CustomTestStringConvertible {
    let label: String
    let name: String
    let expectedMessage: String

    var testDescription: String {
        label
    }
}

func expectIntegerValue(
    _ expectation: IntegerExpectation,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(expectation.actual() == expectation.expected, sourceLocation: sourceLocation)
}

func expectBitValue(
    _ expectation: BitExpectation,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(expectation.actualBit() == expectation.expectedBit, sourceLocation: sourceLocation)
    #expect(expectation.actualBool() == expectation.expectedBool, sourceLocation: sourceLocation)
    #expect(expectation.actualInt() == expectation.expectedBit, sourceLocation: sourceLocation)
}

func expectOrdering(
    _ expectation: ComparisonExpectation,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(expectation.actual() == expectation.expected, sourceLocation: sourceLocation)
}

func expectArrayValue(
    _ expectation: ArrayExpectation,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(expectation.actualLength() == expectation.expectedLength, sourceLocation: sourceLocation)
    #expect(expectation.actualValues() == expectation.expectedValues, sourceLocation: sourceLocation)
}

func failureHarnessURL() throws -> URL {
    var repositoryURL = URL(fileURLWithPath: #filePath)
    for _ in 0..<3 {
        repositoryURL.deleteLastPathComponent()
    }

    let buildURL = repositoryURL.appendingPathComponent(".build")
    let enumerator = FileManager.default.enumerator(
        at: buildURL,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
    )

    while let candidate = enumerator?.nextObject() as? URL {
        guard candidate.lastPathComponent == "TypenumFailureHarness" else {
            continue
        }
        if FileManager.default.isExecutableFile(atPath: candidate.path(percentEncoded: false)) {
            return candidate
        }
    }

    #expect(Bool(false), "TypenumFailureHarness executable was not found in .build")
    throw CocoaError(.fileNoSuchFile)
}

@discardableResult
func runFailureHarness(_ name: String) throws -> ProcessResult {
    let process = Process()
    process.executableURL = try failureHarnessURL()
    process.arguments = [name]

    var environment = ProcessInfo.processInfo.environment
    environment["LLVM_PROFILE_FILE"] =
        URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("TypenumFailureHarness-%p.profraw")
        .path(percentEncoded: false)
    process.environment = environment

    let stderrPipe = Pipe()
    process.standardError = stderrPipe

    try process.run()
    process.waitUntilExit()

    let stderr = String(
        data: stderrPipe.fileHandleForReading.readDataToEndOfFile(),
        encoding: .utf8
    ) ?? ""

    return ProcessResult(status: process.terminationStatus, stderr: stderr)
}

func expectHarnessFailure(
    _ expectation: FailureHarnessExpectation,
    sourceLocation: SourceLocation = #_sourceLocation
) throws {
    let result = try runFailureHarness(expectation.name)
    #expect(result.status != 0, sourceLocation: sourceLocation)
    #expect(
        result.stderr.contains(expectation.expectedMessage),
        sourceLocation: sourceLocation
    )
}
