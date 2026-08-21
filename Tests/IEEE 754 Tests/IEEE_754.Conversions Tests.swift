import Testing

@testable import IEEE_754

extension IEEE_754.Conversions {
    @Suite("IEEE_754.Conversions - Float to Double")
    struct Test {
        @Test(arguments: [
            Float(3.14), Float(-3.14), Float(0.0), Float(-0.0), Float(1.0), Float(100.0),
        ])
        func `Exact Conversion`(value: Float) {
            let result = IEEE_754.Conversions.floatToDouble(value)
            #expect(Double(value) == result, "Conversion should be exact")
        }

        @Test func `Special Values`() {
            #expect(IEEE_754.Conversions.floatToDouble(Float.infinity) == Double.infinity)
            #expect(IEEE_754.Conversions.floatToDouble(-Float.infinity) == -Double.infinity)
            #expect(IEEE_754.Conversions.floatToDouble(Float.nan).isNaN)
            #expect(IEEE_754.Conversions.floatToDouble(Float.signalingNaN).isNaN)
        }

        @Test func `Extreme Values`() {
            let maxFloat = Float.greatestFiniteMagnitude
            let result = IEEE_754.Conversions.floatToDouble(maxFloat)
            #expect(result.isFinite, "Max Float should convert to finite Double")
            #expect(result == Double(maxFloat), "Conversion should be exact")
        }

        @Test func subnormals() {
            let subnorm = Float.leastNonzeroMagnitude
            let result = IEEE_754.Conversions.floatToDouble(subnorm)
            #expect(result == Double(subnorm), "Subnormal should convert exactly")
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - Double to Float")
    struct DoubleToFloat {
        @Test(arguments: [1.0, -1.0, 3.14, -2.71, 0.0, -0.0])
        func `Normal Values`(value: Double) {
            let result = IEEE_754.Conversions.doubleToFloat(value)
            #expect(result == Float(value), "Conversion should match Swift's conversion")
        }

        @Test func overflow() {
            let huge = 1e308
            let result = IEEE_754.Conversions.doubleToFloat(huge)
            #expect(result.isInfinite, "Overflow should produce infinity")
            #expect(result.sign == .plus, "Sign should be preserved")
        }

        @Test func underflow() {
            let tiny = 1e-50
            let result = IEEE_754.Conversions.doubleToFloat(tiny)
            #expect(
                result == 0.0 || result.isSubnormal,
                "Underflow should produce zero or subnormal"
            )
        }

        @Test func `Special Values`() {
            #expect(IEEE_754.Conversions.doubleToFloat(Double.infinity) == Float.infinity)
            #expect(IEEE_754.Conversions.doubleToFloat(-Double.infinity) == -Float.infinity)
            #expect(IEEE_754.Conversions.doubleToFloat(Double.nan).isNaN)
        }

        @Test func rounding() {

            let value = 1.00000000000000001
            let result = IEEE_754.Conversions.doubleToFloat(value)
            #expect(result == Float(value), "Should round appropriately")
        }

        @Test func `Signed Zeros`() {
            #expect(IEEE_754.Conversions.doubleToFloat(0.0).sign == .plus)
            #expect(IEEE_754.Conversions.doubleToFloat(-0.0).sign == .minus)
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - Double to Int")
    struct DoubleToInt {
        @Test(arguments: [(3.14, 3), (3.5, 4), (4.5, 4), (-3.5, -4)])
        func `Ties To Even`(value: Double, expected: Int) {
            let result = IEEE_754.Conversions.doubleToInt(value)
            #expect(result == expected, "doubleToInt(\(value)) should be \(expected)")
        }

        @Test func `Special Values`() {
            #expect(IEEE_754.Conversions.doubleToInt(Double.nan) == nil, "NaN should return nil")
            #expect(
                IEEE_754.Conversions.doubleToInt(Double.infinity) == nil,
                "Infinity should return nil"
            )
            #expect(
                IEEE_754.Conversions.doubleToInt(-Double.infinity) == nil,
                "-Infinity should return nil"
            )
        }

        @Test func `Exact Values`() {
            #expect(IEEE_754.Conversions.doubleToInt(0.0) == 0)
            #expect(IEEE_754.Conversions.doubleToInt(1.0) == 1)
            #expect(IEEE_754.Conversions.doubleToInt(-1.0) == -1)
            #expect(IEEE_754.Conversions.doubleToInt(42.0) == 42)
        }

        @Test func `Out Of Range`() {
            let tooLarge = Double(Int.max) + 1.0e10
            let tooSmall = Double(Int.min) - 1.0e10
            #expect(
                IEEE_754.Conversions.doubleToInt(tooLarge) == nil,
                "Out of range should return nil"
            )
            #expect(
                IEEE_754.Conversions.doubleToInt(tooSmall) == nil,
                "Out of range should return nil"
            )
        }
    }
}

