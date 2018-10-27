// Silica © 2018 Constantino Tsarouhas

import SourceKittenFramework

/// A construct in a source.
protocol Declaration : class, Decodable {
	
	/// The kind of declaration.
	static var kind: SwiftDeclarationKind { get }
	
	/// The parent declaration, or `nil` if the declaration is at root level in the source.
	///
	/// If a declaration has a parent, that parent is the sole owner of the declaration.
	///
	/// The parent defines the exact parent-child semantics for this property and is thus responsible for setting this property.
	var parent: Declaration? { get set }
	
}

extension Declaration {
	
	/// Decodes the kind in the container and throws an error if it doesn't match `kind`.
	static func decodeKind(in container: KeyedDecodingContainer<DeclarationCodingKey>) throws {
		let encodedKind = try container.decode(SwiftDeclarationKind.self, forKey: .kind)
		if encodedKind != kind {
			throw DeclarationDecodingError.incorrectKind(encodedKind, expected: kind)
		}
	}
	
	/// The ancestor declarations of `self`, starting with the parent of `self` and ending with the root declaration in the source.
	///
	/// - Invariant: `ancestors.first === parent`.
	var ancestors: AnySequence<Declaration> {
		guard let parent = parent else { return .init(EmptyCollection()) }
		return .init(sequence(first: parent, next: { $0.parent }))
	}
	
}

enum DeclarationDecodingError : Error {
	
	/// The container encodes a different kind of declaration than the one expected by `Self`.
	case incorrectKind(SwiftDeclarationKind, expected: SwiftDeclarationKind)
	
}

extension Sequence where Self.Element == Declaration {
	
	/// Assigns `parent` as the parent of the declarations in `self`.
	///
	/// - Parameter parent: The (new) parent of the declarations in `self`.
	func bind(toParent parent: Declaration) {
		for child in self {
			child.parent = parent
		}
	}
	
}
