import Testing

@testable import IEEE_754

extension Double.Test {
    @Suite("IEEE 754 - Double Special Values")
    struct SpecialValues {
        @Test(arguments: [0.0, -0.0])
        func `zero values`(value: Double) {
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "\(value) should round-trip")

            if value.sign == .minus {
                #expect(restored?.sign == .minus, "Negative zero should preserve sign bit")
            } else {
                #expect(restored?.sign == .plus, "Positive zero should have plus sign")
            }
        }

        @Test(arguments: [Double.infinity, -Double.infinity])
        func `infinity values`(value: Double) {
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "\(value) should round-trip")
            #expect(restored?.isInfinite == true, "Value should be infinite")

            if value.sign == .minus {
                #expect(restored?.sign == .minus, "Negative infinity should preserve sign")
            } else {
                #expect(restored?.sign == .plus, "Positive infinity should have plus sign")
            }
        }

        @Test func `NaN value`() {
            let nan = Double.nan
            let bytes = nan.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored?.isNaN == true, "NaN should round-trip as NaN")
        }

        @Test func `greatest finite magnitude`() {
            let value = Double.greatestFiniteMagnitude
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "Greatest finite magnitude should round-trip")
        }

        @Test func `least nonzero magnitude`() {
            let value = Double.leastNonzeroMagnitude
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "Least nonzero magnitude should round-trip")
        }

        @Test func `least normal magnitude`() {
            let value = Double.leastNormalMagnitude
            let bytes = value.bytes()
            let restored = Double(bytes: bytes)

            #expect(restored == value, "Least normal magnitude should round-trip")
        }
    }
}

extension Float.Test {
    @Suite("IEEE 754 - Float Special Values")
    struct SpecialValues {
        @Test(arguments: [Float(0.0), Float(-0.0)])
        func `zero values`(value: Float) {
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)

            #expect(restored == value, "\(value) should round-trip")

            if value.sign == .minus {
                #expect(restored?.sign == .minus, "Negative zero should preserve sign bit")
            } else {
                #expect(restored?.sign == .plus, "Positive zero should have plus sign")
            }
        }

        @Test(arguments: [Float.infinity, -Float.infinity])
        func `infinity values`(value: Float) {
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)

            #expect(restored == value, "\(value) should round-trip")
            #expect(restored?.isInfinite == true, "Value should be infinite")

            if value.sign == .minus {
                #expect(restored?.sign == .minus, "Negative infinity should preserve sign")
            } else {
                #expect(restored?.sign == .plus, "Positive infinity should have plus sign")
            }
        }

        @Test func `NaN value`() {
            let nan = Float.nan
            let bytes = nan.bytes()
            let restored = Float(bytes: bytes)

            #expect(restored?.isNaN == true, "NaN should round-trip as NaN")
        }

        @Test func `greatest finite magnitude`() {
            let value = Float.greatestFiniteMagnitude
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)

            #expect(restored == value, "Greatest finite magnitude should round-trip")
        }

        @Test func `least nonzero magnitude`() {
            let value = Float.leastNonzeroMagnitude
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)

            #expect(restored == value, "Least nonzero magnitude should round-trip")
        }

        @Test func `least normal magnitude`() {
            let value = Float.leastNormalMagnitude
            let bytes = value.bytes()
            let restored = Float(bytes: bytes)

            #expect(restored == value, "Least normal magnitude should round-trip")
        }
    }
}
