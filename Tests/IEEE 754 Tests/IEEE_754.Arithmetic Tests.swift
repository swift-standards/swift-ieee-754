// IEEE_754.Arithmetic Tests.swift
// swift-ieee-754
//
// Comprehensive tests for IEEE 754-2019 Section 5.4 Arithmetic Operations

import Testing

@testable import IEEE_754

// MARK: - Basic Arithmetic Operations Tests

extension IEEE_754.Arithmetic {
    @Suite("IEEE_754.Arithmetic - Addition")
    struct Test {
        @Test func `Basic Addition`() {
            let result = IEEE_754.Arithmetic.addition(3.14, 2.86)
            #expect(result == 6.0)
        }

        @Test func `Negative Addition`() {
            let result = IEEE_754.Arithmetic.addition(-5.0, 3.0)
            #expect(result == -2.0)
        }

        @Test func `Zero Addition`() {
            #expect(IEEE_754.Arithmetic.addition(0.0, 0.0) == 0.0)
            #expect(IEEE_754.Arithmetic.addition(5.0, 0.0) == 5.0)
            #expect(IEEE_754.Arithmetic.addition(-0.0, 0.0) == 0.0)
        }

        @Test func `Infinity Addition`() {
            #expect(IEEE_754.Arithmetic.addition(Double.infinity, 5.0) == Double.infinity)
            #expect(IEEE_754.Arithmetic.addition(-Double.infinity, 5.0) == -Double.infinity)
            #expect(
                IEEE_754.Arithmetic.addition(Double.infinity, Double.infinity) == Double.infinity
            )
        }

        @Test func `Nan Addition`() {
            let result = IEEE_754.Arithmetic.addition(Double.infinity, -Double.infinity)
            #expect(result.isNaN)
        }

        @Test func `Float Addition`() {
            let result = IEEE_754.Arithmetic.addition(Float(1.5), Float(2.5))
            #expect(result == 4.0)
        }
    }
}

extension IEEE_754.Arithmetic.Test {
    @Suite("IEEE_754.Arithmetic - Subtraction")
    struct Subtraction {
        @Test func `Basic Subtraction`() {
            let result = IEEE_754.Arithmetic.subtraction(10.0, 3.0)
            #expect(result == 7.0)
        }

        @Test func `Negative Subtraction`() {
            let result = IEEE_754.Arithmetic.subtraction(-5.0, -3.0)
            #expect(result == -2.0)
        }

        @Test func `Zero Subtraction`() {
            #expect(IEEE_754.Arithmetic.subtraction(5.0, 5.0) == 0.0)
            #expect(IEEE_754.Arithmetic.subtraction(0.0, 0.0) == 0.0)
        }

        @Test func `Infinity Subtraction`() {
            #expect(IEEE_754.Arithmetic.subtraction(Double.infinity, 5.0) == Double.infinity)
            let result = IEEE_754.Arithmetic.subtraction(Double.infinity, Double.infinity)
            #expect(result.isNaN)
        }
    }
}

extension IEEE_754.Arithmetic.Test {
    @Suite("IEEE_754.Arithmetic - Multiplication")
    struct Multiplication {
        @Test func `Basic Multiplication`() {
            let result = IEEE_754.Arithmetic.multiplication(3.0, 4.0)
            #expect(result == 12.0)
        }

        @Test func `Negative Multiplication`() {
            #expect(IEEE_754.Arithmetic.multiplication(-3.0, 4.0) == -12.0)
            #expect(IEEE_754.Arithmetic.multiplication(-3.0, -4.0) == 12.0)
        }

        @Test func `Zero Multiplication`() {
            #expect(IEEE_754.Arithmetic.multiplication(0.0, 5.0) == 0.0)
            #expect(IEEE_754.Arithmetic.multiplication(5.0, 0.0) == 0.0)
        }

        @Test func `Infinity Multiplication`() {
            #expect(IEEE_754.Arithmetic.multiplication(Double.infinity, 2.0) == Double.infinity)
            #expect(IEEE_754.Arithmetic.multiplication(Double.infinity, -2.0) == -Double.infinity)

            let result = IEEE_754.Arithmetic.multiplication(Double.infinity, 0.0)
            #expect(result.isNaN)
        }

