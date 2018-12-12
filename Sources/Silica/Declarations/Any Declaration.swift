// Silica © 2018 Constantino Tsarouhas

import SourceKittenFramework

/// A type-erased declaration.
struct AnyDeclaration : Decodable {
	
	private static let declarationTypes: [Declaration.Type] = [
		StructureTypeDeclaration.self,
		EnumeratedTypeDeclaration.self,
		EnumeratedTypeDeclaration.CaseDeclaration.self,
		ClassDeclaration.self,
		Parameter.self,
		PropertyDeclaration.self
	]
	
	init(from decoder: Decoder) throws {
		
		for type in AnyDeclaration.declarationTypes {
			do {
				base = try type.init(from: decoder)
				return
			} catch DeclarationDecodingError.incorrectKind {
				continue
			} catch DeclarationDecodingError.unsupportedKind {
				break
			} catch Parameter.DecodingError.unsupportedParameter {
				break
			}
		}
		
		base = nil
		
	}
	
	/// The declaration, if any.
	let base: Declaration?
	
}
