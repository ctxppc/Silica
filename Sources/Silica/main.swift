// Silica © 2018 Constantino Tsarouhas

import Foundation

extension FileHandle : TextOutputStream {
	public func write(_ string: String) {
		write(Data(string.utf8))
	}
}

let command = Command()
command.start()
if let error = command.error {
	var handle = FileHandle.standardError
	print("error: \(error)", to: &handle)
	exit(1)
}
