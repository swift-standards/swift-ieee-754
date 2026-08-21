extension IEEE_754 {

    public enum SignOperations {}
}

extension IEEE_754.SignOperations {

    @inlinable
    public static func negate(_ value: Double) -> Double {
        -value
    }

    @inlinable
    public static func abs(_ value: Double) -> Double {
        Swift.abs(value)
    }

    @inlinable
    public static func copySign(magnitude: Double, sign: Double) -> Double {
        Double(sign: sign.sign, exponent: magnitude.exponent, significand: magnitude.significand)
    }
}

extension IEEE_754.SignOperations {

    @inlinable
    public static func negate(_ value: Float) -> Float {
        -value
    }

    @inlinable
    public static func abs(_ value: Float) -> Float {
        Swift.abs(value)
    }

    @inlinable
    public static func copySign(magnitude: Float, sign: Float) -> Float {
        Float(sign: sign.sign, exponent: magnitude.exponent, significand: magnitude.significand)
    }
}
