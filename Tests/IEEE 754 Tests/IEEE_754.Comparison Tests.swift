// IEEE_754.Comparison Tests.swift
// swift-ieee-754
//
// Comprehensive tests for IEEE 754-2019 Section 5.6 & 5.10 Comparison operations

import Testing

@testable import IEEE_754

// MARK: - Double Comparison Tests

extension IEEE_754.Comparison {
    @Suite("IEEE_754.Comparison - Double isEqual")
    struct Test {
        @Test(arguments: [(3.14, 3.14, true), (3.14, 2.71, false), (0.0, -0.0, true)])
        func equality(lhs: Double, rhs: Double, expected: Bool) {
            #expect(IEEE_754.Comparison.isEqual(lhs, rhs) == expected)
        }

        @Test func `Nan Equality`() {
            #expect(
                !IEEE_754.Comparison.isEqual(Double.nan, Double.nan),
                "NaN should not equal NaN"
            )
            #expect(!IEEE_754.Comparison.isEqual(Double.nan, 3.14), "NaN should not equal number")
            #expect(!IEEE_754.Comparison.isEqual(3.14, Double.nan), "Number should not equal NaN")
        }

        @Test func `Signed Zeros`() {
            #expect(
                IEEE_754.Comparison.isEqual(0.0, -0.0),
                "Positive zero should equal negative zero"
            )
            #expect(
                IEEE_754.Comparison.isEqual(-0.0, 0.0),
                "Negative zero should equal positive zero"
            )
        }

        @Test func infinities() {
            #expect(
                IEEE_754.Comparison.isEqual(Double.infinity, Double.infinity),
                "Infinity should equal itself"
            )
            #expect(
                IEEE_754.Comparison.isEqual(-Double.infinity, -Double.infinity),
                "Negative infinity should equal itself"
            )
            #expect(
                !IEEE_754.Comparison.isEqual(Double.infinity, -Double.infinity),
                "Positive and negative infinity should not be equal"
            )
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Double isNotEqual")
    struct DoubleIsNotEqual {
        @Test(arguments: [(3.14, 2.71, true), (3.14, 3.14, false)])
        func inequality(lhs: Double, rhs: Double, expected: Bool) {
            #expect(IEEE_754.Comparison.isNotEqual(lhs, rhs) == expected)
        }

        @Test func `Nan Inequality`() {
            #expect(
                IEEE_754.Comparison.isNotEqual(Double.nan, Double.nan),
                "NaN should not equal NaN"
            )
            #expect(IEEE_754.Comparison.isNotEqual(Double.nan, 3.14), "NaN should not equal number")
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Double isLess")
    struct DoubleIsLess {
        @Test(arguments: [
            (2.71, 3.14, true),
            (3.14, 2.71, false),
            (3.14, 3.14, false),
        ])
        func `Less Than`(lhs: Double, rhs: Double, expected: Bool) {
            #expect(IEEE_754.Comparison.isLess(lhs, rhs) == expected)
        }

        @Test func `Nan Comparisons`() {
            #expect(
                !IEEE_754.Comparison.isLess(Double.nan, 3.14),
                "NaN comparisons should be false"
            )
            #expect(
                !IEEE_754.Comparison.isLess(3.14, Double.nan),
                "NaN comparisons should be false"
            )
            #expect(
                !IEEE_754.Comparison.isLess(Double.nan, Double.nan),
                "NaN comparisons should be false"
            )
        }

        @Test func `Infinity Comparisons`() {
            #expect(IEEE_754.Comparison.isLess(-Double.infinity, 0.0), "-inf < 0")
            #expect(IEEE_754.Comparison.isLess(0.0, Double.infinity), "0 < +inf")
            #expect(
                !IEEE_754.Comparison.isLess(Double.infinity, Double.infinity),
                "+inf not < +inf"
            )
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Double isLessEqual")
    struct DoubleIsLessEqual {
        @Test(arguments: [
            (2.71, 3.14, true),
            (3.14, 3.14, true),
            (3.14, 2.71, false),
        ])
        func `Less Equal`(lhs: Double, rhs: Double, expected: Bool) {
            #expect(IEEE_754.Comparison.isLessEqual(lhs, rhs) == expected)
        }

        @Test func `Signed Zeros`() {
            #expect(IEEE_754.Comparison.isLessEqual(0.0, -0.0), "0.0 <= -0.0")
            #expect(IEEE_754.Comparison.isLessEqual(-0.0, 0.0), "-0.0 <= 0.0")
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Double isGreater")
    struct DoubleIsGreater {
        @Test(arguments: [
            (3.14, 2.71, true),
            (2.71, 3.14, false),
            (3.14, 3.14, false),
        ])
        func `Greater Than`(lhs: Double, rhs: Double, expected: Bool) {
            #expect(IEEE_754.Comparison.isGreater(lhs, rhs) == expected)
        }

        @Test func `Nan Comparisons`() {
            #expect(
                !IEEE_754.Comparison.isGreater(Double.nan, 3.14),
                "NaN comparisons should be false"
            )
            #expect(
                !IEEE_754.Comparison.isGreater(3.14, Double.nan),
                "NaN comparisons should be false"
            )
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Double isGreaterEqual")
    struct DoubleIsGreaterEqual {
        @Test(arguments: [
            (3.14, 2.71, true),
            (3.14, 3.14, true),
            (2.71, 3.14, false),
        ])
        func `Greater Equal`(lhs: Double, rhs: Double, expected: Bool) {
            #expect(IEEE_754.Comparison.isGreaterEqual(lhs, rhs) == expected)
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Double totalOrder")
    struct DoubleTotalOrder {
        @Test func `Signed Zero Ordering`() {
            #expect(IEEE_754.Comparison.totalOrder(-0.0, 0.0), "-0 should be ordered before +0")
            #expect(
                !IEEE_754.Comparison.totalOrder(0.0, -0.0),
                "+0 should not be ordered before -0"
            )
        }

        @Test func `Nan Ordering`() {
            // NaN values are ordered after all non-NaN values
            #expect(
                !IEEE_754.Comparison.totalOrder(Double.nan, 3.14),
                "NaN should not be ordered before numbers"
            )
            #expect(
                IEEE_754.Comparison.totalOrder(3.14, Double.nan),
                "Numbers should be ordered before NaN"
            )
            #expect(
                !IEEE_754.Comparison.totalOrder(Double.nan, Double.infinity),
                "NaN should not be ordered before infinity"
            )
        }

        @Test func `Infinity Ordering`() {
            #expect(IEEE_754.Comparison.totalOrder(-Double.infinity, 0.0), "-inf before 0")
            #expect(IEEE_754.Comparison.totalOrder(0.0, Double.infinity), "0 before +inf")
            #expect(
                IEEE_754.Comparison.totalOrder(-Double.infinity, Double.infinity),
                "-inf before +inf"
            )
        }

        @Test func `Normal Value Ordering`() {
            #expect(IEEE_754.Comparison.totalOrder(-100.0, -10.0), "-100 before -10")
            #expect(IEEE_754.Comparison.totalOrder(-10.0, -1.0), "-10 before -1")
            #expect(IEEE_754.Comparison.totalOrder(-1.0, 0.0), "-1 before 0")
            #expect(IEEE_754.Comparison.totalOrder(0.0, 1.0), "0 before 1")
            #expect(IEEE_754.Comparison.totalOrder(1.0, 10.0), "1 before 10")
        }

        @Test func `Complete Ordering`() {
            // totalOrder defines a complete ordering: -NaN < -Inf < -Finite < -0 < +0 < +Finite < +Inf < +NaN
            let values: [Double] = [
                -Double.infinity, -100.0, -1.0, -0.0, 0.0, 1.0, 100.0, Double.infinity,
            ]
            for i in 0..<values.count - 1 {
                #expect(
                    IEEE_754.Comparison.totalOrder(values[i], values[i + 1]),
                    "\(values[i]) should be ordered before \(values[i + 1])"
                )
            }
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Double totalOrderMag")
    struct DoubleTotalOrderMag {
        @Test func `Magnitude Ordering`() {
            #expect(IEEE_754.Comparison.totalOrderMag(2.71, 3.14), "|2.71| < |3.14|")
            #expect(IEEE_754.Comparison.totalOrderMag(-2.71, 3.14), "|-2.71| < |3.14|")
            #expect(IEEE_754.Comparison.totalOrderMag(-3.14, 2.71) == false, "|-3.14| not < |2.71|")
        }

        @Test func `Zero Magnitude`() {
            #expect(IEEE_754.Comparison.totalOrderMag(0.0, 1.0), "|0| < |1|")
            #expect(IEEE_754.Comparison.totalOrderMag(-0.0, 1.0), "|-0| < |1|")
        }

        @Test func `Infinity Magnitude`() {
            #expect(IEEE_754.Comparison.totalOrderMag(1.0, Double.infinity), "|1| < |inf|")
            #expect(IEEE_754.Comparison.totalOrderMag(1.0, -Double.infinity), "|1| < |-inf|")
        }
    }
}

