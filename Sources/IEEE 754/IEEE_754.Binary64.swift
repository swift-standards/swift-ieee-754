// IEEE_754.Binary64.swift
// swift-ieee-754
//
// IEEE 754 binary64 (double precision) format

public import Binary_Primitives

extension IEEE_754 {
    /// IEEE 754 binary64 (double precision) format
    ///
    /// ## Format Specification (IEEE 754-2019 Section 3.6)
    ///
    /// Total: 64 bits (8 bytes)
    /// - Sign: 1 bit
    /// - Exponent: 11 bits (biased by 1023)
    /// - Significand: 52 bits (plus implicit leading 1)
    ///
    /// ## Encoding
    ///
    /// ```
    /// seee eeee eeee ffff ... ffff
    /// │└────┬────┘ └──────┬──────┘
    /// │  exponent    significand
    /// sign (52 bits)
    /// (11 bits)
    /// ```
    ///
    /// ## Special Values
    ///
    /// - Zero: exponent = 0, fraction = 0
    /// - Subnormal: exponent = 0, fraction ≠ 0
    /// - Infinity: exponent = 2047, fraction = 0
    /// - NaN: exponent = 2047, fraction ≠ 0
    ///
    /// ## Overview
    ///
    /// Binary64 corresponds to Swift's `Double` type. This namespace provides
    /// the canonical binary serialization and deserialization:
    /// ```
    /// Double ↔ [UInt8] (IEEE 754 binary64 bytes)
    /// ```
    public enum Binary64 {}
}

extension IEEE_754.Binary64 {
    /// Number of bytes in binary64 format
    public static let byteSize: Int = 8

    /// Number of bits in binary64 format
    public static let bitSize: Int = 64

    /// Sign bit: 1 bit
    public static let signBits: Int = 1

    /// Exponent bits: 11 bits
    public static let exponentBits: Int = 11

    /// Significand bits: 52 bits (plus implicit leading 1)
    public static let significandBits: Int = 52

    /// Exponent bias: 1023
    public static let exponentBias: Int = 1023

    /// Maximum exponent value (before bias)
    public static let maxExponent: Int = (1 << exponentBits) - 1

    /// Precision (including implicit bit) - IEEE 754-2019 Table 3.5
    ///
    /// The precision p is the number of significant bits in the significand,
    /// including the implicit leading bit. For binary64, p = 53.
    public static let precision: Int = 53

    /// Minimum exponent - IEEE 754-2019 Table 3.5
    ///
    /// The minimum exponent emin for binary64 is -1022. This is the smallest
    /// exponent for normal numbers.
    public static let emin: Int = -1022

    /// Maximum exponent - IEEE 754-2019 Table 3.5
    ///
    /// The maximum exponent emax for binary64 is 1023. This is the largest
    /// exponent for normal numbers.
    public static let emax: Int = 1023

    /// Machine epsilon - IEEE 754-2019
    ///
    /// Machine epsilon is 2^-(p-1) = 2^-52 for binary64. This is the difference
    /// between 1.0 and the next representable value.
    ///
    /// Example:
    /// ```swift
    /// let eps = IEEE_754.Binary64.epsilon  // 2^-52 ≈ 2.220446049250313e-16
    /// ```
    public static let epsilon: Double = 0x1.0p-52

    /// Smallest normal value - IEEE 754-2019
    ///
    /// The smallest positive normal number for binary64. Equal to 2^emin.
    ///
    /// Example:
    /// ```swift
    /// let min = IEEE_754.Binary64.minNormal  // 2^-1022 ≈ 2.2250738585072014e-308
    /// ```
    public static let minNormal: Double = Double.leastNormalMagnitude

    /// Smallest subnormal value - IEEE 754-2019
    ///
    /// The smallest positive subnormal (denormalized) number for binary64.
    /// Equal to 2^(emin - (p-1)).
    ///
    /// Example:
    /// ```swift
    /// let min = IEEE_754.Binary64.minSubnormal  // 2^-1074 ≈ 4.9406564584124654e-324
    /// ```
    public static let minSubnormal: Double = Double.leastNonzeroMagnitude

    /// Largest normal value - IEEE 754-2019
    ///
    /// The largest finite representable number for binary64.
    ///
    /// Example:
    /// ```swift
    /// let max = IEEE_754.Binary64.maxNormal  // ≈ 1.7976931348623157e+308
    /// ```
    public static let maxNormal: Double = Double.greatestFiniteMagnitude
}

