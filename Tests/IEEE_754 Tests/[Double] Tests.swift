// [Double] Tests.swift
// swift-ieee-754
//
// Tests for [Double] array extensions

import StandardsTestSupport
import Testing

@testable import IEEE_754

@Suite("Array<Double> - Deserialization")
struct DoubleArrayTests {

    @Test("Single Double from 8 bytes")
    func singleDouble() {
        let bytes: [UInt8] = [0x6E, 0x86, 0x1B, 0xF0, 0xF9, 0x21, 0x09, 0x40]
        let doubles = [Double](bytes: bytes)
        #expect(doubles != nil)
        #expect(doubles?.count == 1)
        #expect(doubles?[0] == 3.14159)
    }

    @Test("Multiple Doubles from bytes")
    func multipleDoubles() {
        let bytes: [UInt8] = [
            0x6E, 0x86, 0x1B, 0xF0, 0xF9, 0x21, 0x09, 0x40,  // 3.14159
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x3F,  // 1.0
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40   // 2.0
        ]
        let doubles = [Double](bytes: bytes)
        #expect(doubles != nil)
        #expect(doubles?.count == 3)
        #expect(doubles?[0] == 3.14159)
        #expect(doubles?[1] == 1.0)
        #expect(doubles?[2] == 2.0)
    }

    @Test("Empty bytes returns empty array")
    func emptyBytes() {
        let bytes: [UInt8] = []
        let doubles = [Double](bytes: bytes)
        #expect(doubles != nil)
        #expect(doubles?.isEmpty == true)
    }

    @Test("Invalid byte count returns nil")
    func invalidByteCount() {
        // 7 bytes - not a multiple of 8
        let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]
        let doubles = [Double](bytes: bytes)
        #expect(doubles == nil)
    }

    @Test(arguments: [1, 9, 15, 23, 31, 100])
    func `invalid byte counts return nil`(byteCount: Int) {
        let bytes = [UInt8](repeating: 0, count: byteCount)
        let doubles = [Double](bytes: bytes)
        #expect(doubles == nil)
    }

    @Test("Big-endian deserialization")
    func bigEndian() {
        let bytes: [UInt8] = [
            0x40, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18,  // 3.141592653589793 (big-endian)
            0x3F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   // 1.0 (big-endian)
        ]
        let doubles = [Double](bytes: bytes, endianness: .big)
        #expect(doubles != nil)
        #expect(doubles?.count == 2)
        #expect(doubles?[0] == 3.141592653589793)
        #expect(doubles?[1] == 1.0)
    }

    @Test("Special values - infinity and NaN")
    func specialValues() {
        let infBytes = Double.infinity.bytes()
        let negInfBytes = (-Double.infinity).bytes()
        let nanBytes = Double.nan.bytes()

        let bytes = infBytes + negInfBytes + nanBytes
        let doubles = [Double](bytes: bytes)

        #expect(doubles != nil)
        #expect(doubles?.count == 3)
        #expect(doubles?[0] == .infinity)
        #expect(doubles?[1] == -.infinity)
        #expect(doubles?[2].isNaN == true)
    }

    @Test("Special values - signed zero")
    func signedZero() {
        let posZeroBytes = (0.0 as Double).bytes()
        let negZeroBytes = (-0.0 as Double).bytes()

        let bytes = posZeroBytes + negZeroBytes
        let doubles = [Double](bytes: bytes)

        #expect(doubles != nil)
        #expect(doubles?.count == 2)
        #expect(doubles?[0] == 0.0)
        #expect(doubles?[1] == -0.0)

        // Verify sign bit is preserved
        #expect(doubles?[0].sign == .plus)
        #expect(doubles?[1].sign == .minus)
    }

    @Test("Subnormal values preserved")
    func subnormalValues() {
        let values: [Double] = [
            .leastNonzeroMagnitude,
            -.leastNonzeroMagnitude,
            .leastNormalMagnitude,
            -.leastNormalMagnitude,
        ]

        var bytes: [UInt8] = []
        for value in values {
            bytes += value.bytes()
        }

        let deserialized = [Double](bytes: bytes)
        #expect(deserialized != nil)
        #expect(deserialized?.count == 4)
        #expect(deserialized?[0] == .leastNonzeroMagnitude)
        #expect(deserialized?[1] == -.leastNonzeroMagnitude)
        #expect(deserialized?[2] == .leastNormalMagnitude)
        #expect(deserialized?[3] == -.leastNormalMagnitude)
    }

    @Test("Extreme values preserved")
    func extremeValues() {
        let values: [Double] = [
            .greatestFiniteMagnitude,
            -.greatestFiniteMagnitude,
            Double.pi,
            -Double.pi,
        ]

        var bytes: [UInt8] = []
        for value in values {
            bytes += value.bytes()
        }

        let deserialized = [Double](bytes: bytes)
        #expect(deserialized != nil)
        #expect(deserialized?.count == 4)
        #expect(deserialized?[0] == .greatestFiniteMagnitude)
        #expect(deserialized?[1] == -.greatestFiniteMagnitude)
        #expect(deserialized?[2] == Double.pi)
        #expect(deserialized?[3] == -Double.pi)
    }

    @Test("Large array of Doubles")
    func largeArray() {
        let count = 1000
        let originalDoubles = (0..<count).map { Double($0) }

        var allBytes: [UInt8] = []
        for double in originalDoubles {
            allBytes += double.bytes()
        }

        let deserializedDoubles = [Double](bytes: allBytes)
        #expect(deserializedDoubles != nil)
        #expect(deserializedDoubles?.count == count)
        #expect(deserializedDoubles == originalDoubles)
    }

    @Test("Round-trip through array serialization")
    func roundTrip() {
        let original: [Double] = [3.14159, 2.71828, 1.41421, 1.61803]

        var bytes: [UInt8] = []
        for double in original {
            bytes += double.bytes()
        }

        let roundtripped = [Double](bytes: bytes)
        #expect(roundtripped != nil)
        #expect(roundtripped == original)
    }

    @Test("Mixed endianness arrays are independent")
    func mixedEndianness() {
        let values: [Double] = [1.0, 2.0, 3.0]

        var littleEndianBytes: [UInt8] = []
        var bigEndianBytes: [UInt8] = []

        for value in values {
            littleEndianBytes += value.bytes(endianness: .little)
            bigEndianBytes += value.bytes(endianness: .big)
        }

        let littleDeserialize = [Double](bytes: littleEndianBytes, endianness: .little)
        let bigDeserialize = [Double](bytes: bigEndianBytes, endianness: .big)

        #expect(littleDeserialize == values)
        #expect(bigDeserialize == values)

        // Cross-endianness should not work
        let wrongLittle = [Double](bytes: bigEndianBytes, endianness: .little)
        let wrongBig = [Double](bytes: littleEndianBytes, endianness: .big)

        #expect(wrongLittle != values)
        #expect(wrongBig != values)
    }

    @Test("Array from collection types")
    func collectionTypes() {
        let bytes: [UInt8] = [0x6E, 0x86, 0x1B, 0xF0, 0xF9, 0x21, 0x09, 0x40]

        // Test with different collection types
        let fromArray = [Double](bytes: bytes)
        let fromArraySlice = [Double](bytes: bytes[0...])
        let fromContiguousArray = [Double](bytes: ContiguousArray(bytes))

        #expect(fromArray != nil)
        #expect(fromArraySlice != nil)
        #expect(fromContiguousArray != nil)

        #expect(fromArray?[0] == 3.14159)
        #expect(fromArraySlice?[0] == 3.14159)
        #expect(fromContiguousArray?[0] == 3.14159)
    }

    @Test("Powers of 2 arrays")
    func powersOfTwo() {
        let values: [Double] = [1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0, 128.0]

        var bytes: [UInt8] = []
        for value in values {
            bytes += value.bytes()
        }

        let deserialized = [Double](bytes: bytes)
        #expect(deserialized == values)
    }
}

