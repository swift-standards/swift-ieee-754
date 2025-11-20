// RoundTrip Tests.swift
// swift-ieee-754
//
// Comprehensive round-trip conversion tests

import Testing
@testable import IEEE_754

@Suite("IEEE 754 - Double Round-trip Conversions")
struct DoubleRoundTripTests {
    @Test(arguments: [
        3.14159265358979323846,  // π approximation
        2.71828182845904523536,  // e
        1.41421356237309504880,  // √2
        1.61803398874989484820,  // φ (golden ratio)
        0.57721566490153286060,  // γ (Euler-Mascheroni)
        Double.pi,
        Double.infinity,
        -Double.infinity,
        0.0,
        -0.0,
        1.0,
        -1.0,
        42.0,
        -42.0,
    ])
    func `all Double conversion paths`(original: Double) {
        // Path 1: Direct bytes()
        let bytes1 = original.bytes()
        let restored1 = Double(bytes: bytes1)

        // Path 2: Namespace bytes()
        let bytes2 = original.ieee754.bytes()
        let restored2 = Double(bytes: bytes2)

        // Path 3: [UInt8] init
        let bytes3 = [UInt8](original)
        let restored3 = Double(bytes: bytes3)

        // Path 4: Type method
        let bytes4 = original.bytes()
        let restored4 = Double.ieee754(bytes4)

        // Verify all paths work
        if original.isNaN {
            #expect(restored1?.isNaN == true, "Path 1 should preserve NaN")
            #expect(restored2?.isNaN == true, "Path 2 should preserve NaN")
            #expect(restored3?.isNaN == true, "Path 3 should preserve NaN")
            #expect(restored4?.isNaN == true, "Path 4 should preserve NaN")
        } else {
            #expect(restored1 == original, "Path 1 (direct bytes) failed for \(original)")
            #expect(restored2 == original, "Path 2 (namespace bytes) failed for \(original)")
            #expect(restored3 == original, "Path 3 ([UInt8] init) failed for \(original)")
            #expect(restored4 == original, "Path 4 (type method) failed for \(original)")

            // Verify all paths produce identical bytes
            #expect(bytes1 == bytes2, "Paths 1 and 2 should produce identical bytes")
            #expect(bytes2 == bytes3, "Paths 2 and 3 should produce identical bytes")
            #expect(bytes3 == bytes4, "Paths 3 and 4 should produce identical bytes")
        }
    }
}

@Suite("IEEE 754 - Float Round-trip Conversions")
struct FloatRoundTripTests {
    @Test(arguments: [
        Float(3.14159),
        Float(2.71828),
        Float(1.41421),
        Float.pi,
        Float.infinity,
        -Float.infinity,
        Float(0.0),
        Float(-0.0),
        Float(1.0),
        Float(-1.0),
        Float(42.0),
        Float(-42.0),
    ])
    func `all Float conversion paths`(original: Float) {
        // Path 1: Direct bytes()
        let bytes1 = original.bytes()
        let restored1 = Float(bytes: bytes1)

        // Path 2: Namespace bytes()
        let bytes2 = original.ieee754.bytes()
        let restored2 = Float(bytes: bytes2)

        // Path 3: [UInt8] init
        let bytes3 = [UInt8](original)
        let restored3 = Float(bytes: bytes3)

        // Path 4: Type method
        let bytes4 = original.bytes()
        let restored4 = Float.ieee754(bytes4)

        // Verify all paths work
        if original.isNaN {
            #expect(restored1?.isNaN == true, "Path 1 should preserve NaN")
            #expect(restored2?.isNaN == true, "Path 2 should preserve NaN")
            #expect(restored3?.isNaN == true, "Path 3 should preserve NaN")
            #expect(restored4?.isNaN == true, "Path 4 should preserve NaN")
        } else {
            #expect(restored1 == original, "Path 1 (direct bytes) failed for \(original)")
            #expect(restored2 == original, "Path 2 (namespace bytes) failed for \(original)")
            #expect(restored3 == original, "Path 3 ([UInt8] init) failed for \(original)")
            #expect(restored4 == original, "Path 4 (type method) failed for \(original)")

            // Verify all paths produce identical bytes
            #expect(bytes1 == bytes2, "Paths 1 and 2 should produce identical bytes")
            #expect(bytes2 == bytes3, "Paths 2 and 3 should produce identical bytes")
            #expect(bytes3 == bytes4, "Paths 3 and 4 should produce identical bytes")
        }
    }
}
