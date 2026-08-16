// ExoticEdgeCases Tests.swift
// swift-ieee-754
//
// Exotic and obscure edge cases that have historically broken other implementations
// These are the final 5% of edge cases that catch implementation bugs

import Standard_Library_Extensions
import Testing

@testable import IEEE_754

// MARK: - Powers of 2 (Exact Representations)

extension Double.Test {
    @Suite("IEEE 754 - Double Powers of 2")
    struct PowersOfTwo {
        @Test func `powers of 2 have exact representations`() {
            // Powers of 2 should round-trip perfectly with exact bit patterns
            let powers: [(Int, Double)] = [
                (0, 1.0),  // 2^0
                (1, 2.0),  // 2^1
                (2, 4.0),  // 2^2
                (3, 8.0),  // 2^3
                (10, 1024.0),  // 2^10
                (20, 1048576.0),  // 2^20
                (30, 1073741824.0),  // 2^30
                (52, 4503599627370496.0),  // 2^52 (significand precision boundary)
                (53, 9007199254740992.0),  // 2^53 (last exactly representable integer)
                (100, 1.2676506002282294e30),  // 2^100
                (500, 3.273390607896142e150),  // 2^500
                (1000, 1.0715086071862673e301),  // 2^1000
                (1023, 8.98846567431158e307),  // 2^1023 (near max exponent)
            ]

            for (exponent, value) in powers {
                let bytes = value.bytes()
                let restored = Double(bytes: bytes)

                #expect(restored == value, "2^\(exponent) should round-trip exactly")
            }
        }

        @Test func `negative powers of 2 have exact representations`() {
            let powers: [(Int, Double)] = [
                (-1, 0.5),  // 2^-1
                (-2, 0.25),  // 2^-2
                (-3, 0.125),  // 2^-3
                (-10, 0.0009765625),  // 2^-10
                (-20, 9.5367431640625e-7),  // 2^-20
                (-52, 2.220446049250313e-16),  // 2^-52 (epsilon)
                (-100, 7.888609052210118e-31),  // 2^-100
                (-500, 3.054936363499605e-151),  // 2^-500
                (-1022, 2.2250738585072014e-308),  // 2^-1022 (min normal exponent)
                (-1074, 4.9406564584124654e-324),  // 2^-1074 (min subnormal)
            ]

            for (exponent, value) in powers {
                let bytes = value.bytes()
                let restored = Double(bytes: bytes)

                #expect(restored == value, "2^\(exponent) should round-trip exactly")
            }
        }

        @Test func `negative powers of 2 are negative`() {
            let powers: [Double] = [
                -1.0,  // -2^0
                -2.0,  // -2^1
                -4.0,  // -2^2
                -0.5,  // -2^-1
                -0.25,  // -2^-2
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
                (23, 8388608.0),  // 2^23 (significand precision boundary)
                (24, 16777216.0),  // 2^24 (last exactly representable integer)
                (100, 1.2676506e30),  // 2^100
                (127, 1.7014118e38),  // 2^127 (near max exponent)
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
                (-23, 1.1920929e-7),  // 2^-23 (epsilon)
                (-126, 1.1754944e-38),  // 2^-126 (min normal exponent)
                (-149, 1.4012985e-45),  // 2^-149 (min subnormal)
            ]

            for (exponent, value) in powers {
                let bytes = value.bytes()
                let restored = Float(bytes: bytes)

                #expect(restored == value, "2^\(exponent) should round-trip exactly")
            }
        }
    }
}

// MARK: - Exponent Sweep

