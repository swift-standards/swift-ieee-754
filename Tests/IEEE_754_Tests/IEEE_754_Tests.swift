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
        let bytes = original.ieee754.bytes()
        let restored = bytes.ieee754.asDouble()

        #expect(restored == original)
    }

    @Test("Double canonical init round-trip")
    func doubleCanonicalInitRoundTrip() {
        let original: Double = 3.14159265358979323846
        let bytes = [UInt8](original)
        let restored = Double(bytes: bytes)

        #expect(restored == original)
    }

    @Test("Double big-endian serialization")
    func doubleBigEndian() {
        let value: Double = 3.14159
        let bytes = value.ieee754.bytes(endianness: .big)
        let restored = bytes.ieee754.asDouble(endianness: .big)

        #expect(restored == value)
    }

    @Test("Double canonical init big-endian")
    func doubleCanonicalInitBigEndian() {
        let value: Double = 3.14159
        let bytes = [UInt8](value, endianness: .big)
        let restored = Double(bytes: bytes, endianness: .big)

        #expect(restored == value)
    }

    @Test("Double special values")
    func doubleSpecialValues() {
        // Zero
        let zero = (0.0 as Double).ieee754.bytes()
        #expect(zero.ieee754.asDouble() == 0.0)

        // Infinity
        let inf = Double.infinity.ieee754.bytes()
        #expect(inf.ieee754.asDouble() == Double.infinity)

        // NaN
        let nan = Double.nan.ieee754.bytes()
        #expect(nan.ieee754.asDouble()?.isNaN == true)
    }
}

@Suite("IEEE 754 Binary32 Tests")
struct Binary32Tests {
    @Test("Float round-trip serialization")
    func floatRoundTrip() {
        let original: Float = 3.14159
        let bytes = original.ieee754.bytes()
        let restored = bytes.ieee754.asFloat()

        #expect(restored == original)
    }

    @Test("Float canonical init round-trip")
    func floatCanonicalInitRoundTrip() {
        let original: Float = 3.14159
        let bytes = [UInt8](original)
        let restored = Float(bytes: bytes)

        #expect(restored == original)
    }

    @Test("Float big-endian serialization")
    func floatBigEndian() {
        let value: Float = 3.14
        let bytes = value.ieee754.bytes(endianness: .big)
        let restored = bytes.ieee754.asFloat(endianness: .big)

        #expect(restored == value)
    }

    @Test("Float canonical init big-endian")
    func floatCanonicalInitBigEndian() {
        let value: Float = 3.14
        let bytes = [UInt8](value, endianness: .big)
        let restored = Float(bytes: bytes, endianness: .big)

        #expect(restored == value)
    }

    @Test("Float special values")
    func floatSpecialValues() {
        // Zero
        let zero = Float(0.0).ieee754.bytes()
        #expect(zero.ieee754.asFloat() == 0.0)

        // Infinity
        let inf = Float.infinity.ieee754.bytes()
        #expect(inf.ieee754.asFloat() == Float.infinity)

        // NaN
        let nan = Float.nan.ieee754.bytes()
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
