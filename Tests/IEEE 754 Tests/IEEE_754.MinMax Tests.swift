// IEEE_754.MinMax Tests.swift
// swift-ieee-754
//
// Comprehensive tests for IEEE 754-2019 Section 5.3 & 9.6 MinMax operations

import Testing

@testable import IEEE_754

// MARK: - Double MinMax Tests

extension IEEE_754.MinMax {
    @Suite("IEEE_754.MinMax - Double minimum")
    struct Test {
        @Test(arguments: [(3.14, 2.71, 2.71), (2.71, 3.14, 2.71), (3.14, 3.14, 3.14)])
        func `normal Values`(x: Double, y: Double, expected: Double) {
            #expect(IEEE_754.MinMax.minimum(x, y) == expected)
        }

        @Test func `signed Zeros`() {
            let result = IEEE_754.MinMax.minimum(-0.0, 0.0)
            #expect(result.isZero, "minimum should be zero")
            #expect(result.sign == .minus, "minimum(-0.0, +0.0) should be -0.0")

            let result2 = IEEE_754.MinMax.minimum(0.0, -0.0)
            #expect(result2.sign == .minus, "minimum(+0.0, -0.0) should be -0.0")
        }

        @Test func `nan Propagation`() {
            #expect(IEEE_754.MinMax.minimum(Double.nan, 3.14).isNaN, "minimum propagates NaN")
            #expect(IEEE_754.MinMax.minimum(3.14, Double.nan).isNaN, "minimum propagates NaN")
            #expect(IEEE_754.MinMax.minimum(Double.nan, Double.nan).isNaN, "minimum propagates NaN")
        }

