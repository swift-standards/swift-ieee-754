extension IEEE_754 {

    public enum Scaling {}
}

extension IEEE_754.Scaling {

    @inlinable
    public static func scaleB(_ value: Double, _ n: Int) -> Double {

        if value.isNaN || value.isInfinite || value.isZero {
            return value
        }

        return value * Double(sign: .plus, exponent: n, significand: 1.0)
    }

    @inlinable
    public static func logB(_ value: Double) -> Int {
        if value.isNaN {
            return Int.max
        }
        if value.isInfinite {
            return Int.max
        }
        if value.isZero {
            return Int.min
        }

        return value.exponent
    }

    @inlinable
    public static func exponent(_ value: Double) -> Double {
        if value.isNaN {
            return .nan
        }
        if value.isInfinite {
            return .infinity
        }
        if value.isZero {
            return -.infinity
        }

        return Double(value.exponent)
    }

    @inlinable
    public static func significand(_ value: Double) -> Double {
        value.significand
    }
}

extension IEEE_754.Scaling {

    @inlinable
    public static func scaleB(_ value: Float, _ n: Int) -> Float {
        if value.isNaN || value.isInfinite || value.isZero {
            return value
        }

        return value * Float(sign: .plus, exponent: n, significand: 1.0)
    }

    @inlinable
    public static func logB(_ value: Float) -> Int {
        if value.isNaN {
            return Int.max
        }
        if value.isInfinite {
            return Int.max
        }
        if value.isZero {
            return Int.min
        }

        return value.exponent
    }

    @inlinable
    public static func exponent(_ value: Float) -> Float {
        if value.isNaN {
            return .nan
        }
        if value.isInfinite {
            return .infinity
        }
        if value.isZero {
            return -.infinity
        }

        return Float(value.exponent)
    }

    @inlinable
    public static func significand(_ value: Float) -> Float {
        value.significand
    }
}
