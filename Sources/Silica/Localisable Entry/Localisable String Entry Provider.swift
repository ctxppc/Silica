// Silica © 2018 Constantino Tsarouhas

/// An instance that can provide localisable entries.
///
/// Types whose instances can (conditionally) provide localisable entries conform to this protocol.
protocol LocalisableStringEntryProvider {
	
	/// The generated localisable entries, if any.
	var localisableEntries: [LocalisableStringEntry] { get }
	
}

extension LocalisableStringEntryProvider where Self : ScopingDeclaration & AccessibleDeclaration {
	var localisableEntries: [LocalisableStringEntry] {
		guard accessibility >= .internal else { return [] }
		return members.flatMap { ($0 as? LocalisableStringEntryProvider)?.localisableEntries ?? [] }
	}
}
