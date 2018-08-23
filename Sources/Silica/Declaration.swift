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
	/// - Parameter name: The case's parameters.
	case `case`(name: String, parameters: [Parameter])
	struct Parameter {
		let name: String?
		let type: String
	}
	
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
		try self.init(from: decoder.container(keyedBy: CodingKey.self))
	}
	
	private init(from container: KeyedDecodingContainer<CodingKey>) throws {
		
		func members() throws -> [Declaration] {
			
			guard container.contains(.substructure) else { return [] }
			var containerOfMembers = try container.nestedUnkeyedContainer(forKey: .substructure)
			
			var members: [Declaration] = []
			while !containerOfMembers.isAtEnd {
				let containerForMember = try containerOfMembers.nestedContainer(keyedBy: CodingKey.self)
				if case .enumcase? = SwiftDeclarationKind(rawValue: try containerForMember.decode(key: .kind)) {
					var containerOfCaseElements = try containerForMember.nestedUnkeyedContainer(forKey: .substructure)
					while !containerOfCaseElements.isAtEnd {
						
						let containerForCaseElement = try containerOfCaseElements.nestedContainer(keyedBy: CodingKey.self)
						let labelledName = try containerForCaseElement.decode(String.self, forKey: .name)
						let numberOfParameters = labelledName.reduce(0, { $0 + ($1 == ":" ? 1 : 0) })
						
						let parameters = try (0..<numberOfParameters).map { index -> Parameter in
							let containerForParameter = try containerOfMembers.nestedContainer(keyedBy: CodingKey.self)
							let name = try containerForParameter.decodeIfPresent(String.self, forKey: .name)
							let kind = SwiftDeclarationKind(rawValue: try containerForParameter.decode(key: .kind))
							guard case .varParameter? = kind else { throw DecodingError.noCaseParameter(labelledCaseName: labelledName, parameterIndex: index, actualKind: kind, actualName: name, codingPath: containerForParameter.codingPath) }
							return .init(name: name, type: try containerForParameter.decode(key: .typeName))
						}
						
						guard let baseName = labelledName.split(separator: "(", maxSplits: 1, omittingEmptySubsequences: true).first else { throw DecodingError.emptyName(kind: SwiftDeclarationKind.enumelement, codingPath: containerForCaseElement.codingPath) }
						
						members.append(.case(name: .init(baseName), parameters: parameters))
						
					}
				} else {
					members.append(try .init(from: containerForMember))
				}
			}
			
			return members
			
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
		
		let kindIdentifier = try container.decode(String.self, forKey: .kind)
		switch SwiftDeclarationKind(rawValue: kindIdentifier) {
			case .struct?:			self = try type(kind: .struct)
			case .enum?:			self = try type(kind: .enum)
			case .class?:			self = try type(kind: .class)
			case .extension?:		self = try .extension(extendedType: container.decode(key: .name), conformances:	conformances(), members: members())
			case .protocol?:		self = try .protocol(name: container.decode(key: .name), accessibility: container.decode(key: .accessibility), members: members())
			case .functionFree?:	self = try .function(name: container.decode(key: .name), accessibility: container.decode(key: .accessibility))
			case let kind?:			self = try .other(name: container.decodeIfPresent(key: .name), kind: kind)
			case nil:				self = .nondeclaration(kindIdentifier: kindIdentifier)
		}
		
	}
	
	enum Accessibility : String, Codable, Equatable, CaseIterable {
		case `private` = "source.lang.swift.accessibility.private"
		case `fileprivate` = "source.lang.swift.accessibility.fileprivate"
		case `internal` = "source.lang.swift.accessibility.internal"
		case `public` = "source.lang.swift.accessibility.public"
		case `open` = "source.lang.swift.accessibility.open"
	}
	
	enum CodingKey : Swift.CodingKey {
		case name
		case kind
		case accessibility
		case substructure
		case inheritedTypes
		case typeName
	}
	
	enum DecodingError : Error, CustomStringConvertible {
		
		/// A parameter declaration was expected after the case containing a case element with associated values but got a different kind of declaration instead.
		///
		/// - Parameter labelledCaseName: The labelled name of the case for which a parameter was expected.
		/// - Parameter parameterIndex: The index of the parameter that couldn't be decoded.
		/// - Parameter actualKind: The kind of the declaration that was expected to be a parameter, or `nil` if not available.
		/// - Parameter actualName: The name of the declaration that was expected to be a parameter, or `nil` if it is nameless.
		/// - Parameter codingPath: The coding path of the declaration that was expected to be a parameter.
		case noCaseParameter(labelledCaseName: String, parameterIndex: Int, actualKind: SwiftDeclarationKind?, actualName: String?, codingPath: [Swift.CodingKey])
		
		/// A declaration's name is empty.
		///
		/// - Parameter kind: The kind of the declaration.
		/// - Parameter codingPath: The coding path of the declaration.
		case emptyName(kind: SwiftDeclarationKind, codingPath: [Swift.CodingKey])
		
		// See protocol.
		var description: String {
			switch self {
				
				case .noCaseParameter(labelledCaseName: let caseName, parameterIndex: let index, actualKind: let kind, actualName: let actualName, codingPath: let path):
				return "parameter declaration expected at for parameter \(index) for case \(caseName) at \(path.description); got \(actualName ?? "(no name)") of kind \(kind?.rawValue ?? "(no kind)") instead"
				
				case .emptyName(kind: let kind, codingPath: let path):
				return "nonempty name expected for declaration of kind \(kind) at \(path.description)"
				
			}
		}
		
	}
	
}

extension Declaration.Accessibility : Comparable {
	static func < (smaller: Declaration.Accessibility, greater: Declaration.Accessibility) -> Bool {
		return allCases.index(of: smaller)! < allCases.index(of: greater)!
	}
}

extension Array where Element == CodingKey {
	var description: String {
		return map { $0.intValue.flatMap(String.init) ?? $0.stringValue }.joined(separator: "/")
	}
}
