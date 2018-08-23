// Silica © 2018 Constantino Tsarouhas

extension LocalisableStringType {
	
	/// Returns Swift source text containing generated conformances for the localisable string type.
	func generatedConformance(indentation: String = "\t") -> String {
		
		let identifierSwitchBody = cases.map { c -> String in
			
			func placeholder(for parameter: Declaration.Parameter) -> String {
				switch parameter.type {
					case "Int":		return "%ld"
					case "Double":	return "%f"
					default:		return "%@"
				}
			}
			
			let parameterList: String = c.parameters.map { parameter in
				if let name = parameter.name {
					return "\(name): \(placeholder(for: parameter))"
				} else {
					return placeholder(for: parameter)
				}
			}.joined(separator: ", ")
			
			let identifierValue: String
			if c.parameters.isEmpty {
				identifierValue = c.name
			} else {
				identifierValue = "\(c.name)(\(parameterList))"
			}
			
			return "\(indentation * 3)case .\(c.name):\(indentation)return \"\(identifierValue)\""
			
		}.joined(separator: "\n")
		
		let argumentsBody: String
		if cases.contains(where: { !$0.parameters.isEmpty }) {
			
			let argumentsSwitchBody = cases.map { c -> String in
				
				if c.parameters.isEmpty {
					return "\(indentation * 3)case .\(c.name):\(indentation)return []"
				}
				
				let processedParameters: [(pattern: String, argument: String)] = zip(c.parameters, 0...).map {
					let (parameter, index) = $0
					if let name = parameter.name {
						return ("\(name): let \(name)", name)
					} else {
						return ("let v\(index)", "v\(index)")
					}
				}
				
				let patternParameterList = processedParameters.map { $0.pattern }.joined(separator: ", ")
				let argumentList = processedParameters.map { $0.argument }.joined(separator: ", ")
				
				let pattern = ".\(c.name)(\(patternParameterList))"
				let statement = "return [\(argumentList)]"
				
				return "\(indentation * 3)case \(pattern):\(indentation)\(statement)"
				
			}.joined(separator: "\n")
			
			argumentsBody = """
			\(indentation * 2)switch self {
			\(argumentsSwitchBody)
			\(indentation * 2)}
			"""
			
		} else {
			argumentsBody = """
			\(indentation * 2)return []
			"""
		}
		
		return """
		extension \(fullyQualifiedName) {
		
		\(indentation)static var domain: String {
		\(indentation * 2)return \"\(fullyQualifiedName)\"
		\(indentation)}
		
		\(indentation)var identifier: String {
		\(indentation * 2)switch self {
		\(identifierSwitchBody)
		\(indentation * 2)}
		\(indentation)}
		
		\(indentation)var arguments: [CVarArg] {
		\(argumentsBody)
		\(indentation)}
		
		}
		"""
		
	}
	
}

private func * (string: String, times: Int) -> String {
	return (1...times).map { _ in string }.joined()
}
