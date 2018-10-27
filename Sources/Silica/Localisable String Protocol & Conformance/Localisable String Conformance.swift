// Conserve © 2018 Constantino Tsarouhas

struct LocalisableStringConformance {
	
	/// Creates a `LocalisableString` conformance.
	init(for conformingType: TypeDeclaration, identifierSource: GeneratedSource, argumentsSource: GeneratedSource) {
		self.conformingType = conformingType
		self.identifierSource = identifierSource
		self.argumentsSource = argumentsSource
	}
	
	/// The type declaration of the type conforming to the `LocalisableString` protocol.
	let conformingType: TypeDeclaration
	
	/// The source for determining the identifier.
	let identifierSource: GeneratedSource
	
	/// The source for determining the arguments.
	let argumentsSource: GeneratedSource
	
	/// The source of the conformance.
	var source: GeneratedSource {
		return .block(
			lead: "extension \(conformingType.internalFullyQualifiedName)",
			body: [
				.block(
					lead: "var identifier: String {",
					body: [identifierSource],
					tail: "}"
				),
				.block(
					lead: "var arguments: [CVarArg] {",
					body: [argumentsSource],
					tail: "}"
				)
			],
			tail: "}"
		)
	}
	
}
