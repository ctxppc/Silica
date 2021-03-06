// Silica © 2018 Constantino Tsarouhas

/// A declaration that can be referred to by name.
protocol NamedDeclaration : Declaration {
	
	/// The name by which the declaration can be referred to.
	var name: String { get }
	
	/// The declaration's fully-qualified name within its module.
	///
	/// The localised qualified name includes the name of any ancestors but not the module name.
	var internalFullyQualifiedName: String { get }
	
}

extension NamedDeclaration {
	var internalFullyQualifiedName: String {
		return ancestors.reversed().compactMap { ($0 as? NamedDeclaration)?.name }.appending(name).joined(separator: ".")
	}
}
