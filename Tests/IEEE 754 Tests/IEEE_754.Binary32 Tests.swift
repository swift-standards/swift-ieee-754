// IEEE_754.Binary32 Tests.swift
// swift-ieee-754
//
// Tests for IEEE 754 Binary32 (authoritative implementation)

import Testing

@testable import IEEE_754

extension IEEE_754.Binary32 {
    @Suite("IEEE_754.Binary32 - Constants")
    struct Test {
        @Test func `byte size is 4`() {
            #expect(IEEE_754.Binary32.byteSize == 4)
        }

        @Test func `bit size is 32`() {
            #expect(IEEE_754.Binary32.bitSize == 32)
        }

        @Test func `sign bits is 1`() {
            #expect(IEEE_754.Binary32.signBits == 1)
        }

        @Test func `exponent bits is 8`() {
            #expect(IEEE_754.Binary32.exponentBits == 8)
        }

        @Test func `significand bits is 23`() {
            #expect(IEEE_754.Binary32.significandBits == 23)
        }

        @Test func `exponent bias is 127`() {
            #expect(IEEE_754.Binary32.exponentBias == 127)
        }

        @Test func `max exponent is 255`() {
            #expect(IEEE_754.Binary32.maxExponent == 255)
        }

        @Test func `bit layout sums to 32`() {
            let total =
                IEEE_754.Binary32.signBits + IEEE_754.Binary32.exponentBits
                + IEEE_754.Binary32.significandBits
            #expect(total == 32, "Sign + exponent + significand bits should equal 32")
        }
    }
}

extension IEEE_754.Binary32.Test {
    @Suite("IEEE_754.Binary32 - Authoritative serialization")
    struct Serialization {
        @Test(arguments: [
            Float(3.14159),
            Float(2.71828),
            Float(1.41421),
            Float(0.0),
            Float(-0.0),
            Float(1.0),
            Float(-1.0),
            Float.infinity,
            -Float.infinity,
            Float.pi,
        ])
        func `bytes(from:) produces correct byte count`(value: Float) {
            let bytes = IEEE_754.Binary32.bytes(from: value)
            #expect(bytes.count == 4, "Binary32 should always produce 4 bytes")
        }

        @Test(arguments: [Float(3.14), Float(2.718), Float(1.414), Float(42.0)])
        func `bytes(from:) with different endianness`(value: Float) {
            let little = IEEE_754.Binary32.bytes(from: value, endianness: .little)
            let big = IEEE_754.Binary32.bytes(from: value, endianness: .big)

            #expect(little.count == 4, "Little endian should produce 4 bytes")
            #expect(big.count == 4, "Big endian should produce 4 bytes")
            #expect(little != big, "Different endianness should produce different byte order")
            #expect(little == big.reversed(), "Big endian should be reverse of little")
        }
    }
}

extension IEEE_754.Binary32.Test {
    @Suite("IEEE_754.Binary32 - Authoritative deserialization")
    struct Deserialization {
        @Test(arguments: [
            Float(3.14159),
            Float(2.71828),
            Float(1.41421),
            Float(0.0),
            Float(1.0),
            Float(-1.0),
            Float.infinity,
            -Float.infinity,
        ])
        func `value(from:) round-trip`(original: Float) {
            let bytes = IEEE_754.Binary32.bytes(from: original)
            let restored = IEEE_754.Binary32.value(from: bytes)

            #expect(restored == original, "\(original) should round-trip through Binary32")
        }

        @Test func `value(from:) with wrong byte count returns nil`() {
            #expect(IEEE_754.Binary32.value(from: []) == nil, "Empty array should return nil")
            #expect(
                IEEE_754.Binary32.value(from: [UInt8](repeating: 0, count: 3)) == nil,
                "3 bytes should return nil"
            )
            #expect(
                IEEE_754.Binary32.value(from: [UInt8](repeating: 0, count: 5)) == nil,
                "5 bytes should return nil"
            )
        }

        @Test func `value(from:) with exactly 4 bytes succeeds`() {
            let bytes = [UInt8](repeating: 0, count: 4)
            let result = IEEE_754.Binary32.value(from: bytes)

            #expect(result != nil, "4 bytes should succeed")
            #expect(result == 0.0, "All-zero bytes should decode to 0.0")
        }

        @Test(arguments: [Float(3.14), Float(2.718), Float(1.414)])
        func `value(from:) respects endianness`(value: Float) {
            let littleBytes = IEEE_754.Binary32.bytes(from: value, endianness: .little)
            let bigBytes = IEEE_754.Binary32.bytes(from: value, endianness: .big)

            let fromLittle = IEEE_754.Binary32.value(from: littleBytes, endianness: .little)
            let fromBig = IEEE_754.Binary32.value(from: bigBytes, endianness: .big)

            #expect(fromLittle == value, "Little endian round-trip should work")
            #expect(fromBig == value, "Big endian round-trip should work")

            // Mismatched endianness should fail
            let wrongLittle = IEEE_754.Binary32.value(from: bigBytes, endianness: .little)
            let wrongBig = IEEE_754.Binary32.value(from: littleBytes, endianness: .big)

            #expect(wrongLittle != value, "Mismatched endianness should fail")
            #expect(wrongBig != value, "Mismatched endianness should fail")
        }
    }
}

extension IEEE_754.Binary32.Test {
    @Suite("IEEE_754.Binary32 - Special values")
    struct SpecialValues {
        @Test func `NaN round-trip`() {
            let nan = Float.nan
            let bytes = IEEE_754.Binary32.bytes(from: nan)
            let restored = IEEE_754.Binary32.value(from: bytes)

            #expect(restored?.isNaN == true, "NaN should round-trip as NaN")
        }

        @Test(arguments: [Float(0.0), Float(-0.0)])
        func `zero with sign preservation`(value: Float) {
            let bytes = IEEE_754.Binary32.bytes(from: value)
            let restored = IEEE_754.Binary32.value(from: bytes)

            #expect(restored == value, "Zero should round-trip")
            if value.sign == .minus {
                #expect(restored?.sign == .minus, "Negative zero should preserve sign")
            }
        }
    }
}
