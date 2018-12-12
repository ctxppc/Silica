// Silica © 2018 Constantino Tsarouhas

protocol TypeDeclaration : ScopingDeclaration, NamedDeclaration, AccessibleDeclaration {
	
	/// The types the type declared by `self` conforms to.
	///
	/// These are the conformances written and as written on the declaration. Conformances declared in separate extensions are not included.
	var conformances: [Conformance] { get }
	
}

extension TypeDeclaration {
	
	/// The type declaration's property declarations.
	var propertyDeclarations: [PropertyDeclaration] {
		return members.compactMap { $0 as? PropertyDeclaration }
	}
	
}

struct Conformance : Decodable {
	
	/// The name of the type being conformed to, to be evaluated in the lexical scope of the declaration declaring the conformance.
	let name: String
	
}
