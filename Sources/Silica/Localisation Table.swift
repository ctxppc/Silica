// Silica © 2018 Constantino Tsarouhas

import Foundation

final class LocalisationTable {
	
	/// An identifier for a string in a localisation table.
	typealias Identifier = String
	
	/// Loads or creates a localisation table.
	///
	/// - Parameter url: The location of the localisation table.
	/// - Parameter replacingExisting: If `false`, loads the table at `url` if it exists. The default value is `false`.
	init(at url: URL, replacingExisting: Bool = false) throws {
		self.url = url
		if replacingExisting {
			savedLocalisedStringsByIdentifier = [:]
		} else {
			do {
				var format = PropertyListSerialization.PropertyListFormat.openStep
				savedLocalisedStringsByIdentifier = try PropertyListDecoder().decode([String : String].self, from: Data(contentsOf: url), format: &format)
			} catch let error as CocoaError where error.code == .fileReadNoSuchFile {
				savedLocalisedStringsByIdentifier = [:]
			}
		}
	}
	
	/// The location of the localisation table.
	let url: URL
	
	/// The localised strings, keyed by identifier, as stored in persistent storage.
	private let savedLocalisedStringsByIdentifier: [Identifier : String]
	
	/// The localised strings, keyed by identifier, that haven't been saved to persistent storage yet.
	private var unsavedLocalisedStringsByIdentifier: [Identifier : String] = [:]
	
	/// Accesses a localised string (`nil` if not available) with given identifier.
	subscript (identifier: String) -> String? {
		get { return unsavedLocalisedStringsByIdentifier[identifier] ?? savedLocalisedStringsByIdentifier[identifier] }
		set { unsavedLocalisedStringsByIdentifier[identifier] = newValue }
	}
	
	/// Whether the table has been saved before.
	private(set) var hasBeenSaved: Bool = false
	
	/// Writes the localised strings to disk.
	///
	/// This method must be invoked at most once.
	func save() throws {
		
		precondition(!hasBeenSaved, "Table has already been saved before; create a new instance")
		
		func escaped(_ string: String) -> String {
			return string.replacingOccurrences(of: "\"", with: "\\\"")
		}
		
		var lines = ""
		func append(identifier: Identifier, value: String, unused: Bool = false) {
			lines += "\"\(escaped(identifier))\" = \"\(escaped(value))\";\(unused ? "\t/* unused */" : "")\n\n"
		}
		
		for (identifier, value) in unsavedLocalisedStringsByIdentifier.sorted(by: { $0.0 < $1.0 }) {
			append(identifier: identifier, value: value)
		}
		
		for (identifier, value) in savedLocalisedStringsByIdentifier.sorted(by: { $0.0 < $1.0 }) where value != "" && !unsavedLocalisedStringsByIdentifier.keys.contains(identifier) {
			append(identifier: identifier, value: value, unused: true)
		}
		
		try """
		/* This file has been generated by Silica. Do not edit this file manually. */

		\(lines)
		""".write(to: url, atomically: false, encoding: .utf8)
		
		hasBeenSaved = true
		
	}
	
}
