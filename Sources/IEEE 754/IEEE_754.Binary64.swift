public import Binary_Primitives

extension IEEE_754 {

    public enum Binary64 {}
}

extension IEEE_754.Binary64 {

    public static let byteSize: Int = 8

    public static let bitSize: Int = 64

    public static let signBits: Int = 1

    public static let exponentBits: Int = 11

    public static let significandBits: Int = 52

    public static let exponentBias: Int = 1023

    public static let maxExponent: Int = (1 << exponentBits) - 1

    public static let precision: Int = 53

    public static let emin: Int = -1022

    public static let emax: Int = 1023

    public static let epsilon: Double = 0x1.0p-52

    public static let minNormal: Double = Double.leastNormalMagnitude

    public static let minSubnormal: Double = Double.leastNonzeroMagnitude

    public static let maxNormal: Double = Double.greatestFiniteMagnitude
}

extension IEEE_754.Binary64 {

    public enum SpecialValues {}
}

extension IEEE_754.Binary64.SpecialValues {

    public static let positiveZero: Double = 0.0

    public static let negativeZero: Double = -0.0

    public static let positiveInfinity: Double = Double.infinity

    public static let negativeInfinity: Double = -Double.infinity

    public static let quietNaN: Double = Double.nan

    public static let signalingNaN: Double = Double.signalingNaN
}

extension IEEE_754.Binary64 {

    @inlinable
    public static func bytes(
        from value: Double,
        endianness: Binary.Endianness = .little
    ) -> [UInt8] {
        let bitPattern = value.bitPattern
        return [UInt8](bitPattern, endianness: endianness)
    }

    @inlinable
    public static func value(
        from bytes: [UInt8],
        endianness: Binary.Endianness = .little
    ) -> Double? {
        guard bytes.count == byteSize else { return nil }

        let bitPattern: UInt64 = bytes.withUnsafeBytes { buffer in
            let loaded = unsafe buffer.loadUnaligned(fromByteOffset: 0, as: UInt64.self)
            switch endianness {
            case .little:
                return UInt64(littleEndian: loaded)

            case .big:
                return UInt64(bigEndian: loaded)
            }
        }

        return Double(bitPattern: bitPattern)
    }
}
