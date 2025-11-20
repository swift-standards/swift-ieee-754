// Double+IEEE_754 Tests.swift
// swift-ieee-754
//
// Tests for Double IEEE 754 extensions

import Testing
@testable import IEEE_754

@Suite("Double+IEEE_754 - Direct bytes() method")
struct DoubleDirectBytesTests {
    @Test(arguments: [
        3.14159265358979323846,
        2.71828182845904523536,
        1.41421356237309504880,
        0.0,
        -0.0,
        1.0,
        -1.0,
    ])
    func `direct bytes round-trip`(value: Double) {
        let bytes = value.bytes()
        let restored = Double(bytes: bytes)

        if value.isNaN {
            #expect(restored?.isNaN == true, "NaN should round-trip")
        } else if value == 0 && value.sign == .minus {
            // Negative zero
            #expect(restored == value && restored!.sign == .minus, "Negative zero should preserve sign")
        } else {
            #expect(restored == value, "\(value) should round-trip through bytes()")
        }
    }

    @Test(arguments: [3.14159, 2.71828, 1.41421])
    func `direct bytes big-endian round-trip`(value: Double) {
        let bytes = value.bytes(endianness: .big)
        let restored = Double(bytes: bytes, endianness: .big)

        #expect(restored == value, "\(value) should round-trip through bytes(endianness: .big)")
    }
}

@Suite("Double+IEEE_754 - Namespace API")
struct DoubleNamespaceTests {
    @Test(arguments: [3.14159, 2.71828, 1.41421])
    func `namespace bytes round-trip`(value: Double) {
        let bytes = value.ieee754.bytes()
        let restored = Double(bytes: bytes)

        #expect(restored == value, "\(value) should round-trip through ieee754.bytes()")
    }

    @Test(arguments: [3.14159, 2.71828, 1.41421])
    func `namespace type method`(value: Double) {
        let bytes = value.ieee754.bytes()
        let restored = Double.ieee754(bytes)

        #expect(restored == value, "\(value) should round-trip through Double.ieee754()")
    }

    @Test func `bitPattern property`() {
        let value: Double = 3.14159265358979323846
        let pattern1 = value.bitPattern
        let pattern2 = value.ieee754.bitPattern

        #expect(pattern1 == pattern2, "Direct and namespace bitPattern should match")
    }
}

@Suite("Double+IEEE_754 - Canonical init")
struct DoubleCanonicalInitTests {
    @Test(arguments: [3.14159265358979323846, 2.71828, 1.41421, 0.0, 1.0, -1.0])
    func `canonical init bytes parameter`(value: Double) {
        let bytes = value.bytes()
        let restored = Double(bytes: bytes)

        #expect(restored == value, "\(value) should round-trip through Double(bytes:)")
    }

    @Test(arguments: [3.14159, 2.71828, 1.41421])
    func `canonical init big-endian`(value: Double) {
        let bytes = value.bytes(endianness: .big)
        let restored = Double(bytes: bytes, endianness: .big)

        #expect(restored == value, "\(value) should round-trip with big-endian")
    }

    @Test func `invalid byte count returns nil`() {
        let tooFew = [UInt8](repeating: 0, count: 7)
        let tooMany = [UInt8](repeating: 0, count: 9)

        #expect(Double(bytes: tooFew) == nil, "7 bytes should return nil")
        #expect(Double(bytes: tooMany) == nil, "9 bytes should return nil")
    }

    @Test func `exactly 8 bytes succeeds`() {
        let exactlyEight = [UInt8](repeating: 0, count: 8)
        let result = Double(bytes: exactlyEight)

        #expect(result != nil, "Exactly 8 bytes should succeed")
        #expect(result == 0.0, "All-zero bytes should decode to 0.0")
    }
}
