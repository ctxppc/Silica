// Silica © 2018 Constantino Tsarouhas

import SourceKittenFramework

/// A construct in a source.
protocol Declaration : class {
	
	/// The kind of declaration.
	static var kind: SwiftDeclarationKind { get }
	
	/// Decodes a declaration with given decoding container.
	///
	/// - Parameter container: The keyed container encoding the declaration.
	/// - Parameter parent: The parent declaration, or `nil` if the declaration is at root level in the source.
	init(from container: KeyedDecodingContainer<DeclarationCodingKey>, in parent: ScopingDeclaration?) throws
	
	/// The parent declaration, or `nil` if the declaration is at root level in the source.
	var parent: ScopingDeclaration? { get }
	
}

extension Declaration {
	
	/// The ancestor declarations of `self`, starting with the parent of `self` and ending with the root declaration in the source.
	///
	/// - Invariant: `ancestors.first === parent`.
	var ancestors: AnySequence<ScopingDeclaration> {
		guard let parent = parent else { return .init(EmptyCollection()) }
		return .init(sequence(first: parent, next: { $0.parent }))
	}
	
}