        @Test func infinities() {
            #expect(IEEE_754.MinMax.minimum(-Double.infinity, 0.0) == -Double.infinity)
            #expect(IEEE_754.MinMax.minimum(0.0, Double.infinity) == 0.0)
            #expect(IEEE_754.MinMax.minimum(Double.infinity, Double.infinity) == Double.infinity)
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Double maximum")
    struct DoubleMaximum {
        @Test(arguments: [(3.14, 2.71, 3.14), (2.71, 3.14, 3.14), (3.14, 3.14, 3.14)])
        func `normal Values`(x: Double, y: Double, expected: Double) {
            #expect(IEEE_754.MinMax.maximum(x, y) == expected)
        }

        @Test func `signed Zeros`() {
            let result = IEEE_754.MinMax.maximum(-0.0, 0.0)
            #expect(result.isZero, "maximum should be zero")
            #expect(result.sign == .plus, "maximum(-0.0, +0.0) should be +0.0")

            let result2 = IEEE_754.MinMax.maximum(0.0, -0.0)
            #expect(result2.sign == .plus, "maximum(+0.0, -0.0) should be +0.0")
        }

        @Test func `nan Propagation`() {
            #expect(IEEE_754.MinMax.maximum(Double.nan, 3.14).isNaN, "maximum propagates NaN")
            #expect(IEEE_754.MinMax.maximum(3.14, Double.nan).isNaN, "maximum propagates NaN")
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Double minimumNumber")
    struct DoubleMinimumNumber {
        @Test(arguments: [(3.14, 2.71, 2.71), (2.71, 3.14, 2.71)])
        func `normal Values`(x: Double, y: Double, expected: Double) {
            #expect(IEEE_754.MinMax.minimumNumber(x, y) == expected)
        }

        @Test func `nan Preference`() {
            #expect(
                IEEE_754.MinMax.minimumNumber(Double.nan, 3.14) == 3.14,
                "Prefer number over NaN"
            )
            #expect(
                IEEE_754.MinMax.minimumNumber(3.14, Double.nan) == 3.14,
                "Prefer number over NaN"
            )
            #expect(
                IEEE_754.MinMax.minimumNumber(Double.nan, Double.nan).isNaN,
                "Both NaN returns NaN"
            )
        }

        @Test func `signed Zeros`() {
            let result = IEEE_754.MinMax.minimumNumber(-0.0, 0.0)
            #expect(result.sign == .minus, "minimumNumber(-0.0, +0.0) should be -0.0")
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Double maximumNumber")
    struct DoubleMaximumNumber {
        @Test(arguments: [(3.14, 2.71, 3.14), (2.71, 3.14, 3.14)])
        func `normal Values`(x: Double, y: Double, expected: Double) {
            #expect(IEEE_754.MinMax.maximumNumber(x, y) == expected)
        }

        @Test func `nan Preference`() {
            #expect(
                IEEE_754.MinMax.maximumNumber(Double.nan, 3.14) == 3.14,
                "Prefer number over NaN"
            )
            #expect(
                IEEE_754.MinMax.maximumNumber(3.14, Double.nan) == 3.14,
                "Prefer number over NaN"
            )
            #expect(
                IEEE_754.MinMax.maximumNumber(Double.nan, Double.nan).isNaN,
                "Both NaN returns NaN"
            )
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Double minimumMagnitude")
    struct DoubleMinimumMagnitude {
        @Test func `by Absolute Value`() {
            #expect(IEEE_754.MinMax.minimumMagnitude(3.14, -2.71) == -2.71, "Select by magnitude")
            #expect(IEEE_754.MinMax.minimumMagnitude(-3.14, 2.71) == 2.71, "Select by magnitude")
            #expect(
                IEEE_754.MinMax.minimumMagnitude(-3.14, 3.14) == -3.14,
                "Equal magnitude: tie-break by sign"
            )
        }

        @Test func `nan Propagation`() {
            #expect(IEEE_754.MinMax.minimumMagnitude(Double.nan, 3.14).isNaN, "Propagate NaN")
            #expect(IEEE_754.MinMax.minimumMagnitude(3.14, Double.nan).isNaN, "Propagate NaN")
        }

        @Test func `zero Handling`() {
            #expect(
                IEEE_754.MinMax.minimumMagnitude(0.0, 3.14) == 0.0,
                "Zero has smallest magnitude"
            )
            #expect(
                IEEE_754.MinMax.minimumMagnitude(-0.0, 3.14) == -0.0,
                "Zero has smallest magnitude"
            )
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Double maximumMagnitude")
    struct DoubleMaximumMagnitude {
        @Test func `by Absolute Value`() {
            #expect(IEEE_754.MinMax.maximumMagnitude(3.14, -2.71) == 3.14, "Select by magnitude")
            #expect(IEEE_754.MinMax.maximumMagnitude(-3.14, 2.71) == -3.14, "Select by magnitude")
        }

        @Test func `nan Propagation`() {
            #expect(IEEE_754.MinMax.maximumMagnitude(Double.nan, 3.14).isNaN, "Propagate NaN")
            #expect(IEEE_754.MinMax.maximumMagnitude(3.14, Double.nan).isNaN, "Propagate NaN")
        }

        @Test func infinities() {
            #expect(
                IEEE_754.MinMax.maximumMagnitude(Double.infinity, 100.0) == Double.infinity,
                "Infinity has largest magnitude"
            )
            #expect(
                IEEE_754.MinMax.maximumMagnitude(-Double.infinity, 100.0) == -Double.infinity,
                "Negative infinity has largest magnitude"
            )
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Double minimumMagnitudeNumber")
    struct DoubleMinimumMagnitudeNumber {
        @Test func `by Absolute Value`() {
            #expect(
                IEEE_754.MinMax.minimumMagnitudeNumber(3.14, -2.71) == -2.71,
                "Select by magnitude"
            )
            #expect(
                IEEE_754.MinMax.minimumMagnitudeNumber(-3.14, 2.71) == 2.71,
                "Select by magnitude"
            )
        }

