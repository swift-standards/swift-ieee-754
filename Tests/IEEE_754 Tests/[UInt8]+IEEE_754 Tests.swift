// [UInt8]+IEEE_754 Tests.swift
// swift-ieee-754
//
// Tests for [UInt8] IEEE 754 extensions

import Testing
@testable import IEEE_754

@Suite("[UInt8]+IEEE_754 - Canonical Double serialization")
struct ArrayDoubleSerializationTests {
    @Test(arguments: [3.14159265358979323846, 2.71828, 1.41421, 0.0, 1.0, -1.0])
    func `unlabeled init with Double`(value: Double) {
        let bytes = [UInt8](value)
        let restored = Double(bytes: bytes)

        #expect(restored == value, "\(value) should round-trip through [UInt8](Double)")
    }

    @Test(arguments: [3.14159, 2.71828, 1.41421])
    func `unlabeled init with Double big-endian`(value: Double) {
        let bytes = [UInt8](value, endianness: .big)
        let restored = Double(bytes: bytes, endianness: .big)

        #expect(restored == value, "\(value) should round-trip with big-endian")
    }

    @Test func `Double serialization produces 8 bytes`() {
        let value: Double = 3.14159
        let bytes = [UInt8](value)

        #expect(bytes.count == 8, "Double serialization should produce exactly 8 bytes")
    }
}

@Suite("[UInt8]+IEEE_754 - Canonical Float serialization")
struct ArrayFloatSerializationTests {
    @Test(arguments: [Float(3.14159), Float(2.71828), Float(1.41421), Float(0.0), Float(1.0), Float(-1.0)])
    func `unlabeled init with Float`(value: Float) {
        let bytes = [UInt8](value)
        let restored = Float(bytes: bytes)

        #expect(restored == value, "\(value) should round-trip through [UInt8](Float)")
    }

    @Test(arguments: [Float(3.14), Float(2.718), Float(1.414)])
    func `unlabeled init with Float big-endian`(value: Float) {
        let bytes = [UInt8](value, endianness: .big)
        let restored = Float(bytes: bytes, endianness: .big)

        #expect(restored == value, "\(value) should round-trip with big-endian")
    }

    @Test func `Float serialization produces 4 bytes`() {
        let value: Float = 3.14159
        let bytes = [UInt8](value)

        #expect(bytes.count == 4, "Float serialization should produce exactly 4 bytes")
    }
}
