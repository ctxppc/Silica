// Silica © 2018 Constantino Tsarouhas

import Foundation
import Utility

let arguments = CommandLine.arguments.dropFirst()
let parser = ArgumentParser(
	usage: "<source file(s)> -o <output file(s)> -l <localisation files>",
	overview: "Generates localisable string files from Swift source files."
)

let sourcesArgument = parser.add(positional: "source files", kind: PathArgument.self, optional: true, usage: "The source file or the root directory containing the source files to process. When running Silica as part of an Xcode build phase, omit this parameter to use the input files/directories or, if no inputs provided, the source root.")
let conformanceArgument = parser.add(option: "--output", shortName: "-o", kind: PathArgument.self, usage: "The file where the generated protocol and its conformances are to be placed. When running Silica as part of an Xcode build phase, omit this option to write to the phase's output file or directory. The default value is “Localisable String.swift” under the source root.")
let localisationsArgument = parser.add(option: "--localisations", shortName: "-l", kind: PathArgument.self, usage: "The directory where the localisation files are to be placed. No localisation files are generated if this option is omitted.")

let result = try parser.parse(.init(arguments))

let sourceRootURL: Foundation.URL
if let sourcesPath = result.get(sourcesArgument)?.path {
	sourceRootURL = URL(fileURLWithPath: sourcesPath.asString)
} else if let sourcesPath = ProcessInfo.processInfo.environment["SCRIPT_INPUT_FILE_0"] {
	sourceRootURL = URL(fileURLWithPath: sourcesPath)
} else if let sourcesPath = ProcessInfo.processInfo.environment["SRCROOT"] {
	sourceRootURL = URL(fileURLWithPath: sourcesPath)
} else {
	print("error: no source path given")
	exit(1)
}

let generatedSourcesURL: Foundation.URL
if let generatedSourcesPath = result.get(conformanceArgument)?.path {
	generatedSourcesURL = URL(fileURLWithPath: generatedSourcesPath.asString)
} else if let generatedSourcesPath = ProcessInfo.processInfo.environment["SCRIPT_OUTPUT_FILE_0"] {
	generatedSourcesURL = URL(fileURLWithPath: generatedSourcesPath)
} else {
	generatedSourcesURL = sourceRootURL.appendingPathComponent("Localisable String.swift", isDirectory: false)
}

let operation = GenerationOperation(sourcesAt: sourceRootURL, generatingAt: generatedSourcesURL)
operation.start()
if operation.hasErrors {
	exit(1)
}