        @Test func `nan Preference`() {
            #expect(
                IEEE_754.MinMax.minimumMagnitudeNumber(Double.nan, 3.14) == 3.14,
                "Prefer number over NaN"
            )
            #expect(
                IEEE_754.MinMax.minimumMagnitudeNumber(3.14, Double.nan) == 3.14,
                "Prefer number over NaN"
            )
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Double maximumMagnitudeNumber")
    struct DoubleMaximumMagnitudeNumber {
        @Test func `by Absolute Value`() {
            #expect(
                IEEE_754.MinMax.maximumMagnitudeNumber(3.14, -2.71) == 3.14,
                "Select by magnitude"
            )
            #expect(
                IEEE_754.MinMax.maximumMagnitudeNumber(-3.14, 2.71) == -3.14,
                "Select by magnitude"
            )
        }

        @Test func `nan Preference`() {
            #expect(
                IEEE_754.MinMax.maximumMagnitudeNumber(Double.nan, 3.14) == 3.14,
                "Prefer number over NaN"
            )
            #expect(
                IEEE_754.MinMax.maximumMagnitudeNumber(3.14, Double.nan) == 3.14,
                "Prefer number over NaN"
            )
        }
    }
}

// MARK: - Float MinMax Tests

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Float minimum")
    struct FloatMinimum {
        @Test(arguments: [
            (Float(3.14), Float(2.71), Float(2.71)), (Float(2.71), Float(3.14), Float(2.71)),
        ])
        func `normal Values`(x: Float, y: Float, expected: Float) {
            #expect(IEEE_754.MinMax.minimum(x, y) == expected)
        }

        @Test func `signed Zeros`() {
            let result = IEEE_754.MinMax.minimum(Float(-0.0), Float(0.0))
            #expect(result.sign == .minus, "minimum(-0.0, +0.0) should be -0.0")
        }

        @Test func `nan Propagation`() {
            #expect(IEEE_754.MinMax.minimum(Float.nan, Float(3.14)).isNaN, "minimum propagates NaN")
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Float maximum")
    struct FloatMaximum {
        @Test(arguments: [
            (Float(3.14), Float(2.71), Float(3.14)), (Float(2.71), Float(3.14), Float(3.14)),
        ])
        func `normal Values`(x: Float, y: Float, expected: Float) {
            #expect(IEEE_754.MinMax.maximum(x, y) == expected)
        }

        @Test func `signed Zeros`() {
            let result = IEEE_754.MinMax.maximum(Float(-0.0), Float(0.0))
            #expect(result.sign == .plus, "maximum(-0.0, +0.0) should be +0.0")
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Float minimumNumber")
    struct FloatMinimumNumber {
        @Test func `nan Preference`() {
            #expect(
                IEEE_754.MinMax.minimumNumber(Float.nan, Float(3.14)) == Float(3.14),
                "Prefer number over NaN"
            )
            #expect(
                IEEE_754.MinMax.minimumNumber(Float(3.14), Float.nan) == Float(3.14),
                "Prefer number over NaN"
            )
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Float maximumNumber")
    struct FloatMaximumNumber {
        @Test func `nan Preference`() {
            #expect(
                IEEE_754.MinMax.maximumNumber(Float.nan, Float(3.14)) == Float(3.14),
                "Prefer number over NaN"
            )
            #expect(
                IEEE_754.MinMax.maximumNumber(Float(3.14), Float.nan) == Float(3.14),
                "Prefer number over NaN"
            )
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Float minimumMagnitude")
    struct FloatMinimumMagnitude {
        @Test func `by Absolute Value`() {
            #expect(
                IEEE_754.MinMax.minimumMagnitude(Float(3.14), Float(-2.71)) == Float(-2.71),
                "Select by magnitude"
            )
            #expect(
                IEEE_754.MinMax.minimumMagnitude(Float(-3.14), Float(2.71)) == Float(2.71),
                "Select by magnitude"
            )
        }
    }
}

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Float maximumMagnitude")
    struct FloatMaximumMagnitude {
        @Test func `by Absolute Value`() {
            #expect(
                IEEE_754.MinMax.maximumMagnitude(Float(3.14), Float(-2.71)) == Float(3.14),
                "Select by magnitude"
            )
            #expect(
                IEEE_754.MinMax.maximumMagnitude(Float(-3.14), Float(2.71)) == Float(-3.14),
                "Select by magnitude"
            )
        }
    }
}

// MARK: - Hierarchical Operation API Tests