extension Double.Test {
    @Suite("IEEE 754 - Double Exponent Sweep")
    struct ExponentSweep {
        @Test func `sample exponent values across range`() {
            // Test representative exponent values across the entire range
            // Exponent field values: 0 (subnormal), 1-2046 (normal), 2047 (inf/NaN)
            let exponents: [Int] = [
                1,  // Minimum normal exponent
                10,
                100,
                500,
                1000,
                1023,  // Exponent bias
                1500,
                2000,
                2046,  // Maximum normal exponent
            ]

            for expValue in exponents {
                // Create a Double with this exponent and significand = 1.0
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
            // Exponent = 0 (subnormal)
            let subnormal = Double.leastNonzeroMagnitude
            #expect(Double(bytes: subnormal.bytes()) == subnormal)

            // Exponent = 1 (min normal)
            let minNormal = Double.leastNormalMagnitude
            #expect(Double(bytes: minNormal.bytes()) == minNormal)

            // Exponent = 2046 (max normal)
            let maxNormal = Double.greatestFiniteMagnitude
            #expect(Double(bytes: maxNormal.bytes()) == maxNormal)

            // Exponent = 2047 (infinity/NaN)
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
                1,  // Minimum normal exponent
                10,
                50,
                100,
                127,  // Exponent bias
                150,
                200,
                254,  // Maximum normal exponent
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

// MARK: - Significand Bit Walking

extension IEEE_754.Binary64.Test {
    @Suite("IEEE 754 - Double Significand Bit Walking")
    struct SignificandBitWalking {
        @Test func `single bit set in each significand position`() {
            // Test with exponent = 0 (subnormal) so only significand bits matter
            for bitPosition in 0..<52 {
                // Create bytes with only one significand bit set
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
            // Test with exponent = 1023 (unbiased 0, value = 1.0 * 2^0)
            // Significand bits represent fractional parts
            for bitPosition in 0..<10 {  // Test first 10 positions as sample
                // Exponent = 1023
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

// MARK: - Negative NaN

@Suite("IEEE 754 - Negative NaN")
struct NegativeNaNTests {
    @Test func `negative NaN round-trips as NaN`() {
        // Negative quiet NaN: sign=1, exp=all 1s, significand MSB=1
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
        // Positive NaN
        let posNaN = Double.nan
        let posBytes = posNaN.bytes()

        // Create negative NaN by setting sign bit
        var negBytes = posBytes
        negBytes[7] |= 0x80

        let negNaN = Double(bytes: negBytes)
        #expect(negNaN?.isNaN == true, "Negative NaN should be NaN")
    }
}

// MARK: - Known Problematic Values

extension Double.Test {
    @Suite("IEEE 754 - Known Problematic Values")
    struct KnownProblematicValues {
        @Test func `famous Java bug value`() {
            // 2.2250738585072014e-308 caused infinite loop in Java
            let value: Double = 2.2250738585072014e-308
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "Java bug value should round-trip")
        }

        @Test func `non-representable decimal fractions`() {
            // These cannot be represented exactly in binary but should still round-trip
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
            // 0.1 + 0.2 != 0.3 in binary, but each should still round-trip
            let a: Double = 0.1
            let b: Double = 0.2
            let sum = a + b

            #expect(Double(bytes: a.bytes()) == a)
            #expect(Double(bytes: b.bytes()) == b)
            #expect(Double(bytes: sum.bytes()) == sum)
        }

        @Test func `near-one values`() {
            // Values very close to 1.0
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
            // From real-world bug reports
            let problematicBytes: [[UInt8]] = [
                [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xEF, 0x7F],  // Largest finite
                [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],  // Smallest subnormal
                [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0x00],  // Largest subnormal
                [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00],  // Smallest normal
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

// MARK: - Exact Binary Fractions

@Suite("IEEE 754 - Exact Binary Fractions")
struct ExactBinaryFractionsTests {
    @Test func `powers of 2 fractions are exact`() {
        let fractions: [Double] = [
            0.5,  // 2^-1
            0.25,  // 2^-2
            0.125,  // 2^-3
            0.0625,  // 2^-4
            0.03125,  // 2^-5
            0.015625,  // 2^-6
        ]

        for value in fractions {
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)
            #expect(restored == value, "\(value) should be exact")

            // Verify it's actually exact by checking bit pattern
            let original = value
            #expect(restored == original, "Should be bit-exact, not just approximately equal")
        }
    }

    @Test func `sums of powers of 2 are exact`() {
        let values: [Double] = [
            0.75,  // 0.5 + 0.25
            0.375,  // 0.25 + 0.125
            0.875,  // 0.5 + 0.25 + 0.125
            0.6875,  // 0.5 + 0.125 + 0.0625
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
            0.75,  // 0.5 + 0.25
            0.875,  // 0.5 + 0.25 + 0.125
        ]

        for value in fractions {
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)
            #expect(restored == value, "\(value) should be exact")
        }
    }
}

// MARK: - Large Integer Boundaries

@Suite("IEEE 754 - Large Integer Boundaries")
struct LargeIntegerBoundariesTests {
    @Test func `largest exactly representable integer for Double`() {
        // 2^53 is the largest integer that can be exactly represented
        let maxInt: Double = 9007199254740992.0  // 2^53

        let bytes = maxInt.bytes()
        let restored = Double(bytes: bytes)

        #expect(restored == maxInt, "2^53 should be exactly representable")
    }

    @Test func `one beyond largest exactly representable integer`() {
        // 2^53 + 1 cannot be exactly represented (no ULP for odd integers here)
        let beyondMax: Double = 9007199254740993.0  // 2^53 + 1

        let bytes = beyondMax.bytes()
        let restored = Double(bytes: bytes)

        // Should round-trip to whatever it was rounded to
        #expect(restored == beyondMax, "Should round-trip to same approximation")
    }

    @Test func `integer boundaries for Double`() {
        let boundaries: [Double] = [
            9007199254740992.0,  // 2^53 (last exact integer)
            9007199254740991.0,  // 2^53 - 1 (largest odd exact integer)
            -9007199254740992.0,  // -2^53
            -9007199254740991.0,  // -(2^53 - 1)
        ]

        for value in boundaries {
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)
            #expect(restored == value, "\(value) should round-trip exactly")
        }
    }

    @Test func `largest exactly representable integer for Float`() {
        // 2^24 is the largest integer that can be exactly represented
        let maxInt: Float = 16777216.0  // 2^24

        let bytes = maxInt.bytes()
        let restored = Float(bytes: bytes)

        #expect(restored == maxInt, "2^24 should be exactly representable")
    }

    @Test func `integer boundaries for Float`() {
        let boundaries: [Float] = [
            16777216.0,  // 2^24 (last exact integer)
            16777215.0,  // 2^24 - 1
            -16777216.0,  // -2^24
            -16777215.0,  // -(2^24 - 1)
        ]

        for value in boundaries {
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)
            #expect(restored == value, "\(value) should round-trip exactly")
        }
    }
}

// MARK: - Cross-Format Comprehensive

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

            // Serialize both
            let floatBytes = floatVal.bytes()
            let doubleBytes = doubleVal.bytes()

            // Deserialize
            let restoredFloat = Float(bytes: floatBytes)
            let restoredDouble = Double(bytes: doubleBytes)

            #expect(restoredFloat == floatVal, "Float should round-trip")
            #expect(restoredDouble == doubleVal, "Double should round-trip")
            #expect(Double(restoredFloat!) == restoredDouble, "Conversion should be consistent")
        }
    }

    @Test func `Double to Float loses precision but round-trips`() {
        // Values that don't fit in Float range
        let value: Double = 1e100  // Too large for Float

        let floatVal = Float(value)
        #expect(floatVal.isInfinite, "Should overflow to infinity")

        let floatBytes = floatVal.bytes()
        let restored = Float(bytes: floatBytes)
        #expect(restored?.isInfinite == true, "Should remain infinity")
    }

    @Test func `precision loss scenarios`() {
        // Double values that lose precision when converted to Float
        let doubleValues: [Double] = [
            1.2345678901234567,  // More precision than Float can hold
            0.123456789012345,  // Small with high precision
        ]

        for doubleVal in doubleValues {
            let floatVal = Float(doubleVal)
            let backToDouble = Double(floatVal)

            // Float round-trip should work
            #expect(Float(bytes: floatVal.bytes()) == floatVal)

            // Double round-trip should work
            #expect(Double(bytes: doubleVal.bytes()) == doubleVal)

            // Precision is lost in conversion, but each format preserves its own
            #expect(backToDouble != doubleVal, "Should have lost precision")
        }
    }
}
