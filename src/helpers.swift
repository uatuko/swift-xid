private var xid = Xid()

public func NewXid() -> String {
	String(describing: xid.next())
}
