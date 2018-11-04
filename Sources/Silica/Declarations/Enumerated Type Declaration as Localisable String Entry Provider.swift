// Silica © 2018 Constantino Tsarouhas

extension EnumeratedTypeDeclaration : LocalisableStringEntryProvider {
	var localisableEntries: [LocalisableStringEntry] {
		
		guard accessibility >= .internal else { return [] }
		
		let nestedEntries = members.flatMap { ($0 as? LocalisableStringEntryProvider)?.localisableEntries ?? [] }
		if conformances.contains(where: { $0.name == localisableStringProtocolName }) {
			return elements.map(LocalisableStringEntry.init(for:)) + nestedEntries
		} else {
			return nestedEntries
		}
		
	}
}
