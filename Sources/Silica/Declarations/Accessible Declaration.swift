// Silica © 2018 Constantino Tsarouhas

/// A declaration that can be accessed, or whose members can be accessed, from other lexical scopes.
protocol AccessibleDeclaration : Declaration {
	
	/// The breadth of lexical scopes that can access this declaration or its members.
	var accessibility: DeclarationAccessibility { get }
	
}

enum DeclarationAccessibility : String, Codable, Equatable, CaseIterable {
	case `private` = "source.lang.swift.accessibility.private"
	case `fileprivate` = "source.lang.swift.accessibility.fileprivate"
	case `internal` = "source.lang.swift.accessibility.internal"
	case `public` = "source.lang.swift.accessibility.public"
	case `open` = "source.lang.swift.accessibility.open"
}

extension DeclarationAccessibility : Comparable {
	static func < (smaller: DeclarationAccessibility, greater: DeclarationAccessibility) -> Bool {
		return allCases.index(of: smaller)! < allCases.index(of: greater)!
	}
}
