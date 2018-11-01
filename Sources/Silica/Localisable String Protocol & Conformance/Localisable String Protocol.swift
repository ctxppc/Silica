// Conserve © 2018 Constantino Tsarouhas

let localisableStringProtocolName = "LocalisableString"

func localisableStringProtocolSource(tableName: String) -> String {
	return """
	/// A value that can provide a localisable string.
	protocol \(localisableStringProtocolName) {
	
		/// The localisable string's identifier, including placeholders for any arguments.
		var identifier: String { get }

		/// The arguments for the localised string.
		var arguments: [CVarArg] { get }

		/// `self` localised in the current locale.
		var localised: String { get }

	}

	extension \(localisableStringProtocolName) {

		var localised: String {
	
			let errorPattern = "(No translation available for \\(identifier) in \(tableName).strings.)"
			let pattern = Bundle.main.localizedString(forKey: identifier, value: errorPattern, table: \"\(tableName)\")

			guard pattern != errorPattern else {
				os_log(.error, "Missing localised string for key %@ in table \(tableName)", identifier)
				return errorPattern
			}

			return .init(format: pattern, arguments: arguments)

		}

	}
	"""
}
