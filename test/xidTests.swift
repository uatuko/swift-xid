import XCTest
@testable import xid

final class xidTests: XCTestCase {
	func testIdString() {
		let bytes: [UInt8] = [0x4d, 0x88, 0xe1, 0x5b, 0x60, 0xf4, 0x86, 0xe4, 0x28, 0x41, 0x2d, 0xc9]
		let id = Id(bytes: Data(bytes))

		XCTAssertEqual("9m4e2mr0ui3e8a215n4g", String(describing: id))
	}
}
