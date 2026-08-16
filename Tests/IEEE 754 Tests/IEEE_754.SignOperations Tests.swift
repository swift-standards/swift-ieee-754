// IEEE_754.SignOperations Tests.swift
// swift-ieee-754
//
// Comprehensive tests for IEEE 754-2019 Section 5.5 Sign Operations

import Testing

@testable import IEEE_754

// MARK: - Double Sign Operations Tests

extension IEEE_754.SignOperations {
    @Suite("IEEE_754.SignOperations - Double negate")
    struct Test {
        @Test(arguments: [
            (3.14, -3.14),
            (-3.14, 3.14),
            (0.0, -0.0),
            (-0.0, 0.0),
            (1.0, -1.0),
            (-1.0, 1.0),
        ])
        func `normal Values`(value: Double, expected: Double) {
            let result = IEEE_754.SignOperations.negate(value)
            if value.isZero {
                #expect(result.sign != value.sign, "Sign should be flipped for zeros")
            } else {
                #expect(result == expected, "negate(\(value)) should be \(expected)")
            }
        }

        @Test func infinities() {
            #expect(IEEE_754.SignOperations.negate(Double.infinity) == -Double.infinity)
            #expect(IEEE_754.SignOperations.negate(-Double.infinity) == Double.infinity)
        }

        @Test func `nan Sign Bit`() {
            let positiveNaN = Double.nan
            let negativeNaN = IEEE_754.SignOperations.negate(positiveNaN)
            #expect(negativeNaN.isNaN, "Negated NaN should still be NaN")
            #expect(negativeNaN.sign == .minus, "Negated NaN should have minus sign")
        }

        @Test func `double Negation`() {
            let values: [Double] = [3.14, -3.14, 0.0, -0.0, Double.infinity, -Double.infinity]
            for value in values {
                let result = IEEE_754.SignOperations.negate(IEEE_754.SignOperations.negate(value))
                if value.isZero {
                    #expect(
                        result.isZero && result.sign == value.sign,
                        "Double negation should restore original for zeros"
                    )
                } else {
                    #expect(result == value, "Double negation should restore original")
                }
            }
        }
    }
}

extension IEEE_754.SignOperations.Test {
    @Suite("IEEE_754.SignOperations - Double abs")
    struct DoubleAbs {
        @Test(arguments: [
            (3.14, 3.14),
            (-3.14, 3.14),
            (0.0, 0.0),
            (-0.0, 0.0),
            (100.0, 100.0),
            (-100.0, 100.0),
        ])
        func `normal Values`(value: Double, expected: Double) {
            let result = IEEE_754.SignOperations.abs(value)
            #expect(result == expected, "abs(\(value)) should be \(expected)")
            #expect(result.sign == .plus || result.isZero, "abs result should be positive or zero")
        }

        @Test func infinities() {
            #expect(IEEE_754.SignOperations.abs(Double.infinity) == Double.infinity)
            #expect(IEEE_754.SignOperations.abs(-Double.infinity) == Double.infinity)
        }

        @Test func `nan Preservation`() {
            let nan = Double.nan
            let result = IEEE_754.SignOperations.abs(nan)
            #expect(result.isNaN, "abs(NaN) should be NaN")
            #expect(result.sign == .plus, "abs(NaN) should have positive sign")
        }

        @Test func `signed Zeros`() {
            #expect(IEEE_754.SignOperations.abs(0.0) == 0.0)
            #expect(IEEE_754.SignOperations.abs(-0.0) == 0.0)
            #expect(IEEE_754.SignOperations.abs(-0.0).sign == .plus, "abs(-0.0) should be +0.0")
        }
    }
}

extension IEEE_754.SignOperations.Test {
    @Suite("IEEE_754.SignOperations - Double copySign")
    struct DoubleCopySign {
        @Test(arguments: [
            (3.14, 1.0, 3.14),
            (3.14, -1.0, -3.14),
            (-3.14, 1.0, 3.14),
            (-3.14, -1.0, -3.14),
        ])
        func `normal Values`(magnitude: Double, sign: Double, expected: Double) {
            let result = IEEE_754.SignOperations.copySign(magnitude: magnitude, sign: sign)
            #expect(
                result == expected,
                "copySign(magnitude: \(magnitude), sign: \(sign)) should be \(expected)"
            )
        }

