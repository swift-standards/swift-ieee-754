import Standard_Library_Extensions
import Testing

@testable import IEEE_754

extension Double.Test {
    @Suite("IEEE 754 - Double Powers of 2")
    struct PowersOfTwo {
        @Test func `powers of 2 have exact representations`() {

            let powers: [(Int, Double)] = [
                (0, 1.0),
                (1, 2.0),
                (2, 4.0),
                (3, 8.0),
                (10, 1024.0),
                (20, 1048576.0),
                (30, 1073741824.0),
                (52, 4503599627370496.0),
                (53, 9007199254740992.0),
                (100, 1.2676506002282294e30),
                (500, 3.273390607896142e150),
                (1000, 1.0715086071862673e301),
                (1023, 8.98846567431158e307),
            ]

            for (exponent, value) in powers {
                let bytes = value.bytes()
                let restored = Double(bytes: bytes)

                #expect(restored == value, "2^\(exponent) should round-trip exactly")
            }
        }

        @Test func `negative powers of 2 have exact representations`() {
            let powers: [(Int, Double)] = [
                (-1, 0.5),
                (-2, 0.25),
                (-3, 0.125),
                (-10, 0.0009765625),
                (-20, 9.5367431640625e-7),
                (-52, 2.220446049250313e-16),
                (-100, 7.888609052210118e-31),
                (-500, 3.054936363499605e-151),
                (-1022, 2.2250738585072014e-308),
                (-1074, 4.9406564584124654e-324),
            ]

            for (exponent, value) in powers {
                let bytes = value.bytes()
                let restored = Double(bytes: bytes)

                #expect(restored == value, "2^\(exponent) should round-trip exactly")
            }
        }

        @Test func `negative powers of 2 are negative`() {
            let powers: [Double] = [
                -1.0,
                -2.0,
                -4.0,
                -0.5,
                -0.25,
            ]

            for value in powers {
                let bytes = value.bytes()
                let restored = Double(bytes: bytes)

                #expect(restored == value, "\(value) should round-trip exactly")
                #expect(restored?.sign == .minus, "Should preserve negative sign")
            }
        }
    }
}

extension Float.Test {
    @Suite("IEEE 754 - Float Powers of 2")
    struct PowersOfTwo {
        @Test func `powers of 2 have exact representations`() {
            let powers: [(Int, Float)] = [
                (0, 1.0),
                (1, 2.0),
                (2, 4.0),
                (10, 1024.0),
                (23, 8388608.0),
                (24, 16777216.0),
                (100, 1.2676506e30),
                (127, 1.7014118e38),
            ]

            for (exponent, value) in powers {
                let bytes = value.bytes()
                let restored = Float(bytes: bytes)

                #expect(restored == value, "2^\(exponent) should round-trip exactly")
            }
        }

        @Test func `negative powers of 2 have exact representations`() {
            let powers: [(Int, Float)] = [
                (-1, 0.5),
                (-2, 0.25),
                (-10, 0.0009765625),
                (-23, 1.1920929e-7),
                (-126, 1.1754944e-38),
                (-149, 1.4012985e-45),
            ]

            for (exponent, value) in powers {
                let bytes = value.bytes()
                let restored = Float(bytes: bytes)

                #expect(restored == value, "2^\(exponent) should round-trip exactly")
            }
        }
    }
}

extension Double.Test {
    @Suite("IEEE 754 - Double Exponent Sweep")
    struct ExponentSweep {
        @Test func `sample exponent values across range`() {

            let exponents: [Int] = [
                1,
                10,
                100,
                500,
                1000,
                1023,
                1500,
                2000,
                2046,
            ]

            for expValue in exponents {

                let biasedExp = expValue - 1023
                let value = Double(biasedExp).power(2)

                let bytes = value.bytes()
                let restored = Double(bytes: bytes)

                #expect(
                    restored == value,
                    "Exponent \(expValue) (2^\(biasedExp)) should round-trip"
                )
            }
        }

        @Test func `boundary exponents`() {

            let subnormal = Double.leastNonzeroMagnitude
            #expect(Double(bytes: subnormal.bytes()) == subnormal)

            let minNormal = Double.leastNormalMagnitude
            #expect(Double(bytes: minNormal.bytes()) == minNormal)

            let maxNormal = Double.greatestFiniteMagnitude
            #expect(Double(bytes: maxNormal.bytes()) == maxNormal)

            let infinity = Double.infinity
            #expect(Double(bytes: infinity.bytes()) == infinity)
        }
    }
}

extension Float.Test {
    @Suite("IEEE 754 - Float Exponent Sweep")
    struct ExponentSweep {
        @Test func `sample exponent values across range`() {
            let exponents: [Int] = [
                1,
                10,
                50,
                100,
                127,
                150,
                200,
                254,
            ]

            for expValue in exponents {
                let biasedExp = expValue - 127
                let value = Float(biasedExp).power(2)

                let bytes = value.bytes()
                let restored = Float(bytes: bytes)

                #expect(restored == value, "Exponent \(expValue) should round-trip")
            }
        }
    }
}

