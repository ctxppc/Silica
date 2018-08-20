// Silica © 2018 Constantino Tsarouhas

import Foundation

/// A task of generating conformances for localisable string types.
final class ConformanceGenerationOperation : Operation {
	
	/// Creates a task with given source root URL and generated conformances URL.
	init(sourcesAt sourcesURL: URL, generatedConformancesAt generatedConformancesURL: URL) {
		self.sourcesURL = sourcesURL
		self.generatedConformancesURL = generatedConformancesURL
	}
	
	/// The location of the sources. It must be a readable file or directory.
	let sourcesURL: URL
	
	/// The location of the generated conformances. It must be a writeable file or directory.
	let generatedConformancesURL: URL
	
	override func main() {
		do {
			
			let sources = try SourceRoot(at: sourcesURL).sources
			let localisableStringTypes = sources.flatMap { LocalisableStringType.types(in: $0) }
			
			struct GeneratedConformance {
				
				init(for type: LocalisableStringType) throws {
					filename = "\(type.fullyQualifiedName) as Localisable String.swift"
					sourceText = type.generatedConformance()
				}
				
				let filename: String
				let sourceText: String
				
			}
			
			let conformances = try localisableStringTypes.map(GeneratedConformance.init)
			for conformance in conformances {
				let url = generatedConformancesURL.appendingPathComponent(conformance.filename, isDirectory: false)
				try conformance.sourceText.write(to: url, atomically: false, encoding: .utf8)
				print("written conformances to \(url.path)")
			}
			
		} catch {
			print("error: Silica couldn't generate conformances: \(error)")
		}
	}
	
}
