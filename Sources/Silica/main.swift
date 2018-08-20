// Silica © 2018 Constantino Tsarouhas

import Foundation
import Utility

let arguments = CommandLine.arguments.dropFirst()
let parser = ArgumentParser(
	usage: "<source files> -c <conformance sources> -l <localisation files> -c <cache file>",
	overview: "Generates localisable string files from Swift source files."
)

let sourcesArgument = parser.add(positional: "source files", kind: PathArgument.self, optional: true, usage: "The root directory containing the source files.")
let conformanceArgument = parser.add(option: "--conformances", shortName: "-c", kind: PathArgument.self, usage: "The directory where the conformances are to be placed. The default path is <source files>/Silica.")
let localisationsArgument = parser.add(option: "--localisations", shortName: "-l", kind: PathArgument.self, usage: "The directory where the localisation files are to be placed. The default path is <source files>/Localisations.")

let result = try parser.parse(.init(arguments))

let sourceRootURL: Foundation.URL
if let sourcesPath = result.get(sourcesArgument)?.path {
	sourceRootURL = URL(fileURLWithPath: sourcesPath.asString)
} else if let sourcesPath = ProcessInfo.processInfo.environment["SCRIPT_INPUT_FILE_0"] {
	sourceRootURL = URL(fileURLWithPath: sourcesPath)
} else {
	fatalError("error: no source path given")
}

let conformancesURL: Foundation.URL
if let conformancesPath = result.get(conformanceArgument)?.path {
	conformancesURL = URL(fileURLWithPath: conformancesPath.asString)
} else if let conformancesPath = ProcessInfo.processInfo.environment["SCRIPT_OUTPUT_FILE_0"] {
	conformancesURL = URL(fileURLWithPath: conformancesPath)
} else {
	conformancesURL = sourceRootURL.appendingPathComponent("Silica", isDirectory: true)
}

ConformanceGenerationOperation(sourcesAt: sourceRootURL, generatedConformancesAt: conformancesURL).start()
