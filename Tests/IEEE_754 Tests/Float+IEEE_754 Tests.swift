// Float+IEEE_754 Tests.swift
// swift-ieee-754
//
// Tests for Float IEEE 754 extensions

import Testing
@testable import IEEE_754

@Suite("Float+IEEE_754 - Direct bytes() method")
struct FloatDirectBytesTests {
    @Test(arguments: [
        Float(3.14159),
        Float(2.71828),
        Float(1.41421),
        Float(0.0),
        Float(-0.0),
        Float(1.0),
        Float(-1.0),
    ])
    func `direct bytes round-trip`(value: Float) {
        let bytes = value.bytes()
        let restored = Float(bytes: bytes)

        if value.isNaN {
            #expect(restored?.isNaN == true, "NaN should round-trip")
        } else if value == 0 && value.sign == .minus {
            // Negative zero
            #expect(restored == value && restored!.sign == .minus, "Negative zero should preserve sign")
        } else {
            #expect(restored == value, "\(value) should round-trip through bytes()")
        }
    }

    @Test(arguments: [Float(3.14159), Float(2.71828), Float(1.41421)])
    func `direct bytes big-endian round-trip`(value: Float) {
        let bytes = value.bytes(endianness: .big)
        let restored = Float(bytes: bytes, endianness: .big)

        #expect(restored == value, "\(value) should round-trip through bytes(endianness: .big)")
    }
}

@Suite("Float+IEEE_754 - Namespace API")
struct FloatNamespaceTests {
    @Test(arguments: [Float(3.14159), Float(2.71828), Float(1.41421)])
    func `namespace bytes round-trip`(value: Float) {
        let bytes = value.ieee754.bytes()
        let restored = Float(bytes: bytes)

        #expect(restored == value, "\(value) should round-trip through ieee754.bytes()")
    }

    @Test(arguments: [Float(3.14), Float(1.414), Float(2.718)])
    func `namespace type method`(value: Float) {
        let bytes = value.ieee754.bytes()
        let restored = Float.ieee754(bytes)

        #expect(restored == value, "\(value) should round-trip through Float.ieee754()")
    }

    @Test func `bitPattern property`() {
        let value: Float = 3.14159
        let pattern1 = value.bitPattern
        let pattern2 = value.ieee754.bitPattern

        #expect(pattern1 == pattern2, "Direct and namespace bitPattern should match")
    }
}

@Suite("Float+IEEE_754 - Canonical init")
struct FloatCanonicalInitTests {
    @Test(arguments: [Float(3.14159), Float(2.71828), Float(1.41421), Float(0.0), Float(1.0), Float(-1.0)])
    func `canonical init bytes parameter`(value: Float) {
        let bytes = value.bytes()
        let restored = Float(bytes: bytes)

        #expect(restored == value, "\(value) should round-trip through Float(bytes:)")
    }

    @Test(arguments: [Float(3.14), Float(2.718), Float(1.414)])
    func `canonical init big-endian`(value: Float) {
        let bytes = value.bytes(endianness: .big)
        let restored = Float(bytes: bytes, endianness: .big)

        #expect(restored == value, "\(value) should round-trip with big-endian")
    }

    @Test func `invalid byte count returns nil`() {
        let tooFew = [UInt8](repeating: 0, count: 3)
        let tooMany = [UInt8](repeating: 0, count: 5)

        #expect(Float(bytes: tooFew) == nil, "3 bytes should return nil")
        #expect(Float(bytes: tooMany) == nil, "5 bytes should return nil")
    }

    @Test func `exactly 4 bytes succeeds`() {
        let exactlyFour = [UInt8](repeating: 0, count: 4)
        let result = Float(bytes: exactlyFour)

        #expect(result != nil, "Exactly 4 bytes should succeed")
        #expect(result == 0.0, "All-zero bytes should decode to 0.0")
    }
}
