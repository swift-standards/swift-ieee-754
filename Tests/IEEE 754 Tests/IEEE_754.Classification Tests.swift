import Testing

@testable import IEEE_754

extension IEEE_754.Classification.NumberClass: @unchecked Sendable {}

extension IEEE_754.Classification {
    @Suite("IEEE_754.Classification - Double isSignMinus")
    struct Test {
        @Test(arguments: [
            (3.14, false),
            (-3.14, true),
            (0.0, false),
            (-0.0, true),
            (Double.infinity, false),
            (-Double.infinity, true),
            (Double.leastNonzeroMagnitude, false),
            (-Double.leastNonzeroMagnitude, true),
        ])
        func `Is Sign Minus`(value: Double, expected: Bool) {
            #expect(
                IEEE_754.Classification.isSignMinus(value) == expected,
                "isSignMinus(\(value)) should be \(expected)"
            )
        }

        @Test func `Nan Sign Bits`() {
            let positiveNaN = Double.nan
            let negativeNaN = -Double.nan
            #expect(
                !IEEE_754.Classification.isSignMinus(positiveNaN),
                "Positive NaN should not have sign bit set"
            )
            #expect(
                IEEE_754.Classification.isSignMinus(negativeNaN),
                "Negative NaN should have sign bit set"
            )
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Double isNormal")
    struct DoubleIsNormal {
        @Test(arguments: [1.0, -1.0, 3.14, -2.71, 1000.0, -0.001])
        func `Normal Values`(value: Double) {
            #expect(IEEE_754.Classification.isNormal(value), "\(value) should be normal")
        }

        @Test(arguments: [0.0, -0.0])
        func zeros(value: Double) {
            #expect(!IEEE_754.Classification.isNormal(value), "\(value) should not be normal")
        }

        @Test(arguments: [Double.infinity, -Double.infinity])
        func infinities(value: Double) {
            #expect(!IEEE_754.Classification.isNormal(value), "\(value) should not be normal")
        }

        @Test(arguments: [Double.nan, Double.signalingNaN])
        func nans(value: Double) {
            #expect(!IEEE_754.Classification.isNormal(value), "NaN should not be normal")
        }

        @Test func subnormals() {
            let subnormal = Double.leastNonzeroMagnitude
            #expect(!IEEE_754.Classification.isNormal(subnormal), "Subnormal should not be normal")
            #expect(
                !IEEE_754.Classification.isNormal(-subnormal),
                "Negative subnormal should not be normal"
            )
        }

        @Test func `Min Normal`() {
            let minNorm = Double.leastNormalMagnitude
            #expect(
                IEEE_754.Classification.isNormal(minNorm),
                "leastNormalMagnitude should be normal"
            )
            #expect(
                IEEE_754.Classification.isNormal(-minNorm),
                "Negative leastNormalMagnitude should be normal"
            )
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Double isFinite")
    struct DoubleIsFinite {
        @Test(arguments: [0.0, -0.0, 1.0, -1.0, 3.14, -2.71, 1e308, -1e308])
        func `Finite Values`(value: Double) {
            #expect(IEEE_754.Classification.isFinite(value), "\(value) should be finite")
        }

        @Test(arguments: [Double.infinity, -Double.infinity])
        func infinities(value: Double) {
            #expect(!IEEE_754.Classification.isFinite(value), "\(value) should not be finite")
        }

        @Test(arguments: [Double.nan, Double.signalingNaN])
        func nans(value: Double) {
            #expect(!IEEE_754.Classification.isFinite(value), "NaN should not be finite")
        }

        @Test func `Extreme Finite Values`() {
            let maxFinite = Double.greatestFiniteMagnitude
            #expect(
                IEEE_754.Classification.isFinite(maxFinite),
                "greatestFiniteMagnitude should be finite"
            )
            #expect(
                IEEE_754.Classification.isFinite(-maxFinite),
                "Negative greatestFiniteMagnitude should be finite"
            )
        }

        @Test func subnormals() {
            let subnormal = Double.leastNonzeroMagnitude
            #expect(IEEE_754.Classification.isFinite(subnormal), "Subnormal should be finite")
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Double isZero")
    struct DoubleIsZero {
        @Test(arguments: [0.0, -0.0])
        func zeros(value: Double) {
            #expect(IEEE_754.Classification.isZero(value), "\(value) should be zero")
        }

        @Test(arguments: [
            1.0, -1.0, 0.1, -0.1, Double.leastNonzeroMagnitude, -Double.leastNonzeroMagnitude,
        ])
        func `Non Zeros`(value: Double) {
            #expect(!IEEE_754.Classification.isZero(value), "\(value) should not be zero")
        }

        @Test(arguments: [Double.infinity, -Double.infinity, Double.nan])
        func `Special Values`(value: Double) {
            #expect(!IEEE_754.Classification.isZero(value), "\(value) should not be zero")
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Double isSubnormal")
    struct DoubleIsSubnormal {
        @Test func `Min Subnormal`() {
            let minSubnorm = Double.leastNonzeroMagnitude
            #expect(
                IEEE_754.Classification.isSubnormal(minSubnorm),
                "leastNonzeroMagnitude should be subnormal"
            )
            #expect(
                IEEE_754.Classification.isSubnormal(-minSubnorm),
                "Negative leastNonzeroMagnitude should be subnormal"
            )
        }

        @Test func `Max Subnormal`() {
            let maxSubnorm = Double.leastNormalMagnitude.nextDown
            #expect(
                IEEE_754.Classification.isSubnormal(maxSubnorm),
                "Value just below leastNormalMagnitude should be subnormal"
            )
        }

        @Test(arguments: [0.0, -0.0])
        func zeros(value: Double) {
            #expect(!IEEE_754.Classification.isSubnormal(value), "\(value) should not be subnormal")
        }

        @Test(arguments: [1.0, -1.0, 3.14])
        func `Normal Values`(value: Double) {
            #expect(!IEEE_754.Classification.isSubnormal(value), "\(value) should not be subnormal")
        }

        @Test(arguments: [Double.infinity, -Double.infinity, Double.nan])
        func `Special Values`(value: Double) {
            #expect(!IEEE_754.Classification.isSubnormal(value), "\(value) should not be subnormal")
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Double isInfinite")
    struct DoubleIsInfinite {
        @Test(arguments: [Double.infinity, -Double.infinity])
        func infinities(value: Double) {
            #expect(IEEE_754.Classification.isInfinite(value), "\(value) should be infinite")
        }

        @Test(arguments: [0.0, -0.0, 1.0, -1.0, 3.14, -2.71])
        func `Finite Values`(value: Double) {
            #expect(!IEEE_754.Classification.isInfinite(value), "\(value) should not be infinite")
        }

        @Test(arguments: [Double.nan, Double.signalingNaN])
        func nans(value: Double) {
            #expect(!IEEE_754.Classification.isInfinite(value), "NaN should not be infinite")
        }

        @Test func overflow() {
            let maxFinite = Double.greatestFiniteMagnitude
            let overflow = maxFinite * 2.0
            #expect(
                IEEE_754.Classification.isInfinite(overflow),
                "Overflow should produce infinity"
            )
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Double isNaN")
    struct DoubleIsNaN {
        @Test(arguments: [Double.nan, Double.signalingNaN, -Double.nan])
        func nans(value: Double) {
            #expect(IEEE_754.Classification.isNaN(value), "\(value) should be NaN")
        }

        @Test(arguments: [0.0, -0.0, 1.0, -1.0, Double.infinity, -Double.infinity])
        func `Non Na Ns`(value: Double) {
            #expect(!IEEE_754.Classification.isNaN(value), "\(value) should not be NaN")
        }

        @Test func `Nan Operations`() {
            let result = 0.0 / 0.0
            #expect(IEEE_754.Classification.isNaN(result), "0/0 should produce NaN")
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Double isSignaling")
    struct DoubleIsSignaling {
        @Test func `Signaling NaN`() {
            let snan = Double.signalingNaN
            #expect(IEEE_754.Classification.isSignaling(snan), "signalingNaN should be signaling")
        }

        @Test func `Quiet NaN`() {
            let qnan = Double.nan
            #expect(!IEEE_754.Classification.isSignaling(qnan), "quiet NaN should not be signaling")
        }

        @Test(arguments: [0.0, 1.0, -1.0, Double.infinity, -Double.infinity])
        func `Non Na Ns`(value: Double) {
            #expect(!IEEE_754.Classification.isSignaling(value), "\(value) should not be signaling")
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Double isCanonical")
    struct DoubleIsCanonical {
        @Test(arguments: [
            0.0, -0.0, 1.0, -1.0, 3.14, Double.infinity, -Double.infinity, Double.nan,
            Double.signalingNaN,
        ])
        func `All Values Canonical`(value: Double) {
            #expect(
                IEEE_754.Classification.isCanonical(value),
                "All binary format values should be canonical"
            )
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Double radix")
    struct DoubleRadix {
        @Test(arguments: [0.0, 1.0, -1.0, 3.14, Double.infinity, Double.nan])
        func `Radix Is Two`(value: Double) {
            #expect(
                IEEE_754.Classification.radix(value) == 2,
                "Radix should always be 2 for binary formats"
            )
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Double numberClass")
    struct DoubleNumberClass {
        @Test func `Signaling NaN`() {
            let snan = Double.signalingNaN
            #expect(IEEE_754.Classification.numberClass(snan) == .nan(.signaling))
        }

        @Test func `Quiet NaN`() {
            let qnan = Double.nan
            #expect(IEEE_754.Classification.numberClass(qnan) == .nan(.quiet))
        }

        @Test func `Negative Infinity`() {
            #expect(IEEE_754.Classification.numberClass(-Double.infinity) == .negative(.infinity))
        }

        @Test func `Negative Normal`() {
            #expect(IEEE_754.Classification.numberClass(-3.14) == .negative(.normal))
        }

        @Test func `Negative Subnormal`() {
            let negSubnorm = -Double.leastNonzeroMagnitude
            #expect(IEEE_754.Classification.numberClass(negSubnorm) == .negative(.subnormal))
        }

        @Test func `Negative Zero`() {
            #expect(IEEE_754.Classification.numberClass(-0.0) == .negative(.zero))
        }

        @Test func `Positive Zero`() {
            #expect(IEEE_754.Classification.numberClass(0.0) == .positive(.zero))
        }

        @Test func `Positive Subnormal`() {
            let posSubnorm = Double.leastNonzeroMagnitude
            #expect(IEEE_754.Classification.numberClass(posSubnorm) == .positive(.subnormal))
        }

        @Test func `Positive Normal`() {
            #expect(IEEE_754.Classification.numberClass(3.14) == .positive(.normal))
        }

        @Test func `Positive Infinity`() {
            #expect(IEEE_754.Classification.numberClass(Double.infinity) == .positive(.infinity))
        }

        @Test(arguments: [
            (-Double.infinity, IEEE_754.Classification.NumberClass.negative(.infinity)),
            (-100.0, .negative(.normal)),
            (-0.0, .negative(.zero)),
            (0.0, .positive(.zero)),
            (100.0, .positive(.normal)),
            (Double.infinity, .positive(.infinity)),
        ])
        func `Number Class Cases`(value: Double, expected: IEEE_754.Classification.NumberClass) {
            #expect(IEEE_754.Classification.numberClass(value) == expected)
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Float isSignMinus")
    struct FloatIsSignMinus {
        @Test(arguments: [
            (Float(3.14), false),
            (Float(-3.14), true),
            (Float(0.0), false),
            (Float(-0.0), true),
            (Float.infinity, false),
            (-Float.infinity, true),
        ])
        func `Is Sign Minus`(value: Float, expected: Bool) {
            #expect(IEEE_754.Classification.isSignMinus(value) == expected)
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Float isNormal")
    struct FloatIsNormal {
        @Test(arguments: [Float(1.0), Float(-1.0), Float(3.14)])
        func `Normal Values`(value: Float) {
            #expect(IEEE_754.Classification.isNormal(value))
        }

        @Test(arguments: [Float(0.0), Float.infinity, Float.nan])
        func `Non Normal Values`(value: Float) {
            #expect(!IEEE_754.Classification.isNormal(value))
        }

        @Test func subnormals() {
            let subnormal = Float.leastNonzeroMagnitude
            #expect(!IEEE_754.Classification.isNormal(subnormal))
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Float isFinite")
    struct FloatIsFinite {
        @Test(arguments: [Float(0.0), Float(1.0), Float(-1.0), Float(3.14)])
        func `Finite Values`(value: Float) {
            #expect(IEEE_754.Classification.isFinite(value))
        }

        @Test(arguments: [Float.infinity, -Float.infinity, Float.nan])
        func `Non Finite Values`(value: Float) {
            #expect(!IEEE_754.Classification.isFinite(value))
        }
    }
}

extension IEEE_754.Classification.Test {
    @Suite("IEEE_754.Classification - Float numberClass")
    struct FloatNumberClass {
        @Test(arguments: [
            (Float(-0.0), IEEE_754.Classification.NumberClass.negative(.zero)),
            (Float(0.0), .positive(.zero)),
            (Float(-3.14), .negative(.normal)),
            (Float(3.14), .positive(.normal)),
            (-Float.infinity, .negative(.infinity)),
            (Float.infinity, .positive(.infinity)),
        ])
        func `Number Class Cases`(value: Float, expected: IEEE_754.Classification.NumberClass) {
            #expect(IEEE_754.Classification.numberClass(value) == expected)
        }

        @Test func `Quiet NaN`() {
            #expect(IEEE_754.Classification.numberClass(Float.nan) == .nan(.quiet))
        }

        @Test func `Signaling NaN`() {
            #expect(IEEE_754.Classification.numberClass(Float.signalingNaN) == .nan(.signaling))
        }

        @Test func subnormals() {
            let posSubnorm = Float.leastNonzeroMagnitude
            let negSubnorm = -Float.leastNonzeroMagnitude
            #expect(IEEE_754.Classification.numberClass(posSubnorm) == .positive(.subnormal))
            #expect(IEEE_754.Classification.numberClass(negSubnorm) == .negative(.subnormal))
        }
    }
}
