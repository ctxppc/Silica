// Silica © 2018 Constantino Tsarouhas

import DepthKit
import SourceKittenFramework

/// A declaration of an enumerated type, introduced by the `enum` keyword.
final class EnumeratedTypeDeclaration : TypeDeclaration {
	
	// See protocol.
	static let kind = SwiftDeclarationKind.enum
	
	// See protocol.
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: DeclarationCodingKey.self)
		try type(of: self).decodeKind(in: container)
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
	
	/// The elements declared for the enumerated type.
	var elements: AnyCollection<CaseDeclaration.Element> {
		return .init(
			members
				.lazy
				.compactMap { $0 as? CaseDeclaration }
				.flatMap { $0.elements }
		)
	}
	
	/// A collection of one or more named elements of an enumerated type, introduced by the `case` keyword and separated by a comma.
	final class CaseDeclaration : Declaration {
		
		// See protocol.
		static let kind: SwiftDeclarationKind = .enumcase

		// See protocol.
		init(from decoder: Decoder) throws {
			elements = try decoder.container(keyedBy: DeclarationCodingKey.self).decode(key: .substructure)
		}
		
		/// The case declaration's elements.
		let elements: [Element]
		
		/// An element of a case declaration.
		final class Element : NamedDeclaration {
			
			// See protocol.
			static let kind: SwiftDeclarationKind = .enumelement
			
			// See protocol.
			init(from decoder: Decoder) throws {
				let labelledName = try decoder.container(keyedBy: DeclarationCodingKey.self).decode(String.self, forKey: .name)
				if let index = labelledName.firstIndex(of: "(") {
					name = .init(labelledName.prefix(upTo: index))
					numberOfParameters = labelledName.reduce(0, { $0 + ($1 == ":" ? 1 : 0) })
				} else {
					name = labelledName
					numberOfParameters = 0
				}
			}
			
			// See protocol.
			let name: String
			
			/// The number of parameters.
			private let numberOfParameters: Int
			
			/// The element's parameters, if any.
			var parameters: [Parameter] {
				
				guard numberOfParameters > 0, let caseDeclaration = parent as? CaseDeclaration, let enumDeclaration = caseDeclaration.parent as? EnumeratedTypeDeclaration else { return [] }
				guard let elementIndex = caseDeclaration.elements.firstIndex(where: { $0 === self }) else { preconditionFailure("Element expected in parent case") }
				guard let caseIndex = enumDeclaration.members.firstIndex(where: { $0 === caseDeclaration }) else { preconditionFailure("Case member expected in parent enum") }
				
				let numberOfPrecedingParameters = caseDeclaration.elements[..<elementIndex].lazy.map { $0.numberOfParameters }.reduce(0, +)
				let caseParametersStartIndex = caseIndex + 1
				let elementParametersStartIndex = caseParametersStartIndex + numberOfPrecedingParameters
				let elementParametersEndIndex = elementParametersStartIndex + numberOfParameters
				
				return Array(enumDeclaration.members[elementParametersStartIndex..<elementParametersEndIndex]) as? [Parameter] !! "Expected \(numberOfPrecedingParameters + numberOfParameters) parameters after case"
				
			}
			
			// See protocol.
			var parent: Declaration?
			
		}
		
		// See protocol.
		weak var parent: Declaration?
		
	}
	
}
