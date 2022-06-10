import Atomics
import CryptoKit
import Foundation

#if canImport(UIKit)
import UIKit
#endif

public struct Xid {
	private let counter = ManagedAtomic<UInt32>(0)
	private var _mid: Data?
	private var _pid: Data?

	var mid: Data {
		mutating get {
			if _mid == nil {
				_mid = machineId()
			}

			return _mid!
		}
	}

	var pid: Data {
		mutating get {
			if _pid == nil {
				_pid = processId()
			}

			return _pid!
		}
	}

	public init() {
		counter.store(random(), ordering: .relaxed)
	}

	public mutating func next() -> Id {
		var bytes = Data(repeating: 0x00, count: 12)

		// Timestamp, 4 bytes (big endian)
		let ts = timestamp()
		bytes[0] = ts[3]
		bytes[1] = ts[2]
		bytes[2] = ts[1]
		bytes[3] = ts[0]

		// Machine ID, 3 bytes
		bytes[4] = mid[0]
		bytes[5] = mid[1]
		bytes[6] = mid[2]

		// Process ID, 2 bytes (specs don't specify endianness, use big endian)
		bytes[7] = pid[1]
		bytes[8] = pid[0]

		// Increment, 3 bytes (big endian)
		let i = counter.wrappingIncrementThenLoad(ordering: .relaxed)
		bytes[9] = UInt8((i & 0xff0000) >> 16)
		bytes[10] = UInt8((i & 0x00ff00) >> 8)
		bytes[11] = UInt8(i & 0x0000ff)

		return Id(bytes: bytes)
	}

	func machineId() -> Data {
		let ptr = UnsafeMutablePointer<uuid_t>.allocate(capacity: 1)
		defer {
			ptr.deinitialize(count: 1)
			ptr.deallocate()
		}

#if os(macOS)
		var timeout = timespec(tv_sec: 0, tv_nsec: 500_000_000)
		gethostuuid(ptr, &timeout)
#else
#if canImport(UIKit)
		ptr.pointee = UIDevice.current.identifierForVendor!.uuid
#else
		uuid_generate(ptr)
#endif
#endif

		var mid = Data()
		withUnsafeBytes(of: ptr.pointee) { bytes in
			let digest = Insecure.MD5.hash(data: bytes)
			digest.withUnsafeBytes { bytes in
				mid = Data(bytes)
			}
		}

		return mid
	}

	func processId() -> Data {
		var pid = Data()
		withUnsafeBytes(of: getpid()) { bytes in
			pid = Data(bytes)
		}

		return pid
	}

	func random() -> UInt32 {
		var i: UInt32 = 0
		let status = withUnsafeMutableBytes(of: &i) { ptr in
			SecRandomCopyBytes(kSecRandomDefault, ptr.count, ptr.baseAddress!)
		}

		if status != errSecSuccess {
			i = UInt32.random(in: UInt32.min...UInt32.max)
		}

		return i
	}

	func timestamp() -> Data {
		var data = Data()
		withUnsafeBytes(of: Date().timeIntervalSince1970) { bytes in
			data = Data(bytes)
		}

		return data
	}
}
