import Testing

@testable import IEEE_754

extension IEEE_754.NextOperations {
    @Suite("IEEE_754.NextOperations - Double nextUp")
    struct Test {
        @Test func `normal Values`() {
            let value = 1.0
            let next = IEEE_754.NextOperations.nextUp(value)
            #expect(next > value, "nextUp should be greater than original")
            #expect(next == value.nextUp, "Should match Swift's nextUp")
        }

        @Test func `from Zero`() {
            let next = IEEE_754.NextOperations.nextUp(0.0)
            #expect(
                next == Double.leastNonzeroMagnitude,
                "nextUp(0) should be leastNonzeroMagnitude"
            )
            #expect(next > 0.0, "nextUp(0) should be positive")
        }

        @Test func `from Negative Zero`() {
            let next = IEEE_754.NextOperations.nextUp(-0.0)
            #expect(
                next == Double.leastNonzeroMagnitude,
                "nextUp(-0) should be leastNonzeroMagnitude"
            )
            #expect(next > 0.0, "nextUp(-0) should be positive")
        }

        @Test func `from Infinity`() {
            let next = IEEE_754.NextOperations.nextUp(Double.infinity)
            #expect(next.isInfinite, "nextUp(+inf) should be +inf")
            #expect(next.sign == .plus, "nextUp(+inf) should be positive")
        }

        @Test func `from NaN`() {
            let next = IEEE_754.NextOperations.nextUp(Double.nan)
            #expect(next.isNaN, "nextUp(NaN) should be NaN")
        }

        @Test func `from Max Finite`() {
            let maxFinite = Double.greatestFiniteMagnitude
            let next = IEEE_754.NextOperations.nextUp(maxFinite)
            #expect(next.isInfinite, "nextUp(maxFinite) should overflow to infinity")
            #expect(next.sign == .plus, "Should be positive infinity")
        }

        @Test func `across Subnormal Boundary`() {
            let maxSubnorm = Double.leastNormalMagnitude.nextDown
            #expect(maxSubnorm.isSubnormal, "Setup: should be subnormal")
            let next = IEEE_754.NextOperations.nextUp(maxSubnorm)
            #expect(next.isNormal, "nextUp from maxSubnormal should be normal")
            #expect(next == Double.leastNormalMagnitude, "Should be leastNormalMagnitude")
        }
    }
}

extension IEEE_754.NextOperations.Test {
    @Suite("IEEE_754.NextOperations - Double nextDown")
    struct DoubleNextDown {
        @Test func `normal Values`() {
            let value = 1.0
            let next = IEEE_754.NextOperations.nextDown(value)
            #expect(next < value, "nextDown should be less than original")
            #expect(next == value.nextDown, "Should match Swift's nextDown")
        }

        @Test func `from Zero`() {
            let next = IEEE_754.NextOperations.nextDown(0.0)
            #expect(
                next == -Double.leastNonzeroMagnitude,
                "nextDown(0) should be -leastNonzeroMagnitude"
            )
            #expect(next < 0.0, "nextDown(0) should be negative")
        }

        @Test func `from Negative Zero`() {
            let next = IEEE_754.NextOperations.nextDown(-0.0)
            #expect(
                next == -Double.leastNonzeroMagnitude,
                "nextDown(-0) should be -leastNonzeroMagnitude"
            )
            #expect(next < 0.0, "nextDown(-0) should be negative")
        }

        @Test func `from Negative Infinity`() {
            let next = IEEE_754.NextOperations.nextDown(-Double.infinity)
            #expect(next.isInfinite, "nextDown(-inf) should be -inf")
            #expect(next.sign == .minus, "nextDown(-inf) should be negative")
        }

        @Test func `from NaN`() {
            let next = IEEE_754.NextOperations.nextDown(Double.nan)
            #expect(next.isNaN, "nextDown(NaN) should be NaN")
        }

        @Test func `from Min Finite`() {
            let minFinite = -Double.greatestFiniteMagnitude
            let next = IEEE_754.NextOperations.nextDown(minFinite)
            #expect(next.isInfinite, "nextDown(minFinite) should overflow to -infinity")
            #expect(next.sign == .minus, "Should be negative infinity")
        }

        @Test func `across Subnormal Boundary`() {
            let minNorm = Double.leastNormalMagnitude
            #expect(minNorm.isNormal, "Setup: should be normal")
            let next = IEEE_754.NextOperations.nextDown(minNorm)
            #expect(next.isSubnormal, "nextDown from leastNormalMagnitude should be subnormal")
        }
    }
}

extension IEEE_754.NextOperations.Test {
    @Suite("IEEE_754.NextOperations - Double nextAfter")
    struct DoubleNextAfter {
        @Test func `toward Larger`() {
            let result = IEEE_754.NextOperations.nextAfter(1.0, toward: 2.0)
            #expect(result > 1.0, "nextAfter toward larger should increase")
            #expect(result == 1.0.nextUp, "Should equal nextUp")
        }

        @Test func `toward Smaller`() {
            let result = IEEE_754.NextOperations.nextAfter(1.0, toward: 0.0)
            #expect(result < 1.0, "nextAfter toward smaller should decrease")
            #expect(result == 1.0.nextDown, "Should equal nextDown")
        }

        @Test func `toward Self`() {
            let result = IEEE_754.NextOperations.nextAfter(1.0, toward: 1.0)
            #expect(result == 1.0, "nextAfter toward self should return unchanged")
        }

