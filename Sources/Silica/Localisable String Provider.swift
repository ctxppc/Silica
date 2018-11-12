// Conserve © 2018 Constantino Tsarouhas

/// An instance that can provide `LocalisableString` conformances and localisable string entries.
///
/// Types whose instances can (conditionally) provide `LocalisableString` conformances and localisable string entries conform to this protocol.
protocol LocalisableStringProvider {
	
	/// The `LocalisableString` conformances, if any.
	var localisableStringConformances: [LocalisableStringConformance] { get }
	
	/// The generated localisable entries, if any.
	var localisableStringEntries: [LocalisableStringEntry] { get }
	
}

extension LocalisableStringProvider where Self : ScopingDeclaration & AccessibleDeclaration {
	
	var localisableStringConformances: [LocalisableStringConformance] {
		guard accessibility >= .internal else { return [] }
		return members.flatMap { ($0 as? LocalisableStringProvider)?.localisableStringConformances ?? [] }
	}
	
	var localisableStringEntries: [LocalisableStringEntry] {
		guard accessibility >= .internal else { return [] }
		return members.flatMap { ($0 as? LocalisableStringProvider)?.localisableStringEntries ?? [] }
	}
	
}

extension TypeDeclaration {
	
	/// A Boolean value indicating whether the type declared by this declaration declares conformance to the `LocalisableString` protocol.
	var declaresLocalisableStringConformance: Bool {
		return conformances.contains(where: { $0.name == localisableStringProtocolName })
	}
	
}
