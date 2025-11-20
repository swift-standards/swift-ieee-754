// [UInt8]+IEEE_754.swift
// swift-ieee-754
//
// Convenient namespaced access to IEEE 754 serialization

import Standards

extension [UInt8] {
    /// Access to IEEE 754 type-level constants and methods
    public static var ieee754: IEEE754.Type {
        IEEE754.self
    }

    /// Access to IEEE 754 instance methods for this byte array
    public var ieee754: IEEE754 {
        IEEE754(bytes: self)
    }

    public struct IEEE754 {
        public let bytes: [UInt8]

        public init(bytes: [UInt8]) {
            self.bytes = bytes
        }
    }
}

// MARK: - Type-level Methods (Serialization)

extension [UInt8].IEEE754 {
    /// Creates byte array from Double using IEEE 754 binary64 format
    ///
    /// Convenience that delegates to `IEEE_754.Binary64.bytes(from:endianness:)`.
    ///
    /// - Parameters:
    ///   - value: Double to serialize
    ///   - endianness: Byte order (little or big)
    /// - Returns: 8-byte array in IEEE 754 binary64 format
    ///
    /// Example:
    /// ```swift
    /// let bytes = [UInt8].ieee754.bytes(from: 3.14159)
    /// let bytes = [UInt8].ieee754.bytes(from: 3.14159, endianness: .big)
    /// ```
    public static func bytes(
        from value: Double,
        endianness: [UInt8].Endianness = .little
    ) -> [UInt8] {
        IEEE_754.Binary64.bytes(from: value, endianness: endianness)
    }

    /// Creates byte array from Float using IEEE 754 binary32 format
    ///
    /// Convenience that delegates to `IEEE_754.Binary32.bytes(from:endianness:)`.
    ///
    /// - Parameters:
    ///   - value: Float to serialize
    ///   - endianness: Byte order (little or big)
    /// - Returns: 4-byte array in IEEE 754 binary32 format
    ///
    /// Example:
    /// ```swift
    /// let bytes = [UInt8].ieee754.bytes(from: Float(3.14))
    /// let bytes = [UInt8].ieee754.bytes(from: Float(3.14), endianness: .big)
    /// ```
    public static func bytes(
        from value: Float,
        endianness: [UInt8].Endianness = .little
    ) -> [UInt8] {
        IEEE_754.Binary32.bytes(from: value, endianness: endianness)
    }
}

// MARK: - Instance Methods (Deserialization)

extension [UInt8].IEEE754 {
    /// Interprets bytes as IEEE 754 binary64 and returns Double
    ///
    /// Convenience that delegates to `IEEE_754.Binary64.value(from:endianness:)`.
    ///
    /// - Parameter endianness: Byte order of input bytes
    /// - Returns: Double value, or nil if bytes.count ≠ 8
    ///
    /// Example:
    /// ```swift
    /// let value = bytes.ieee754.asDouble()
    /// let value = bytes.ieee754.asDouble(endianness: .big)
    /// ```
    public func asDouble(endianness: [UInt8].Endianness = .little) -> Double? {
        IEEE_754.Binary64.value(from: bytes, endianness: endianness)
    }

    /// Interprets bytes as IEEE 754 binary32 and returns Float
    ///
    /// Convenience that delegates to `IEEE_754.Binary32.value(from:endianness:)`.
    ///
    /// - Parameter endianness: Byte order of input bytes
    /// - Returns: Float value, or nil if bytes.count ≠ 4
    ///
    /// Example:
    /// ```swift
    /// let value = bytes.ieee754.asFloat()
    /// let value = bytes.ieee754.asFloat(endianness: .big)
    /// ```
    public func asFloat(endianness: [UInt8].Endianness = .little) -> Float? {
        IEEE_754.Binary32.value(from: bytes, endianness: endianness)
    }
}

// MARK: - Canonical [UInt8] Initializers

extension [UInt8] {
    /// Creates byte array from Double using IEEE 754 binary64 format
    ///
    /// This is the canonical binary serialization for Double, following the
    /// FixedWidthInteger pattern. IEEE 754 is THE authoritative representation
    /// for floating-point values, not one encoding among many.
    ///
    /// - Parameters:
    ///   - value: Double to serialize
    ///   - endianness: Byte order (defaults to little-endian)
    ///
    /// Example:
    /// ```swift
    /// let bytes = [UInt8](3.14159)                    // Little-endian
    /// let bytes = [UInt8](3.14159, endianness: .big)  // Big-endian (network order)
    /// ```
    public init(_ value: Double, endianness: Endianness = .little) {
        self = IEEE_754.Binary64.bytes(from: value, endianness: endianness)
    }

    /// Creates byte array from Float using IEEE 754 binary32 format
    ///
    /// This is the canonical binary serialization for Float, following the
    /// FixedWidthInteger pattern. IEEE 754 is THE authoritative representation
    /// for floating-point values, not one encoding among many.
    ///
    /// - Parameters:
    ///   - value: Float to serialize
    ///   - endianness: Byte order (defaults to little-endian)
    ///
    /// Example:
    /// ```swift
    /// let bytes = [UInt8](Float(3.14))                    // Little-endian
    /// let bytes = [UInt8](Float(3.14), endianness: .big)  // Big-endian (network order)
    /// ```
    public init(_ value: Float, endianness: Endianness = .little) {
        self = IEEE_754.Binary32.bytes(from: value, endianness: endianness)
    }
}
