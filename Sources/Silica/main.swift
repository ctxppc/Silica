// Silica © 2018 Constantino Tsarouhas

import Foundation
import Utility

enum ArgumentError : Error {
	case noSourcesPath
}

let arguments = CommandLine.arguments.dropFirst()
let parser = ArgumentParser(
	usage: "<source files> -c <conformance sources> -l <localisation files> -c <cache file>",
	overview: "Generates localisable string files from Swift source files."
)

let sourcesArgument = parser.add(positional: "source files", kind: PathArgument.self, usage: "The root directory containing the source files.")
let conformanceSourcesArgument = parser.add(option: "--conformances", shortName: "-c", kind: PathArgument.self, usage: "The directory where the conformances are to be placed. The default path is <source files>/Derived Sources/Silica.")
let localisationsArgument = parser.add(option: "--localisations", shortName: "-l", kind: PathArgument.self, usage: "The directory where the localisation files are to be placed. The default path is <source files>/Localisations.")

do {
	let result = try parser.parse(.init(arguments))
	guard let sourcesPath = result.get(sourcesArgument)?.path else { throw ArgumentError.noSourcesPath }
	let source = try Source(at: URL(fileURLWithPath: sourcesPath.asString, isDirectory: false))
	print(source.declarations, source.issues)
} catch {
	print(error)
}
