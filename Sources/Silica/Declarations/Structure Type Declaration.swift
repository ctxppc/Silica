// Silica © 2018 Constantino Tsarouhas

import DepthKit
import SourceKittenFramework

final class StructureTypeDeclaration : ScopingDeclaration, NamedDeclaration {
	
	// See protocol.
	static let kind = SwiftDeclarationKind.struct
	
	// See protocol.
	init(from container: KeyedDecodingContainer<DeclarationCodingKey>, in parent: ScopingDeclaration?) throws {
		
		self.name = try container.decode(key: .name)
		self.parent = parent
		
		TODO.unimplemented
		
	}
	
	// See protocol.
	let name: String
	
	// See protocol.
	unowned let source: Source
	
	// See protocol.
	weak var parent: ScopingDeclaration?
	
	// See protocol.
	var children: [Declaration]
	
}
