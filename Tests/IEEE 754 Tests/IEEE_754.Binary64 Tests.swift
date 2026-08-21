import Testing

@testable import IEEE_754

extension IEEE_754.Binary64 {
    @Suite("IEEE_754.Binary64 - Constants")
    struct Test {
        @Test func `byte size is 8`() {
            #expect(IEEE_754.Binary64.byteSize == 8)
        }

        @Test func `bit size is 64`() {
            #expect(IEEE_754.Binary64.bitSize == 64)
        }

        @Test func `sign bits is 1`() {
            #expect(IEEE_754.Binary64.signBits == 1)
        }

        @Test func `exponent bits is 11`() {
            #expect(IEEE_754.Binary64.exponentBits == 11)
        }

        @Test func `significand bits is 52`() {
            #expect(IEEE_754.Binary64.significandBits == 52)
        }

        @Test func `exponent bias is 1023`() {
            #expect(IEEE_754.Binary64.exponentBias == 1023)
        }

        @Test func `max exponent is 2047`() {
            #expect(IEEE_754.Binary64.maxExponent == 2047)
        }

        @Test func `bit layout sums to 64`() {
            let total =
                IEEE_754.Binary64.signBits + IEEE_754.Binary64.exponentBits
                + IEEE_754.Binary64.significandBits
            #expect(total == 64, "Sign + exponent + significand bits should equal 64")
        }
    }
}

extension IEEE_754.Binary64.Test {
    @Suite("IEEE_754.Binary64 - Authoritative serialization")
    struct Serialization {
        @Test(arguments: [
            3.14159265358979323846,
            2.71828182845904523536,
            1.41421356237309504880,
            0.0,
            -0.0,
            1.0,
            -1.0,
            Double.infinity,
            -Double.infinity,
            Double.pi,
        ])
        func `bytes(from:) produces correct byte count`(value: Double) {
            let bytes = IEEE_754.Binary64.bytes(from: value)
            #expect(bytes.count == 8, "Binary64 should always produce 8 bytes")
        }

        @Test(arguments: [3.14159, 2.71828, 1.41421, 42.0])
        func `bytes(from:) with different endianness`(value: Double) {
            let little = IEEE_754.Binary64.bytes(from: value, endianness: .little)
            let big = IEEE_754.Binary64.bytes(from: value, endianness: .big)

            #expect(little.count == 8, "Little endian should produce 8 bytes")
            #expect(big.count == 8, "Big endian should produce 8 bytes")
            #expect(little != big, "Different endianness should produce different byte order")
            #expect(little == big.reversed(), "Big endian should be reverse of little")
        }
    }
}

extension IEEE_754.Binary64.Test {
    @Suite("IEEE_754.Binary64 - Authoritative deserialization")
    struct Deserialization {
        @Test(arguments: [
            3.14159265358979323846,
            2.71828182845904523536,
            1.41421356237309504880,
            0.0,
            1.0,
            -1.0,
            Double.infinity,
            -Double.infinity,
        ])
        func `value(from:) round-trip`(original: Double) {
            let bytes = IEEE_754.Binary64.bytes(from: original)
            let restored = IEEE_754.Binary64.value(from: bytes)

            #expect(restored == original, "\(original) should round-trip through Binary64")
        }

        @Test func `value(from:) with wrong byte count returns nil`() {
            #expect(IEEE_754.Binary64.value(from: []) == nil, "Empty array should return nil")
            #expect(
                IEEE_754.Binary64.value(from: [UInt8](repeating: 0, count: 7)) == nil,
                "7 bytes should return nil"
            )
            #expect(
                IEEE_754.Binary64.value(from: [UInt8](repeating: 0, count: 9)) == nil,
                "9 bytes should return nil"
            )
        }

        @Test func `value(from:) with exactly 8 bytes succeeds`() {
            let bytes = [UInt8](repeating: 0, count: 8)
            let result = IEEE_754.Binary64.value(from: bytes)

            #expect(result != nil, "8 bytes should succeed")
            #expect(result == 0.0, "All-zero bytes should decode to 0.0")
        }

        @Test(arguments: [3.14159, 2.71828, 1.41421])
        func `value(from:) respects endianness`(value: Double) {
            let littleBytes = IEEE_754.Binary64.bytes(from: value, endianness: .little)
            let bigBytes = IEEE_754.Binary64.bytes(from: value, endianness: .big)

            let fromLittle = IEEE_754.Binary64.value(from: littleBytes, endianness: .little)
            let fromBig = IEEE_754.Binary64.value(from: bigBytes, endianness: .big)

            #expect(fromLittle == value, "Little endian round-trip should work")
            #expect(fromBig == value, "Big endian round-trip should work")

            let wrongLittle = IEEE_754.Binary64.value(from: bigBytes, endianness: .little)
            let wrongBig = IEEE_754.Binary64.value(from: littleBytes, endianness: .big)

            #expect(wrongLittle != value, "Mismatched endianness should fail")
            #expect(wrongBig != value, "Mismatched endianness should fail")
        }
    }
}

extension IEEE_754.Binary64.Test {
    @Suite("IEEE_754.Binary64 - Special values")
    struct SpecialValues {
        @Test func `NaN round-trip`() {
            let nan = Double.nan
            let bytes = IEEE_754.Binary64.bytes(from: nan)
            let restored = IEEE_754.Binary64.value(from: bytes)

            #expect(restored?.isNaN == true, "NaN should round-trip as NaN")
        }

        @Test(arguments: [0.0, -0.0])
        func `zero with sign preservation`(value: Double) {
            let bytes = IEEE_754.Binary64.bytes(from: value)
            let restored = IEEE_754.Binary64.value(from: bytes)

            #expect(restored == value, "Zero should round-trip")
            if value.sign == .minus {
                #expect(restored?.sign == .minus, "Negative zero should preserve sign")
            }
        }
    }
}
