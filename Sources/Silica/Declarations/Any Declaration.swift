// Silica © 2018 Constantino Tsarouhas

import SourceKittenFramework

/// A type-erased declaration.
struct AnyDeclaration : Decodable {
	
	private static let declarationTypes: [Declaration.Type] = [
		StructureTypeDeclaration.self,
		EnumeratedTypeDeclaration.self,
		EnumeratedTypeDeclaration.CaseDeclaration.self,
		ClassDeclaration.self,
		Parameter.self
	]
	
	init(from decoder: Decoder) throws {
		let kind = try decoder.container(keyedBy: DeclarationCodingKey.self).decode(SwiftDeclarationKind.self, forKey: .kind)
		base = try AnyDeclaration.declarationTypes.first(where: { type in type.kind == kind })?.init(from: decoder)
	}
	
	/// The declaration, if any.
	let base: Declaration?
	
}