extension IEEE_754.Binary64 {
    /// Special IEEE 754 values for Binary64
    ///
    /// This namespace provides access to all special values defined in IEEE 754-2019
    /// for the binary64 format.
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

extension IEEE_754.Binary64.SpecialValues {
    /// Positive zero (+0.0)
    ///
    /// IEEE 754 distinguishes between positive and negative zero.
    /// Positive zero has sign bit = 0, exponent = 0, fraction = 0.
    public static let positiveZero: Double = 0.0

    /// Negative zero (-0.0)
    ///
    /// IEEE 754 distinguishes between positive and negative zero.
    /// Negative zero has sign bit = 1, exponent = 0, fraction = 0.
    ///
    /// Example:
    /// ```swift
    /// let nz = IEEE_754.Binary64.SpecialValues.negativeZero
    /// nz == 0.0  // true (compares equal to positive zero)
    /// nz.sign    // .minus
    /// ```
    public static let negativeZero: Double = -0.0

    /// Positive infinity (+∞)
    ///
    /// Represents overflow to positive infinity.
    /// Has sign bit = 0, exponent = 2047, fraction = 0.
    ///
    /// Example:
    /// ```swift
    /// let inf = IEEE_754.Binary64.SpecialValues.positiveInfinity
    /// inf.isInfinite  // true
    /// ```
    public static let positiveInfinity: Double = Double.infinity

    /// Negative infinity (-∞)
    ///
    /// Represents overflow to negative infinity.
    /// Has sign bit = 1, exponent = 2047, fraction = 0.
    public static let negativeInfinity: Double = -Double.infinity

    /// Quiet NaN (Not a Number)
    ///
    /// Represents an undefined or unrepresentable value. Quiet NaN does not
    /// raise exceptions and propagates through operations.
    /// Has exponent = 2047, fraction ≠ 0, with the most significant fraction bit = 1.
    ///
    /// Example:
    /// ```swift
    /// let qnan = IEEE_754.Binary64.SpecialValues.quietNaN
    /// qnan.isNaN  // true
    /// ```
    public static let quietNaN: Double = Double.nan

    /// Signaling NaN
    ///
    /// Represents an undefined or unrepresentable value that should raise an
    /// exception when used. Has exponent = 2047, fraction ≠ 0, with the most
    /// significant fraction bit = 0.
    ///
    /// Note: Swift's exception handling for signaling NaN may vary by platform.
    public static let signalingNaN: Double = Double.signalingNaN
}

extension IEEE_754.Binary64 {
    /// Serializes Double to IEEE 754 binary64 byte representation
    ///
    /// Authoritative serialization method. Converts a Double to an 8-byte array
    /// in IEEE 754 binary64 format. This is a lossless transformation preserving
    /// all bits of the floating-point value.
    ///
    /// - Parameters:
    ///   - value: Double to serialize
    ///   - endianness: Byte order (defaults to little-endian)
    /// - Returns: 8-byte array in IEEE 754 binary64 format
    ///
    /// Example:
    /// ```swift
    /// let bytes = IEEE_754.Binary64.bytes(from: 3.14159)
    /// let bytes = IEEE_754.Binary64.bytes(from: 3.14159, endianness: .big)
    /// ```
    @inlinable
    public static func bytes(
        from value: Double,
        endianness: Binary.Endianness = .little
    ) -> [UInt8] {
        let bitPattern = value.bitPattern
        return [UInt8](bitPattern, endianness: endianness)
    }

    /// Deserializes IEEE 754 binary64 bytes to Double
    ///
    /// Authoritative deserialization method. Converts an 8-byte array in
    /// IEEE 754 binary64 format back to a Double. This is the inverse of
    /// the serialization operation, preserving all bits of the original value.
    ///
    /// - Parameters:
    ///   - bytes: 8-byte array in IEEE 754 binary64 format
    ///   - endianness: Byte order of input bytes (defaults to little-endian)
    /// - Returns: Double value, or nil if bytes.count ≠ 8
    ///
    /// Example:
    /// ```swift
    /// let value = IEEE_754.Binary64.value(from: bytes)
    /// let value = IEEE_754.Binary64.value(from: bytes, endianness: .big)
    /// ```
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