// MARK: - Performance Tests

extension `Performance Tests` {
    @Suite
    struct `Array<Double> - Performance` {
        @Test(.timed(threshold: .milliseconds(50)))
        func `deserialize 1000 Doubles from bytes`() {
            var bytes: [UInt8] = []
            for i in 0..<1_000 {
                bytes += Double(i).bytes()
            }

            _ = [Double](bytes: bytes)
        }

        @Test(.timed(threshold: .milliseconds(100)))
        func `serialize and deserialize 1000 Doubles`() {
            let values = (0..<1_000).map { Double($0) * 3.14159 }

            var bytes: [UInt8] = []
            for value in values {
                bytes += value.bytes()
            }

            let deserialized = [Double](bytes: bytes)
            #expect(deserialized != nil)
        }

        @Test(.timed(threshold: .milliseconds(200)))
        func `round-trip 10000 random Doubles through arrays`() {
            let values = (0..<10_000).map { _ in Double.random(in: -1e100...1e100) }

            var bytes: [UInt8] = []
            for value in values {
                bytes += value.bytes()
            }

            let deserialized = [Double](bytes: bytes)
            #expect(deserialized?.count == 10_000)
        }

        @Test(.timed(threshold: .milliseconds(5)))
        func `deserialize 100 Doubles repeatedly`() {
            var bytes: [UInt8] = []
            for i in 0..<100 {
                bytes += Double(i).bytes()
            }

            for _ in 0..<100 {
                _ = [Double](bytes: bytes)
            }
        }

        @Test(.timed(threshold: .milliseconds(10)))
        func `alternating endianness 1000 values`() {
            let value: Double = 3.141592653589793

            for i in 0..<1_000 {
                let endianness: [UInt8].Endianness = i % 2 == 0 ? .little : .big
                let bytes = value.bytes(endianness: endianness)
                _ = [Double](bytes: [bytes].flatMap { $0 }, endianness: endianness)
            }
        }

        @Test(.timed(threshold: .milliseconds(10)))
        func `special values array 1000 times`() {
            let specialValues: [Double] = [
                0.0, -0.0,
                .infinity, -.infinity,
                .leastNonzeroMagnitude,
                .leastNormalMagnitude,
                .greatestFiniteMagnitude,
            ]

            var bytes: [UInt8] = []
            for value in specialValues {
                bytes += value.bytes()
            }

            for _ in 0..<1_000 {
                _ = [Double](bytes: bytes)
            }
        }
    }
}
