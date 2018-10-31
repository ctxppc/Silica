// Silica © 2018 Constantino Tsarouhas

extension EnumeratedTypeDeclaration : LocalisableStringConformanceProvider {
	var localisableStringConformances: [LocalisableStringConformance] {
		
		guard accessibility >= .internal else { return [] }
		let nestedConformances = members.flatMap { ($0 as? LocalisableStringConformanceProvider)?.localisableStringConformances ?? [] }
		
		guard declaresLocalisableStringConformance else { return nestedConformances }
		
		let identifierSource = GeneratedSource.block(
			lead:	"switch self {",
			body:	elements.map { element in .singleLine("case .\(element.name):\treturn \"\(element.localisationIdentifier)\"") },
			tail:	"}"
		)
		
		let caseLines = elements.map { element -> String in
			
			let parameters = element.parameters
			if parameters.isEmpty {
				return "case .\(element.name):\treturn []"
			}
			
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
		
		let argumentSource = GeneratedSource.block(
			lead:	"switch self {",
			body:	caseLines.map { .singleLine($0) },
			tail:	"}"
		)
		
		return nestedConformances.appending(.init(
			for:				self,
			identifierSource:	identifierSource,
			argumentsSource:	argumentSource
		))
		
	}
}
