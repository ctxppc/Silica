// Silica © 2018 Constantino Tsarouhas

extension StructureTypeDeclaration : LocalisableStringProvider {
	
	var localisableStringConformances: [LocalisableStringConformance] {
		
		guard accessibility >= .internal else { return [] }
		let nestedConformances = Array(members.lazy.compactMap { $0 as? LocalisableStringProvider }.flatMap { $0.localisableStringConformances })
		
		guard declaresLocalisableStringConformance else { return nestedConformances }
		
		return nestedConformances.appending(.init(
			for:				self,
			identifierSource:	.singleLine("return \"\(localisableStringEntry.tableEntryIdentifier)\""),
			argumentsSource:	.singleLine("return [\(propertyDeclarations.map { $0.name }.joined(separator: ", "))]")
		))
		
	}
	
	var localisableStringEntries: [LocalisableStringEntry] {
		
		guard accessibility >= .internal else { return [] }
		let nestedEntries = Array(members.lazy.compactMap { $0 as? LocalisableStringProvider }.flatMap { $0.localisableStringEntries })
		
		guard declaresLocalisableStringConformance else { return nestedEntries }
		
		return nestedEntries.appending(localisableStringEntry)
		
	}
	
	/// The localisable string entry for the structure type definition, assuming that it declares conformance to the `LocalisableString` protocol.
	private var localisableStringEntry: LocalisableStringEntry {
		return .init(for: self, parameters:	propertyDeclarations.map { .init(label: $0.name, valueType: .init(typeName: $0.valueType)) })
	}
	
}
