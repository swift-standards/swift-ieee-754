// [Float] Tests.swift
// swift-ieee-754
//
// Tests for [Float] array extensions

import Testing

@testable import IEEE_754

@Suite
struct `[Float] Tests` {

    @Test
    func `Single Float from 4 bytes`() {
        let bytes: [UInt8] = [0xD0, 0x0F, 0x49, 0x40]
        let floats = [Float](bytes: bytes)
        #expect(floats != nil)
        #expect(floats?.count == 1)
        #expect(floats?[0] == 3.14159)
    }

    @Test
    func `Multiple Floats from bytes`() {
        let bytes: [UInt8] = [
            0xD0, 0x0F, 0x49, 0x40,  // 3.14159
            0x00, 0x00, 0x80, 0x3F,  // 1.0
            0x00, 0x00, 0x00, 0x40,  // 2.0
        ]
        let floats = [Float](bytes: bytes)
        #expect(floats != nil)
        #expect(floats?.count == 3)
        #expect(floats?[0] == 3.14159)
        #expect(floats?[1] == 1.0)
        #expect(floats?[2] == 2.0)
    }

    @Test
    func `Empty bytes returns empty array`() {
        let bytes: [UInt8] = []
        let floats = [Float](bytes: bytes)
        #expect(floats != nil)
        #expect(floats?.isEmpty == true)
    }

    @Test
    func `Invalid byte count returns nil`() {
        // 3 bytes - not a multiple of 4
        let bytes: [UInt8] = [0x01, 0x02, 0x03]
        let floats = [Float](bytes: bytes)
        #expect(floats == nil)
    }

    @Test(arguments: [1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 99])
    func `invalid byte counts return nil`(byteCount: Int) {
        let bytes = [UInt8](repeating: 0, count: byteCount)
        let floats = [Float](bytes: bytes)
        #expect(floats == nil)
    }

    @Test
    func `Big-endian deserialization`() {
        let bytes: [UInt8] = [
            0x40, 0x49, 0x0F, 0xD0,  // 3.14159 (big-endian)
            0x3F, 0x80, 0x00, 0x00,  // 1.0 (big-endian)
        ]
        let floats = [Float](bytes: bytes, endianness: .big)
        #expect(floats != nil)
        #expect(floats?.count == 2)
        #expect(floats?[0] == 3.14159)
        #expect(floats?[1] == 1.0)
    }

    @Test
    func `Special values - infinity and NaN`() {
        let infBytes = Float.infinity.bytes()
        let negInfBytes = (-Float.infinity).bytes()
        let nanBytes = Float.nan.bytes()

        let bytes = infBytes + negInfBytes + nanBytes
        let floats = [Float](bytes: bytes)

        #expect(floats != nil)
        #expect(floats?.count == 3)
        #expect(floats?[0] == .infinity)
        #expect(floats?[1] == -.infinity)
        #expect(floats?[2].isNaN == true)
    }

    @Test
    func `Special values - signed zero`() {
        let posZeroBytes = (0.0 as Float).bytes()
        let negZeroBytes = (-0.0 as Float).bytes()

        let bytes = posZeroBytes + negZeroBytes
        let floats = [Float](bytes: bytes)

        #expect(floats != nil)
        #expect(floats?.count == 2)
        #expect(floats?[0] == 0.0)
        #expect(floats?[1] == -0.0)

        // Verify sign bit is preserved
        #expect(floats?[0].sign == .plus)
        #expect(floats?[1].sign == .minus)
    }

    @Test
    func `Large array of Floats`() {
        let count = 1000
        let originalFloats = (0..<count).map { Float($0) }

        var allBytes: [UInt8] = []
        for float in originalFloats {
            allBytes += float.bytes()
        }

        let deserializedFloats = [Float](bytes: allBytes)
        #expect(deserializedFloats != nil)
        #expect(deserializedFloats?.count == count)
        #expect(deserializedFloats == originalFloats)
    }

    @Test
    func `Round-trip through array serialization`() {
        let original: [Float] = [3.14159, 2.71828, 1.41421, 1.61803]

        var bytes: [UInt8] = []
        for float in original {
            bytes += float.bytes()
        }

        let roundtripped = [Float](bytes: bytes)
        #expect(roundtripped != nil)
        #expect(roundtripped == original)
    }

    @Test
    func `Mixed positive and negative values`() {
        let original: [Float] = [-100.5, 0.0, 100.5, -0.0, Float.infinity, -Float.infinity]

        var bytes: [UInt8] = []
        for float in original {
            bytes += float.bytes()
        }

        let deserialized = [Float](bytes: bytes)
        #expect(deserialized != nil)
        #expect(deserialized?.count == 6)

        if let deserialized {
            #expect(deserialized[0] == -100.5)
            #expect(deserialized[1] == 0.0)
            #expect(deserialized[2] == 100.5)
            #expect(deserialized[3] == -0.0)
            #expect(deserialized[4] == .infinity)
            #expect(deserialized[5] == -.infinity)
        }
    }

