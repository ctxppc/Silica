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
			
			/// Determines a value type from a given (Swift) type name.
			init(typeName: String?) {
				switch typeName {
					case "Int"?:	self = .integer
					case "Double"?:	self = .floatingPoint
					default:		self = .string
				}
			}
			
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
	
	/// The entry's identifier in a localisable table.
	var tableEntryIdentifier: String {
		if parameters.isEmpty {
			return name
		} else {
			return "\(name)(\(parameters.map { $0.rawValue }.joined(separator: ", ")))"
		}
	}
	
}

extension LocalisableStringEntry {
	
	/// Creates a localisable string entry for given named declaration with given parameters.
	init(for declaration: NamedDeclaration, parameters: [Parameter]) {
		let name = declaration.internalFullyQualifiedName.replacingOccurrences(of: "ViewController.", with: ".").replacingOccurrences(of: "String.", with: ".")
		self.init(name: name, parameters: parameters)
	}
	
}
