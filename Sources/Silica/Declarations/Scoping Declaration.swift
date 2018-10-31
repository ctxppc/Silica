// Silica © 2018 Constantino Tsarouhas

/// A declaration that introduces scope and can contain declarations.
protocol ScopingDeclaration : Declaration {
	
	/// The declarations scoped within `self`.
	///
	/// - Invariant: For each member `m` in `members`, `m.parent === self`.
	var members: [Declaration] { get }
	
}
