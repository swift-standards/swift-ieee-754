import Testing

@testable import IEEE_754

@Suite("README Verification")
struct ReadmeVerificationTests {

    @Test
    func `Quick Start example (lines 46-56)`() throws {

        let bytes = (3.14159).bytes()
        #expect(bytes.count == 8)

        let value = Double(bytes: bytes)
        #expect(value != nil)
        #expect(value! == 3.14159)
    }

    @Test
    func `Basic Serialization example (lines 63-71)`() throws {

        let value: Double = 3.141592653589793
        let bytes = value.bytes()

        let restored = Double(bytes: bytes)
        #expect(restored == value)
    }

    @Test
    func `Endianness Control example (lines 76-84)`() throws {
        let value: Double = 3.14159

        let littleEndian = value.bytes(endianness: .little)

        let bigEndian = value.bytes(endianness: .big)

        let restored = Double(bytes: bigEndian, endianness: .big)
        #expect(restored == value)
        #expect(littleEndian != bigEndian)
    }

    @Test
    func `Float Operations example (lines 89-96)`() throws {

        let float: Float = 3.14159
        let bytes = float.bytes()
        #expect(bytes == [0xD0, 0x0F, 0x49, 0x40])

        let restored = Float(bytes: bytes)
        #expect(restored == float)
    }

    @Test
    func `Authoritative API example (lines 103-110)`() throws {

        let bytes = IEEE_754.Binary64.bytes(from: 3.14159)
        let value = IEEE_754.Binary64.value(from: bytes)
        #expect(value == 3.14159)

        let floatBytes = IEEE_754.Binary32.bytes(from: Float(3.14))
        let floatValue = IEEE_754.Binary32.value(from: floatBytes)
        #expect(floatValue == Float(3.14))
    }

    @Test
    func `Array Extensions example (lines 115-118)`() throws {

        let doubleBytes: [UInt8] = [UInt8](3.14159)
        let floatBytes: [UInt8] = [UInt8](Float(3.14))

        #expect(doubleBytes.count == 8)
        #expect(floatBytes.count == 4)
    }

    @Test
    func `Special Values example (lines 123-136)`() throws {

        let inf = Double.infinity.bytes()
        let negInf = (-Double.infinity).bytes()
        #expect(inf.count == 8)
        #expect(negInf.count == 8)

        let nan = Double.nan.bytes()
        #expect(nan.count == 8)

        let posZero = (0.0).bytes()
        let negZero = (-0.0).bytes()
        #expect(posZero.count == 8)
        #expect(negZero.count == 8)
        #expect(posZero != negZero)

        let subnormal = Double.leastNonzeroMagnitude.bytes()
        #expect(subnormal.count == 8)
    }
}
