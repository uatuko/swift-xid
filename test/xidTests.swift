import XCTest
@testable import xid

final class xidTests: XCTestCase {
	func testIdPartsExtraction() {
		struct Test {
			var id: Id
			var time: Date
			var machineId: Data
			var pid: UInt16
			var counter: Int32
		}

		let tests: [Test] = [
			Test(
				id: Id(bytes: Data([0x4d, 0x88, 0xe1, 0x5b, 0x60, 0xf4, 0x86, 0xe4, 0x28, 0x41, 0x2d, 0xc9])),
				time: Date(timeIntervalSince1970: TimeInterval(1300816219)),
				machineId: Data([0x60, 0xf4, 0x86]),
				pid: 0xe428,
				counter: 4271561
			),
			Test(
				id: Id(bytes: Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])),
				time: Date(timeIntervalSince1970: TimeInterval(0)),
				machineId: Data([0x00, 0x00, 0x00]),
				pid: 0x0000,
				counter: 0
			),
			Test(
				id: Id(bytes: Data([0x00, 0x00, 0x00, 0x00, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0x00, 0x00, 0x01])),
				time: Date(timeIntervalSince1970: TimeInterval(0)),
				machineId: Data([0xaa, 0xbb, 0xcc]),
				pid: 0xddee,
				counter: 1
			),
		]

		for test in tests {
			XCTAssertEqual(test.time, test.id.time())
			XCTAssertEqual(test.machineId, test.id.machineId())
			XCTAssertEqual(test.pid, test.id.pid())
			XCTAssertEqual(test.counter, test.id.counter())
		}
	}

	func testIdString() {
		let bytes: [UInt8] = [0x4d, 0x88, 0xe1, 0x5b, 0x60, 0xf4, 0x86, 0xe4, 0x28, 0x41, 0x2d, 0xc9]
		let id = Id(bytes: Data(bytes))

		XCTAssertEqual("9m4e2mr0ui3e8a215n4g", String(describing: id))
	}

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