extension IEEE_754.Conversions.Test.DoubleToInt {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Three Returns Nil Not Trap`() {
            let twoToTheSixtyThree = 9_223_372_036_854_775_808.0
            #expect(IEEE_754.Conversions.doubleToInt(twoToTheSixtyThree) == nil)
        }

        @Test func `Value Just Below Two To The Sixty Three Converts`() {
            let justBelowBoundary = Double(Int.max).nextDown
            #expect(IEEE_754.Conversions.doubleToInt(justBelowBoundary) != nil)
        }

        @Test func `Negative Boundary At Int Min Converts Exactly`() {

            #expect(IEEE_754.Conversions.doubleToInt(Double(Int.min)) == Int.min)
        }

        @Test func `Value Below Int Min Returns Nil`() {

            let belowMin = Double(Int.min).nextDown
            #expect(IEEE_754.Conversions.doubleToInt(belowMin) == nil)
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - Double to Int Truncating")
    struct DoubleToIntTruncating {
        @Test(arguments: [(3.9, 3), (-3.9, -3), (3.1, 3), (-3.1, -3)])
        func truncation(value: Double, expected: Int) {
            let result = IEEE_754.Conversions.doubleToIntTruncating(value)
            #expect(result == expected, "doubleToIntTruncating(\(value)) should be \(expected)")
        }

        @Test func `Exact Values`() {
            #expect(IEEE_754.Conversions.doubleToIntTruncating(0.0) == 0)
            #expect(IEEE_754.Conversions.doubleToIntTruncating(42.0) == 42)
            #expect(IEEE_754.Conversions.doubleToIntTruncating(-42.0) == -42)
        }

        @Test func `Special Values`() {
            #expect(IEEE_754.Conversions.doubleToIntTruncating(Double.nan) == nil)
            #expect(IEEE_754.Conversions.doubleToIntTruncating(Double.infinity) == nil)
        }
    }
}

extension IEEE_754.Conversions.Test.DoubleToIntTruncating {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Three Returns Nil Not Trap`() {
            let twoToTheSixtyThree = 9_223_372_036_854_775_808.0
            #expect(IEEE_754.Conversions.doubleToIntTruncating(twoToTheSixtyThree) == nil)
        }

        @Test func `Value Just Below Two To The Sixty Three Converts`() {
            let justBelowBoundary = Double(Int.max).nextDown
            #expect(IEEE_754.Conversions.doubleToIntTruncating(justBelowBoundary) != nil)
        }

        @Test func `Negative Boundary At Int Min Converts Exactly`() {
            #expect(IEEE_754.Conversions.doubleToIntTruncating(Double(Int.min)) == Int.min)
        }