    @Test
    func `Subnormal values preserved`() {
        let values: [Float] = [
            .leastNonzeroMagnitude,
            -.leastNonzeroMagnitude,
            .leastNormalMagnitude,
            -.leastNormalMagnitude,
        ]

        var bytes: [UInt8] = []
        for value in values {
            bytes += value.bytes()
        }

        let deserialized = [Float](bytes: bytes)
        #expect(deserialized != nil)
        #expect(deserialized?.count == 4)
        #expect(deserialized?[0] == .leastNonzeroMagnitude)
        #expect(deserialized?[1] == -.leastNonzeroMagnitude)
        #expect(deserialized?[2] == .leastNormalMagnitude)
        #expect(deserialized?[3] == -.leastNormalMagnitude)
    }

    @Test
    func `Extreme values preserved`() {
        let values: [Float] = [
            .greatestFiniteMagnitude,
            -.greatestFiniteMagnitude,
            Float.pi,
            -Float.pi,
        ]

        var bytes: [UInt8] = []
        for value in values {
            bytes += value.bytes()
        }

        let deserialized = [Float](bytes: bytes)
        #expect(deserialized != nil)
        #expect(deserialized?.count == 4)
        #expect(deserialized?[0] == .greatestFiniteMagnitude)
        #expect(deserialized?[1] == -.greatestFiniteMagnitude)
        #expect(deserialized?[2] == Float.pi)
        #expect(deserialized?[3] == -Float.pi)
    }

    @Test
    func `Mixed endianness arrays are independent`() {
        let values: [Float] = [1.0, 2.0, 3.0]

        var littleEndianBytes: [UInt8] = []
        var bigEndianBytes: [UInt8] = []

        for value in values {
            littleEndianBytes += value.bytes(endianness: .little)
            bigEndianBytes += value.bytes(endianness: .big)
        }

        let littleDeserialize = [Float](bytes: littleEndianBytes, endianness: .little)
        let bigDeserialize = [Float](bytes: bigEndianBytes, endianness: .big)

        #expect(littleDeserialize == values)
        #expect(bigDeserialize == values)

        // Cross-endianness should not work
        let wrongLittle = [Float](bytes: bigEndianBytes, endianness: .little)
        let wrongBig = [Float](bytes: littleEndianBytes, endianness: .big)

        #expect(wrongLittle != values)
        #expect(wrongBig != values)
    }

    @Test
    func `Array from collection types`() {
        let bytes: [UInt8] = [0xD0, 0x0F, 0x49, 0x40]

        // Test with different collection types
        let fromArray = [Float](bytes: bytes)
        let fromArraySlice = [Float](bytes: bytes[0...])
        let fromContiguousArray = [Float](bytes: ContiguousArray(bytes))

        #expect(fromArray != nil)
        #expect(fromArraySlice != nil)
        #expect(fromContiguousArray != nil)

        #expect(fromArray?[0] == 3.14159)
        #expect(fromArraySlice?[0] == 3.14159)
        #expect(fromContiguousArray?[0] == 3.14159)
    }

    @Test
    func `Powers of 2 arrays`() {
        let values: [Float] = [1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0, 128.0]

        var bytes: [UInt8] = []
        for value in values {
            bytes += value.bytes()
        }

        let deserialized = [Float](bytes: bytes)
        #expect(deserialized == values)
    }
}

// MARK: - Performance Tests

extension `Performance Tests` {
    @Suite
    struct `Array<Float> - Performance` {
        @Test
        func `deserialize 1000 Floats from bytes`() {
            var bytes: [UInt8] = []
            for i in 0..<1_000 {
                bytes += Float(i).bytes()
            }

            _ = [Float](bytes: bytes)
        }

        @Test
        func `serialize and deserialize 1000 Floats`() {
            let values = (0..<1_000).map { Float($0) * 3.14159 }

            var bytes: [UInt8] = []
            for value in values {
                bytes += value.bytes()
            }

            let deserialized = [Float](bytes: bytes)
            #expect(deserialized != nil)
        }

        @Test
        func `round-trip 10000 random Floats through arrays`() {
            let values = (0..<10_000).map { _ in Float.random(in: -1e30...1e30) }

            var bytes: [UInt8] = []
            for value in values {
                bytes += value.bytes()
            }

            let deserialized = [Float](bytes: bytes)
            #expect(deserialized?.count == 10_000)
        }

        @Test
        func `deserialize 100 Floats repeatedly`() {
            var bytes: [UInt8] = []
            for i in 0..<100 {
                bytes += Float(i).bytes()
            }

            for _ in 0..<100 {
                _ = [Float](bytes: bytes)
            }
        }

        @Test
        func `alternating endianness 1000 values`() {
            let value: Float = 3.14159

            for i in 0..<1_000 {
                let endianness: Binary.Endianness = i % 2 == 0 ? .little : .big
                let bytes = value.bytes(endianness: endianness)
                _ = [Float](bytes: [bytes].flatMap { $0 }, endianness: endianness)
            }
        }

        @Test
        func `special values array 1000 times`() {
            let specialValues: [Float] = [
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
                _ = [Float](bytes: bytes)
            }
        }
    }
}
