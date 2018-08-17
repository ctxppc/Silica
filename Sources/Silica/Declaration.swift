// Silica © 2018 Constantino Tsarouhas

import Foundation
import DepthKit
import SourceKittenFramework

enum Declaration : Decodable {
	
	/// The declaration is a type of some kind.
	case type(kind: TypeKind, name: String, accessibility: Accessibility, members: [Declaration])
	enum TypeKind {
		case `struct`
		case `enum`
		case `class`
	}
	
	/// The declaration is an extension.
	case `extension`(extendedType: String, protocols: [String], accessibility: Accessibility, members: [Declaration])
	
	/// The declaration is a protocol.
	case `protocol`(name: String, accessibility: Accessibility, members: [Declaration])
	
	/// The declaration is a case in an `enum` declaration.
	case `case`(name: String)
	
	case function(name: String, accessibility: Accessibility)
	
	init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKey.self)
		
		func type(kind: TypeKind) throws -> Declaration {
			return try .type(
				kind:			kind,
				name:			container.decode(key: .name),
				accessibility:	container.decode(key: .accessibility),
				members:		[]	// TODO
			)
		}
		
		let kindIdentifier = try container.decode(String.self, forKey: .kind)
		guard let kind = SwiftDeclarationKind(rawValue: kindIdentifier) else { throw DecodingError.unknownKind(rawValue: kindIdentifier) }
		switch kind {
			case .struct:		self = try type(kind: .struct)
			case .enum:			self = try type(kind: .enum)
			case .class:		self = try type(kind: .class)
			case .enumcase:		self = try .case(name: container.decode(key: .name))
			case .extension:	self = try .extension(extendedType: container.decode(key: .name), protocols: [], accessibility: container.decode(key: .accessibility), members: [])		// TODO
			case let other:		throw DecodingError.unsupportedKind(other)
		}
		
	}
	
	enum Accessibility : String, Codable {
		case `open` = "source.lang.swift.accessibility.open"
		case `public` = "source.lang.swift.accessibility.public"
		case `internal` = "source.lang.swift.accessibility.internal"
		case `fileprivate` = "source.lang.swift.accessibility.fileprivate"
		case `private` = "source.lang.swift.accessibility.private"
	}
	
	enum CodingKey : Swift.CodingKey {
		case name
		case kind
		case accessibility
		case substructure
	}
	
	enum DecodingError : Error {
		
		/// The declaration is of an unknown kind.
		case unknownKind(rawValue: String)
		
		/// The declaration is of a kind not supported by Silica.
		case unsupportedKind(SwiftDeclarationKind)
		
	}
	
}