        @Test func `Value Below Int Min Returns Nil`() {
            let belowMin = Double(Int.min).nextDown
            #expect(IEEE_754.Conversions.doubleToIntTruncating(belowMin) == nil)
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - Int to Double")
    struct IntToDouble {
        @Test(arguments: [0, 1, -1, 42, -42, 1000, -1000])
        func `Small Integers`(value: Int) {
            let result = IEEE_754.Conversions.intToDouble(value)
            #expect(result == Double(value), "Conversion should be exact for small integers")
            #expect(Int(result) == value, "Should round-trip exactly")
        }

        @Test func `Large Integers`() {
            let large = Int(1_000_000_000_000_000)
            let result = IEEE_754.Conversions.intToDouble(large)
            #expect(result == Double(large), "Conversion should match Swift's conversion")
        }

        @Test func `Extreme Values`() {
            #expect(IEEE_754.Conversions.intToDouble(Int.max) == Double(Int.max))
            #expect(IEEE_754.Conversions.intToDouble(Int.min) == Double(Int.min))
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - Float to Int")
    struct FloatToInt {
        @Test(arguments: [(Float(3.14), 3), (Float(3.5), 4), (Float(4.5), 4)])
        func `Ties To Even`(value: Float, expected: Int) {
            let result = IEEE_754.Conversions.floatToInt(value)
            #expect(result == expected)
        }

        @Test func `Special Values`() {
            #expect(IEEE_754.Conversions.floatToInt(Float.nan) == nil)
            #expect(IEEE_754.Conversions.floatToInt(Float.infinity) == nil)
        }
    }
}

extension IEEE_754.Conversions.Test.FloatToInt {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Three Returns Nil Not Trap`() {
            let twoToTheSixtyThree = Float(9_223_372_036_854_775_808.0)
            #expect(IEEE_754.Conversions.floatToInt(twoToTheSixtyThree) == nil)
        }

        @Test func `Value Just Below Two To The Sixty Three Converts`() {
            let justBelowBoundary = Float(Int.max).nextDown
            #expect(IEEE_754.Conversions.floatToInt(justBelowBoundary) != nil)
        }

        @Test func `Negative Boundary At Int Min Converts Exactly`() {
            #expect(IEEE_754.Conversions.floatToInt(Float(Int.min)) == Int.min)
        }

        @Test func `Value Below Int Min Returns Nil`() {
            let belowMin = Float(Int.min).nextDown
            #expect(IEEE_754.Conversions.floatToInt(belowMin) == nil)
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - Float to Int Truncating")
    struct FloatToIntTruncating {
        @Test(arguments: [(Float(3.9), 3), (Float(-3.9), -3)])
        func truncation(value: Float, expected: Int) {
            let result = IEEE_754.Conversions.floatToIntTruncating(value)
            #expect(result == expected)
        }
    }
}

extension IEEE_754.Conversions.Test.FloatToIntTruncating {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Three Returns Nil Not Trap`() {
            let twoToTheSixtyThree = Float(9_223_372_036_854_775_808.0)
            #expect(IEEE_754.Conversions.floatToIntTruncating(twoToTheSixtyThree) == nil)
        }

        @Test func `Value Just Below Two To The Sixty Three Converts`() {
            let justBelowBoundary = Float(Int.max).nextDown
            #expect(IEEE_754.Conversions.floatToIntTruncating(justBelowBoundary) != nil)
        }

        @Test func `Negative Boundary At Int Min Converts Exactly`() {
            #expect(IEEE_754.Conversions.floatToIntTruncating(Float(Int.min)) == Int.min)
        }

        @Test func `Value Below Int Min Returns Nil`() {
            let belowMin = Float(Int.min).nextDown
            #expect(IEEE_754.Conversions.floatToIntTruncating(belowMin) == nil)
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - Int to Float")
    struct IntToFloat {
        @Test(arguments: [0, 1, -1, 42, -42])
        func `Small Integers`(value: Int) {
            let result = IEEE_754.Conversions.intToFloat(value)
            #expect(result == Float(value))
        }

        @Test func `Large Integers`() {
            let large = 16_777_217
            let result = IEEE_754.Conversions.intToFloat(large)
            #expect(result == Float(large), "Should match Swift's conversion (with rounding)")
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - Double to UInt")
    struct DoubleToUInt {
        @Test(arguments: [(3.14, UInt(3)), (3.5, UInt(4)), (0.0, UInt(0))])
        func `Positive Values`(value: Double, expected: UInt) {
            let result = IEEE_754.Conversions.doubleToUInt(value)
            #expect(result == expected)
        }

        @Test func `Negative Values`() {
            #expect(IEEE_754.Conversions.doubleToUInt(-1.0) == nil, "Negative should return nil")
            #expect(IEEE_754.Conversions.doubleToUInt(-0.0) != nil, "-0.0 should convert to 0")
        }

        @Test func `Special Values`() {
            #expect(IEEE_754.Conversions.doubleToUInt(Double.nan) == nil)
            #expect(IEEE_754.Conversions.doubleToUInt(Double.infinity) == nil)
        }
    }
}

extension IEEE_754.Conversions.Test.DoubleToUInt {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Four Returns Nil Not Trap`() {
            let twoToTheSixtyFour = 18_446_744_073_709_551_616.0
            #expect(IEEE_754.Conversions.doubleToUInt(twoToTheSixtyFour) == nil)
        }

        @Test func `Value Just Below Two To The Sixty Four Converts`() {
            let justBelowBoundary = Double(UInt.max).nextDown
            #expect(IEEE_754.Conversions.doubleToUInt(justBelowBoundary) != nil)
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - UInt to Double")
    struct UIntToDouble {
        @Test(arguments: [UInt(0), UInt(1), UInt(42), UInt(1000)])
        func `Normal Values`(value: UInt) {
            let result = IEEE_754.Conversions.uintToDouble(value)
            #expect(result == Double(value))
        }

        @Test func `Large Values`() {
            let large = UInt.max
            let result = IEEE_754.Conversions.uintToDouble(large)
            #expect(result == Double(large))
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - Float to UInt")
    struct FloatToUInt {
        @Test(arguments: [(Float(3.14), UInt(3)), (Float(0.0), UInt(0))])
        func `Positive Values`(value: Float, expected: UInt) {
            let result = IEEE_754.Conversions.floatToUInt(value)
            #expect(result == expected)
        }

        @Test func `Negative Values`() {
            #expect(IEEE_754.Conversions.floatToUInt(Float(-1.0)) == nil)
        }
    }
}

extension IEEE_754.Conversions.Test.FloatToUInt {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Four Returns Nil Not Trap`() {
            let twoToTheSixtyFour = Float(18_446_744_073_709_551_616.0)
            #expect(IEEE_754.Conversions.floatToUInt(twoToTheSixtyFour) == nil)
        }

        @Test func `Value Just Below Two To The Sixty Four Converts`() {
            let justBelowBoundary = Float(UInt.max).nextDown
            #expect(IEEE_754.Conversions.floatToUInt(justBelowBoundary) != nil)
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - UInt to Float")
    struct UIntToFloat {
        @Test(arguments: [UInt(0), UInt(1), UInt(42)])
        func `Normal Values`(value: UInt) {
            let result = IEEE_754.Conversions.uintToFloat(value)
            #expect(result == Float(value))
        }
    }
}

extension IEEE_754.Conversions.Test {
    @Suite("IEEE_754.Conversions - Round-trip Tests")
    struct ConversionRoundTrip {
        @Test(arguments: [Float(0.0), Float(1.0), Float(3.14), Float(-2.71)])
        func `Float Double Float Round Trip`(value: Float) {
            let asDouble = IEEE_754.Conversions.floatToDouble(value)
            let backToFloat = IEEE_754.Conversions.doubleToFloat(asDouble)
            if value.isNaN {
                #expect(backToFloat.isNaN, "NaN should round-trip")
            } else if value.isZero {
                #expect(
                    backToFloat.isZero && backToFloat.sign == value.sign,
                    "Signed zero should round-trip"
                )
            } else {
                #expect(backToFloat == value, "Float → Double → Float should preserve value")
            }
        }

        @Test(arguments: [0, 1, -1, 42, -42, 1000])
        func `Int Double Int Round Trip`(value: Int) {
            let asDouble = IEEE_754.Conversions.intToDouble(value)
            let backToInt = IEEE_754.Conversions.doubleToIntTruncating(asDouble)
            #expect(
                backToInt == value,
                "Int → Double → Int should preserve value for small integers"
            )
        }
    }
}
