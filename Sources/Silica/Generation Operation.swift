// Silica © 2018 Constantino Tsarouhas

import Foundation

/// A task of generating the protocol and its conformances for localisable string types.
final class GenerationOperation : Operation {
	
	/// Creates a task with given source root URL and generated sources URL.
	init(sourcesAt sourcesURL: URL, excludingAt excludedSourcesURL: URL?, generatingAt generatedSourcesURL: URL, tableAt tableURL: URL?) {
		self.sourcesURL = sourcesURL
		self.excludedSourcesURL = excludedSourcesURL
		self.generatedSourcesURL = generatedSourcesURL
		self.tableURL = tableURL
	}
	
	/// The location of the sources. It must be a readable file or directory.
	let sourcesURL: URL
	
	/// The location of the excluded sources, or `nil` if no sources are to be excluded. If relative, it's resolved against `sourcesURL`.
	let excludedSourcesURL: URL?
	
	/// The location of the generated sources. It must be a writeable file or directory.
	let generatedSourcesURL: URL
	
	/// The location of the localisation table, or `nil` if no table is to be created or updated.
	let tableURL: URL?
	
	override func main() {
		do {
			try run()
		} catch {
			self.error = error
		}
	}
	
	private func run() throws {
		
		let module = try Module(at: sourcesURL, excludingAt: excludedSourcesURL)
		
		let localisableEntries = module.localisableStringEntries
		if localisableEntries.isEmpty {
			print("warning: Silica did not find any localisable entries in the module at \(sourcesURL).")
		}
		
		let tableName: String
		if let tableURL = tableURL {
			
			guard tableURL.pathExtension.caseInsensitiveCompare("strings") == .orderedSame else { throw TableError.unsupportedFormat }
			let table = try LocalisationTable(at: tableURL)
			tableName = tableURL.deletingPathExtension().lastPathComponent
			
			for entry in localisableEntries {
				table[entry.tableEntryIdentifier] = table[entry.tableEntryIdentifier] ?? ""
			}
			
			try table.save()
			
		} else {
			tableName = "Localizable"	// TODO: Correct default value?
		}
		
		let conformances = module.localisableStringConformances
		let prelude = "// This file has been generated by Silica. Do not edit this file manually."
		
		if generatedSourcesURL.pathExtension.caseInsensitiveCompare("swift") == .orderedSame {
			try """
				\(prelude)

				import Foundation
				import os

				\(localisableStringProtocolSource(tableName: tableName))

				\(conformances.map { $0.source.stringValue() }.joined(separator: "\n\n"))
				""".write(to: generatedSourcesURL, atomically: false, encoding: .utf8)
		} else {

			try """
				\(prelude)

				import Foundation
				import os

				\(localisableStringProtocolSource(tableName: tableName))
				""".write(to: generatedSourcesURL.appendingPathComponent("Localisable String.swift", isDirectory: false), atomically: false, encoding: .utf8)

			for conformance in conformances {
				try """
					\(prelude)

					\(conformance.source.stringValue())
					""".write(to: generatedSourcesURL.appendingPathComponent("\(conformance.conformingType.internalFullyQualifiedName).silica.swift", isDirectory: false), atomically: false, encoding: .utf8)
			}

		}
		
	}
	
	/// An error thrown while performing the operation, or `nil` if the operation hasn't been started or if no error occurred.
	var error: Error?
	
	enum TableError : Error, CustomStringConvertible {
		
		case unsupportedFormat
		
		var description: String {
			switch self {
				case .unsupportedFormat:	return "This localisation table format is not supported by Silica."
			}
		}
		
	}
	
}
