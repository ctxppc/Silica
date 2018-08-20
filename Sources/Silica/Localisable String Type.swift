// Silica © 2018 Constantino Tsarouhas

final class LocalisableStringType {
	
	static let localisableStringProtocolName = "LocalisableString"
	
	/// Returns all localisable string types in given declaration.
	static func types(in declaration: Declaration, fullyQualifiedNamePath: [String]) -> [LocalisableStringType] {
		switch declaration {
			
			case .type(kind: .enum, name: let name, conformances: let conformances, accessibility: let accessibility, members: let members) where conformances.contains(localisableStringProtocolName): do {
				
				guard accessibility >= .internal else { return [] }
				
				let caseNames = members.compactMap { member -> String? in
					guard case .case(name: let name) = member else { return nil }
					return name
				}
				
				guard !caseNames.isEmpty else { return [] }
				return [.init(fullyQualifiedNamePath: fullyQualifiedNamePath.appending(name), caseNames: caseNames)]
				
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
	init(fullyQualifiedNamePath: [String], caseNames: [String]) {
		self.fullyQualifiedNamePath = fullyQualifiedNamePath
		self.fullyQualifiedName = fullyQualifiedNamePath.joined(separator: ".")
		self.caseNames = caseNames
	}
	
	/// The decomposed fully qualified name of the type.
	let fullyQualifiedNamePath: [String]
	
	/// The fully qualified name of the type.
	let fullyQualifiedName: String
	
	/// The case names.
	let caseNames: [String]
	
}

extension LocalisableStringType : CustomDebugStringConvertible {
	var debugDescription: String {
		return "<Localisable string type \(fullyQualifiedName) with cases \(caseNames)>"
	}
}
