public import Binary_Primitives

extension Float {

    public static var ieee754: IEEE754.Type {
        IEEE754.self
    }

    public var ieee754: IEEE754 {
        IEEE754(float: self)
    }

    public struct IEEE754: Sendable {
        public let float: Float
    }
}

extension Float {

    @_transparent
    public init?(bytes: [UInt8], endianness: Binary.Endianness = .little) {
        guard let value = IEEE_754.Binary32.value(from: bytes, endianness: endianness) else {
            return nil
        }
        self = value
    }
}

extension Float {

    @_transparent
    public func bytes(endianness: Binary.Endianness = .little) -> [UInt8] {
        IEEE_754.Binary32.bytes(from: self, endianness: endianness)
    }
}

extension Float {

    @_transparent
    public static func ieee754(
        _ bytes: [UInt8],
        endianness: Binary.Endianness = .little
    ) -> Float? {
        IEEE_754.Binary32.value(from: bytes, endianness: endianness)
    }
}

extension Float.IEEE754 {

    @_transparent
    public func bytes(endianness: Binary.Endianness = .little) -> [UInt8] {
        IEEE_754.Binary32.bytes(from: float, endianness: endianness)
    }

    @_transparent
    public var bitPattern: UInt32 {
        float.bitPattern
    }
}