        @Test func `nan Handling`() {
            let result1 = IEEE_754.NextOperations.nextAfter(Double.nan, toward: 1.0)
            #expect(result1.isNaN, "nextAfter(NaN, x) should be NaN")

            let result2 = IEEE_754.NextOperations.nextAfter(1.0, toward: Double.nan)
            #expect(result2.isNaN, "nextAfter(x, NaN) should be NaN")
        }

        @Test func `zero Transition`() {
            let result1 = IEEE_754.NextOperations.nextAfter(-0.0, toward: 0.0)
            #expect(result1 == 0.0 && result1.sign == .plus, "nextAfter(-0, +0) should be +0")

            let result2 = IEEE_754.NextOperations.nextAfter(0.0, toward: -0.0)
            #expect(result2 == -0.0 && result2.sign == .minus, "nextAfter(+0, -0) should be -0")
        }

        @Test func `toward Infinity`() {
            let maxFinite = Double.greatestFiniteMagnitude
            let result = IEEE_754.NextOperations.nextAfter(maxFinite, toward: Double.infinity)
            #expect(result.isInfinite, "nextAfter(maxFinite, +inf) should be +inf")
        }

        @Test func `crossing Zero`() {
            let tiny = Double.leastNonzeroMagnitude
            let result = IEEE_754.NextOperations.nextAfter(tiny, toward: -1.0)
            #expect(result == 0.0, "nextAfter(leastNonzero, negative) should be 0")
        }
    }
}

extension IEEE_754.NextOperations.Test {
    @Suite("IEEE_754.NextOperations - Float nextUp")
    struct FloatNextUp {
        @Test func `normal Values`() {
            let value = Float(1.0)
            let next = IEEE_754.NextOperations.nextUp(value)
            #expect(next > value, "nextUp should be greater than original")
            #expect(next == value.nextUp, "Should match Swift's nextUp")
        }

        @Test func `from Zero`() {
            let next = IEEE_754.NextOperations.nextUp(Float(0.0))
            #expect(
                next == Float.leastNonzeroMagnitude,
                "nextUp(0) should be leastNonzeroMagnitude"
            )
        }

        @Test func `from Infinity`() {
            let next = IEEE_754.NextOperations.nextUp(Float.infinity)
            #expect(next.isInfinite, "nextUp(+inf) should be +inf")
        }

        @Test func `from NaN`() {
            let next = IEEE_754.NextOperations.nextUp(Float.nan)
            #expect(next.isNaN, "nextUp(NaN) should be NaN")
        }
    }
}

extension IEEE_754.NextOperations.Test {
    @Suite("IEEE_754.NextOperations - Float nextDown")
    struct FloatNextDown {
        @Test func `normal Values`() {
            let value = Float(1.0)
            let next = IEEE_754.NextOperations.nextDown(value)
            #expect(next < value, "nextDown should be less than original")
            #expect(next == value.nextDown, "Should match Swift's nextDown")
        }

        @Test func `from Zero`() {
            let next = IEEE_754.NextOperations.nextDown(Float(0.0))
            #expect(
                next == -Float.leastNonzeroMagnitude,
                "nextDown(0) should be -leastNonzeroMagnitude"
            )
        }

        @Test func `from Negative Infinity`() {
            let next = IEEE_754.NextOperations.nextDown(-Float.infinity)
            #expect(next.isInfinite, "nextDown(-inf) should be -inf")
        }
    }
}

extension IEEE_754.NextOperations.Test {
    @Suite("IEEE_754.NextOperations - Float nextAfter")
    struct FloatNextAfter {
        @Test func `toward Larger`() {
            let result = IEEE_754.NextOperations.nextAfter(Float(1.0), toward: Float(2.0))
            #expect(result > Float(1.0), "nextAfter toward larger should increase")
            #expect(result == Float(1.0).nextUp, "Should equal nextUp")
        }

        @Test func `toward Smaller`() {
            let result = IEEE_754.NextOperations.nextAfter(Float(1.0), toward: Float(0.0))
            #expect(result < Float(1.0), "nextAfter toward smaller should decrease")
        }

        @Test func `toward Self`() {
            let result = IEEE_754.NextOperations.nextAfter(Float(1.0), toward: Float(1.0))
            #expect(result == Float(1.0), "nextAfter toward self should return unchanged")
        }

        @Test func `nan Handling`() {
            let result = IEEE_754.NextOperations.nextAfter(Float.nan, toward: Float(1.0))
            #expect(result.isNaN, "nextAfter(NaN, x) should be NaN")
        }
    }
}

extension IEEE_754.NextOperations.Test {
    @Suite("IEEE_754.NextOperations - Edge Cases")
    struct NextOperationsEdgeCases {
        @Test func `ulp Consistency`() {
            let value = 1.0
            let nextUp = IEEE_754.NextOperations.nextUp(value)
            let difference = nextUp - value
            #expect(difference == value.ulp, "Difference should equal ULP at 1.0")
        }

        @Test func symmetry() {
            let value = 3.14
            let up = IEEE_754.NextOperations.nextUp(value)
            let down = IEEE_754.NextOperations.nextDown(up)
            #expect(down == value, "nextDown(nextUp(x)) should equal x")
        }

        @Test func `negative Symmetry`() {
            let value = -3.14
            let down = IEEE_754.NextOperations.nextDown(value)
            let up = IEEE_754.NextOperations.nextUp(down)
            #expect(up == value, "nextUp(nextDown(x)) should equal x")
        }
    }
}
