// IEEE_754.Binary32.swift
// swift-ieee-754
//
// IEEE 754 binary32 (single precision) format

public import Binary_Primitives

extension IEEE_754 {
    /// IEEE 754 binary32 (single precision) format
    ///
    /// ## Format Specification (IEEE 754-2019 Section 3.6)
    ///
    /// Total: 32 bits (4 bytes)
    /// - Sign: 1 bit
    /// - Exponent: 8 bits (biased by 127)
    /// - Significand: 23 bits (plus implicit leading 1)
    ///
    /// ## Encoding
    ///
    /// ```
    /// seee eeee efff ffff ffff ffff ffff ffff
    /// │└──┬──┘ └────────────┬──────────────┘
    /// │ exponent      significand
    /// sign      (23 bits)
    /// (8 bits)
    /// ```
    ///
    /// ## Special Values
    ///
    /// - Zero: exponent = 0, fraction = 0
    /// - Subnormal: exponent = 0, fraction ≠ 0
    /// - Infinity: exponent = 255, fraction = 0
    /// - NaN: exponent = 255, fraction ≠ 0
    ///
    /// ## Overview
    ///
    /// Binary32 corresponds to Swift's `Float` type. This namespace provides
    /// the canonical binary serialization and deserialization:
    /// ```
    /// Float ↔ [UInt8] (IEEE 754 binary32 bytes)
    /// ```
    public enum Binary32 {}
}

extension IEEE_754.Binary32 {
    /// Number of bytes in binary32 format
    public static let byteSize: Int = 4

    /// Number of bits in binary32 format
    public static let bitSize: Int = 32

    /// Sign bit: 1 bit
    public static let signBits: Int = 1

    /// Exponent bits: 8 bits
    public static let exponentBits: Int = 8

    /// Significand bits: 23 bits (plus implicit leading 1)
    public static let significandBits: Int = 23

    /// Exponent bias: 127
    public static let exponentBias: Int = 127

    /// Maximum exponent value (before bias)
    public static let maxExponent: Int = (1 << exponentBits) - 1

    /// Precision (including implicit bit) - IEEE 754-2019 Table 3.5
    ///
    /// The precision p is the number of significant bits in the significand,
    /// including the implicit leading bit. For binary32, p = 24.
    public static let precision: Int = 24

    /// Minimum exponent - IEEE 754-2019 Table 3.5
    ///
    /// The minimum exponent emin for binary32 is -126. This is the smallest
    /// exponent for normal numbers.
    public static let emin: Int = -126

    /// Maximum exponent - IEEE 754-2019 Table 3.5
    ///
    /// The maximum exponent emax for binary32 is 127. This is the largest
    /// exponent for normal numbers.
    public static let emax: Int = 127

    /// Machine epsilon - IEEE 754-2019
    ///
    /// Machine epsilon is 2^-(p-1) = 2^-23 for binary32. This is the difference
    /// between 1.0 and the next representable value.
    ///
    /// Example:
    /// ```swift
    /// let eps = IEEE_754.Binary32.epsilon  // 2^-23 ≈ 1.1920929e-07
    /// ```
    public static let epsilon: Float = 0x1.0p-23

    /// Smallest normal value - IEEE 754-2019
    ///
    /// The smallest positive normal number for binary32. Equal to 2^emin.
    ///
    /// Example:
    /// ```swift
    /// let min = IEEE_754.Binary32.minNormal  // 2^-126 ≈ 1.1754944e-38
    /// ```
    public static let minNormal: Float = Float.leastNormalMagnitude

    /// Smallest subnormal value - IEEE 754-2019
    ///
    /// The smallest positive subnormal (denormalized) number for binary32.
    /// Equal to 2^(emin - (p-1)).
    ///
    /// Example:
    /// ```swift
    /// let min = IEEE_754.Binary32.minSubnormal  // 2^-149 ≈ 1.4012985e-45
    /// ```
    public static let minSubnormal: Float = Float.leastNonzeroMagnitude

    /// Largest normal value - IEEE 754-2019
    ///
    /// The largest finite representable number for binary32.
    ///
    /// Example:
    /// ```swift
    /// let max = IEEE_754.Binary32.maxNormal  // ≈ 3.4028235e+38
    /// ```
    public static let maxNormal: Float = Float.greatestFiniteMagnitude
}

