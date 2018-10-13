// Silica © 2018 Constantino Tsarouhas

/// A declaration that introduces scope and can contain declarations.
protocol ScopingDeclaration : Declaration {
	
	/// The name by which scoped declarations can be qualified by.
	///
	/// This is typically the declaration's name for named declarations.
	var qualifyingName: String { get }
	
	/// The declarations scoped within `self`.
	var children: [Declaration] { get }
	
}

extension ScopingDeclaration where Self : NamedDeclaration {
	var qualifyingName: String {
		return name
	}
}
