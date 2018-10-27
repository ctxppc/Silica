// Silica © 2018 Constantino Tsarouhas

/// An entry in a localisation table, without localised value.
struct LocalisableEntry {
	
	/// The name of the entry.
	let name: String
	
	/// The entry's parameters, if any.
	let parameters: [Parameter]
	struct Parameter {
		
		/// The label for arguments, or `nil` if arguments for the parameter are unlabelled.
		let label: String?
		
		/// The value type for localised arguments.
		let valueType: ValueType
		enum ValueType : String {
			
			/// The parameter takes (formatted) integer arguments.
			case integer = "%ld"
			
			/// The parameter takes (formatted) floating-point number arguments.
			case floatingPoint = "%f"
			
			/// The parameter takes string arguments.
			case string = "%@"
			
		}
		
		/// The parameter as a string representation.
		var rawValue: String {
			return "\(label ?? "_"): \(valueType.rawValue)"
		}
		
	}
	
	/// The entry as a string representation.
	var rawValue: String {
		if parameters.isEmpty {
			return name
		} else {
			return "\(name)(\(parameters.map { $0.rawValue }.joined(separator: ", ")))"
		}
	}
	
}

extension LocalisableEntry.Parameter {
	
	/// Creates a localisable entry parameter that mirrors a given parameter declaration.
	init(for parameter: Parameter) {
		
		let type: LocalisableEntry.Parameter.ValueType
		switch parameter.argumentType {
			case "Int":		type = .integer
			case "Double":	type = .floatingPoint
			default:		type = .string
		}
		
		self.init(label: parameter.name, valueType: type)
		
	}
	
}
