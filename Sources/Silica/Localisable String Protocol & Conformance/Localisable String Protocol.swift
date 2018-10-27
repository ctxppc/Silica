// Conserve © 2018 Constantino Tsarouhas

let localisableStringProtocolName = "LocalisableString"

let localisableStringProtocol = """
/// A value that can provide a localisable string.
protocol \(localisableStringProtocolName) {
	
	/// An identifier that groups localisable strings.
	///
	/// All localisable strings must be located in a table named after the domain.
	static var domain: String { get }
	
	/// The localisable string's identifier, including placeholders for any arguments.
	var identifier: String { get }
	
	/// The arguments for the localised string.
	var arguments: [CVarArg] { get }
	
	/// `self` localised in the current locale.
	var localised: String { get }
	
}

extension \(localisableStringProtocolName) {

	var localised: String {
		
		let domain = type(of: self).domain
		let errorPattern = "(No translation available for \\(identifier) in \\(domain).)"
		let pattern = Bundle.main.localizedString(forKey: identifier, value: errorPattern, table: domain)
		
		guard pattern != errorPattern else {
			os_log(.error, "Missing localisable string key %@ in table %@", identifier, domain)
			return errorPattern
		}
		
		return .init(format: pattern, arguments: arguments)
		
	}
	
}
"""