extension IEEE_754.Binary64.Test {
    @Suite("IEEE 754 - Double Significand Bit Walking")
    struct SignificandBitWalking {
        @Test func `single bit set in each significand position`() {

            for bitPosition in 0..<52 {

                var bytes: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]

                let byteIndex = bitPosition / 8
                let bitIndex = bitPosition % 8
                bytes[byteIndex] = 1 << bitIndex

                let value = IEEE_754.Binary64.value(from: bytes)
                #expect(value != nil, "Single bit at position \(bitPosition) should decode")

                if let value {
                    let roundTrip = value.bytes()
                    let restored = IEEE_754.Binary64.value(from: roundTrip)
                    #expect(restored == value, "Bit \(bitPosition) should round-trip")
                }
            }
        }

        @Test func `walking bits with normal exponent`() {

            for bitPosition in 0..<10 {

                var bytes: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x3F]

                let byteIndex = bitPosition / 8
                let bitIndex = bitPosition % 8
                bytes[byteIndex] |= 1 << bitIndex

                let value = IEEE_754.Binary64.value(from: bytes)
                #expect(value != nil, "Bit \(bitPosition) with normal exponent should decode")

                if let value {
                    let roundTrip = value.bytes()
                    #expect(IEEE_754.Binary64.value(from: roundTrip) == value, "Should round-trip")
                }
            }
        }
    }
}

extension IEEE_754.Binary32.Test {
    @Suite("IEEE 754 - Float Significand Bit Walking")
    struct SignificandBitWalking {
        @Test func `single bit set in each significand position`() {
            for bitPosition in 0..<23 {
                var bytes: [UInt8] = [0x00, 0x00, 0x00, 0x00]

                let byteIndex = bitPosition / 8
                let bitIndex = bitPosition % 8
                bytes[byteIndex] = 1 << bitIndex

                let value = IEEE_754.Binary32.value(from: bytes)
                #expect(value != nil, "Single bit at position \(bitPosition) should decode")

                if let value {
                    let roundTrip = value.bytes()
                    let restored = IEEE_754.Binary32.value(from: roundTrip)
                    #expect(restored == value, "Bit \(bitPosition) should round-trip")
                }
            }
        }
    }
}

@Suite("IEEE 754 - Negative NaN")
struct NegativeNaNTests {
    @Test func `negative NaN round-trips as NaN`() {

        let negNaNBytes: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF8, 0xFF]
        let value = IEEE_754.Binary64.value(from: negNaNBytes)

        #expect(value?.isNaN == true, "Negative NaN should be recognized as NaN")

        if let value {
            let roundTrip = value.bytes()
            let restored = IEEE_754.Binary64.value(from: roundTrip)
            #expect(restored?.isNaN == true, "Should remain NaN after round-trip")
        }
    }

    @Test func `negative NaN for Float`() {
        let negNaNBytes: [UInt8] = [0x00, 0x00, 0xC0, 0xFF]
        let value = IEEE_754.Binary32.value(from: negNaNBytes)

        #expect(value?.isNaN == true, "Negative NaN should be recognized as NaN")

        if let value {
            let roundTrip = value.bytes()
            let restored = IEEE_754.Binary32.value(from: roundTrip)
            #expect(restored?.isNaN == true, "Should remain NaN after round-trip")
        }
    }

    @Test func `NaN sign bit variations`() {

        let posNaN = Double.nan
        let posBytes = posNaN.bytes()

        var negBytes = posBytes
        negBytes[7] |= 0x80

        let negNaN = Double(bytes: negBytes)
        #expect(negNaN?.isNaN == true, "Negative NaN should be NaN")
    }
}

extension Double.Test {
    @Suite("IEEE 754 - Known Problematic Values")
    struct KnownProblematicValues {
        @Test func `famous Java bug value`() {

            let value: Double = 2.2250738585072014e-308
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "Java bug value should round-trip")
        }

        @Test func `non-representable decimal fractions`() {

            let values: [Double] = [
                0.1,
                0.2,
                0.3,
                0.7,
                0.9,
            ]

            for value in values {
                let bytes = value.bytes()
                let restored = Double(bytes: bytes)
                #expect(restored == value, "\(value) should round-trip to same approximation")
            }
        }

        @Test func `problematic sums`() {

            let a: Double = 0.1
            let b: Double = 0.2
            let sum = a + b

            #expect(Double(bytes: a.bytes()) == a)
            #expect(Double(bytes: b.bytes()) == b)
            #expect(Double(bytes: sum.bytes()) == sum)
        }

        @Test func `near-one values`() {

            let values: [Double] = [
                1.0 + Double.ulpOfOne,
                1.0 - Double.ulpOfOne,
                1.0 + 2 * Double.ulpOfOne,
                1.0 - 2 * Double.ulpOfOne,
            ]

            for value in values {
                let bytes = value.bytes()
                let restored = Double(bytes: bytes)
                #expect(restored == value, "\(value) should round-trip")
            }
        }

