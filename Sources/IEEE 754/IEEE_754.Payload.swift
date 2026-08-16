// IEEE_754.Payload.swift
// swift-ieee-754
//
// IEEE 754-2019 Section 6.2: NaN Payload Operations
// Authoritative implementations for NaN payload manipulation

// MARK: - IEEE 754 Payload Operations

extension IEEE_754 {
    /// IEEE 754 NaN payload operations (Section 6.2)
    ///
    /// Implements operations for extracting and encoding NaN payloads as defined
    /// in IEEE 754-2019.
    ///
    /// ## Overview
    ///
    /// The IEEE 754 standard defines NaN (Not a Number) values with payloads.
    /// These payloads can carry diagnostic information about the source of the
    /// NaN. The standard defines operations to:
    ///
    /// - Extract the payload from a NaN value
    /// - Encode a payload into a quiet or signaling NaN
    ///
    /// ## NaN Encoding
    ///
    /// In IEEE 754 binary formats:
    /// - NaN values have all exponent bits set to 1 and a non-zero fraction
    /// - Quiet NaN: Most significant fraction bit = 1
    /// - Signaling NaN: Most significant fraction bit = 0, but fraction ≠ 0
    /// - Payload: The remaining fraction bits
    ///
    /// ## Limitations
    ///
    /// Swift's standard library provides limited direct access to NaN payloads.
    /// This implementation provides best-effort support using available APIs.
    ///
    /// ## See Also
    ///
    /// - IEEE 754-2019 Section 6.2: NaN propagation and operations
    /// - IEEE 754-2019 Section 6.2.1: NaN payload operations
    public enum Payload {}
}

// MARK: - Hierarchical NaN Type Enum

extension IEEE_754.Payload {
    /// IEEE 754 NaN Type
    ///
    /// Hierarchical structure for NaN types with associated payload values.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let nan = IEEE_754.Payload.encode(.quiet(payload: 0x1234))
    ///
    /// switch nanType {
    /// case .quiet(let payload):
    ///     // Handle quiet NaN with payload
    /// case .signaling(let payload):
    ///     // Handle signaling NaN with payload
    /// }
    /// ```
    ///
    /// ## See Also
    /// - IEEE 754-2019 Section 6.2: NaN propagation and operations
    public enum NaNType: Sendable, Equatable {
        /// Quiet NaN with payload
        case quiet(payload: UInt64)
        /// Signaling NaN with payload
        case signaling(payload: UInt64)
    }

    /// Encode a NaN value from NaNType for Double
    ///
    /// Creates a NaN with the specified type and payload.
    ///
    /// - Parameter type: The NaN type with payload
    /// - Returns: A NaN value
    @inlinable
    public static func encode(_ type: NaNType) -> Double {
        switch type {
        case .quiet(let payload):
            return encodeQuietNaN(payload: payload)

        case .signaling(let payload):
            return encodeSignalingNaN(payload: payload)
        }
    }

    /// Encode a NaN value from NaNType for Float
    ///
    /// Creates a NaN with the specified type and payload.
    ///
    /// - Parameter type: The NaN type with payload
    /// - Returns: A NaN value
    @inlinable
    public static func encode(_ type: NaNType) -> Float {
        switch type {
        case .quiet(let payload):
            return encodeQuietNaN(payload: UInt32(payload & 0x001F_FFFF))

        case .signaling(let payload):
            return encodeSignalingNaN(payload: UInt32(payload & 0x001F_FFFF))
        }
    }

    /// Decode a Double NaN value to NaNType
    ///
    /// Extracts the type and payload from a NaN value.
    ///
    /// - Parameter value: The value to decode
    /// - Returns: The NaN type with payload, or nil if not NaN
    @inlinable
    public static func decode(_ value: Double) -> NaNType? {
        guard value.isNaN else { return nil }

        if let payload = extract(from: value) {
            if value.isSignalingNaN {
                return .signaling(payload: payload)
            } else {
                return .quiet(payload: payload)
            }
        }
        return nil
    }

