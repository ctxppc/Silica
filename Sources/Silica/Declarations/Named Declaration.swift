// Silica © 2018 Constantino Tsarouhas

/// A declaration that can be referred to by name.
protocol NamedDeclaration : Declaration {
	
	/// The name by which the declaration can be referred to.
	var name: String { get }
	
	/// The declaration's fully-qualified name within its module.
	///
	/// The localised qualified name includes the name of any ancestors but not the module name.
	var localQualifiedName: String { get }
	
}

extension NamedDeclaration {
	var localQualifiedName: String {
		return "\(ancestors.map { $0.qualifyingName }.joined(separator: ".")).\(name)"
	}
}
