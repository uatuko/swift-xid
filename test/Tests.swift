import XCTest
@testable import xid

final class Tests: XCTestCase {
	func testJsonDecode() throws {
		struct User: Decodable {
			var id: Id
			var name: String
		}

		let data = """
		{
		  "id": "cajj5ctbutokmmm2jdsg",
		  "name": "user:testJsonDecode"
		}
		""".data(using: .utf8)!

		let decoder = JSONDecoder()
		let user = try decoder.decode(User.self, from: data)

		XCTAssertEqual("cajj5ctbutokmmm2jdsg", String(describing: user.id))
	}

	func testJsonEncode() throws {
		struct User: Encodable {
			var id: Id
			var name: String
		}

		let user = User(id: NewXid(), name: "user:testJsonEncode")

		let encoder = JSONEncoder()
		let data = try encoder.encode(user)

		print(String(data: data, encoding: .utf8)!)
		XCTAssertEqual(
			"{\"id\":\"\(user.id)\",\"name\":\"user:testJsonEncode\"}",
			String(data: data, encoding: .utf8)
		)
	}

	func testNewXidFromBytes() throws {
		let id = try NewXid(bytes: Data([0x62, 0xa7, 0x28, 0x66, 0xab, 0xf7, 0x71, 0x46, 0x09, 0xa4, 0xa3, 0x55]))

		XCTAssertEqual("cajigplbutokc2d4kdag", String(describing: id))
	}

	func testNewXidFromData() throws {
		let actual = try NewXid(from: "9m4e2mr0ui3e8a215n4g".data(using: .utf8)!)
		let expected = Id(bytes: Data([0x4d, 0x88, 0xe1, 0x5b, 0x60, 0xf4, 0x86, 0xe4, 0x28, 0x41, 0x2d, 0xc9]))

		XCTAssertEqual(expected, actual)
	}

	func testNewXidFromString() throws {
		let actual = try NewXid(from: "9m4e2mr0ui3e8a215n4g")
		let expected = Id(bytes: Data([0x4d, 0x88, 0xe1, 0x5b, 0x60, 0xf4, 0x86, 0xe4, 0x28, 0x41, 0x2d, 0xc9]))

		XCTAssertEqual(expected, actual)
	}
}
