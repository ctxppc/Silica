// Silica © 2018 Constantino Tsarouhas

import DepthKit
import SourceKittenFramework

/// A declaration of a class, introduced by the `class` keyword.
final class ClassDeclaration : TypeDeclaration {
	
	// See protocol.
	static let kind = SwiftDeclarationKind.class
	
	// See protocol.
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: DeclarationCodingKey.self)
		name = try container.decode(key: .name)
		accessibility = try container.decode(key: .accessibility)
		conformances = try container.decode(key: .inheritedTypes)
		members = try container.decode([AnyDeclaration].self, forKey: .substructure).compactMap { $0.base }
		members.bind(toParent: self)
	}
	
	// See protocol.
	let name: String
	
	// See protocol.
	let accessibility: DeclarationAccessibility
	
	// See protocol.
	let conformances: [Conformance]
	
	// See protocol.
	weak var parent: Declaration?
	
	// See protocol.
	let members: [Declaration]
	
}
