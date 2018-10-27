// Silica © 2018 Constantino Tsarouhas

import SourceKittenFramework

/// A parameter of a function or case.
final class Parameter : Declaration {
	
	// See protocol.
	static let kind = SwiftDeclarationKind.varParameter
	
	// See protocol.
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: DeclarationCodingKey.self)
		try type(of: self).decodeKind(in: container)
		name = try container.decode(key: .name)
		argumentType = try container.decode(key: .typeName)
	}
	
	/// The type of the parameter, or `nil` if the parameter is unnamed.
	///
	/// The argument can have a name that differs from the parameter's name.
	let name: String?
	
	/// The type of the arguments.
	let argumentType: String
	
	// See protocol.
	var parent: Declaration?
	
}
