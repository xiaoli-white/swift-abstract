@attached(member, names: arbitrary)
@attached(peer, names: named(init))
public macro abstractClass() = #externalMacro(module: "SwiftAbstractMacros", type: "AbstractClassMacro")

@attached(body)
public macro abstractInit() = #externalMacro(module: "SwiftAbstractMacros", type: "AbstractInitMacro")

@attached(body)
public macro abstract() = #externalMacro(module: "SwiftAbstractMacros", type: "AbstractFuncMacro")
