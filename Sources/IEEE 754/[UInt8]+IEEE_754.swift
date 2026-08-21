public import Binary_Primitives

extension [UInt8] {

    public static var ieee754: IEEE754.Type {
        IEEE754.self
    }

    public var ieee754: IEEE754 {
        IEEE754(bytes: self)
    }

    public struct IEEE754: Sendable {
        public let bytes: [UInt8]
    }
}

extension [UInt8].IEEE754 {

    public static func bytes(
        from value: Double,
        endianness: Binary.Endianness = .little
    ) -> [UInt8] {
        IEEE_754.Binary64.bytes(from: value, endianness: endianness)
    }

    public static func bytes(
        from value: Float,
        endianness: Binary.Endianness = .little
    ) -> [UInt8] {
        IEEE_754.Binary32.bytes(from: value, endianness: endianness)
    }
}

extension [UInt8] {

    public init(_ value: Double, endianness: Binary.Endianness = .little) {
        self = IEEE_754.Binary64.bytes(from: value, endianness: endianness)
    }

    public init(_ value: Float, endianness: Binary.Endianness = .little) {
        self = IEEE_754.Binary32.bytes(from: value, endianness: endianness)
    }
}
