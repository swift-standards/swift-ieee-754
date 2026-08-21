import Testing

@testable import IEEE_754

extension Double.Test {
    @Suite("IEEE 754 - Double Subnormal Numbers")
    struct Subnormal {
        @Test func `smallest subnormal number round-trips`() {
            let value = Double.leastNonzeroMagnitude
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "Smallest subnormal should round-trip")
            #expect(!restored!.isNormal, "Should remain subnormal")
        }

        @Test func `negative smallest subnormal round-trips`() {
            let value = -Double.leastNonzeroMagnitude
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "Negative smallest subnormal should round-trip")
            #expect(!restored!.isNormal, "Should remain subnormal")
        }

        @Test func `boundary between subnormal and normal`() {
            let leastNormal = Double.leastNormalMagnitude
            let bytes = leastNormal.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == leastNormal, "Least normal magnitude should round-trip")
            #expect(restored!.isNormal, "Should be normal, not subnormal")
        }

        @Test func `just below normal threshold`() {

            let leastNormal = Double.leastNormalMagnitude
            let largestSubnormal = leastNormal.nextDown

            let bytes = largestSubnormal.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == largestSubnormal, "Largest subnormal should round-trip")
            #expect(!restored!.isNormal, "Should be subnormal")
        }
    }
}

extension Double.Test {
    @Suite("IEEE 754 - Double Sign Bit Edge Cases")
    struct SignEdgeCases {
        @Test func `positive zero has correct sign bit`() {
            let zero: Double = 0.0
            let bytes = zero.bytes()

            #expect(bytes[7] & 0x80 == 0, "Positive zero should have sign bit = 0")

            let restored = Double(bytes: bytes)
            #expect(restored == 0.0)
            #expect(restored?.sign == .plus, "Should be positive zero")
        }

        @Test func `negative zero has correct sign bit`() {
            let negZero: Double = -0.0
            let bytes = negZero.bytes()

            #expect(bytes[7] & 0x80 == 0x80, "Negative zero should have sign bit = 1")

            let restored = Double(bytes: bytes)
            #expect(restored == -0.0)
            #expect(restored?.sign == .minus, "Should be negative zero")
        }

        @Test func `positive and negative zero are equal but distinguishable`() {
            let posZero: Double = 0.0
            let negZero: Double = -0.0

            #expect(posZero == negZero, "IEEE 754 requires +0 == -0")

            let posBytes = posZero.bytes()
            let negBytes = negZero.bytes()

            #expect(posBytes != negBytes, "Byte representations should differ")
            #expect(posBytes[7] & 0x80 != negBytes[7] & 0x80, "Sign bits should differ")
        }

        @Test func `infinity signs are preserved`() {
            let posInf = Double.infinity
            let negInf = -Double.infinity

            let posBytes = posInf.bytes()
            let negBytes = negInf.bytes()

            #expect(posBytes[7] & 0x80 == 0, "Positive infinity should have sign bit = 0")
            #expect(negBytes[7] & 0x80 == 0x80, "Negative infinity should have sign bit = 1")

            #expect(Double(bytes: posBytes) == posInf)
            #expect(Double(bytes: negBytes) == negInf)
        }
    }
}

extension Double.Test {
    @Suite("IEEE 754 - Double ULP (Unit in Last Place) Edge Cases")
    struct ULPEdgeCases {
        @Test func `one ULP above zero`() {
            let value = Double.leastNonzeroMagnitude
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "One ULP above zero should round-trip")
        }

        @Test func `adjacent representable numbers differ by exactly 1 ULP`() {
            let value: Double = 1.0
            let nextUp = value.nextUp
            let nextDown = value.nextDown

            let bytes1 = value.bytes()
            let bytes2 = nextUp.bytes()
            let bytes3 = nextDown.bytes()

            #expect(Double(bytes: bytes1) == value)
            #expect(Double(bytes: bytes2) == nextUp)
            #expect(Double(bytes: bytes3) == nextDown)

            #expect(nextDown < value)
            #expect(value < nextUp)
        }

        @Test func `ULP at different magnitudes`() {
            let values: [Double] = [
                1.0,
                10.0,
                100.0,
                1000.0,
                1e10,
                1e100,
                1e200,
            ]

            for value in values {
                let bytes = value.bytes()
                let nextUpBytes = value.nextUp.bytes()

                let restored = Double(bytes: bytes)
                let restoredNextUp = Double(bytes: nextUpBytes)

                #expect(restored == value, "\(value) should round-trip")
                #expect(restoredNextUp == value.nextUp, "\(value).nextUp should round-trip")
            }
        }
    }
}

extension Double.Test {
    @Suite("IEEE 754 - Double Extreme Values")
    struct ExtremeValues {
        @Test func `maximum finite value round-trips`() {
            let value = Double.greatestFiniteMagnitude
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "Maximum finite value should round-trip")
            #expect(restored!.isFinite, "Should remain finite")
            #expect(!restored!.isInfinite, "Should not become infinite")
        }

