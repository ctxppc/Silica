// Silica © 2018 Constantino Tsarouhas

import Foundation

final class Source {
	
	/// Creates and loads a source from a file at a given location.
	///
	/// - Parameter url: The location of the source file.
	///
	/// - Throws: An error if loading the source fails.
	init(at url: URL) throws {
		self.url = url
		text = try String(contentsOf: url)
	}
	
	/// The location of the source file.
	let url: URL
	
	/// The source text.
	let text: String
	
}