        @Test func `Subnormal Multiplication`() {
            let tiny = Double.leastNonzeroMagnitude
            let result = IEEE_754.Arithmetic.multiplication(tiny, 0.5)
            #expect(result == 0.0 || result == tiny * 0.5)
        }
    }
}

extension IEEE_754.Arithmetic.Test {
    @Suite("IEEE_754.Arithmetic - Division")
    struct Division {
        @Test func `Basic Division`() {
            let result = IEEE_754.Arithmetic.division(10.0, 2.0)
            #expect(result == 5.0)
        }

        @Test func `Negative Division`() {
            #expect(IEEE_754.Arithmetic.division(-10.0, 2.0) == -5.0)
            #expect(IEEE_754.Arithmetic.division(10.0, -2.0) == -5.0)
            #expect(IEEE_754.Arithmetic.division(-10.0, -2.0) == 5.0)
        }

        @Test func `Division By Zero`() {
            #expect(IEEE_754.Arithmetic.division(5.0, 0.0) == Double.infinity)
            #expect(IEEE_754.Arithmetic.division(-5.0, 0.0) == -Double.infinity)

            let result = IEEE_754.Arithmetic.division(0.0, 0.0)
            #expect(result.isNaN)
        }

        @Test func `Infinity Division`() {
            #expect(IEEE_754.Arithmetic.division(5.0, Double.infinity) == 0.0)

            let result = IEEE_754.Arithmetic.division(Double.infinity, Double.infinity)
            #expect(result.isNaN)
        }

        @Test func `Exact Division`() {
            #expect(IEEE_754.Arithmetic.division(1.0, 2.0) == 0.5)
            #expect(IEEE_754.Arithmetic.division(1.0, 4.0) == 0.25)
        }
    }
}

extension IEEE_754.Arithmetic.Test {
    @Suite("IEEE_754.Arithmetic - Remainder")
    struct Remainder {
        @Test func `Basic Remainder`() {
            let result = IEEE_754.Arithmetic.remainder(7.0, 3.0)
            #expect(result == 1.0)
        }

        @Test func `Exact Remainder`() {
            let result = IEEE_754.Arithmetic.remainder(10.0, 5.0)
            #expect(result == 0.0)
        }

        @Test func `Negative Remainder`() {
            let result1 = IEEE_754.Arithmetic.remainder(-7.0, 3.0)
            let result2 = IEEE_754.Arithmetic.remainder(7.0, -3.0)
            #expect(result1 == -1.0)
            #expect(result2 == 1.0)
        }

        @Test func `Fractional Remainder`() {
            // IEEE 754 remainder: 7.5 / 2.0 → quotient rounds to 4 (nearest even)
            // remainder = 7.5 - (4 × 2.0) = -0.5
            let result = IEEE_754.Arithmetic.remainder(7.5, 2.0)
            #expect(abs(result - (-0.5)) < 0.0001)
        }
    }
}

// MARK: - Special Operations Tests

extension IEEE_754.Arithmetic.Test {
    @Suite("IEEE_754.Arithmetic - Square Root")
    struct SquareRoot {
        @Test func `Perfect Squares`() {
            #expect(IEEE_754.Arithmetic.squareRoot(4.0) == 2.0)
            #expect(IEEE_754.Arithmetic.squareRoot(9.0) == 3.0)
            #expect(IEEE_754.Arithmetic.squareRoot(16.0) == 4.0)
            #expect(IEEE_754.Arithmetic.squareRoot(1.0) == 1.0)
            #expect(IEEE_754.Arithmetic.squareRoot(0.0) == 0.0)
        }

        @Test func `Imperfect Squares`() {
            let sqrt2 = IEEE_754.Arithmetic.squareRoot(2.0)
            #expect(abs(sqrt2 - 1.4142135623730951) < 1e-15)
        }

        @Test func `Negative Square Root`() {
            let result = IEEE_754.Arithmetic.squareRoot(-1.0)
            #expect(result.isNaN)
        }

