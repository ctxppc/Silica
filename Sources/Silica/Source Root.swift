// Silica © 2018 Constantino Tsarouhas

import Foundation

/// A directory containing Swift source files.
final class SourceRoot {
	
	/// Initialises and loads a source root.
	///
	/// The root is searched recursively if it is a directory. The root can also be a source file.
	///
	/// - Parameter url: The location of the root.
	///
	/// - Throws: An error if searching the root or loading a source fails.
	init(at url: URL) throws {
		
		self.url = url
		
		if try Source.isSource(at: url) {
			sources = [try Source(at: url)]
			return
		}
		
		var enumerationError: Error?
		let enumerator = FileManager.default.enumerator(
			at: url,
			includingPropertiesForKeys: [.typeIdentifierKey],
			options: [.skipsPackageDescendants],
			errorHandler: { _, error in
				enumerationError = error
				return false
			}
		)
		
		guard let urls = enumerator else {
			sources = []
			return
		}
		
		sources = try urls.compactMap { url in
			let url = url as! URL
			return try Source.isSource(at: url) ? Source(at: url) : nil
		}
		
		if let error = enumerationError {
			throw error
		}
		
	}
	
	/// The location of the root.
	let url: URL
	
	/// The sources in the source root.
	let sources: [Source]
	
}
