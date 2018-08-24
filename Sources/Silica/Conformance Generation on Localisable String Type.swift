// Silica © 2018 Constantino Tsarouhas

extension LocalisableStringType {
	
	/// Returns Swift source text containing generated conformances for the localisable string type.
	///
	/// - Parameter indentation: A single layer of indentation. The default value is a single horizontal tab.
	/// - Parameter commonDomain: The common domain, or `nil` if the string type defines its own domain.
	func generatedConformance(indentation: String = "\t", commonDomain: String?) -> String {
		
		let usingCommonDomain = commonDomain != nil
		let identifiersSwitchBody = cases
			.map { c in "\(indentation * 3)case .\(c.name):\(indentation)return \"\(c.localisationIdentifier(withDomain: usingCommonDomain ? shortenedFullyQualifiedName : nil))\"" }
			.joined(separator: "\n")
		
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
		\(indentation * 2)return \"\(commonDomain ?? shortenedFullyQualifiedName)\"
		\(indentation)}
		
		\(indentation)var identifier: String {
		\(indentation * 2)switch self {
		\(identifiersSwitchBody)
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
