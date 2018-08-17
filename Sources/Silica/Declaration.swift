// Silica © 2018 Constantino Tsarouhas

import Foundation
import DepthKit
import SourceKittenFramework

enum Declaration : Decodable {
	
	/// The declaration is a type of some kind.
	///
	/// - Parameter kind: The kind of type being declared.
	/// - Parameter name: The name of the type.
	/// - Parameter conformances: The name of the protocols that the type is declaring conformance to, if any.
	/// - Parameter accessibility: The access level of the declaration.
	/// - Parameter extendedType: The type declaration's members.
	case type(kind: TypeKind, name: String, conformances: [String], accessibility: Accessibility, members: [Declaration])
	enum TypeKind {
		case `struct`
		case `enum`
		case `class`
	}
	
	/// The declaration is an extension.
	///
	/// - Parameter extendedType: The name of the type being extended.
	/// - Parameter conformances: The name of the protocols that the extension is declaring conformance to, if any.
	/// - Parameter extendedType: The extension's members.
	case `extension`(extendedType: String, conformances: [String], members: [Declaration])
	
	/// The declaration is a protocol.
	///
	/// - Parameter name: The protocol's name.
	/// - Parameter accessibility: The access level of the declaration.
	/// - Parameter members: The protocol's requirements, if any.
	case `protocol`(name: String, accessibility: Accessibility, members: [Declaration])
	
	/// The declaration is a case in an `enum` declaration.
	///
	/// - Parameter name: The case's base name.
	case `case`(name: String)
	
	/// The declaration is a function.
	///
	/// - Parameter name: The function name (including argument labels).
	/// - Parameter accessibility: The access level of the declaration.
	case function(name: String, accessibility: Accessibility)
	
	/// The declaration is of a kind not supported by Silica.
	///
	/// - Parameter name: The declaration's name, or `nil` if it doesn't have one.
	/// - Parameter kind: The kind of declaration.
	case other(name: String?, kind: SwiftDeclarationKind)
	
	/// The object is not a declaration.
	///
	/// - Parameter kindIdentifier: The identifier of the kind of object.
	case nondeclaration(kindIdentifier: String)		// TODO: This case is a stopgap measure. Replace/remove it when expressions and statements are implemented.
	
	// See protocol.
	init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKey.self)
		
		func members() throws -> [Declaration] {
			return try container.decodeIfPresent(key: .substructure) ?? []
		}
		
		func conformances() throws -> [String] {
			
			struct Conformance : Decodable {
				let name: String
			}
			
			guard let conformances = try container.decodeIfPresent([Conformance].self, forKey: .inheritedTypes) else { return [] }
			return conformances.map { $0.name }
			
		}
		
		func type(kind: TypeKind) throws -> Declaration {
			return try .type(
				kind:			kind,
				name:			container.decode(key: .name),
				conformances:	conformances(),
				accessibility:	container.decode(key: .accessibility),
				members:		members()
			)
		}
		
		func caseName() throws -> String {
			
			struct Element : Decodable {
				let name: String
			}
			
			return try container.decode([Element].self, forKey: .substructure)[0].name	// TODO: Add support for multiple elements per `case`
			
		}
		
		let kindIdentifier = try container.decode(String.self, forKey: .kind)
		switch SwiftDeclarationKind(rawValue: kindIdentifier) {
			case .struct?:			self = try type(kind: .struct)
			case .enum?:			self = try type(kind: .enum)
			case .class?:			self = try type(kind: .class)
			case .enumcase?:		self = try .case(name: caseName())
			case .extension?:		self = try .extension(extendedType: container.decode(key: .name), conformances:	conformances(), members: members())
			case .protocol?:		self = try .protocol(name: container.decode(key: .name), accessibility: container.decode(key: .accessibility), members: members())
			case .functionFree?:	self = try .function(name: container.decode(key: .name), accessibility: container.decode(key: .accessibility))
			case let kind?:			self = try .other(name: container.decodeIfPresent(key: .name), kind: kind)
			case nil:				self = .nondeclaration(kindIdentifier: kindIdentifier)
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
		case inheritedTypes
	}
	
}
