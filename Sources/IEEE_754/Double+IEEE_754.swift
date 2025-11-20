// Double+IEEE_754.swift
// swift-ieee-754
//
// IEEE 754 extensions for Double (binary64)

import Standards

extension Double {
    /// Access to IEEE 754 binary64 constants and methods
    public static var ieee754: IEEE754.Type {
        IEEE754.self
    }

    /// Access to IEEE 754 instance methods for this Double
    public var ieee754: IEEE754 {
        IEEE754(double: self)
    }

    public struct IEEE754 {
        public let double: Double

        init(double: Double) {
            self.double = double
        }
    }
}

// MARK: - Canonical Deserialization

extension Double {
    /// Creates Double from IEEE 754 binary64 bytes
    ///
    /// This is the canonical deserialization for Double, following the
    /// FixedWidthInteger pattern. IEEE 754 is THE authoritative representation
    /// for floating-point values.
    ///
    /// Delegates to `IEEE_754.Binary64.value(from:endianness:)`.
    ///
    /// - Parameters:
    ///   - bytes: 8-byte array in IEEE 754 binary64 format
    ///   - endianness: Byte order of input bytes
    /// - Returns: nil if bytes.count ≠ 8
    ///
    /// Example:
    /// ```swift
    /// let value = Double(bytes: data)
    /// let value = Double(bytes: data, endianness: .big)
    /// ```
    public init?(bytes: [UInt8], endianness: [UInt8].Endianness = .little) {
        guard let value = IEEE_754.Binary64.value(from: bytes, endianness: endianness) else {
            return nil
        }
        self = value
    }
}

// MARK: - Type-level Methods

extension Double {
    /// Creates Double from IEEE 754 binary64 bytes
    ///
    /// Delegates to `IEEE_754.Binary64.value(from:endianness:)`.
    ///
    /// - Parameters:
    ///   - bytes: 8-byte array in IEEE 754 binary64 format
    ///   - endianness: Byte order of input bytes
    /// - Returns: Double value, or nil if bytes.count ≠ 8
    ///
    /// Example:
    /// ```swift
    /// let value = Double.ieee754(bytes)
    /// let value = Double.ieee754(bytes, endianness: .big)
    /// ```
    public static func ieee754(
        _ bytes: [UInt8],
        endianness: [UInt8].Endianness = .little
    ) -> Double? {
        IEEE_754.Binary64.value(from: bytes, endianness: endianness)
    }
}

// MARK: - Instance Methods

extension Double.IEEE754 {
    /// Returns IEEE 754 binary64 byte representation
    ///
    /// Convenience that delegates to `IEEE_754.Binary64.bytes(from:endianness:)`.
    ///
    /// - Parameter endianness: Byte order (little or big)
    /// - Returns: 8-byte array in IEEE 754 binary64 format
    ///
    /// Example:
    /// ```swift
    /// let bytes = (3.14159).ieee754.bytes()
    /// let bytes = (3.14159).ieee754.bytes(endianness: .big)
    /// ```
    public func bytes(endianness: [UInt8].Endianness = .little) -> [UInt8] {
        IEEE_754.Binary64.bytes(from: double, endianness: endianness)
    }

    /// Returns the IEEE 754 binary64 bit pattern
    ///
    /// Direct access to the underlying bit representation.
    ///
    /// Example:
    /// ```swift
    /// let pattern = (3.14159).ieee754.bitPattern
    /// ```
    public var bitPattern: UInt64 {
        double.bitPattern
    }
}
