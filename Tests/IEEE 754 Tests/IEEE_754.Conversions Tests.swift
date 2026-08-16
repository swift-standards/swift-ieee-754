// IEEE_754.Conversions Tests.swift
// swift-ieee-754
//
// Comprehensive tests for IEEE 754-2019 Section 5.4 Conversion operations

import Testing

@testable import IEEE_754

// MARK: - Format Conversions

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
            let huge = 1e308  // Much larger than Float max
            let result = IEEE_754.Conversions.doubleToFloat(huge)
            #expect(result.isInfinite, "Overflow should produce infinity")
            #expect(result.sign == .plus, "Sign should be preserved")
        }

        @Test func underflow() {
            let tiny = 1e-50  // Much smaller than Float min
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
            // Value that requires rounding when converting to Float
            let value = 1.00000000000000001  // More precision than Float can hold
            let result = IEEE_754.Conversions.doubleToFloat(value)
            #expect(result == Float(value), "Should round appropriately")
        }

        @Test func `Signed Zeros`() {
            #expect(IEEE_754.Conversions.doubleToFloat(0.0).sign == .plus)
            #expect(IEEE_754.Conversions.doubleToFloat(-0.0).sign == .minus)
        }
    }
}

// MARK: - Integer Conversions

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

// MARK: - Double to Int Boundary Regression (F-001)
//
// `Int.max` (2^63 - 1) is not exactly representable as `Double`;
// `Double(Int.max)` rounds up to 2^63. A range guard of the shape
// `value > Double(Int.max)` therefore lets `value == 2^63` itself through,
// and converting that value to `Int` traps instead of returning nil as
// documented. These pin the exact boundary (2^63), `nextDown(2^63)`, and the
// (already-exact) negative boundary at `Int.min`.

extension IEEE_754.Conversions.Test.DoubleToInt {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Three Returns Nil Not Trap`() {
            let twoToTheSixtyThree = 9_223_372_036_854_775_808.0  // 2^63, one past Int.max
            #expect(IEEE_754.Conversions.doubleToInt(twoToTheSixtyThree) == nil)
        }

        @Test func `Value Just Below Two To The Sixty Three Converts`() {
            let justBelowBoundary = Double(Int.max).nextDown
            #expect(IEEE_754.Conversions.doubleToInt(justBelowBoundary) != nil)
        }

        @Test func `Negative Boundary At Int Min Converts Exactly`() {
            // Int.min (-2^63) IS exactly representable as Double, so this
            // boundary already worked pre-fix; kept here as a paired sanity
            // check alongside the positive-side boundary tests.
            #expect(IEEE_754.Conversions.doubleToInt(Double(Int.min)) == Int.min)
        }

        @Test func `Value Below Int Min Returns Nil`() {
            // `Double(Int.min)` is exact (-2^63); near this magnitude the ULP
            // is 2048, so an arbitrary small offset (e.g. -1024) can round
            // back to -2^63 itself instead of a smaller value. `.nextDown`
            // is the unambiguous next representable Double strictly below it.
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

// MARK: - Double to Int Truncating Boundary Regression (F-001)
//
// Mirrors the `DoubleToInt` boundary regression: `doubleToIntTruncating`
// carried the same `value > Double(Int.max)` / `value < Double(Int.min)`
// exclusive-bounds trap, letting the exact rounded boundary (2^63) through
// to a trapping `Int(value)` instead of returning nil.

extension IEEE_754.Conversions.Test.DoubleToIntTruncating {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Three Returns Nil Not Trap`() {
            let twoToTheSixtyThree = 9_223_372_036_854_775_808.0  // 2^63, one past Int.max
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

// MARK: - Float to Int Boundary Regression (F-001)
//
// Mirrors the `DoubleToInt` boundary regression: `Int.max` (2^63 - 1) is not
// exactly representable as `Float` either; `Float(Int.max)` rounds up to
// 2^63 (a power of two, exactly representable). A `value > Float(Int.max)`
// guard let that exact boundary value through to a trapping `Int(rounded)`.

extension IEEE_754.Conversions.Test.FloatToInt {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Three Returns Nil Not Trap`() {
            let twoToTheSixtyThree = Float(9_223_372_036_854_775_808.0)  // 2^63
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

// MARK: - Float to Int Truncating Boundary Regression (F-001)
//
// Mirrors the `FloatToInt` boundary regression above for the truncating
// entry point, which carried the identical exclusive-bounds trap.

extension IEEE_754.Conversions.Test.FloatToIntTruncating {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Three Returns Nil Not Trap`() {
            let twoToTheSixtyThree = Float(9_223_372_036_854_775_808.0)  // 2^63
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
            let large = 16_777_217  // 2^24 + 1, cannot be exactly represented in Float
            let result = IEEE_754.Conversions.intToFloat(large)
            #expect(result == Float(large), "Should match Swift's conversion (with rounding)")
        }
    }
}

// MARK: - Unsigned Integer Conversions

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

// MARK: - Double to UInt Boundary Regression (F-001)
//
// Mirrors the `DoubleToInt` boundary regression above: `UInt.max`
// (2^64 - 1) is not exactly representable as `Double`, so `Double(UInt.max)`
// rounds up to 2^64, and a `value > Double(UInt.max)` guard let that exact
// boundary value through to a trapping conversion instead of nil.

extension IEEE_754.Conversions.Test.DoubleToUInt {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Four Returns Nil Not Trap`() {
            let twoToTheSixtyFour = 18_446_744_073_709_551_616.0  // 2^64, one past UInt.max
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

// MARK: - Float to UInt Boundary Regression (F-001)
//
// Mirrors the `DoubleToUInt` boundary regression: `UInt.max` (2^64 - 1) is
// not exactly representable as `Float`; `Float(UInt.max)` rounds up to
// 2^64. A `value > Float(UInt.max)` guard let that exact boundary value
// through to a trapping `UInt(rounded)`.

extension IEEE_754.Conversions.Test.FloatToUInt {
    @Suite
    struct `Edge Case` {
        @Test func `Value Exactly Two To The Sixty Four Returns Nil Not Trap`() {
            let twoToTheSixtyFour = Float(18_446_744_073_709_551_616.0)  // 2^64
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

// MARK: - Round-trip Tests

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
