// Silica © 2018 Constantino Tsarouhas

extension EnumeratedTypeDeclaration : LocalisableStringEntryProvider {
	var localisableEntries: [LocalisableEntry] {
		
		guard accessibility >= .internal else { return [] }
		
		let nestedEntries = members.flatMap { ($0 as? LocalisableStringEntryProvider)?.localisableEntries ?? [] }
		guard conformances.contains(where: { $0.name == localisableStringProtocolName }) else { return nestedEntries }
		
		let selfEntries = elements.map { element in
			LocalisableEntry(
				name:		element.internalFullyQualifiedName.replacingOccurrences(of: "ViewController.", with: ".").replacingOccurrences(of: "String.", with: "."),
				parameters:	element.parameters.map(LocalisableEntry.Parameter.init(for:))
			)
		}
		
		return selfEntries + nestedEntries
		
	}
}
