// Silica © 2018 Constantino Tsarouhas

final class LocalisableStringType {
	
	static let protocolName = "LocalisableString"
	
	/// Returns all localisable string types in given declaration.
	static func types(in declaration: Declaration, fullyQualifiedNamePath: [String]) -> [LocalisableStringType] {
		switch declaration {
			
			case .type(kind: .enum, name: let name, conformances: let conformances, accessibility: let accessibility, members: let members) where conformances.contains(protocolName): do {
				
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
		
		fullyQualifiedName = fullyQualifiedNamePath.joined(separator: ".")
		shortenedFullyQualifiedName = fullyQualifiedNamePath.map {
			$0.replacingOccurrences(of: "ViewController", with: "", options: [.anchored, .backwards]).replacingOccurrences(of: "String", with: "", options: [.anchored, .backwards])
		}.joined(separator: ".")
		
		self.cases = cases
		
	}
	
	/// The fully qualified name of the type.
	let fullyQualifiedName: String
	
	/// The fully qualified name of the type with "ViewController" and "String" suffixes removed.
	let shortenedFullyQualifiedName: String
	
	/// The cases.
	let cases: [Case]
	struct Case {
		
		/// The base name of the case.
		let name: String
		
		/// The parameters of the associated values, if any.
		let parameters: [Parameter]
		
		/// The identifier used for localisation, including any placeholders for parameters.
		///
		/// - Parameter domain: The domain to include in the identifier, or `nil` to produce an unqualified identifier.
		func localisationIdentifier(withDomain domain: String?) -> String {
			
			func placeholder(for parameter: Parameter) -> String {
				switch parameter.argumentType {
					case "Int":		return "%ld"
					case "Double":	return "%f"
					default:		return "%@"
				}
			}
			
			let parameterList: String = parameters.map { parameter in
				if let name = parameter.name {
					return "\(name): \(placeholder(for: parameter))"
				} else {
					return placeholder(for: parameter)
				}
			}.joined(separator: ", ")
			
			let unqualifiedIdentifier = parameters.isEmpty ? name : "\(name)(\(parameterList))"
			
			if let domain = domain {
				return "\(domain).\(unqualifiedIdentifier)"
			} else {
				return unqualifiedIdentifier
			}
			
		}
		
	}
	
}

extension LocalisableStringType : CustomDebugStringConvertible {
	var debugDescription: String {
		return "<Localisable string type \(fullyQualifiedName) with cases \(cases)>"
	}
}
