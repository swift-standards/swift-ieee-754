// IEEE_754_Tests.swift
// swift-ieee-754
//
// Tests for IEEE 754 binary floating-point serialization

import Testing
@testable import IEEE_754

@Suite("IEEE 754 Binary64 Tests")
struct Binary64Tests {
    @Test("Double round-trip serialization")
    func doubleRoundTrip() {
        let original: Double = 3.14159265358979323846
        let bytes = [UInt8](original)
        let restored = bytes.ieee754.asDouble()

        #expect(restored == original)
    }

    @Test("Double big-endian serialization")
    func doubleBigEndian() {
        let value: Double = 3.14159
        let bytes = [UInt8](value, endianness: .big)
        let restored = bytes.ieee754.asDouble(endianness: .big)

        #expect(restored == value)
    }

    @Test("Double special values")
    func doubleSpecialValues() {
        // Zero
        let zero = [UInt8](0.0)
        #expect(zero.ieee754.asDouble() == 0.0)

        // Infinity
        let inf = [UInt8](Double.infinity)
        #expect(inf.ieee754.asDouble() == Double.infinity)

        // NaN
        let nan = [UInt8](Double.nan)
        #expect(nan.ieee754.asDouble()?.isNaN == true)
    }
}

@Suite("IEEE 754 Binary32 Tests")
struct Binary32Tests {
    @Test("Float round-trip serialization")
    func floatRoundTrip() {
        let original: Float = 3.14159
        let bytes = [UInt8](original)
        let restored = bytes.ieee754.asFloat()

        #expect(restored == original)
    }

    @Test("Float big-endian serialization")
    func floatBigEndian() {
        let value: Float = 3.14
        let bytes = [UInt8](value, endianness: .big)
        let restored = bytes.ieee754.asFloat(endianness: .big)

        #expect(restored == value)
    }

    @Test("Float special values")
    func floatSpecialValues() {
        // Zero
        let zero = [UInt8](Float(0.0))
        #expect(zero.ieee754.asFloat() == 0.0)

        // Infinity
        let inf = [UInt8](Float.infinity)
        #expect(inf.ieee754.asFloat() == Float.infinity)

        // NaN
        let nan = [UInt8](Float.nan)
        #expect(nan.ieee754.asFloat()?.isNaN == true)
    }
}

@Suite("IEEE 754 Convenience API Tests")
struct ConvenienceAPITests {
    @Test("Double namespaced API")
    func doubleNamespacedAPI() {
        let value: Double = 2.71828
        let bytes = value.ieee754.bytes()
        let restored = Double.ieee754(bytes)

        #expect(restored == value)
    }

    @Test("Float namespaced API")
    func floatNamespacedAPI() {
        let value: Float = 1.414
        let bytes = value.ieee754.bytes()
        let restored = Float.ieee754(bytes)

        #expect(restored == value)
    }
}