        @Test func `one ULP below infinity`() {
            let value = Double.greatestFiniteMagnitude
            let bytes = value.bytes()

            let exponent = (UInt16(bytes[7] & 0x7F) << 4) | (UInt16(bytes[6]) >> 4)
            #expect(exponent == 2046, "Should have exponent 2046")

            let restored = Double(bytes: bytes)
            #expect(restored!.isFinite)
        }

        @Test func `negative maximum magnitude round-trips`() {
            let value = -Double.greatestFiniteMagnitude
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "Negative maximum should round-trip")
            #expect(restored!.isFinite)
            #expect(restored!.sign == .minus)
        }
    }
}

extension Double.Test {
    @Suite("IEEE 754 - Double NaN Bit Patterns")
    struct NaNEdgeCases {
        @Test func `quiet NaN round-trips`() {
            let nan = Double.nan
            let bytes = nan.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored?.isNaN == true, "NaN should round-trip as NaN")
        }

        @Test func `signaling NaN becomes quiet NaN`() {

            var bytes: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x7F]
            let value = Double(bytes: bytes)

            #expect(value?.isNaN == true, "Signaling NaN should be recognized as NaN")

            let roundTrip = value!.bytes()
            let restored = Double(bytes: roundTrip)

            #expect(restored?.isNaN == true, "Should remain NaN after round-trip")
        }

        @Test func `NaN with different payloads`() {

            let nanPatterns: [[UInt8]] = [
                [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF8, 0x7F],
                [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F],
                [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF8, 0x7F],
            ]

            for pattern in nanPatterns {
                let value = Double(bytes: pattern)
                #expect(value?.isNaN == true, "Should recognize NaN pattern")

                let restored = Double(bytes: value!.bytes())
                #expect(restored?.isNaN == true, "Should preserve NaN-ness")
            }
        }
    }
}

extension Double.Test {
    @Suite("IEEE 754 - Double Endianness Edge Cases")
    struct EndiannessEdgeCases {
        @Test func `special values survive endianness conversion`() {
            let values: [Double] = [
                0.0,
                -0.0,
                .infinity,
                -.infinity,
                .nan,
                .leastNonzeroMagnitude,
                .leastNormalMagnitude,
                .greatestFiniteMagnitude,
            ]

            for value in values {
                let littleBytes = value.bytes(endianness: .little)
                let bigBytes = value.bytes(endianness: .big)

                #expect(littleBytes == bigBytes.reversed(), "Endianness should be exact reversal")

                if value.isNaN {
                    let restoredLittle = Double(bytes: littleBytes, endianness: .little)
                    let restoredBig = Double(bytes: bigBytes, endianness: .big)
                    #expect(restoredLittle?.isNaN == true)
                    #expect(restoredBig?.isNaN == true)
                } else {
                    #expect(Double(bytes: littleBytes, endianness: .little) == value)
                    #expect(Double(bytes: bigBytes, endianness: .big) == value)
                }
            }
        }
    }
}

extension Float.Test {
    @Suite("IEEE 754 - Float Subnormal Numbers")
    struct Subnormal {
        @Test func `smallest subnormal number round-trips`() {
            let value = Float.leastNonzeroMagnitude
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)

            #expect(restored == value, "Smallest subnormal should round-trip")
            #expect(!restored!.isNormal, "Should remain subnormal")
        }

        @Test func `boundary between subnormal and normal`() {
            let leastNormal = Float.leastNormalMagnitude
            let bytes = leastNormal.bytes()
            let restored = Float(bytes: bytes)

            #expect(restored == leastNormal, "Least normal magnitude should round-trip")
            #expect(restored!.isNormal, "Should be normal, not subnormal")
        }

        @Test func `just below normal threshold`() {
            let leastNormal = Float.leastNormalMagnitude
            let largestSubnormal = leastNormal.nextDown

            let bytes = largestSubnormal.bytes()
            let restored = Float(bytes: bytes)

            #expect(restored == largestSubnormal, "Largest subnormal should round-trip")
            #expect(!restored!.isNormal, "Should be subnormal")
        }
    }
}

extension Float.Test {
    @Suite("IEEE 754 - Float Sign Bit Edge Cases")
    struct SignEdgeCases {
        @Test func `positive and negative zero byte patterns`() {
            let posZero: Float = 0.0
            let negZero: Float = -0.0

            let posBytes = posZero.bytes()
            let negBytes = negZero.bytes()

            #expect(posBytes[3] & 0x80 == 0, "Positive zero should have sign bit = 0")
            #expect(negBytes[3] & 0x80 == 0x80, "Negative zero should have sign bit = 1")

            #expect(Float(bytes: posBytes) == 0.0)
            #expect(Float(bytes: negBytes) == -0.0)
        }
    }
}

extension Float.Test {
    @Suite("IEEE 754 - Float Extreme Values")
    struct ExtremeValues {
        @Test func `maximum finite value round-trips`() {
            let value = Float.greatestFiniteMagnitude
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)

            #expect(restored == value, "Maximum finite value should round-trip")
            #expect(restored!.isFinite, "Should remain finite")
        }

