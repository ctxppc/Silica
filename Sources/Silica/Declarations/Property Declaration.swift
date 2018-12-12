// Silica © 2018 Constantino Tsarouhas

import SourceKittenFramework

final class PropertyDeclaration : Declaration {
	
	// See protocol.
	static let kind = SwiftDeclarationKind.varInstance
	
	// See protocol.
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: DeclarationCodingKey.self)
		try type(of: self).decodeKind(in: container)
		name = try container.decode(key: .name)
		valueType = try container.decodeIfPresent(String.self, forKey: .typeName)
	}
	
	/// The name of the property.
	let name: String
	
	/// The type of the values the property holds, or `nil` if the type is inferred.
	let valueType: String?
	
	// See protocol.
	var parent: Declaration?
	
}