        @Test func `Infinity Square Root`() {
            #expect(IEEE_754.Arithmetic.squareRoot(Double.infinity) == Double.infinity)
        }

        @Test func `Subnormal Square Root`() {
            let tiny = Double.leastNonzeroMagnitude
            let result = IEEE_754.Arithmetic.squareRoot(tiny)
            #expect(result > 0)
        }

        @Test func `Float Square Root`() {
            let result = IEEE_754.Arithmetic.squareRoot(Float(4.0))
            #expect(result == 2.0)
        }
    }
}

extension IEEE_754.Arithmetic.Test {
    @Suite("IEEE_754.Arithmetic - Fused Multiply-Add")
    struct FMA {
        @Test func `Basic FMA`() {
            // (2 * 3) + 1 = 7
            let result = IEEE_754.Arithmetic.fusedMultiplyAdd(a: 2.0, b: 3.0, c: 1.0)
            #expect(result == 7.0)
        }

        @Test func `Zero FMA`() {
            // (0 * 5) + 3 = 3
            let result = IEEE_754.Arithmetic.fusedMultiplyAdd(a: 0.0, b: 5.0, c: 3.0)
            #expect(result == 3.0)
        }

        @Test func `Negative FMA`() {
            // (-2 * 3) + 10 = 4
            let result = IEEE_754.Arithmetic.fusedMultiplyAdd(a: -2.0, b: 3.0, c: 10.0)
            #expect(result == 4.0)
        }

        @Test func `Fma Accuracy`() {
            // FMA should be more accurate than separate multiply and add
            // Test case where intermediate overflow would occur
            let huge = Double.greatestFiniteMagnitude / 2.0
            let result = IEEE_754.Arithmetic.fusedMultiplyAdd(a: huge, b: 2.0, c: -huge)
            #expect(result.isFinite || result == huge)
        }

        @Test func `Fma With Infinity`() {
            let result = IEEE_754.Arithmetic.fusedMultiplyAdd(a: Double.infinity, b: 2.0, c: 3.0)
            #expect(result == Double.infinity)
        }

        @Test func `Float FMA`() {
            let result = IEEE_754.Arithmetic.fusedMultiplyAdd(
                a: Float(2.0),
                b: Float(3.0),
                c: Float(1.0)
            )
            #expect(result == 7.0)
        }
    }
}

// MARK: - Compound Operations Tests

extension IEEE_754.Arithmetic.Test {
    @Suite("IEEE_754.Arithmetic - Absolute Value")
    struct AbsoluteValue {
        @Test func `Positive Abs`() {
            #expect(IEEE_754.Arithmetic.absoluteValue(5.0) == 5.0)
            #expect(IEEE_754.Arithmetic.absoluteValue(3.14) == 3.14)
        }

        @Test func `Negative Abs`() {
            #expect(IEEE_754.Arithmetic.absoluteValue(-5.0) == 5.0)
            #expect(IEEE_754.Arithmetic.absoluteValue(-3.14) == 3.14)
        }

        @Test func `Zero Abs`() {
            #expect(IEEE_754.Arithmetic.absoluteValue(0.0) == 0.0)
            #expect(IEEE_754.Arithmetic.absoluteValue(-0.0) == 0.0)
        }

        @Test func `Infinity Abs`() {
            #expect(IEEE_754.Arithmetic.absoluteValue(Double.infinity) == Double.infinity)
            #expect(IEEE_754.Arithmetic.absoluteValue(-Double.infinity) == Double.infinity)
        }

        @Test func `Nan Abs`() {
            let result = IEEE_754.Arithmetic.absoluteValue(Double.nan)
            #expect(result.isNaN)
        }

        @Test func `Subnormal Abs`() {
            let tiny = -Double.leastNonzeroMagnitude
            #expect(IEEE_754.Arithmetic.absoluteValue(tiny) == Double.leastNonzeroMagnitude)
        }
    }
}