        @Test func `one ULP below infinity`() {
            let value = Float.greatestFiniteMagnitude
            let bytes = value.bytes()

            let exponent = (UInt16(bytes[3] & 0x7F) << 1) | (UInt16(bytes[2]) >> 7)
            #expect(exponent == 254, "Should have exponent 254")

            let restored = Float(bytes: bytes)
            #expect(restored!.isFinite)
        }
    }
}

extension Float.Test {
    @Suite("IEEE 754 - Float NaN Bit Patterns")
    struct NaNEdgeCases {
        @Test func `NaN with different payloads`() {
            let nanPatterns: [[UInt8]] = [
                [0x01, 0x00, 0xC0, 0x7F],
                [0xFF, 0xFF, 0xFF, 0x7F],
                [0x00, 0x00, 0xC0, 0x7F],
            ]

            for pattern in nanPatterns {
                let value = Float(bytes: pattern)
                #expect(value?.isNaN == true, "Should recognize NaN pattern")

                let restored = Float(bytes: value!.bytes())
                #expect(restored?.isNaN == true, "Should preserve NaN-ness")
            }
        }
    }
}

@Suite("IEEE 754 - Mixed Precision Edge Cases")
struct MixedPrecisionEdgeCases {
    @Test func `Float leastNonzeroMagnitude is different from Double`() {
        let floatMin = Float.leastNonzeroMagnitude
        let doubleMin = Double.leastNonzeroMagnitude

        #expect(Double(floatMin) != doubleMin, "Different precisions have different minimums")
    }

    @Test func `Float and Double infinity convert correctly`() {
        let floatInf = Float.infinity
        let doubleInf = Double.infinity

        #expect(Double(floatInf) == doubleInf, "Float infinity should convert to Double infinity")
        #expect(Float(doubleInf) == floatInf, "Double infinity should convert to Float infinity")
    }
}

extension IEEE_754.Binary64.Test {
    @Suite("IEEE 754 - Binary64 Bit Pattern Validation")
    struct BitPatternValidation {
        @Test func `all zeros produces positive zero`() {
            let bytes: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            let value = IEEE_754.Binary64.value(from: bytes)

            #expect(value == 0.0, "All zeros should be +0.0")
            #expect(value?.sign == .plus, "Should be positive")
        }

        @Test func `sign bit only produces negative zero`() {
            let bytes: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80]
            let value = IEEE_754.Binary64.value(from: bytes)

            #expect(value == -0.0, "Sign bit only should be -0.0")
            #expect(value?.sign == .minus, "Should be negative")
        }

        @Test func `max exponent with zero significand is infinity`() {

            let posInfBytes: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x7F]
            let negInfBytes: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF]

            let posInf = IEEE_754.Binary64.value(from: posInfBytes)
            let negInf = IEEE_754.Binary64.value(from: negInfBytes)

            #expect(posInf?.isInfinite == true, "Should be infinity")
            #expect(posInf?.sign == .plus, "Should be positive infinity")
            #expect(negInf?.isInfinite == true, "Should be infinity")
            #expect(negInf?.sign == .minus, "Should be negative infinity")
        }

        @Test func `max exponent with non-zero significand is NaN`() {

            let nanBytes: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF8, 0x7F]
            let value = IEEE_754.Binary64.value(from: nanBytes)

            #expect(value?.isNaN == true, "Max exponent with non-zero significand should be NaN")
        }
    }
}

extension IEEE_754.Binary32.Test {
    @Suite("IEEE 754 - Binary32 Bit Pattern Validation")
    struct BitPatternValidation {
        @Test func `all zeros produces positive zero`() {
            let bytes: [UInt8] = [0x00, 0x00, 0x00, 0x00]
            let value = IEEE_754.Binary32.value(from: bytes)

            #expect(value == 0.0, "All zeros should be +0.0")
            #expect(value?.sign == .plus, "Should be positive")
        }

        @Test func `sign bit only produces negative zero`() {
            let bytes: [UInt8] = [0x00, 0x00, 0x00, 0x80]
            let value = IEEE_754.Binary32.value(from: bytes)

            #expect(value == -0.0, "Sign bit only should be -0.0")
            #expect(value?.sign == .minus, "Should be negative")
        }

        @Test func `max exponent with zero significand is infinity`() {
            let posInfBytes: [UInt8] = [0x00, 0x00, 0x80, 0x7F]
            let negInfBytes: [UInt8] = [0x00, 0x00, 0x80, 0xFF]

            let posInf = IEEE_754.Binary32.value(from: posInfBytes)
            let negInf = IEEE_754.Binary32.value(from: negInfBytes)

            #expect(posInf?.isInfinite == true, "Should be infinity")
            #expect(posInf?.sign == .plus, "Should be positive infinity")
            #expect(negInf?.isInfinite == true, "Should be infinity")
            #expect(negInf?.sign == .minus, "Should be negative infinity")
        }

        @Test func `max exponent with non-zero significand is NaN`() {
            let nanBytes: [UInt8] = [0x01, 0x00, 0xC0, 0x7F]
            let value = IEEE_754.Binary32.value(from: nanBytes)

            #expect(value?.isNaN == true, "Max exponent with non-zero significand should be NaN")
        }
    }
}
