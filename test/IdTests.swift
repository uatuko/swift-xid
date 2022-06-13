import XCTest
@testable import xid

final class IdTests: XCTestCase {
	func testIdDecodable() throws {
		let data = "\"caia5ng890f0tr00hgtg\"".data(using: .utf8)!
		let decoder = JSONDecoder()
		let id = try decoder.decode(Id.self, from: data)

		XCTAssertEqual("caia5ng890f0tr00hgtg", String(describing: id))
	}

	func testIdEncodable() throws {
		var xid = Xid()
		let id = xid.next()

		let encoder = JSONEncoder()
		let data = try encoder.encode(id)

		let expected = "\"\(String(describing: id))\""
		let actual = String(data: data, encoding: .utf8)
		XCTAssertEqual(expected, actual)
	}

	func testIdInitFromDataThrow() {
		XCTAssertThrowsError(try Id(from:Data([0x78, 0x69, 0x64]))) { error in
			XCTAssertEqual(XidError.invalidId, error as! XidError)
		}
	}

	func testIdInitFromStringThrow() {
		XCTAssertThrowsError(try Id(from: "xid")) { error in
			XCTAssertEqual(XidError.invalidIdStringLength(have: 3, want: 20), error as! XidError)
		}

		XCTAssertThrowsError(try Id(from: "caia5ng890f0tr00hgt=")) { error in
			XCTAssertEqual(XidError.decodeValidationFailure, error as! XidError)
		}
	}

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

}