        @Test func `specific bit patterns that broke other implementations`() {

            let problematicBytes: [[UInt8]] = [
                [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xEF, 0x7F],
                [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
                [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0x00],
                [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00],
            ]

            for pattern in problematicBytes {
                let value = IEEE_754.Binary64.value(from: pattern)
                #expect(value != nil, "Should decode pattern \(pattern)")

                if let value, !value.isNaN {
                    let roundTrip = value.bytes()
                    #expect(roundTrip == pattern, "Should produce identical bytes")
                }
            }
        }
    }
}

@Suite("IEEE 754 - Exact Binary Fractions")
struct ExactBinaryFractionsTests {
    @Test func `powers of 2 fractions are exact`() {
        let fractions: [Double] = [
            0.5,
            0.25,
            0.125,
            0.0625,
            0.03125,
            0.015625,
        ]

        for value in fractions {
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)
            #expect(restored == value, "\(value) should be exact")

            let original = value
            #expect(restored == original, "Should be bit-exact, not just approximately equal")
        }
    }

    @Test func `sums of powers of 2 are exact`() {
        let values: [Double] = [
            0.75,
            0.375,
            0.875,
            0.6875,
        ]

        for value in values {
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)
            #expect(restored == value, "\(value) should be exact")
        }
    }

    @Test func `float exact fractions`() {
        let fractions: [Float] = [
            0.5,
            0.25,
            0.125,
            0.0625,
            0.75,
            0.875,
        ]

        for value in fractions {
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)
            #expect(restored == value, "\(value) should be exact")
        }
    }
}

@Suite("IEEE 754 - Large Integer Boundaries")
struct LargeIntegerBoundariesTests {
    @Test func `largest exactly representable integer for Double`() {

        let maxInt: Double = 9007199254740992.0

        let bytes = maxInt.bytes()
        let restored = Double(bytes: bytes)

        #expect(restored == maxInt, "2^53 should be exactly representable")
    }

    @Test func `one beyond largest exactly representable integer`() {

        let beyondMax: Double = 9007199254740993.0

        let bytes = beyondMax.bytes()
        let restored = Double(bytes: bytes)

        #expect(restored == beyondMax, "Should round-trip to same approximation")
    }

    @Test func `integer boundaries for Double`() {
        let boundaries: [Double] = [
            9007199254740992.0,
            9007199254740991.0,
            -9007199254740992.0,
            -9007199254740991.0,
        ]

        for value in boundaries {
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)
            #expect(restored == value, "\(value) should round-trip exactly")
        }
    }

    @Test func `largest exactly representable integer for Float`() {

        let maxInt: Float = 16777216.0

        let bytes = maxInt.bytes()
        let restored = Float(bytes: bytes)

        #expect(restored == maxInt, "2^24 should be exactly representable")
    }

    @Test func `integer boundaries for Float`() {
        let boundaries: [Float] = [
            16777216.0,
            16777215.0,
            -16777216.0,
            -16777215.0,
        ]

        for value in boundaries {
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)
            #expect(restored == value, "\(value) should round-trip exactly")
        }
    }
}

@Suite("IEEE 754 - Cross-Format Precision")
struct CrossFormatPrecisionTests {
    @Test func `Float to Double preserves value`() {
        let floatValues: [Float] = [
            3.14159,
            2.71828,
            0.1,
            1000000.0,
            Float.leastNonzeroMagnitude,
            Float.leastNormalMagnitude,
        ]

        for floatVal in floatValues {
            let doubleVal = Double(floatVal)

            let floatBytes = floatVal.bytes()
            let doubleBytes = doubleVal.bytes()

            let restoredFloat = Float(bytes: floatBytes)
            let restoredDouble = Double(bytes: doubleBytes)

            #expect(restoredFloat == floatVal, "Float should round-trip")
            #expect(restoredDouble == doubleVal, "Double should round-trip")
            #expect(Double(restoredFloat!) == restoredDouble, "Conversion should be consistent")
        }
    }

    @Test func `Double to Float loses precision but round-trips`() {

        let value: Double = 1e100

        let floatVal = Float(value)
        #expect(floatVal.isInfinite, "Should overflow to infinity")

        let floatBytes = floatVal.bytes()
        let restored = Float(bytes: floatBytes)
        #expect(restored?.isInfinite == true, "Should remain infinity")
    }

    @Test func `precision loss scenarios`() {

        let doubleValues: [Double] = [
            1.2345678901234567,
            0.123456789012345,
        ]

        for doubleVal in doubleValues {
            let floatVal = Float(doubleVal)
            let backToDouble = Double(floatVal)

            #expect(Float(bytes: floatVal.bytes()) == floatVal)

            #expect(Double(bytes: doubleVal.bytes()) == doubleVal)

            #expect(backToDouble != doubleVal, "Should have lost precision")
        }
    }
}
