// Silica © 2018 Constantino Tsarouhas

extension LocalisableStringType {
	
	/// Returns Swift code containing generated conformances for the localisable string type.
	func generatedConformance(indentation: String = "\t") -> String {
		
		let switchBody = caseNames.map { name in
			"\(indentation * 3)case .\(name):\(indentation)return \"\(name)\""
		}.joined(separator: "\n")
		
		return """
		extension \(fullyQualifiedName) {
		
		\(indentation)static var domain: String {
		\(indentation * 2)return \"\(fullyQualifiedName)\"
		\(indentation)}
		
		\(indentation)var identifier: String {
		\(indentation * 2)switch self {
		\(switchBody)
		\(indentation * 2)}
		\(indentation)}
		
		\(indentation)var arguments: [CVarArg] {
		\(indentation * 2)return []
		\(indentation)}
		
		}
		"""
		
	}
	
}

private func * (string: String, times: Int) -> String {
	return (1...times).map { _ in string }.joined()
}