        @Test func `zero Magnitude`() {
            #expect(IEEE_754.SignOperations.copySign(magnitude: 0.0, sign: 1.0) == 0.0)
            #expect(IEEE_754.SignOperations.copySign(magnitude: 0.0, sign: -1.0) == -0.0)
            #expect(IEEE_754.SignOperations.copySign(magnitude: -0.0, sign: 1.0) == 0.0)
            #expect(IEEE_754.SignOperations.copySign(magnitude: -0.0, sign: -1.0) == -0.0)
        }

        @Test func `zero Sign`() {
            let result1 = IEEE_754.SignOperations.copySign(magnitude: 3.14, sign: 0.0)
            let result2 = IEEE_754.SignOperations.copySign(magnitude: 3.14, sign: -0.0)
            #expect(result1.sign == .plus, "copySign with +0.0 sign should give positive result")
            #expect(result2.sign == .minus, "copySign with -0.0 sign should give negative result")
        }

        @Test func `infinity Magnitude`() {
            #expect(
                IEEE_754.SignOperations.copySign(magnitude: Double.infinity, sign: 1.0)
                    == Double.infinity
            )
            #expect(
                IEEE_754.SignOperations.copySign(magnitude: Double.infinity, sign: -1.0) == -Double
                    .infinity
            )
            #expect(
                IEEE_754.SignOperations.copySign(magnitude: -Double.infinity, sign: 1.0)
                    == Double.infinity
            )
        }

        @Test func `infinity Sign`() {
            #expect(
                IEEE_754.SignOperations.copySign(magnitude: 3.14, sign: Double.infinity) == 3.14
            )
            #expect(
                IEEE_754.SignOperations.copySign(magnitude: 3.14, sign: -Double.infinity) == -3.14
            )
        }

        @Test func `nan Handling`() {
            let result = IEEE_754.SignOperations.copySign(magnitude: Double.nan, sign: -1.0)
            #expect(result.isNaN, "copySign with NaN magnitude should produce NaN")
            #expect(result.sign == .minus, "Sign should be copied to NaN")
        }
    }
}

// MARK: - Float Sign Operations Tests

extension IEEE_754.SignOperations.Test {
    @Suite("IEEE_754.SignOperations - Float negate")
    struct FloatNegate {
        @Test(arguments: [
            (Float(3.14), Float(-3.14)),
            (Float(-3.14), Float(3.14)),
            (Float(0.0), Float(-0.0)),
            (Float(-0.0), Float(0.0)),
        ])
        func `normal Values`(value: Float, expected: Float) {
            let result = IEEE_754.SignOperations.negate(value)
            if value.isZero {
                #expect(result.sign != value.sign, "Sign should be flipped for zeros")
            } else {
                #expect(result == expected, "negate(\(value)) should be \(expected)")
            }
        }

        @Test func infinities() {
            #expect(IEEE_754.SignOperations.negate(Float.infinity) == -Float.infinity)
            #expect(IEEE_754.SignOperations.negate(-Float.infinity) == Float.infinity)
        }

        @Test func `nan Sign Bit`() {
            let positiveNaN = Float.nan
            let negativeNaN = IEEE_754.SignOperations.negate(positiveNaN)
            #expect(negativeNaN.isNaN, "Negated NaN should still be NaN")
            #expect(negativeNaN.sign == .minus, "Negated NaN should have minus sign")
        }
    }
}

extension IEEE_754.SignOperations.Test {
    @Suite("IEEE_754.SignOperations - Float abs")
    struct FloatAbs {
        @Test(arguments: [
            (Float(3.14), Float(3.14)),
            (Float(-3.14), Float(3.14)),
            (Float(0.0), Float(0.0)),
            (Float(-0.0), Float(0.0)),
        ])
        func `normal Values`(value: Float, expected: Float) {
            let result = IEEE_754.SignOperations.abs(value)
            #expect(result == expected, "abs(\(value)) should be \(expected)")
            #expect(result.sign == .plus || result.isZero, "abs result should be positive or zero")
        }

