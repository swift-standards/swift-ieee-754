// Endianness Tests.swift
// swift-ieee-754
//
// Tests for little-endian and big-endian byte order handling

import Testing
@testable import IEEE_754

@Suite("IEEE 754 - Double Endianness")
struct DoubleEndiannessTests {
    @Test(arguments: [3.14159, 2.71828, 1.41421, 0.0, 1.0, -1.0, 42.0])
    func `little-endian round-trip`(value: Double) {
        let bytes = value.bytes(endianness: .little)
        let restored = Double(bytes: bytes, endianness: .little)

        #expect(restored == value, "\(value) should round-trip with little-endian")
    }

    @Test(arguments: [3.14159, 2.71828, 1.41421, 0.0, 1.0, -1.0, 42.0])
    func `big-endian round-trip`(value: Double) {
        let bytes = value.bytes(endianness: .big)
        let restored = Double(bytes: bytes, endianness: .big)

        #expect(restored == value, "\(value) should round-trip with big-endian")
    }

    @Test(arguments: [3.14159, 2.71828, 1.41421])
    func `endianness produces different byte order`(value: Double) {
        let littleBytes = value.bytes(endianness: .little)
        let bigBytes = value.bytes(endianness: .big)

        #expect(littleBytes != bigBytes, "Little and big endian should produce different byte order")
        #expect(littleBytes.count == bigBytes.count, "Both should produce same byte count")
        #expect(littleBytes == bigBytes.reversed(), "Big endian should be reverse of little endian")
    }

    @Test func `default is little-endian`() {
        let value: Double = 3.14159
        let defaultBytes = value.bytes()
        let littleBytes = value.bytes(endianness: .little)

        #expect(defaultBytes == littleBytes, "Default should be little-endian")
    }

    @Test(arguments: [3.14159, 2.71828, 1.41421])
    func `mismatched endianness fails round-trip`(value: Double) {
        let littleBytes = value.bytes(endianness: .little)
        let wrongRestore = Double(bytes: littleBytes, endianness: .big)

        // Intentionally wrong endianness should NOT equal original
        #expect(wrongRestore != value, "Mismatched endianness should fail round-trip")
    }
}

@Suite("IEEE 754 - Float Endianness")
struct FloatEndiannessTests {
    @Test(arguments: [Float(3.14159), Float(2.71828), Float(1.41421), Float(0.0), Float(1.0), Float(-1.0), Float(42.0)])
    func `little-endian round-trip`(value: Float) {
        let bytes = value.bytes(endianness: .little)
        let restored = Float(bytes: bytes, endianness: .little)

        #expect(restored == value, "\(value) should round-trip with little-endian")
    }

    @Test(arguments: [Float(3.14159), Float(2.71828), Float(1.41421), Float(0.0), Float(1.0), Float(-1.0), Float(42.0)])
    func `big-endian round-trip`(value: Float) {
        let bytes = value.bytes(endianness: .big)
        let restored = Float(bytes: bytes, endianness: .big)

        #expect(restored == value, "\(value) should round-trip with big-endian")
    }

    @Test(arguments: [Float(3.14159), Float(2.71828), Float(1.41421)])
    func `endianness produces different byte order`(value: Float) {
        let littleBytes = value.bytes(endianness: .little)
        let bigBytes = value.bytes(endianness: .big)

        #expect(littleBytes != bigBytes, "Little and big endian should produce different byte order")
        #expect(littleBytes.count == bigBytes.count, "Both should produce same byte count")
        #expect(littleBytes == bigBytes.reversed(), "Big endian should be reverse of little endian")
    }

    @Test func `default is little-endian`() {
        let value: Float = 3.14159
        let defaultBytes = value.bytes()
        let littleBytes = value.bytes(endianness: .little)

        #expect(defaultBytes == littleBytes, "Default should be little-endian")
    }

    @Test(arguments: [Float(3.14), Float(2.718), Float(1.414)])
    func `mismatched endianness fails round-trip`(value: Float) {
        let littleBytes = value.bytes(endianness: .little)
        let wrongRestore = Float(bytes: littleBytes, endianness: .big)

        // Intentionally wrong endianness should NOT equal original
        #expect(wrongRestore != value, "Mismatched endianness should fail round-trip")
    }
}
