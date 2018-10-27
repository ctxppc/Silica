// Silica © 2018 Constantino Tsarouhas

extension EnumeratedTypeDeclaration : LocalisableStringEntryProvider {
	var localisableEntries: [LocalisableStringEntry] {
		
		guard accessibility >= .internal else { return [] }
		
		let nestedEntries = members.flatMap { ($0 as? LocalisableStringEntryProvider)?.localisableEntries ?? [] }
		guard conformances.contains(where: { $0.name == localisableStringProtocolName }) else { return nestedEntries }
		
		let selfEntries = elements.map { element in
			LocalisableStringEntry(
				name:		element.localisationIdentifier,
				parameters:	element.parameters.map(LocalisableStringEntry.Parameter.init(for:))
			)
		}
		
		return selfEntries + nestedEntries
		
	}
}

extension EnumeratedTypeDeclaration.CaseDeclaration.Element {
	
	/// The identifier for use in localisation tables for the element.
	var localisationIdentifier: String {
		return internalFullyQualifiedName.replacingOccurrences(of: "ViewController.", with: ".").replacingOccurrences(of: "String.", with: ".")
	}
	
}
