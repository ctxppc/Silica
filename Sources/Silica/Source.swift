// Silica © 2018 Constantino Tsarouhas

import Foundation
import DepthKit
import SourceKittenFramework

/// A file containing Swift source code.
final class Source {
	
	/// Creates and loads a source from a file at a given location.
	///
	/// - Parameter url: The location of the source file.
	///
	/// - Throws: An error if loading or parsing the source fails.
	init(at url: URL) throws {
		
		self.url = url
		text = try String(contentsOf: url)
		
		let decoder = BasicValueDecoder(value: try SourceKittenFramework.Structure(file: File(pathDeferringReading: url.path)).dictionary)
		decoder.convertedKeyValue = { "key.\($0.lowercased())" }
		
		let structure = try decoder.decode(Structure.self)
		if let error = structure.issues.first(where: { $0.severity == .error }) {
			throw error
		}
		
		declarations = structure.declarations
		issues = structure.issues
		
	}
	
	/// The structure of a source.
	private struct Structure : Decodable {
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKey.self)
			declarations = try container.decodeIfPresent(key: .declarations) ?? []
			issues = try container.decodeIfPresent(key: .issues) ?? []
		}
		
		let declarations: [Declaration]
		let issues: [Issue]
		
		enum CodingKey : String, Swift.CodingKey {
			case declarations = "substructure"
			case issues = "diagnostics"
		}
		
	}
	
	/// The location of the source file.
	let url: URL
	
	/// The source text.
	let text: String
	
	/// The declarations in the source.
	let declarations: [Declaration]
	
	/// The warnings or errors thrown by the compiler.
	let issues: [Issue]
	
	/// A warning or error thrown by the compiler.
	struct Issue : Error, Decodable {
		
		/// The relevant line.
		let line: Int
		
		/// The relevant column.
		let column: Int
		
		/// The severity of the issue.
		let severity: Severity
		enum Severity : String, Decodable {
			case warning = "source.diagnostic.severity.warning"		// TODO: Correct raw value?
			case error = "source.diagnostic.severity.error"
		}
		
		/// The compiler-provided description of the issue.
		let description: String
		
	}
	
}
