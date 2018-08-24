// Silica © 2018 Constantino Tsarouhas

import Foundation
import Utility

/// The Silica command.
final class Command : Operation {
	
	override init() {
		
		parser = ArgumentParser(
			usage:		"<source file(s)> -o <output file(s)> -l <localisation files>",
			overview:	"Generates localisable string files from Swift source files."
		)
		
		sourcesArgument = parser.add(positional: "source files", kind: PathArgument.self, optional: true, usage: "The source file or the root directory containing the source files to process. When running Silica as part of an Xcode build phase, omit this parameter to use the input files/directories or, if no inputs provided, the source root.")
		conformanceArgument = parser.add(option: "--output", shortName: "-o", kind: PathArgument.self, usage: "The file where the generated protocol and its conformances are to be placed. When running Silica as part of an Xcode build phase, omit this option to write to the phase's output file or directory. The default value is “Localisable String.swift” under the source root.")
		localisationsArgument = parser.add(option: "--localisations", shortName: "-l", kind: PathArgument.self, usage: "The directory where the localisation files are to be placed. No localisation files are generated if this option is omitted.")
		
		super.init()
		
	}
	
	private let parser: ArgumentParser
	private let sourcesArgument: PositionalArgument<PathArgument>
	private let conformanceArgument: OptionArgument<PathArgument>
	private let localisationsArgument: OptionArgument<PathArgument>
	
	private let arguments = CommandLine.arguments.dropFirst()
	private let environment = ProcessInfo.processInfo.environment
	
	override func main() {
		do {
			try run()
		} catch {
			self.error = error
		}
	}
	
	private func run() throws {
		
		let result = try parser.parse(.init(arguments))
		
		guard let sourceRootPath = result.get(sourcesArgument)?.path.asString ?? environment["SCRIPT_INPUT_FILE_0"] ?? environment["SRCROOT"] else { throw Error.noSourcePath }
		let sourceRootURL = URL(fileURLWithPath: sourceRootPath)
		
		let generatedSourcesURL: Foundation.URL
		if let generatedSourcesPath = result.get(conformanceArgument)?.path.asString ?? environment["SCRIPT_OUTPUT_FILE_0"] {
			generatedSourcesURL = URL(fileURLWithPath: generatedSourcesPath)
		} else {
			generatedSourcesURL = sourceRootURL.appendingPathComponent("Localisable String.swift", isDirectory: false)
		}
		
		let localisationTableURL = result.get(localisationsArgument).flatMap { URL(fileURLWithPath: $0.path.asString) }
		
		let operation = GenerationOperation(sourcesAt: sourceRootURL, generatingAt: generatedSourcesURL, tableAt: localisationTableURL)
		operation.start()
		if let error = operation.error {
			throw error
		}
		
	}
	
	enum Error : Swift.Error, CustomStringConvertible {
		
		case noSourcePath
		
		// See protocol.
		var description: String {
			switch self {
				case .noSourcePath:	return "no source path given"
			}
		}
		
	}
	
	/// An error thrown while performing the operation, or `nil` if the operation hasn't been started or if no error occurred.
	var error: Swift.Error?
	
}