    /// Decode a Float NaN value to NaNType
    ///
    /// Extracts the type and payload from a NaN value.
    ///
    /// - Parameter value: The value to decode
    /// - Returns: The NaN type with payload, or nil if not NaN
    @inlinable
    public static func decode(_ value: Float) -> NaNType? {
        guard value.isNaN else { return nil }

        if let payload = extract(from: value) {
            if value.isSignalingNaN {
                return .signaling(payload: UInt64(payload))
            } else {
                return .quiet(payload: UInt64(payload))
            }
        }
        return nil
    }
}

// MARK: - Double Payload Operations

extension IEEE_754.Payload {
    /// Extract NaN payload - IEEE 754 related operation
    ///
    /// Extracts the payload from a NaN value. Returns nil if the value is not NaN.
    /// The payload is the fraction bits of the NaN (excluding the quiet/signaling bit).
    ///
    /// - Parameter value: The value (must be NaN)
    /// - Returns: The payload as UInt64, or nil if not NaN
    ///
    /// Example:
    /// ```swift
    /// let payload = IEEE_754.Payload.extract(from: .nan)
    /// // Returns the payload bits from the NaN
    /// ```
    ///
    /// Note: Swift's standard library has limited payload access. This implementation
    /// extracts what is available through the bitPattern API.
    @inlinable
    public static func extract(from value: Double) -> UInt64? {
        guard value.isNaN else { return nil }

        // Extract the significand bits (payload)
        let bits = value.bitPattern
        // Mask off sign bit (bit 63), exponent bits (bits 62-52), and quiet bit (bit 51)
        // Keep payload bits (bits 50-0)
        // IEEE 754-2019 Section 6.2.1: Payload is fraction bits excluding quiet/signaling bit
        let payloadMask: UInt64 = 0x0007_FFFF_FFFF_FFFF
        return bits & payloadMask
    }

    /// Encode quiet NaN with payload - IEEE 754 related operation
    ///
    /// Creates a quiet NaN with the specified payload. The payload is stored
    /// in the fraction bits of the NaN.
    ///
    /// - Parameter payload: The payload to encode (will be masked to valid bits)
    /// - Returns: A quiet NaN with the payload
    ///
    /// Example:
    /// ```swift
    /// let nan = IEEE_754.Payload.encodeQuietNaN(payload: 0x1234)
    /// // Creates a quiet NaN with payload 0x1234
    /// ```
    ///
    /// Note: The quiet NaN bit is automatically set. The payload is masked to
    /// fit within the available fraction bits.
    @inlinable
    public static func encodeQuietNaN(payload: UInt64 = 0) -> Double {
        // IEEE 754 binary64 quiet NaN:
        // Sign: 0 (can be either, we use 0)
        // Exponent: 0x7FF (all 1s)
        // Fraction: 1xxx... (MSB=1 for quiet, rest is payload)

        let exponentMask: UInt64 = 0x7FF0_0000_0000_0000
        let quietBit: UInt64 = 0x0008_0000_0000_0000
        let payloadMask: UInt64 = 0x0007_FFFF_FFFF_FFFF

        let bits = exponentMask | quietBit | (payload & payloadMask)
        return Double(bitPattern: bits)
    }

    /// Encode signaling NaN with payload - IEEE 754 related operation
    ///
    /// Creates a signaling NaN with the specified payload. Note that Swift's
    /// behavior with signaling NaN may vary by platform.
    ///
    /// - Parameter payload: The payload to encode (must be non-zero)
    /// - Returns: A signaling NaN with the payload
    ///
    /// Example:
    /// ```swift
    /// let snan = IEEE_754.Payload.encodeSignalingNaN(payload: 0x1234)
    /// // Creates a signaling NaN with payload 0x1234
    /// ```
    ///
    /// Note: IEEE 754 requires signaling NaN to have MSB=0 but fraction≠0.
    /// If payload is 0, a minimal non-zero payload (1) is used.
    @inlinable
    public static func encodeSignalingNaN(payload: UInt64 = 1) -> Double {
        // IEEE 754 binary64 signaling NaN:
        // Sign: 0 (can be either, we use 0)
        // Exponent: 0x7FF (all 1s)
        // Fraction: 0xxx... where xxx ≠ 0 (MSB=0 for signaling, rest is payload)

        let exponentMask: UInt64 = 0x7FF0_0000_0000_0000
        let payloadMask: UInt64 = 0x0007_FFFF_FFFF_FFFF

        // Ensure payload is non-zero (required for signaling NaN)
        let actualPayload = (payload & payloadMask) == 0 ? 1 : (payload & payloadMask)

        let bits = exponentMask | actualPayload
        return Double(bitPattern: bits)
    }