extension IEEE_754.Arithmetic.Test {
    @Suite("IEEE_754.Arithmetic - Negate")
    struct Negate {
        @Test func `Positive Negate`() {
            #expect(IEEE_754.Arithmetic.negate(5.0) == -5.0)
            #expect(IEEE_754.Arithmetic.negate(3.14) == -3.14)
        }

        @Test func `Negative Negate`() {
            #expect(IEEE_754.Arithmetic.negate(-5.0) == 5.0)
            #expect(IEEE_754.Arithmetic.negate(-3.14) == 3.14)
        }

        @Test func `Zero Negate`() {
            #expect(IEEE_754.Arithmetic.negate(0.0) == -0.0)
            #expect(IEEE_754.Arithmetic.negate(-0.0) == 0.0)
        }

        @Test func `Infinity Negate`() {
            #expect(IEEE_754.Arithmetic.negate(Double.infinity) == -Double.infinity)
            #expect(IEEE_754.Arithmetic.negate(-Double.infinity) == Double.infinity)
        }

        @Test func `Nan Negate`() {
            let result = IEEE_754.Arithmetic.negate(Double.nan)
            #expect(result.isNaN)
        }

        @Test func `Double Negation`() {
            #expect(IEEE_754.Arithmetic.negate(IEEE_754.Arithmetic.negate(3.14)) == 3.14)
        }
    }
}

// MARK: - Edge Cases Tests

extension IEEE_754.Arithmetic.Test {
    @Suite("IEEE_754.Arithmetic - Edge Cases")
    struct EdgeCases {
        @Test func `Max Finite Operations`() {
            let max = Double.greatestFiniteMagnitude

            // Addition overflow
            let sum = IEEE_754.Arithmetic.addition(max, max)
            #expect(sum == Double.infinity)

            // Multiplication overflow
            let product = IEEE_754.Arithmetic.multiplication(max, 2.0)
            #expect(product == Double.infinity)
        }

        @Test func `Min Finite Operations`() {
            let min = Double.leastNormalMagnitude

            // Division producing subnormal
            let quotient = IEEE_754.Arithmetic.division(min, 2.0)
            #expect(quotient < min)

            // Multiplication producing subnormal
            let product = IEEE_754.Arithmetic.multiplication(min, 0.5)
            #expect(product < min)
        }

        @Test func `Subnormal Arithmetic`() {
            let subnormal = Double.leastNonzeroMagnitude

            let sum = IEEE_754.Arithmetic.addition(subnormal, subnormal)
            #expect(sum > 0)

            let product = IEEE_754.Arithmetic.multiplication(subnormal, 0.5)
            #expect(product >= 0)  // May underflow to 0
        }

        @Test func `Mixed Sign Zeros`() {
            // IEEE 754 signed zero behavior
            let posZero = 0.0
            let negZero = -0.0

            #expect(IEEE_754.Arithmetic.addition(posZero, negZero) == 0.0)
            #expect(IEEE_754.Arithmetic.subtraction(posZero, negZero) == 0.0)
        }
    }
}

// MARK: - Consistency Tests

extension IEEE_754.Arithmetic.Test {
    @Suite("IEEE_754.Arithmetic - Consistency with Operators")
    struct Consistency {
        @Test func `Addition Consistency`() {
            let values: [(Double, Double)] = [(3.0, 2.0), (-5.0, 3.0), (0.0, 0.0), (1e100, 1e-100)]

            for (a, b) in values {
                let expected = a + b
                let actual = IEEE_754.Arithmetic.addition(a, b)
                #expect(expected == actual)
            }
        }

        @Test func `Multiplication Consistency`() {
            let values: [(Double, Double)] = [(3.0, 2.0), (-5.0, 3.0), (2.0, 0.5), (1e50, 1e-50)]

            for (a, b) in values {
                let expected = a * b
                let actual = IEEE_754.Arithmetic.multiplication(a, b)
                #expect(expected == actual)
            }
        }

        @Test func `Square Root Consistency`() {
            let values = [4.0, 9.0, 2.0, 0.5, 1e100, 1e-100]

            for value in values {
                let expected = value.squareRoot()
                let actual = IEEE_754.Arithmetic.squareRoot(value)
                #expect(expected == actual)
            }
        }
    }
}
