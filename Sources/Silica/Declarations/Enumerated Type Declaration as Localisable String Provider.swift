// Silica © 2018 Constantino Tsarouhas

extension EnumeratedTypeDeclaration : LocalisableStringProvider {
	
	var localisableStringConformances: [LocalisableStringConformance] {
		
		guard accessibility >= .internal else { return [] }
		let nestedConformances = members.flatMap { ($0 as? LocalisableStringProvider)?.localisableStringConformances ?? [] }
		
		guard declaresLocalisableStringConformance else { return nestedConformances }
		
		let identifierSource = GeneratedSource.block(
			lead:	"switch self {",
			body:	elements.map { element in .singleLine("case .\(element.name):\treturn \"\(LocalisableStringEntry(for: element).rawValue)\"") },
			tail:	"}"
		)
		
		var hasParameters = false
		
		let argumentCases = elements.map { element -> String in
			
			let parameters = element.parameters
			if parameters.isEmpty {
				return "case .\(element.name):\treturn []"
			}
			
			hasParameters = true
			
			let parameterPairs: [(pattern: String, argument: String)] = zip(parameters, 0...).map {
				let (parameter, index) = $0
				if let name = parameter.name {
					return ("\(name): let \(name)", name)
				} else {
					return ("let v\(index)", "v\(index)")
				}
			}
			
			let patternParameterList = parameterPairs.map { $0.pattern }.joined(separator: ", ")
			let argumentList = parameterPairs.map { $0.argument }.joined(separator: ", ")
			
			let pattern = ".\(element.name)(\(patternParameterList))"
			let statement = "return [\(argumentList)]"
			
			return "case \(pattern):\t\(statement)"
			
		}
		
		let argumentSource = hasParameters ? GeneratedSource.block(
			lead:	"switch self {",
			body:	argumentCases.map { .singleLine($0) },
			tail:	"}"
		) : .singleLine("return []")
		
		return nestedConformances.appending(.init(
			for:				self,
			identifierSource:	identifierSource,
			argumentsSource:	argumentSource
		))
		
	}
	
	var localisableStringEntries: [LocalisableStringEntry] {
		
		guard accessibility >= .internal else { return [] }
		
		let nestedEntries = members.flatMap { ($0 as? LocalisableStringProvider)?.localisableStringEntries ?? [] }
		if conformances.contains(where: { $0.name == localisableStringProtocolName }) {
			return elements.map(LocalisableStringEntry.init(for:)) + nestedEntries
		} else {
			return nestedEntries
		}
		
	}
	
}
