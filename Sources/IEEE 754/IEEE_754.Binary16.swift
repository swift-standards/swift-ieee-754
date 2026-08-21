extension IEEE_754 {

    public enum Binary16 {}
}

extension IEEE_754.Binary16 {

    public static let byteSize: Int = 2

    public static let bitSize: Int = 16

    public static let signBits: Int = 1

    public static let exponentBits: Int = 5

    public static let significandBits: Int = 10

    public static let exponentBias: Int = 15

    public static let maxExponent: Int = (1 << exponentBits) - 1

    public static let precision: Int = 11

    public static let emin: Int = -14

    public static let emax: Int = 15
}

#if canImport(FloatingPointTypes) && compiler(>=5.9)
    extension IEEE_754.Binary16 {

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let epsilon: Float16 = 0x1.0p-10

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let minNormal: Float16 = Float16.leastNormalMagnitude

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let minSubnormal: Float16 = Float16.leastNonzeroMagnitude

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let maxNormal: Float16 = Float16.greatestFiniteMagnitude
    }

    extension IEEE_754.Binary16 {

        public enum SpecialValues {}
    }

    extension IEEE_754.Binary16.SpecialValues {

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let positiveZero: Float16 = 0.0

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let negativeZero: Float16 = -0.0

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let positiveInfinity: Float16 = Float16.infinity

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let negativeInfinity: Float16 = -Float16.infinity

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let quietNaN: Float16 = Float16.nan

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let signalingNaN: Float16 = Float16.signalingNaN
    }

    extension IEEE_754.Binary16 {

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        @inlinable
        public static func bytes(
            from value: Float16,
            endianness: Binary.Endianness = .little
        ) -> [UInt8] {
            let bitPattern = value.bitPattern
            return [UInt8](bitPattern, endianness: endianness)
        }

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        @inlinable
        public static func value(
            from bytes: [UInt8],
            endianness: Binary.Endianness = .little
        ) -> Float16? {
            guard bytes.count == byteSize else { return nil }

            let bitPattern: UInt16 = bytes.withUnsafeBytes { buffer in
                let loaded = buffer.loadUnaligned(fromByteOffset: 0, as: UInt16.self)
                switch endianness {
                case .little:
                    return UInt16(littleEndian: loaded)

                case .big:
                    return UInt16(bigEndian: loaded)
                }
            }

            return Float16(bitPattern: bitPattern)
        }
    }
#endif
