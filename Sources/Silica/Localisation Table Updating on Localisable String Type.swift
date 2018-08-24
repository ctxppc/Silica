// Silica © 2018 Constantino Tsarouhas

import Foundation

extension LocalisableStringType {
	
	/// Updates given localisation table with the localisation identifiers declared by the localisable string type.
	///
	/// - Parameter localisationTable: The localisation table to update.
	/// - Parameter usingCommonDomain: `true` if all string types use a common domain, or `false` if the string type defines its own domain.
	func update(_ localisationTable: LocalisationTable, usingCommonDomain: Bool) {
		for c in cases {
			let identifier = c.localisationIdentifier(withDomain: usingCommonDomain ? shortenedFullyQualifiedName : nil)
			localisationTable[identifier] = localisationTable[identifier] ?? ""
		}
	}
	
}
