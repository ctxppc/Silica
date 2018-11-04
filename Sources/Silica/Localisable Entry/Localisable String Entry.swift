// Silica © 2018 Constantino Tsarouhas

/// An entry in a localisation table, without localised value.
struct LocalisableStringEntry {
	
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
			if let label = label {
				return "\(label): \(valueType.rawValue)"
			} else {
				return valueType.rawValue
			}
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

extension LocalisableStringEntry {
	
	/// Creates a localisable entry that mirrors a given case declaration element.
	init(for element: EnumeratedTypeDeclaration.CaseDeclaration.Element) {
		self.init(
			name:		element.internalFullyQualifiedName.replacingOccurrences(of: "ViewController.", with: ".").replacingOccurrences(of: "String.", with: "."),
			parameters:	element.parameters.map(LocalisableStringEntry.Parameter.init(for:))
		)
	}
	
}

extension LocalisableStringEntry.Parameter {
	
	/// Creates a localisable entry parameter that mirrors a given parameter declaration.
	init(for parameter: Parameter) {
		
		let type: LocalisableStringEntry.Parameter.ValueType
		switch parameter.argumentType {
			case "Int":		type = .integer
			case "Double":	type = .floatingPoint
			default:		type = .string
		}
		
		self.init(label: parameter.name, valueType: type)
		
	}
	
}