// MARK: - Float Comparison Tests

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Float isEqual")
    struct FloatIsEqual {
        @Test(arguments: [
            (Float(3.14), Float(3.14), true),
            (Float(3.14), Float(2.71), false),
            (Float(0.0), Float(-0.0), true),
        ])
        func equality(lhs: Float, rhs: Float, expected: Bool) {
            #expect(IEEE_754.Comparison.isEqual(lhs, rhs) == expected)
        }

        @Test func `Nan Equality`() {
            #expect(!IEEE_754.Comparison.isEqual(Float.nan, Float.nan), "NaN should not equal NaN")
            #expect(
                !IEEE_754.Comparison.isEqual(Float.nan, Float(3.14)),
                "NaN should not equal number"
            )
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Float isNotEqual")
    struct FloatIsNotEqual {
        @Test(arguments: [
            (Float(3.14), Float(2.71), true),
            (Float(3.14), Float(3.14), false),
        ])
        func inequality(lhs: Float, rhs: Float, expected: Bool) {
            #expect(IEEE_754.Comparison.isNotEqual(lhs, rhs) == expected)
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Float isLess")
    struct FloatIsLess {
        @Test(arguments: [
            (Float(2.71), Float(3.14), true),
            (Float(3.14), Float(2.71), false),
            (Float(3.14), Float(3.14), false),
        ])
        func `Less Than`(lhs: Float, rhs: Float, expected: Bool) {
            #expect(IEEE_754.Comparison.isLess(lhs, rhs) == expected)
        }

        @Test func `Nan Comparisons`() {
            #expect(
                !IEEE_754.Comparison.isLess(Float.nan, Float(3.14)),
                "NaN comparisons should be false"
            )
            #expect(
                !IEEE_754.Comparison.isLess(Float(3.14), Float.nan),
                "NaN comparisons should be false"
            )
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Float isLessEqual")
    struct FloatIsLessEqual {
        @Test(arguments: [
            (Float(2.71), Float(3.14), true),
            (Float(3.14), Float(3.14), true),
            (Float(3.14), Float(2.71), false),
        ])
        func `Less Equal`(lhs: Float, rhs: Float, expected: Bool) {
            #expect(IEEE_754.Comparison.isLessEqual(lhs, rhs) == expected)
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Float isGreater")
    struct FloatIsGreater {
        @Test(arguments: [
            (Float(3.14), Float(2.71), true),
            (Float(2.71), Float(3.14), false),
            (Float(3.14), Float(3.14), false),
        ])
        func `Greater Than`(lhs: Float, rhs: Float, expected: Bool) {
            #expect(IEEE_754.Comparison.isGreater(lhs, rhs) == expected)
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Float isGreaterEqual")
    struct FloatIsGreaterEqual {
        @Test(arguments: [
            (Float(3.14), Float(2.71), true),
            (Float(3.14), Float(3.14), true),
            (Float(2.71), Float(3.14), false),
        ])
        func `Greater Equal`(lhs: Float, rhs: Float, expected: Bool) {
            #expect(IEEE_754.Comparison.isGreaterEqual(lhs, rhs) == expected)
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Float totalOrder")
    struct FloatTotalOrder {
        @Test func `Signed Zero Ordering`() {
            #expect(
                IEEE_754.Comparison.totalOrder(Float(-0.0), Float(0.0)),
                "-0 should be ordered before +0"
            )
            #expect(
                !IEEE_754.Comparison.totalOrder(Float(0.0), Float(-0.0)),
                "+0 should not be ordered before -0"
            )
        }

        @Test func `Nan Ordering`() {
            #expect(
                !IEEE_754.Comparison.totalOrder(Float.nan, Float(3.14)),
                "NaN should not be ordered before numbers"
            )
            #expect(
                IEEE_754.Comparison.totalOrder(Float(3.14), Float.nan),
                "Numbers should be ordered before NaN"
            )
        }

        @Test func `Complete Ordering`() {
            let values: [Float] = [
                -Float.infinity, Float(-100.0), Float(-1.0), Float(-0.0), Float(0.0), Float(1.0),
                Float(100.0),
                Float.infinity,
            ]
            for i in 0..<values.count - 1 {
                #expect(
                    IEEE_754.Comparison.totalOrder(values[i], values[i + 1]),
                    "\(values[i]) should be ordered before \(values[i + 1])"
                )
            }
        }
    }
}

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Float totalOrderMag")
    struct FloatTotalOrderMag {
        @Test func `Magnitude Ordering`() {
            #expect(IEEE_754.Comparison.totalOrderMag(Float(2.71), Float(3.14)), "|2.71| < |3.14|")
            #expect(
                IEEE_754.Comparison.totalOrderMag(Float(-2.71), Float(3.14)),
                "|-2.71| < |3.14|"
            )
            #expect(
                !IEEE_754.Comparison.totalOrderMag(Float(-3.14), Float(2.71)),
                "|-3.14| not < |2.71|"
            )
        }
    }
}

