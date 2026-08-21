extension IEEE_754 {

    public enum Conversions {}
}

extension IEEE_754.Conversions {

    @inlinable
    public static func floatToDouble(_ value: Float) -> Double {
        Double(value)
    }

    @inlinable
    public static func doubleToFloat(_ value: Double) -> Float {
        Float(value)
    }

    #if canImport(FloatingPointTypes) && compiler(>=5.9)

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        @inlinable
        public static func float16ToFloat(_ value: Float16) -> Float {
            Float(value)
        }

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        @inlinable
        public static func floatToFloat16(_ value: Float) -> Float16 {
            Float16(value)
        }

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        @inlinable
        public static func float16ToDouble(_ value: Float16) -> Double {
            Double(value)
        }

        @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
        @inlinable
        public static func doubleToFloat16(_ value: Double) -> Float16 {
            Float16(value)
        }
    #endif
}

extension IEEE_754.Conversions {

    @inlinable
    public static func doubleToInt(_ value: Double) -> Int? {

        if value.isNaN || value.isInfinite {
            return nil
        }

        let rounded = value.rounded(.toNearestOrEven)
        return Int(exactly: rounded)
    }

    @inlinable
    public static func doubleToIntTruncating(_ value: Double) -> Int? {
        if value.isNaN || value.isInfinite {
            return nil
        }

        let truncated = value.rounded(.towardZero)
        return Int(exactly: truncated)
    }

    @inlinable
    public static func intToDouble(_ value: Int) -> Double {
        Double(value)
    }

    @inlinable
    public static func floatToInt(_ value: Float) -> Int? {
        if value.isNaN || value.isInfinite {
            return nil
        }

        let rounded = value.rounded(.toNearestOrEven)
        return Int(exactly: rounded)
    }

    @inlinable
    public static func floatToIntTruncating(_ value: Float) -> Int? {
        if value.isNaN || value.isInfinite {
            return nil
        }

        let truncated = value.rounded(.towardZero)
        return Int(exactly: truncated)
    }

    @inlinable
    public static func intToFloat(_ value: Int) -> Float {
        Float(value)
    }
}

extension IEEE_754.Conversions {

    @inlinable
    public static func doubleToUInt(_ value: Double) -> UInt? {
        if value.isNaN || value.isInfinite || value < 0 {
            return nil
        }

        let rounded = value.rounded(.toNearestOrEven)
        return UInt(exactly: rounded)
    }

    @inlinable
    public static func uintToDouble(_ value: UInt) -> Double {
        Double(value)
    }

    @inlinable
    public static func floatToUInt(_ value: Float) -> UInt? {
        if value.isNaN || value.isInfinite || value < 0 {
            return nil
        }

        let rounded = value.rounded(.toNearestOrEven)
        return UInt(exactly: rounded)
    }

    @inlinable
    public static func uintToFloat(_ value: UInt) -> Float {
        Float(value)
    }
}
