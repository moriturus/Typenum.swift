import PackagePlugin

@main
struct TypenumPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let output = context.pluginWorkDirectoryURL.appending(path: "GeneratedProofs.swift")

        return [
            .buildCommand(
                displayName: "Generating Typenum proof tables",
                executable: try context.tool(named: "TypenumCodegen").url,
                arguments: [output.path()],
                outputFiles: [output]
            )
        ]
    }
}
