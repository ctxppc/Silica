// Conserve © 2018 Constantino Tsarouhas

enum GeneratedSource {
	
	/// The source is a single line.
	case singleLine(String)
	
	/// The source consists of a lead, (indented) body, and tail.
	case block(lead: String, body: [GeneratedSource], tail: String)
	
	/// Returns the string value of the source.
	///
	/// - Requires: `level` is nonnegative.
	///
	/// - Parameter level: The level of indentation. The default value is 0.
	///
	/// - Returns: The string value of the source.
	func stringValue(level: Int = 0) -> String {
		let indentation = (0..<level).map { _ in "\t" }.joined()
		switch self {
			
			case .singleLine(let line):
			return indentation + line
			
			case .block(let lead, let body, let tail):
			return """
			\(indentation)\(lead)
			\(body.lazy.map { $0.stringValue(level: level + 1) }.joined(separator: "\n"))
			\(indentation)\(tail)
			"""
			
		}
	}
	
}
