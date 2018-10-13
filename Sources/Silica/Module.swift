// Silica © 2018 Constantino Tsarouhas

import Foundation

/// A collection of source files compiled as a single module.
final class Module {
	
	/// Initialises and loads a module.
	///
	/// - Parameter url: The location of the module; it can be a single file.
	///
	/// - Throws: An error if loading a source fails.
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
	
	/// The location of the module.
	let url: URL
	
	/// The sources in the module.
	let sources: [Source]
	
	/// Returns the type declaration with given name.
	///
	/// - Parameter name: The name of the type.
	///
	/// - Returns: The declaration for the type named `name`, or `nil` if no such declaration exists in the module.
	func typeDeclaration(withName name: String) -> Declaration? {
		return sources.lazy.compactMap { source in
			source.declarations.first { declaration in
				if case .type(kind: _, name: let n, conformances: _, accessibility: _, members: _) = declaration {
					return n == name
				} else {
					return false
				}
			}
		}.first
	}
	
}