        @Test func infinities() {
            #expect(IEEE_754.SignOperations.abs(Float.infinity) == Float.infinity)
            #expect(IEEE_754.SignOperations.abs(-Float.infinity) == Float.infinity)
        }

        @Test func `nan Preservation`() {
            let result = IEEE_754.SignOperations.abs(Float.nan)
            #expect(result.isNaN, "abs(NaN) should be NaN")
            #expect(result.sign == .plus, "abs(NaN) should have positive sign")
        }
    }
}

extension IEEE_754.SignOperations.Test {
    @Suite("IEEE_754.SignOperations - Float copySign")
    struct FloatCopySign {
        @Test(arguments: [
            (Float(3.14), Float(1.0), Float(3.14)),
            (Float(3.14), Float(-1.0), Float(-3.14)),
            (Float(-3.14), Float(1.0), Float(3.14)),
            (Float(-3.14), Float(-1.0), Float(-3.14)),
        ])
        func `normal Values`(magnitude: Float, sign: Float, expected: Float) {
            let result = IEEE_754.SignOperations.copySign(magnitude: magnitude, sign: sign)
            #expect(
                result == expected,
                "copySign(magnitude: \(magnitude), sign: \(sign)) should be \(expected)"
            )
        }

        @Test func `zero Magnitude`() {
            #expect(
                IEEE_754.SignOperations.copySign(magnitude: Float(0.0), sign: Float(1.0))
                    == Float(0.0)
            )
            #expect(
                IEEE_754.SignOperations.copySign(magnitude: Float(0.0), sign: Float(-1.0))
                    == Float(-0.0)
            )
            let result = IEEE_754.SignOperations.copySign(magnitude: Float(0.0), sign: Float(-1.0))
            #expect(result.sign == .minus, "copySign with negative sign should produce -0.0")
        }

        @Test func `infinity Magnitude`() {
            #expect(
                IEEE_754.SignOperations.copySign(magnitude: Float.infinity, sign: Float(1.0))
                    == Float.infinity
            )
            #expect(
                IEEE_754.SignOperations.copySign(magnitude: Float.infinity, sign: Float(-1.0))
                    == -Float.infinity
            )
        }

        @Test func `nan Handling`() {
            let result = IEEE_754.SignOperations.copySign(magnitude: Float.nan, sign: Float(-1.0))
            #expect(result.isNaN, "copySign with NaN magnitude should produce NaN")
            #expect(result.sign == .minus, "Sign should be copied to NaN")
        }
    }
}

// MARK: - Subnormal Sign Operations Tests

extension IEEE_754.SignOperations.Test {
    @Suite("IEEE_754.SignOperations - Subnormal Values")
    struct SubnormalSignOperations {
        @Test func `negate Subnormals`() {
            let posSubnorm = Double.leastNonzeroMagnitude
            let negSubnorm = IEEE_754.SignOperations.negate(posSubnorm)
            #expect(negSubnorm.isSubnormal, "Negated subnormal should still be subnormal")
            #expect(negSubnorm.sign == .minus, "Negated subnormal should be negative")
            #expect(negSubnorm.magnitude == posSubnorm, "Magnitudes should match")
        }

        @Test func `abs Subnormals`() {
            let negSubnorm = -Double.leastNonzeroMagnitude
            let result = IEEE_754.SignOperations.abs(negSubnorm)
            #expect(result.isSubnormal, "abs of subnormal should still be subnormal")
            #expect(result.sign == .plus, "abs of subnormal should be positive")
        }

        @Test func `copy Sign Subnormals`() {
            let subnorm = Double.leastNonzeroMagnitude
            let result = IEEE_754.SignOperations.copySign(magnitude: subnorm, sign: -1.0)
            #expect(result.isSubnormal, "Result should still be subnormal")
            #expect(result.sign == .minus, "Result should have copied sign")
        }
    }
}
