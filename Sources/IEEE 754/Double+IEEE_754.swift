public import Binary_Primitives

extension Double {

    public static var ieee754: IEEE754.Type {
        IEEE754.self
    }

    public var ieee754: IEEE754 {
        IEEE754(double: self)
    }

    public struct IEEE754: Sendable {
        public let double: Double
    }
}

extension Double {

    @_transparent
    public init?(bytes: [UInt8], endianness: Binary.Endianness = .little) {
        guard let value = IEEE_754.Binary64.value(from: bytes, endianness: endianness) else {
            return nil
        }
        self = value
    }
}

extension Double {

    @_transparent
    public func bytes(endianness: Binary.Endianness = .little) -> [UInt8] {
        IEEE_754.Binary64.bytes(from: self, endianness: endianness)
    }
}

extension Double {

    @_transparent
    public static func ieee754(
        _ bytes: [UInt8],
        endianness: Binary.Endianness = .little
    ) -> Double? {
        IEEE_754.Binary64.value(from: bytes, endianness: endianness)
    }
}

extension Double.IEEE754 {

    @_transparent
    public func bytes(endianness: Binary.Endianness = .little) -> [UInt8] {
        IEEE_754.Binary64.bytes(from: double, endianness: endianness)
    }

    @_transparent
    public var bitPattern: UInt64 {
        double.bitPattern
    }
}
