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
		name = try container.decodeIfPresent(key: .name)
		guard let argumentType = try container.decodeIfPresent(String.self, forKey: .typeName) else { throw DecodingError.unsupportedParameter }
		self.argumentType = argumentType
	}
	
	/// The type of the parameter, or `nil` if the parameter is unnamed.
	///
	/// The argument can have a name that differs from the parameter's name.
	let name: String?
	
	/// The type of the arguments.
	let argumentType: String
	
	// See protocol.
	var parent: Declaration?
	
	enum DecodingError : Error {
		
		/// The parameter cannot be decoded because it's of an unsupported format.
		case unsupportedParameter
		
	}
	
}