extension IEEE_754.Binary32 {
    /// Special IEEE 754 values for Binary32
    ///
    /// This namespace provides access to all special values defined in IEEE 754-2019
    /// for the binary32 format.
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

extension IEEE_754.Binary32.SpecialValues {
    /// Positive zero (+0.0)
    ///
    /// IEEE 754 distinguishes between positive and negative zero.
    /// Positive zero has sign bit = 0, exponent = 0, fraction = 0.
    public static let positiveZero: Float = 0.0

    /// Negative zero (-0.0)
    ///
    /// IEEE 754 distinguishes between positive and negative zero.
    /// Negative zero has sign bit = 1, exponent = 0, fraction = 0.
    ///
    /// Example:
    /// ```swift
    /// let nz = IEEE_754.Binary32.SpecialValues.negativeZero
    /// nz == 0.0  // true (compares equal to positive zero)
    /// nz.sign    // .minus
    /// ```
    public static let negativeZero: Float = -0.0

    /// Positive infinity (+∞)
    ///
    /// Represents overflow to positive infinity.
    /// Has sign bit = 0, exponent = 255, fraction = 0.
    ///
    /// Example:
    /// ```swift
    /// let inf = IEEE_754.Binary32.SpecialValues.positiveInfinity
    /// inf.isInfinite  // true
    /// ```
    public static let positiveInfinity: Float = Float.infinity

    /// Negative infinity (-∞)
    ///
    /// Represents overflow to negative infinity.
    /// Has sign bit = 1, exponent = 255, fraction = 0.
    public static let negativeInfinity: Float = -Float.infinity

    /// Quiet NaN (Not a Number)
    ///
    /// Represents an undefined or unrepresentable value. Quiet NaN does not
    /// raise exceptions and propagates through operations.
    /// Has exponent = 255, fraction ≠ 0, with the most significant fraction bit = 1.
    ///
    /// Example:
    /// ```swift
    /// let qnan = IEEE_754.Binary32.SpecialValues.quietNaN
    /// qnan.isNaN  // true
    /// ```
    public static let quietNaN: Float = Float.nan

    /// Signaling NaN
    ///
    /// Represents an undefined or unrepresentable value that should raise an
    /// exception when used. Has exponent = 255, fraction ≠ 0, with the most
    /// significant fraction bit = 0.
    ///
    /// Note: Swift's exception handling for signaling NaN may vary by platform.
    public static let signalingNaN: Float = Float.signalingNaN
}

extension IEEE_754.Binary32 {
    /// Serializes Float to IEEE 754 binary32 byte representation
    ///
    /// Authoritative serialization method. Converts a Float to a 4-byte array
    /// in IEEE 754 binary32 format. This is a lossless transformation preserving
    /// all bits of the floating-point value.
    ///
    /// - Parameters:
    ///   - value: Float to serialize
    ///   - endianness: Byte order (defaults to little-endian)
    /// - Returns: 4-byte array in IEEE 754 binary32 format
    ///
    /// Example:
    /// ```swift
    /// let bytes = IEEE_754.Binary32.bytes(from: Float(3.14))
    /// let bytes = IEEE_754.Binary32.bytes(from: Float(3.14), endianness: .big)
    /// ```
    @inlinable
    public static func bytes(
        from value: Float,
        endianness: Binary.Endianness = .little
    ) -> [UInt8] {
        let bitPattern = value.bitPattern
        return [UInt8](bitPattern, endianness: endianness)
    }

    /// Deserializes IEEE 754 binary32 bytes to Float
    ///
    /// Authoritative deserialization method. Converts a 4-byte array in
    /// IEEE 754 binary32 format back to a Float. This is the inverse of
    /// the serialization operation, preserving all bits of the original value.
    ///
    /// - Parameters:
    ///   - bytes: 4-byte array in IEEE 754 binary32 format
    ///   - endianness: Byte order of input bytes (defaults to little-endian)
    /// - Returns: Float value, or nil if bytes.count ≠ 4
    ///
    /// Example:
    /// ```swift
    /// let value = IEEE_754.Binary32.value(from: bytes)
    /// let value = IEEE_754.Binary32.value(from: bytes, endianness: .big)
    /// ```
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
