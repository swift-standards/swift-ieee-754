// IEEE_754.Binary16.swift
// swift-ieee-754
//
// IEEE 754-2019: Binary16 (Half Precision) Format
// Authoritative implementation of the binary16 interchange format

extension IEEE_754 {
    /// Binary16 (Half Precision) Format
    ///
    /// 16-bit binary floating-point format per IEEE 754-2019 Section 3.6.
    ///
    /// ## Format Specification (IEEE 754-2019 Section 3.6, Table 3.5)
    ///
    /// Total: 16 bits (2 bytes)
    /// - Sign: 1 bit
    /// - Exponent: 5 bits (biased by 15)
    /// - Significand: 10 bits (plus implicit leading 1)
    ///
    /// ## Encoding
    ///
    /// ```
    /// seee eeff ffff ffff
    /// │└─┬┘ └─────┬────┘
    /// │ exp   significand
    /// sign   (10 bits)
    /// (5 bits)
    /// ```
    ///
    /// ## Special Values
    ///
    /// - Zero: exponent = 0, fraction = 0
    /// - Subnormal: exponent = 0, fraction ≠ 0
    /// - Infinity: exponent = 31, fraction = 0
    /// - NaN: exponent = 31, fraction ≠ 0
    ///
    /// ## Overview
    ///
    /// Binary16 is primarily used for storage and communication where space is at
    /// a premium. Swift provides `Float16` on compatible platforms (macOS 14+, iOS 17+).
    /// This namespace provides constants and metadata for the format.
    ///
    /// ## See Also
    /// - IEEE 754-2019 Section 3.6, Table 3.5
    public enum Binary16 {}
}

extension IEEE_754.Binary16 {
    /// Number of bytes in binary16 format (2)
    public static let byteSize: Int = 2

    /// Number of bits in binary16 format (16)
    public static let bitSize: Int = 16

    /// Sign bit: 1 bit
    public static let signBits: Int = 1

    /// Exponent bits: 5 bits
    public static let exponentBits: Int = 5

    /// Significand bits: 10 bits (plus implicit leading 1)
    public static let significandBits: Int = 10

    /// Exponent bias: 15
    public static let exponentBias: Int = 15

    /// Maximum exponent value (before bias): 31
    public static let maxExponent: Int = (1 << exponentBits) - 1

    /// Precision (including implicit bit) - IEEE 754-2019 Table 3.5
    ///
    /// The precision p is the number of significant bits in the significand,
    /// including the implicit leading bit. For binary16, p = 11.
    public static let precision: Int = 11

    /// Minimum exponent - IEEE 754-2019 Table 3.5
    ///
    /// The minimum exponent emin for binary16 is -14. This is the smallest
    /// exponent for normal numbers.
    public static let emin: Int = -14

    /// Maximum exponent - IEEE 754-2019 Table 3.5
    ///
    /// The maximum exponent emax for binary16 is 15. This is the largest
    /// exponent for normal numbers.
    public static let emax: Int = 15
}