extension IEEE_754.MinMax.Test {
    @Suite("IEEE_754.MinMax - Hierarchical Operation API")
    struct MinMaxOperation {
        @Test
        func `apply with Operation enum - standard(.minimum)`() {
            #expect(IEEE_754.MinMax.apply(3.14, 2.71, operation: .standard(.minimum)) == 2.71)
            #expect(IEEE_754.MinMax.apply(Double.nan, 3.14, operation: .standard(.minimum)).isNaN)
        }

        @Test
        func `apply with Operation enum - standard(.maximum)`() {
            #expect(IEEE_754.MinMax.apply(3.14, 2.71, operation: .standard(.maximum)) == 3.14)
            #expect(IEEE_754.MinMax.apply(Double.nan, 3.14, operation: .standard(.maximum)).isNaN)
        }

        @Test
        func `apply with Operation enum - number(.minimum)`() {
            #expect(IEEE_754.MinMax.apply(3.14, 2.71, operation: .number(.minimum)) == 2.71)
            #expect(IEEE_754.MinMax.apply(Double.nan, 3.14, operation: .number(.minimum)) == 3.14)
        }

        @Test
        func `apply with Operation enum - number(.maximum)`() {
            #expect(IEEE_754.MinMax.apply(3.14, 2.71, operation: .number(.maximum)) == 3.14)
            #expect(IEEE_754.MinMax.apply(Double.nan, 3.14, operation: .number(.maximum)) == 3.14)
        }

        @Test
        func `apply with Operation enum - magnitude(.minimum, preferNumber: false)`() {
            #expect(
                IEEE_754.MinMax.apply(
                    3.14,
                    -2.71,
                    operation: .magnitude(.minimum, preferNumber: false)
                ) == -2.71
            )
            #expect(
                IEEE_754.MinMax.apply(
                    Double.nan,
                    3.14,
                    operation: .magnitude(.minimum, preferNumber: false)
                ).isNaN
            )
        }

        @Test
        func `apply with Operation enum - magnitude(.maximum, preferNumber: false)`() {
            #expect(
                IEEE_754.MinMax.apply(
                    3.14,
                    -2.71,
                    operation: .magnitude(.maximum, preferNumber: false)
                ) == 3.14
            )
        }

        @Test
        func `apply with Operation enum - magnitude(.minimum, preferNumber: true)`() {
            #expect(
                IEEE_754.MinMax.apply(
                    3.14,
                    -2.71,
                    operation: .magnitude(.minimum, preferNumber: true)
                ) == -2.71
            )
            #expect(
                IEEE_754.MinMax.apply(
                    Double.nan,
                    3.14,
                    operation: .magnitude(.minimum, preferNumber: true)
                ) == 3.14
            )
        }

        @Test
        func `apply with Operation enum - magnitude(.maximum, preferNumber: true)`() {
            #expect(
                IEEE_754.MinMax.apply(
                    3.14,
                    -2.71,
                    operation: .magnitude(.maximum, preferNumber: true)
                ) == 3.14
            )
            #expect(
                IEEE_754.MinMax.apply(
                    Double.nan,
                    3.14,
                    operation: .magnitude(.maximum, preferNumber: true)
                ) == 3.14
            )
        }

        @Test
        func `Operation enum pattern matching works correctly`() {
            let operations: [IEEE_754.MinMax.Operation] = [
                .standard(.minimum),
                .standard(.maximum),
                .number(.minimum),
                .number(.maximum),
                .magnitude(.minimum, preferNumber: false),
                .magnitude(.maximum, preferNumber: false),
                .magnitude(.minimum, preferNumber: true),
                .magnitude(.maximum, preferNumber: true),
            ]

            for operation in operations {
                let result = IEEE_754.MinMax.apply(3.14, 2.71, operation: operation)
                #expect(result.isFinite)

                switch operation {
                case .standard(.minimum), .number(.minimum), .magnitude(.minimum, _):
                    #expect(result <= 3.14)

                case .standard(.maximum), .number(.maximum), .magnitude(.maximum, _):
                    #expect(result >= 2.71)
                }
            }
        }
    }
}