    /// Check if NaN is quiet - IEEE 754 related operation
    ///
    /// Tests if a NaN value is quiet (as opposed to signaling).
    ///
    /// - Parameter value: The value to test
    /// - Returns: true if value is quiet NaN, false otherwise
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Payload.isQuietNaN(.nan)             // true
    /// IEEE_754.Payload.isQuietNaN(.signalingNaN)    // false
    /// IEEE_754.Payload.isQuietNaN(3.14)             // false
    /// ```
    @inlinable
    public static func isQuietNaN(_ value: Double) -> Bool {
        value.isNaN && !value.isSignalingNaN
    }

    /// Check if NaN is signaling - IEEE 754 related operation
    ///
    /// Tests if a NaN value is signaling.
    ///
    /// - Parameter value: The value to test
    /// - Returns: true if value is signaling NaN, false otherwise
    @inlinable
    public static func isSignalingNaN(_ value: Double) -> Bool {
        value.isSignalingNaN
    }
}

// MARK: - Float Payload Operations

extension IEEE_754.Payload {
    /// Extract NaN payload
    ///
    /// Extracts the payload from a Float NaN value.
    ///
    /// - Parameter value: The value (must be NaN)
    /// - Returns: The payload as UInt32, or nil if not NaN
    @inlinable
    public static func extract(from value: Float) -> UInt32? {
        guard value.isNaN else { return nil }

        let bits = value.bitPattern
        // Mask off sign bit (bit 31), exponent bits (bits 30-23), and quiet bit (bit 22)
        // Keep payload bits (bits 21-0)
        // IEEE 754-2019 Section 6.2.1: Payload is fraction bits excluding quiet/signaling bit
        let payloadMask: UInt32 = 0x001F_FFFF
        return bits & payloadMask
    }

    /// Encode quiet NaN with payload
    ///
    /// Creates a quiet NaN with the specified payload.
    ///
    /// - Parameter payload: The payload to encode
    /// - Returns: A quiet NaN with the payload
    @inlinable
    public static func encodeQuietNaN(payload: UInt32 = 0) -> Float {
        // IEEE 754 binary32 quiet NaN:
        // Exponent: 0xFF (all 1s)
        // Fraction: 1xxx... (MSB=1 for quiet)

        let exponentMask: UInt32 = 0x7F80_0000
        let quietBit: UInt32 = 0x0040_0000
        let payloadMask: UInt32 = 0x001F_FFFF

        let bits = exponentMask | quietBit | (payload & payloadMask)
        return Float(bitPattern: bits)
    }

    /// Encode signaling NaN with payload
    ///
    /// Creates a signaling NaN with the specified payload.
    ///
    /// - Parameter payload: The payload to encode (must be non-zero)
    /// - Returns: A signaling NaN with the payload
    @inlinable
    public static func encodeSignalingNaN(payload: UInt32 = 1) -> Float {
        let exponentMask: UInt32 = 0x7F80_0000
        let payloadMask: UInt32 = 0x001F_FFFF

        let actualPayload = (payload & payloadMask) == 0 ? 1 : (payload & payloadMask)

        let bits = exponentMask | actualPayload
        return Float(bitPattern: bits)
    }

    /// Check if NaN is quiet
    @inlinable
    public static func isQuietNaN(_ value: Float) -> Bool {
        value.isNaN && !value.isSignalingNaN
    }

    /// Check if NaN is signaling
    @inlinable
    public static func isSignalingNaN(_ value: Float) -> Bool {
        value.isSignalingNaN
    }
}