// MARK: - Hierarchical Predicate API Tests

extension IEEE_754.Comparison.Test {
    @Suite("IEEE_754.Comparison - Hierarchical Predicate API")
    struct ComparisonPredicate {
        @Test
        func `compare with Predicate enum - equality(.equal)`() {
            #expect(IEEE_754.Comparison.compare(3.14, 3.14, using: .equality(.equal)))
            #expect(!IEEE_754.Comparison.compare(3.14, 2.71, using: .equality(.equal)))
            #expect(IEEE_754.Comparison.compare(Float(3.14), Float(3.14), using: .equality(.equal)))
        }

        @Test
        func `compare with Predicate enum - equality(.notEqual)`() {
            #expect(IEEE_754.Comparison.compare(3.14, 2.71, using: .equality(.notEqual)))
            #expect(!IEEE_754.Comparison.compare(3.14, 3.14, using: .equality(.notEqual)))
            #expect(
                IEEE_754.Comparison.compare(Float(3.14), Float(2.71), using: .equality(.notEqual))
            )
        }

        @Test
        func `compare with Predicate enum - ordering(.less(orEqual: false))`() {
            #expect(
                IEEE_754.Comparison.compare(2.71, 3.14, using: .ordering(.less(orEqual: false)))
            )
            #expect(
                !IEEE_754.Comparison.compare(3.14, 2.71, using: .ordering(.less(orEqual: false)))
            )
            #expect(
                !IEEE_754.Comparison.compare(3.14, 3.14, using: .ordering(.less(orEqual: false)))
            )
        }

        @Test
        func `compare with Predicate enum - ordering(.less(orEqual: true))`() {
            #expect(IEEE_754.Comparison.compare(2.71, 3.14, using: .ordering(.less(orEqual: true))))
            #expect(IEEE_754.Comparison.compare(3.14, 3.14, using: .ordering(.less(orEqual: true))))
            #expect(
                !IEEE_754.Comparison.compare(3.14, 2.71, using: .ordering(.less(orEqual: true)))
            )
        }

        @Test
        func `compare with Predicate enum - ordering(.greater(orEqual: false))`() {
            #expect(
                IEEE_754.Comparison.compare(3.14, 2.71, using: .ordering(.greater(orEqual: false)))
            )
            #expect(
                !IEEE_754.Comparison.compare(2.71, 3.14, using: .ordering(.greater(orEqual: false)))
            )
            #expect(
                !IEEE_754.Comparison.compare(3.14, 3.14, using: .ordering(.greater(orEqual: false)))
            )
        }

        @Test
        func `compare with Predicate enum - ordering(.greater(orEqual: true))`() {
            #expect(
                IEEE_754.Comparison.compare(3.14, 2.71, using: .ordering(.greater(orEqual: true)))
            )
            #expect(
                IEEE_754.Comparison.compare(3.14, 3.14, using: .ordering(.greater(orEqual: true)))
            )
            #expect(
                !IEEE_754.Comparison.compare(2.71, 3.14, using: .ordering(.greater(orEqual: true)))
            )
        }

        @Test
        func `Predicate enum pattern matching works correctly`() {
            let predicates: [IEEE_754.Comparison.Predicate] = [
                .equality(.equal),
                .equality(.notEqual),
                .ordering(.less(orEqual: false)),
                .ordering(.less(orEqual: true)),
                .ordering(.greater(orEqual: false)),
                .ordering(.greater(orEqual: true)),
            ]

            for predicate in predicates {
                let result = IEEE_754.Comparison.compare(3.0, 3.0, using: predicate)

                switch predicate {
                case .equality(.equal):
                    #expect(result == true)

                case .equality(.notEqual):
                    #expect(result == false)

                case .ordering(.less(orEqual: let orEqual)):
                    #expect(result == orEqual)

                case .ordering(.greater(orEqual: let orEqual)):
                    #expect(result == orEqual)
                }
            }
        }
    }
}
