// Silica © 2018 Constantino Tsarouhas

final class LocalisableStringType {
	
	static let localisableStringProtocolName = "LocalisableString"
	
	/// Returns all localisable string types in given declaration.
	static func types(in declaration: Declaration, fullyQualifiedNamePath: [String]) -> [LocalisableStringType] {
		switch declaration {
			
			case .type(kind: .enum, name: let name, conformances: let conformances, accessibility: let accessibility, members: let members) where conformances.contains(localisableStringProtocolName): do {
				
				guard accessibility >= .internal else { return [] }
				
				let cases = members.compactMap { member -> Case? in
					guard case .case(name: let name, parameters: let parameters) = member else { return nil }
					return Case(name: name, parameters: parameters)
				}
				
				guard !cases.isEmpty else { return [] }
				return [.init(fullyQualifiedNamePath: fullyQualifiedNamePath.appending(name), cases: cases)]
				
			}
			
			case .type(kind: _, name: let name, conformances: _, accessibility: let accessibility, members: let members):
			guard accessibility >= .internal else { return [] }
			return members.flatMap { types(in: $0, fullyQualifiedNamePath: fullyQualifiedNamePath.appending(name)) }
			
			case .extension(extendedType: let name, conformances: _, members: let members):
			return members.flatMap { types(in: $0, fullyQualifiedNamePath: fullyQualifiedNamePath.appending(name)) }
			
			default:
			return []
			
		}
	}
	
	/// Returns all localisable string types in given source.
	static func types(in source: Source) -> [LocalisableStringType] {
		return source.declarations.flatMap {
			types(in: $0, fullyQualifiedNamePath: [])
		}
	}
	
	/// Creates a localisable string type.
	init(fullyQualifiedNamePath: [String], cases: [Case]) {
		self.fullyQualifiedNamePath = fullyQualifiedNamePath
		self.fullyQualifiedName = fullyQualifiedNamePath.joined(separator: ".")
		self.cases = cases
	}
	
	/// The decomposed fully qualified name of the type.
	let fullyQualifiedNamePath: [String]
	
	/// The fully qualified name of the type.
	let fullyQualifiedName: String
	
	/// The cases.
	let cases: [Case]
	struct Case {
		let name: String
		let parameters: [Declaration.Parameter]
	}
	
}

extension LocalisableStringType : CustomDebugStringConvertible {
	var debugDescription: String {
		return "<Localisable string type \(fullyQualifiedName) with cases \(cases)>"
	}
}
