import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct TypenumPluginMain: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TypeUIntMacro.self,
        TypePositiveMacro.self,
        TypeNegativeMacro.self,
        TypeArrayMacro.self,
        TypenumAssertEqualMacro.self,
    ]
}

private func integerLiteral(from expression: ExprSyntax) throws -> Int {
    let text = expression.trimmed.description
    guard let value = Int(text) else {
        throw MacroExpansionErrorMessage("expected an integer literal")
    }
    return value
}

/// Builds the recursive unsigned type expression for a non-negative integer.
///
/// Mirrors `unsignedExpr` in `TypenumCodegen/main.swift`:
/// - 0 → `UTerm`
/// - 1 → `UOne`
/// - n > 1 → `UInt<…, B0/B1>` built from the binary representation.
private func unsignedTypeExpr(_ value: Int) -> String {
    if value == 0 { return "UTerm" }
    if value == 1 { return "UOne" }
    let binary = String(value, radix: 2)
    var expr = "UOne"
    for bit in binary.dropFirst() {
        expr = "UInt<\(expr), \(bit == "1" ? "B1" : "B0")>"
    }
    return expr
}

public struct TypeUIntMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let firstArg = node.arguments.first else {
            throw MacroExpansionErrorMessage("#typeUInt requires exactly one integer literal argument")
        }
        let value = try integerLiteral(from: firstArg.expression)
        guard value >= 0 else {
            throw MacroExpansionErrorMessage("typeUInt requires a non-negative integer literal")
        }
        return ExprSyntax(stringLiteral: "\(unsignedTypeExpr(value)).self")
    }
}

public struct TypePositiveMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let firstArg = node.arguments.first else {
            throw MacroExpansionErrorMessage("#typePositive requires exactly one integer literal argument")
        }
        let value = try integerLiteral(from: firstArg.expression)
        guard value > 0 else {
            throw MacroExpansionErrorMessage("typePositive requires a positive integer literal")
        }
        return ExprSyntax(stringLiteral: "PInt<\(unsignedTypeExpr(value))>.self")
    }
}

public struct TypeNegativeMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let firstArg = node.arguments.first else {
            throw MacroExpansionErrorMessage("#typeNegative requires exactly one integer literal argument")
        }
        let value = try integerLiteral(from: firstArg.expression)
        guard value > 0 else {
            throw MacroExpansionErrorMessage("typeNegative requires a positive magnitude literal")
        }
        return ExprSyntax(stringLiteral: "NInt<\(unsignedTypeExpr(value))>.self")
    }
}

public struct TypeArrayMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let names = try node.arguments.map { expr in
            let text = expr.expression.trimmed.description
            guard text.hasSuffix(".self") else {
                throw MacroExpansionErrorMessage("typeArray requires metatype arguments ending with .self")
            }
            return String(text.dropLast(5))
        }
        let built = names.reduce("ATerm") { partial, next in
            "TArr<\(next), \(partial)>"
        }
        return ExprSyntax(stringLiteral: "\(built).self")
    }
}

public struct TypenumAssertEqualMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let arguments = Array(node.arguments)
        guard arguments.count == 2 else {
            throw MacroExpansionErrorMessage("typenumAssertEqual requires exactly two metatype arguments")
        }
        let lhs = try inlineExpand(arguments[0].expression)
        let rhs = try inlineExpand(arguments[1].expression)
        return ExprSyntax(stringLiteral: "assertTypeEqual(\(lhs), \(rhs))")
    }

    /// If the expression is a known Typenum macro invocation, expand it here
    /// so that the concrete metatype is preserved (avoiding `Any.Type` erasure
    /// from the macro return type declaration).
    private static func inlineExpand(_ expr: ExprSyntax) throws -> String {
        guard let macro = expr.as(MacroExpansionExprSyntax.self) else {
            return expr.trimmed.description
        }
        switch macro.macroName.text {
        case "typeUInt":
            guard let arg = macro.arguments.first else {
                throw MacroExpansionErrorMessage("#typeUInt requires an argument")
            }
            let v = try integerLiteral(from: arg.expression)
            guard v >= 0 else {
                throw MacroExpansionErrorMessage("typeUInt requires a non-negative integer literal")
            }
            return "\(unsignedTypeExpr(v)).self"
        case "typePositive":
            guard let arg = macro.arguments.first else {
                throw MacroExpansionErrorMessage("#typePositive requires an argument")
            }
            let v = try integerLiteral(from: arg.expression)
            guard v > 0 else {
                throw MacroExpansionErrorMessage("typePositive requires a positive integer literal")
            }
            return "PInt<\(unsignedTypeExpr(v))>.self"
        case "typeNegative":
            guard let arg = macro.arguments.first else {
                throw MacroExpansionErrorMessage("#typeNegative requires an argument")
            }
            let v = try integerLiteral(from: arg.expression)
            guard v > 0 else {
                throw MacroExpansionErrorMessage("typeNegative requires a positive magnitude literal")
            }
            return "NInt<\(unsignedTypeExpr(v))>.self"
        case "typeArray":
            let names = try macro.arguments.map { arg in
                let text = arg.expression.trimmed.description
                guard text.hasSuffix(".self") else {
                    throw MacroExpansionErrorMessage("typeArray requires metatype arguments ending with .self")
                }
                return String(text.dropLast(5))
            }
            let built = names.reduce("ATerm") { partial, next in
                "TArr<\(next), \(partial)>"
            }
            return "\(built).self"
        default:
            return expr.trimmed.description
        }
    }
}
