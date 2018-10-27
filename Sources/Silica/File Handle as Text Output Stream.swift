// Silica © 2018 Constantino Tsarouhas

import Foundation

extension FileHandle : TextOutputStream {
	public func write(_ string: String) {
		write(Data(string.utf8))
	}
}
