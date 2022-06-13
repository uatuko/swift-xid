import Foundation

fileprivate let base32Alphabet = Data("0123456789abcdefghijklmnopqrstuv".utf8)

fileprivate let base32DecodeMap: Data = {
	var map = Data(repeating: 0xff, count: 256)
	for i in 0..<base32Alphabet.count {
		map[Data.Index(base32Alphabet[i])] = UInt8(i)
	}

	return map
}()


public struct Id {
	var bytes: Data

	public var data: Data {
		get { return bytes }
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


extension Id {
	public init(from: Data) throws {
		if from.count != 20 {
			throw XidError.invalidId
		}

		bytes = Data(repeating: 0x00, count: 12)
		bytes[11] = base32DecodeMap[Data.Index(from[17])] << 6 | base32DecodeMap[Data.Index(from[18])] << 1 | base32DecodeMap[Data.Index(from[19])] >> 4
		bytes[10] = base32DecodeMap[Data.Index(from[16])] << 3 | base32DecodeMap[Data.Index(from[17])] >> 2
		bytes[9] = base32DecodeMap[Data.Index(from[14])] << 5 | base32DecodeMap[Data.Index(from[15])]
		bytes[8] = base32DecodeMap[Data.Index(from[12])] << 7 | base32DecodeMap[Data.Index(from[13])] << 2 | base32DecodeMap[Data.Index(from[14])] >> 3
		bytes[7] = base32DecodeMap[Data.Index(from[11])] << 4 | base32DecodeMap[Data.Index(from[12])] >> 1
		bytes[6] = base32DecodeMap[Data.Index(from[9])] << 6 | base32DecodeMap[Data.Index(from[10])] << 1 | base32DecodeMap[Data.Index(from[11])] >> 4
		bytes[5] = base32DecodeMap[Data.Index(from[8])] << 3 | base32DecodeMap[Data.Index(from[9])] >> 2
		bytes[4] = base32DecodeMap[Data.Index(from[6])] << 5 | base32DecodeMap[Data.Index(from[7])]
		bytes[3] = base32DecodeMap[Data.Index(from[4])] << 7 | base32DecodeMap[Data.Index(from[5])] << 2 | base32DecodeMap[Data.Index(from[6])] >> 3
		bytes[2] = base32DecodeMap[Data.Index(from[3])] << 4 | base32DecodeMap[Data.Index(from[4])] >> 1
		bytes[1] = base32DecodeMap[Data.Index(from[1])] << 6 | base32DecodeMap[Data.Index(from[2])] << 1 | base32DecodeMap[Data.Index(from[3])] >> 4
		bytes[0] = base32DecodeMap[Data.Index(from[0])] << 3 | base32DecodeMap[Data.Index(from[1])] >> 2

		// Validate that there are no padding in data that would cause the re-encoded id to not equal data.
		var check = Data(repeating: 0x00, count: 4)
		check[3] = base32Alphabet[Data.Index((bytes[11] << 4) & 0x1f)]
		check[2] = base32Alphabet[Data.Index((bytes[11] >> 1) & 0x1f)]
		check[1] = base32Alphabet[Data.Index((bytes[11] >> 6) & 0x1f | (bytes[10] << 2) & 0x1f)]
		check[0] = base32Alphabet[Data.Index(bytes[10] >> 3)]

		if check != from[16...19] {
			throw XidError.decodeValidationFailure
		}
	}

	public init(from: String) throws {
		if from.count != 20 {
			throw XidError.invalidIdStringLength(have: from.count, want: 20)
		}

		guard let data = from.data(using: .utf8) else {
			throw XidError.invalidId
		}

		try self.init(from: data)
	}
}

extension Id: CustomStringConvertible {
	public var description: String {
		if bytes.count != 12 {
			return ""
		}

		// base32hex encoding
		var chars = Data(repeating: 0x00, count: 20)
		chars[19] = base32Alphabet[Data.Index((bytes[11] << 4) & 0x1f)]
		chars[18] = base32Alphabet[Data.Index((bytes[11] >> 1) & 0x1f)]
		chars[17] = base32Alphabet[Data.Index((bytes[11] >> 6) & 0x1f | (bytes[10] << 2) & 0x1f)]
		chars[16] = base32Alphabet[Data.Index(bytes[10] >> 3)]
		chars[15] = base32Alphabet[Data.Index(bytes[9] & 0x1f)]
		chars[14] = base32Alphabet[Data.Index((bytes[9] >> 5) | (bytes[8] << 3 ) & 0x1f)]
		chars[13] = base32Alphabet[Data.Index((bytes[8] >> 2) & 0x1f)]
		chars[12] = base32Alphabet[Data.Index(bytes[8] >> 7 | (bytes[7] << 1) & 0x1f)]
		chars[11] = base32Alphabet[Data.Index((bytes[7] >> 4) & 0x1f | (bytes[6] << 4) & 0x1f)]
		chars[10] = base32Alphabet[Data.Index((bytes[6] >> 1) & 0x1f)]
		chars[9] = base32Alphabet[Data.Index((bytes[6] >> 6) & 0x1f | (bytes[5] << 2) & 0x1f)]
		chars[8] = base32Alphabet[Data.Index(bytes[5] >> 3)]
		chars[7] = base32Alphabet[Data.Index(bytes[4] & 0x1f)]
		chars[6] = base32Alphabet[Data.Index(bytes[4] >> 5 | (bytes[3] << 3) & 0x1f)]
		chars[5] = base32Alphabet[Data.Index((bytes[3] >> 2) & 0x1f)]
		chars[4] = base32Alphabet[Data.Index(bytes[3] >> 7 | (bytes[2] << 1) & 0x1f)]
		chars[3] = base32Alphabet[Data.Index((bytes[2] >> 4) & 0x1f | (bytes[1] << 4) & 0x1f)]
		chars[2] = base32Alphabet[Data.Index((bytes[1] >> 1) & 0x1f)]
		chars[1] = base32Alphabet[Data.Index((bytes[1] >> 6) & 0x1f | (bytes[0] << 2) & 0x1f)]
		chars[0] = base32Alphabet[Data.Index(bytes[0] >> 3)]

		return String(bytes: chars, encoding: .utf8) ?? ""
	}
}

extension Id: Decodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		try self.init(from: try container.decode(String.self))
	}
}

extension Id: Encodable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(String(describing: self))
	}
}

extension Id: Equatable {
	public static func == (lhs: Id, rhs: Id) -> Bool {
		lhs.bytes == rhs.bytes
	}
}