#if canImport(FloatingPointTypes) && compiler(>=5.9)
    extension IEEE_754.Binary16 {
        /// Machine epsilon (2^-10) - IEEE 754-2019
        ///
        /// Machine epsilon is 2^-(p-1) = 2^-10 for binary16. This is the difference
        /// between 1.0 and the next representable value.
        ///
        /// Example:
        /// ```swift
        /// let eps = IEEE_754.Binary16.epsilon  // 2^-10 ≈ 0.0009765625
        /// ```
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let epsilon: Float16 = 0x1.0p-10

        /// Smallest normal value - IEEE 754-2019
        ///
        /// The smallest positive normal number for binary16. Equal to 2^emin.
        ///
        /// Example:
        /// ```swift
        /// let min = IEEE_754.Binary16.minNormal  // 2^-14 ≈ 6.103515625e-05
        /// ```
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let minNormal: Float16 = Float16.leastNormalMagnitude

        /// Smallest subnormal value - IEEE 754-2019
        ///
        /// The smallest positive subnormal (denormalized) number for binary16.
        /// Equal to 2^(emin - (p-1)) = 2^-24.
        ///
        /// Example:
        /// ```swift
        /// let min = IEEE_754.Binary16.minSubnormal  // 2^-24 ≈ 5.960464477539063e-08
        /// ```
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let minSubnormal: Float16 = Float16.leastNonzeroMagnitude

        /// Largest normal value - IEEE 754-2019
        ///
        /// The largest finite representable number for binary16.
        ///
        /// Example:
        /// ```swift
        /// let max = IEEE_754.Binary16.maxNormal  // ≈ 65504
        /// ```
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let maxNormal: Float16 = Float16.greatestFiniteMagnitude
    }

    extension IEEE_754.Binary16 {
        /// Special IEEE 754 values for Binary16
        ///
        /// This namespace provides access to all special values defined in IEEE 754-2019
        /// for the binary16 format.
        ///
        /// ## Overview
        ///
        /// IEEE 754 defines several special values:
        /// - Positive and negative zero (signed zeros)
        /// - Positive and negative infinity
        /// - Quiet NaN (Not a Number)
        /// - Signaling NaN
        ///
        /// ## See Also
        /// - IEEE 754-2019 Section 6.2: Special values
        public enum SpecialValues {}
    }

    extension IEEE_754.Binary16.SpecialValues {
        /// Positive zero (+0.0)
        ///
        /// IEEE 754 distinguishes between positive and negative zero.
        /// Positive zero has sign bit = 0, exponent = 0, fraction = 0.
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let positiveZero: Float16 = 0.0

        /// Negative zero (-0.0)
        ///
        /// IEEE 754 distinguishes between positive and negative zero.
        /// Negative zero has sign bit = 1, exponent = 0, fraction = 0.
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let negativeZero: Float16 = -0.0

        /// Positive infinity (+∞)
        ///
        /// Represents overflow to positive infinity.
        /// Has sign bit = 0, exponent = 31, fraction = 0.
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let positiveInfinity: Float16 = Float16.infinity

        /// Negative infinity (-∞)
        ///
        /// Represents overflow to negative infinity.
        /// Has sign bit = 1, exponent = 31, fraction = 0.
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let negativeInfinity: Float16 = -Float16.infinity

        /// Quiet NaN (Not a Number)
        ///
        /// Represents an undefined or unrepresentable value. Quiet NaN does not
        /// raise exceptions and propagates through operations.
        /// Has exponent = 31, fraction ≠ 0, with the most significant fraction bit = 1.
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let quietNaN: Float16 = Float16.nan

        /// Signaling NaN
        ///
        /// Represents an undefined or unrepresentable value that should raise an
        /// exception when used. Has exponent = 31, fraction ≠ 0, with the most
        /// significant fraction bit = 0.
        ///
        /// Note: Swift's exception handling for signaling NaN may vary by platform.
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        public static let signalingNaN: Float16 = Float16.signalingNaN
    }

    extension IEEE_754.Binary16 {
        /// Serializes Float16 to IEEE 754 binary16 byte representation
        ///
        /// Authoritative serialization method. Converts a Float16 to a 2-byte array
        /// in IEEE 754 binary16 format. This is a lossless transformation preserving
        /// all bits of the floating-point value.
        ///
        /// - Parameters:
        ///   - value: Float16 to serialize
        ///   - endianness: Byte order (defaults to little-endian)
        /// - Returns: 2-byte array in IEEE 754 binary16 format
        ///
        /// Example:
        /// ```swift
        /// let bytes = IEEE_754.Binary16.bytes(from: Float16(3.14))
        /// let bytes = IEEE_754.Binary16.bytes(from: Float16(3.14), endianness: .big)
        /// ```
        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        @inlinable
        public static func bytes(
            from value: Float16,
            endianness: Binary.Endianness = .little
        ) -> [UInt8] {
            let bitPattern = value.bitPattern
            return [UInt8](bitPattern, endianness: endianness)
        }

        /// Deserializes IEEE 754 binary16 bytes to Float16
        ///
        /// Authoritative deserialization method. Converts a 2-byte array in
        /// IEEE 754 binary16 format back to a Float16. This is the inverse of
        /// the serialization operation, preserving all bits of the original value.
        ///
        /// - Parameters:
        ///   - bytes: 2-byte array in IEEE 754 binary16 format
        ///   - endianness: Byte order of input bytes (defaults to little-endian)
        /// - Returns: Float16 value, or nil if bytes.count ≠ 2
        ///
        /// Example:
        /// ```swift
        /// let value = IEEE_754.Binary16.value(from: bytes)
        /// let value = IEEE_754.Binary16.value(from: bytes, endianness: .big)
        /// ```
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
