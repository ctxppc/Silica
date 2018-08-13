// Silica © 2018 Constantino Tsarouhas

import Foundation
import Utility

let parser = ArgumentParser(
	usage: "<source files> -c <conformance sources> -l <localisation files> -c <cache file>",
	overview: "Generates localisable string files from Swift source files."
)

let sourcesArgument = parser.add(positional: "source files", kind: PathArgument.self, usage: "The root directory containing the source files.")
let conformanceSourcesArgument = parser.add(option: "--conformances", shortName: "-c", kind: PathArgument.self, usage: "The directory where the conformances are to be placed. The default path is <source files>/Derived Sources/Silica.")
let localisationsArgument = parser.add(option: "--localisations", shortName: "-l", kind: PathArgument.self, usage: "The directory where the localisation files are to be placed. The default path is <source files>/Localisations.")

let result = try parser.parse(.init(CommandLine.arguments.dropFirst()))

let sources = result.get(sourcesArgument)?.path
