extension IEEE_754 {

    public enum Payload {}
}

extension IEEE_754.Payload {

    public enum NaNType: Sendable, Equatable {

        case quiet(payload: UInt64)

        case signaling(payload: UInt64)
    }

    @inlinable
    public static func encode(_ type: NaNType) -> Double {
        switch type {
        case .quiet(let payload):
            return encodeQuietNaN(payload: payload)

        case .signaling(let payload):
            return encodeSignalingNaN(payload: payload)
        }
    }

    @inlinable
    public static func encode(_ type: NaNType) -> Float {
        switch type {
        case .quiet(let payload):
            return encodeQuietNaN(payload: UInt32(payload & 0x001F_FFFF))

        case .signaling(let payload):
            return encodeSignalingNaN(payload: UInt32(payload & 0x001F_FFFF))
        }
    }

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

extension IEEE_754.Payload {

    @inlinable
    public static func extract(from value: Double) -> UInt64? {
        guard value.isNaN else { return nil }

        let bits = value.bitPattern

        let payloadMask: UInt64 = 0x0007_FFFF_FFFF_FFFF
        return bits & payloadMask
    }

    @inlinable
    public static func encodeQuietNaN(payload: UInt64 = 0) -> Double {

        let exponentMask: UInt64 = 0x7FF0_0000_0000_0000
        let quietBit: UInt64 = 0x0008_0000_0000_0000
        let payloadMask: UInt64 = 0x0007_FFFF_FFFF_FFFF

        let bits = exponentMask | quietBit | (payload & payloadMask)
        return Double(bitPattern: bits)
    }

    @inlinable
    public static func encodeSignalingNaN(payload: UInt64 = 1) -> Double {

        let exponentMask: UInt64 = 0x7FF0_0000_0000_0000
        let payloadMask: UInt64 = 0x0007_FFFF_FFFF_FFFF

        let actualPayload = (payload & payloadMask) == 0 ? 1 : (payload & payloadMask)

        let bits = exponentMask | actualPayload
        return Double(bitPattern: bits)
    }

    @inlinable
    public static func isQuietNaN(_ value: Double) -> Bool {
        value.isNaN && !value.isSignalingNaN
    }

    @inlinable
    public static func isSignalingNaN(_ value: Double) -> Bool {
        value.isSignalingNaN
    }
}

extension IEEE_754.Payload {

    @inlinable
    public static func extract(from value: Float) -> UInt32? {
        guard value.isNaN else { return nil }

        let bits = value.bitPattern

        let payloadMask: UInt32 = 0x001F_FFFF
        return bits & payloadMask
    }

    @inlinable
    public static func encodeQuietNaN(payload: UInt32 = 0) -> Float {

        let exponentMask: UInt32 = 0x7F80_0000
        let quietBit: UInt32 = 0x0040_0000
        let payloadMask: UInt32 = 0x001F_FFFF

        let bits = exponentMask | quietBit | (payload & payloadMask)
        return Float(bitPattern: bits)
    }

    @inlinable
    public static func encodeSignalingNaN(payload: UInt32 = 1) -> Float {
        let exponentMask: UInt32 = 0x7F80_0000
        let payloadMask: UInt32 = 0x001F_FFFF

        let actualPayload = (payload & payloadMask) == 0 ? 1 : (payload & payloadMask)

        let bits = exponentMask | actualPayload
        return Float(bitPattern: bits)
    }

    @inlinable
    public static func isQuietNaN(_ value: Float) -> Bool {
        value.isNaN && !value.isSignalingNaN
    }

    @inlinable
    public static func isSignalingNaN(_ value: Float) -> Bool {
        value.isSignalingNaN
    }
}
