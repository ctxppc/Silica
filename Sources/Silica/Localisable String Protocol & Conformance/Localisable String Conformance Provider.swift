// Conserve © 2018 Constantino Tsarouhas

/// An instance that can provide `LocalisableString` conformances.
///
/// Types whose instances can (conditionally) provide `LocalisableString` conformances conform to this protocol.
protocol LocalisableStringConformanceProvider {
	
	/// The `LocalisableString` conformances, if any.
	var localisableStringConformances: [LocalisableStringConformance] { get }
	
}

extension LocalisableStringConformanceProvider where Self : ScopingDeclaration & AccessibleDeclaration {
	var localisableStringConformances: [LocalisableStringConformance] {
		guard accessibility >= .internal else { return [] }
		return members.flatMap { ($0 as? LocalisableStringConformanceProvider)?.localisableStringConformances ?? [] }
	}
}

extension TypeDeclaration {
	
	/// A Boolean value indicating whether the type declared by this declaration declares conformance to the `LocalisableString` protocol.
	var declaresLocalisableStringConformance: Bool {
		return conformances.contains(where: { $0.name == localisableStringProtocolName })
	}
	
}
