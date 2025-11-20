// Float+IEEE_754.swift
// swift-ieee-754
//
// IEEE 754 extensions for Float (binary32)

import Standards

extension Float {
    /// Access to IEEE 754 binary32 constants and methods
    public static var ieee754: IEEE754.Type {
        IEEE754.self
    }

    /// Access to IEEE 754 instance methods for this Float
    public var ieee754: IEEE754 {
        IEEE754(float: self)
    }

    public struct IEEE754 {
        public let float: Float

        init(float: Float) {
            self.float = float
        }
    }
}

// MARK: - Canonical Deserialization

extension Float {
    /// Creates Float from IEEE 754 binary32 bytes
    ///
    /// This is the canonical deserialization for Float, following the
    /// FixedWidthInteger pattern. IEEE 754 is THE authoritative representation
    /// for floating-point values.
    ///
    /// Delegates to `IEEE_754.Binary32.value(from:endianness:)`.
    ///
    /// - Parameters:
    ///   - bytes: 4-byte array in IEEE 754 binary32 format
    ///   - endianness: Byte order of input bytes
    /// - Returns: nil if bytes.count ≠ 4
    ///
    /// Example:
    /// ```swift
    /// let value = Float(bytes: data)
    /// let value = Float(bytes: data, endianness: .big)
    /// ```
    public init?(bytes: [UInt8], endianness: [UInt8].Endianness = .little) {
        guard let value = IEEE_754.Binary32.value(from: bytes, endianness: endianness) else {
            return nil
        }
        self = value
    }
}

// MARK: - Type-level Methods

extension Float {
    /// Creates Float from IEEE 754 binary32 bytes
    ///
    /// Delegates to `IEEE_754.Binary32.value(from:endianness:)`.
    ///
    /// - Parameters:
    ///   - bytes: 4-byte array in IEEE 754 binary32 format
    ///   - endianness: Byte order of input bytes
    /// - Returns: Float value, or nil if bytes.count ≠ 4
    ///
    /// Example:
    /// ```swift
    /// let value = Float.ieee754(bytes)
    /// let value = Float.ieee754(bytes, endianness: .big)
    /// ```
    public static func ieee754(
        _ bytes: [UInt8],
        endianness: [UInt8].Endianness = .little
    ) -> Float? {
        IEEE_754.Binary32.value(from: bytes, endianness: endianness)
    }
}

// MARK: - Instance Methods

extension Float.IEEE754 {
    /// Returns IEEE 754 binary32 byte representation
    ///
    /// Convenience that delegates to `IEEE_754.Binary32.bytes(from:endianness:)`.
    ///
    /// - Parameter endianness: Byte order (little or big)
    /// - Returns: 4-byte array in IEEE 754 binary32 format
    ///
    /// Example:
    /// ```swift
    /// let bytes = Float(3.14).ieee754.bytes()
    /// let bytes = Float(3.14).ieee754.bytes(endianness: .big)
    /// ```
    public func bytes(endianness: [UInt8].Endianness = .little) -> [UInt8] {
        IEEE_754.Binary32.bytes(from: float, endianness: endianness)
    }

    /// Returns the IEEE 754 binary32 bit pattern
    ///
    /// Direct access to the underlying bit representation.
    ///
    /// Example:
    /// ```swift
    /// let pattern = Float(3.14).ieee754.bitPattern
    /// ```
    public var bitPattern: UInt32 {
        float.bitPattern
    }
}
