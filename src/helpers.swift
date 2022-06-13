import Foundation

private var xid = Xid()

public func NewXid() -> Id {
	xid.next()
}

public func NewXid() -> String {
	String(describing: xid.next())
}

public func NewXid(bytes: Data) throws -> Id {
	if bytes.count != 12 {
		throw XidError.invalidId
	}

	return Id(bytes: bytes)
}

public func NewXid(from: Data) throws -> Id {
	try Id(from: from)
}

public func NewXid(from: String) throws -> Id {
	try Id(from: from)
}
