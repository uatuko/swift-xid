import XCTest
@testable import xid

final class XidTests: XCTestCase {
	func testXidNext() {
		let n = 100
		var xid = Xid()
		var ids: [Id] = []

		// Generate n ids
		for _ in 0..<n {
			ids.append(xid.next())
		}

		for i in 1..<n {
			let previous = ids[i - 1]
			let current = ids[i]

			// Test for uniqueness among all other generated ids
			for (n, id) in ids.enumerated() {
				if n == i {
					continue
				}

				XCTAssertNotEqual(current, id)
			}

			// Check that timestamp was incremented and is within 30 seconds of the previous one
			let t = current.time().distance(to: previous.time())
			XCTAssertFalse(t < 0)
			XCTAssertFalse(t > 30)

			// Check that machine ids are the same
			XCTAssertEqual(current.machineId(), previous.machineId())

			// Check that pids are the same
			XCTAssertEqual(current.pid(), previous.pid())

			// Test for proper increment
			let diff = current.counter() - previous.counter()
			XCTAssertEqual(diff, 1)
		}
	}
}
