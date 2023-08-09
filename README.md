# Swift Xid

[![license](https://img.shields.io/badge/license-MIT-green)](https://raw.githubusercontent.com/uatuko/swift-xid/main/LICENSE)

A globally unique id generator.

> This is a swift implementation of the Golang package found at: [https://github.com/rs/xid](https://github.com/rs/xid)

Xid uses MongoDB Object ID algorighm[^1] to generate globally unique ids with base32 serialzation to produce shorter strings.


## Binary representation

```
+---+----+----+----+----+----+----+----+----+----+-----+-----+
| 0 |  1 |  2 |  3 |  4 |  5 |  6 |  7 |  8 |  9 |  10 |  11 |
+---+----+----+----+----+----+----+----+----+----+-----+-----+
 \----- time -----/ \ machine id / \- pid -/ \--- counter ---/
```

- 4-byte value representing the seconds since the Unix epoch,
- 3-byte machine identifier,
- 2-byte process id, and
- 3-byte counter, starting with a random value.

The binary representation of the id is compatible with MongoDB's 12 bytes Object IDs.
The string representation is using base32hex (w/o padding)[^2] for better space efficiency when stored in string form (20 bytes). The hex variant of base32 is used to retain the
sortable property of the id.


## Features

- Size: 12 bytes (96 bits), smaller than UUID, larger than Twitter Snowflake[^3]
- Base32hex encoded by default (20 chars when transported as printable string, still sortable)
- Configuration free: there is no need to set a unique machine and/or data center id
- K-ordered
- Embedded time with 1 second precision
- Unicity guaranteed for 16,777,216 (24 bits) unique ids per second and per host/process
- Lock-free (unlike UUIDv1 and v2)


## Comparison

| Name        | Binary Size | String Size    | Features
|-------------|-------------|----------------|----------------
| [UUID]      | 16 bytes    | 36 chars       | configuration free, not sortable
| [shortuuid] | 16 bytes    | 22 chars       | configuration free, not sortable
| [Snowflake] | 8 bytes     | up to 20 chars | needs machine/DC configuration, needs central server, sortable
| [MongoID]   | 12 bytes    | 24 chars       | configuration free, sortable
| xid         | 12 bytes    | 20 chars       | configuration free, sortable

[UUID]: https://en.wikipedia.org/wiki/Universally_unique_identifier
[shortuuid]: https://github.com/stochastic-technologies/shortuuid
[Snowflake]: https://blog.twitter.com/2010/announcing-snowflake
[MongoID]: https://www.mongodb.com/docs/manual/reference/method/ObjectId/


## Usage

```swift
let id: String = NewXid() // or let id: Id = NewXid()
print(id)
// Output: caia5ng890f0tr46f690
```

```swift
var xid = Xid()
print(xid.next())
// Output: caia5ng890f0tr00hgtg
```

```swift
// Get embedded info
let id = xid.next()

id.time()
id.machineId()
id.pid()
id.counter()

// Access raw bytes
print(id.data as NSData)
// Output: {length = 12, bytes = 0x62a4a4a108481e0f9b83781f}
```

### Encoding and Decoding

The `Id` structure complies with `Codable` protocol and can be converted into and out of an external representation (e.g. JSON).

#### Decoding from JSON

```swift
struct User: Decodable {
  var id: Id
  var name: String
}

let data = """
{
  "id": "caia5ng890f0tr00hgtg",
  "name": "Jane Smith"
}
""".data(using: .utf8)!

let decoder = JSONDecoder()
let user = try decoder.decode(User.self, from: data)

print(user.id)
// Output: caia5ng890f0tr00hgtg
```

#### Encoding into JSON
```swift
struct User: Encodable {
  var id: Id
  var name: String
}

let user = User(id: NewXid(), name: "Jane Smith")

let encoder = JSONEncoder()
let data = try encoder.encode(user)

print(String(data: data, encoding: .utf8)!)
// Output: {"id":"caia5ng890f0tr00hgtg","name":"Jane Smith"}
```


[^1]: https://www.mongodb.com/docs/manual/reference/method/ObjectId/
[^2]: https://datatracker.ietf.org/doc/html/rfc4648#section-7
[^3]: https://blog.twitter.com/2010/announcing-snowflake
