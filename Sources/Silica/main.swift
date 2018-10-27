// Silica © 2018 Constantino Tsarouhas

import Foundation

let command = Command()
command.start()
if let error = command.error {
	var handle = FileHandle.standardError
	print("error: \(error)", to: &handle)
	exit(1)
}
