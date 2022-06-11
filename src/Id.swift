import Foundation

public struct Id: CustomStringConvertible {
	private let alphabet = Data("0123456789abcdefghijklmnopqrstuv".utf8)

	var bytes: Data

	public var data: Data {
		get { return bytes }
	}

	public var description: String {
		if bytes.count != 12 {
			return ""
		}

		// base32hex encoding
		var chars = Data(repeating: 0x00, count: 20)
		chars[19] = alphabet[Data.Index((bytes[11] << 4) & 0x1f)]
		chars[18] = alphabet[Data.Index((bytes[11] >> 1) & 0x1f)]
		chars[17] = alphabet[Data.Index((bytes[11] >> 6) & 0x1f | (bytes[10] << 2) & 0x1F)]
		chars[16] = alphabet[Data.Index(bytes[10]) >> 3]
		chars[15] = alphabet[Data.Index(bytes[9] & 0x1f)]
		chars[14] = alphabet[Data.Index((bytes[9] >> 5) | (bytes[8] << 3 ) & 0x1f)]
		chars[13] = alphabet[Data.Index((bytes[8] >> 2) & 0x1f)]
		chars[12] = alphabet[Data.Index(bytes[8] >> 7 | (bytes[7] << 1) & 0x1f)]
		chars[11] = alphabet[Data.Index((bytes[7] >> 4) & 0x1f | (bytes[6] << 4) & 0x1f)]
		chars[10] = alphabet[Data.Index((bytes[6] >> 1) & 0x1f)]
		chars[9] = alphabet[Data.Index((bytes[6] >> 6) & 0x1f | (bytes[5] << 2) & 0x1f)]
		chars[8] = alphabet[Data.Index(bytes[5] >> 3)]
		chars[7] = alphabet[Data.Index(bytes[4] & 0x1f)]
		chars[6] = alphabet[Data.Index(bytes[4] >> 5 | (bytes[3] << 3) & 0x1f)]
		chars[5] = alphabet[Data.Index((bytes[3] >> 2) & 0x1f)]
		chars[4] = alphabet[Data.Index(bytes[3] >> 7 | (bytes[2] << 1) & 0x1f)]
		chars[3] = alphabet[Data.Index((bytes[2] >> 4) & 0x1f | (bytes[1] << 4) & 0x1f)]
		chars[2] = alphabet[Data.Index((bytes[1] >> 1) & 0x1f)]
		chars[1] = alphabet[Data.Index((bytes[1] >> 6) & 0x1f | (bytes[0] << 2) & 0x1f)]
		chars[0] = alphabet[Data.Index(bytes[0] >> 3)]

		if let str = String(bytes: chars, encoding: .utf8) {
			return str
		}

		return ""
	}

	public func counter() -> Int32 {
		return Int32(
			UInt32(bytes[9]) << 16 | UInt32(bytes[10]) << 8 | UInt32(bytes[11])
		)
	}

	public func machineId() -> Data {
		return Data(bytes[4...6])
	}

	public func pid() -> UInt16 {
		let pid: UInt16 = withUnsafeBytes(of: Data(bytes[7...8])) { ptr in
			let n = ptr.load(as: UInt16.self)
			return UInt16(bigEndian: n)
		}

		return pid
	}

	public func time() -> Date {
		let t: Date = withUnsafeBytes(of: Data(bytes[0...3])) { ptr in
			let n = ptr.load(as: UInt32.self)
			return Date(timeIntervalSince1970: TimeInterval(UInt32(bigEndian: n)))
		}

		return t
	}
}


extension Id: Equatable {
	public static func == (lhs: Id, rhs: Id) -> Bool {
		lhs.bytes == rhs.bytes
	}
}
