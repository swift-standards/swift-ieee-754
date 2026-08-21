public import Binary_Primitives

extension IEEE_754 {

    public enum Binary32 {}
}

extension IEEE_754.Binary32 {

    public static let byteSize: Int = 4

    public static let bitSize: Int = 32

    public static let signBits: Int = 1

    public static let exponentBits: Int = 8

    public static let significandBits: Int = 23

    public static let exponentBias: Int = 127

    public static let maxExponent: Int = (1 << exponentBits) - 1

    public static let precision: Int = 24

    public static let emin: Int = -126

    public static let emax: Int = 127

    public static let epsilon: Float = 0x1.0p-23

    public static let minNormal: Float = Float.leastNormalMagnitude

    public static let minSubnormal: Float = Float.leastNonzeroMagnitude

    public static let maxNormal: Float = Float.greatestFiniteMagnitude
}

extension IEEE_754.Binary32 {

    public enum SpecialValues {}
}

extension IEEE_754.Binary32.SpecialValues {

    public static let positiveZero: Float = 0.0

    public static let negativeZero: Float = -0.0

    public static let positiveInfinity: Float = Float.infinity

    public static let negativeInfinity: Float = -Float.infinity

    public static let quietNaN: Float = Float.nan

    public static let signalingNaN: Float = Float.signalingNaN
}

extension IEEE_754.Binary32 {

    @inlinable
    public static func bytes(
        from value: Float,
        endianness: Binary.Endianness = .little
    ) -> [UInt8] {
        let bitPattern = value.bitPattern
        return [UInt8](bitPattern, endianness: endianness)
    }

    @inlinable
    public static func value(
        from bytes: [UInt8],
        endianness: Binary.Endianness = .little
    ) -> Float? {
        guard bytes.count == byteSize else { return nil }

        let bitPattern: UInt32 = bytes.withUnsafeBytes { buffer in
            let loaded = unsafe buffer.loadUnaligned(fromByteOffset: 0, as: UInt32.self)
            switch endianness {
            case .little:
                return UInt32(littleEndian: loaded)

            case .big:
                return UInt32(bigEndian: loaded)
            }
        }

        return Float(bitPattern: bitPattern)
    }
}
