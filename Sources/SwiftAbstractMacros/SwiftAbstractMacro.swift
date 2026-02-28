import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AbstractClassMacro: MemberMacro, PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }

        let className = classDecl.name.text

        let hasInit = classDecl.memberBlock.members.contains { member in
            member.decl.as(InitializerDeclSyntax.self) != nil
        }

        if !hasInit {
            let guardCode = """
                if type(of: self) == \(className).self {
                    fatalError("Cannot instantiate abstract class '\(className)' directly")
                }
                """
            let initCode = "init() { \(guardCode) }"
            return [DeclSyntax(stringLiteral: initCode)]
        }

        return []
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let initDecl = declaration.as(InitializerDeclSyntax.self),
              initDecl.body != nil,
              let classDecl = context.lexicalContext.first?.as(ClassDeclSyntax.self)
        else {
            return []
        }
        
        let className = classDecl.name.text
        let guardCode = """
            if type(of: self) == \(className).self {
                fatalError("Cannot instantiate abstract class '\(className)' directly")
            }
            """
        
        var statements = CodeBlockItemListSyntax([])
        let guardItem = CodeBlockItemSyntax(stringLiteral: guardCode)
        statements.append(guardItem)
        
        if let body = initDecl.body {
            for item in body.statements {
                statements.append(item)
            }
        }
        
        var newInitDecl = initDecl
        newInitDecl.body = CodeBlockSyntax(statements: statements)
        
        return [DeclSyntax(newInitDecl)]
    }
}

public struct AbstractInitMacro: BodyMacro {

    public static func expansion(
        of attribute: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard declaration.as(InitializerDeclSyntax.self) != nil else {
            let diagnostic = Diagnostic(
                node: attribute,
                message: AbstractDiagnostic(id: "abstractInitOnNonInitializer", message: "@abstractInit can only be used on initializers")
            )
            context.diagnose(diagnostic)
            return []
        }
        
        guard let classDecl = context.lexicalContext.first?.as(ClassDeclSyntax.self) else {
            let diagnostic = Diagnostic(
                node: attribute,
                message: AbstractDiagnostic(id: "abstractInitOutsideClass", message: "@abstractInit can only be used inside a class")
            )
            context.diagnose(diagnostic)
            return []
        }
        
        guard hasAbstractClassAttribute(classDecl) else {
            let diagnostic = Diagnostic(
                node: attribute,
                message: AbstractDiagnostic(id: "abstractInitOutsideAbstractClass", message: "@abstractInit can only be used inside @abstractClass")
            )
            context.diagnose(diagnostic)
            return []
        }
        
        let className = classDecl.name.text
        let guardCode = """
            if type(of: self) == \(className).self {
                fatalError("Cannot instantiate abstract class '\(className)' directly")
            }
            """
        
        var statements: [CodeBlockItemSyntax] = []
        
        let guardItem = CodeBlockItemSyntax(stringLiteral: guardCode)
        statements.append(guardItem)
        
        if let initDecl = declaration.as(InitializerDeclSyntax.self),
           let body = initDecl.body {
            statements.append(contentsOf: body.statements)
        }
        
        return statements
    }
}

public struct AbstractFuncMacro: BodyMacro {

    public static func expansion(
        of attribute: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard declaration.as(FunctionDeclSyntax.self) != nil else {
            let diagnostic = Diagnostic(
                node: attribute,
                message: AbstractDiagnostic(id: "abstractOnNonFunction", message: "@abstract can only be used on functions")
            )
            context.diagnose(diagnostic)
            return []
        }
        
        guard let classDecl = context.lexicalContext.first?.as(ClassDeclSyntax.self) else {
            let diagnostic = Diagnostic(
                node: attribute,
                message: AbstractDiagnostic(id: "abstractOutsideClass", message: "@abstract can only be used inside a class")
            )
            context.diagnose(diagnostic)
            return []
        }
        
        guard hasAbstractClassAttribute(classDecl) else {
            let diagnostic = Diagnostic(
                node: attribute,
                message: AbstractDiagnostic(id: "abstractOutsideAbstractClass", message: "@abstract can only be used inside @abstractClass")
            )
            context.diagnose(diagnostic)
            return []
        }
        
        let methodName = declaration.as(FunctionDeclSyntax.self)!.name.text
        let fatalErrorMessage = "Method '\(methodName)' must be overridden in subclass"
        
        let fatalErrorStatement = "fatalError(\"\(fatalErrorMessage)\")"
        
        return [CodeBlockItemSyntax(stringLiteral: fatalErrorStatement)]
    }
}

private func hasAbstractClassAttribute(_ classDecl: ClassDeclSyntax) -> Bool {
    return classDecl.attributes.contains { attr in
        if let simpleAttr = attr.as(AttributeSyntax.self),
           let attrName = simpleAttr.attributeName.as(IdentifierTypeSyntax.self)
        {
            return attrName.name.text == "abstractClass"
        }
        return false
    }
}

struct AbstractDiagnostic: DiagnosticMessage {
    let id: String
    let message: String
    var severity: DiagnosticSeverity { .error }
    var diagnosticID: MessageID {
        MessageID(domain: "SwiftAbstract", id: id)
    }
}

@main
struct SwiftAbstractPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AbstractClassMacro.self,
        AbstractInitMacro.self,
        AbstractFuncMacro.self
    ]
}
