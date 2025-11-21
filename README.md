# IEEE 754

[![CI](https://github.com/swift-standards/swift-ieee-754/workflows/CI/badge.svg)](https://github.com/swift-standards/swift-ieee-754/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Swift implementation of IEEE 754-2019 binary floating-point standard for canonical serialization of Float and Double types.

## Overview

This package provides IEEE 754 binary interchange format serialization for Swift's native floating-point types. The implementation follows IEEE 754-2019 specification for binary32 (Float) and binary64 (Double) formats, offering lossless conversion between floating-point values and byte arrays.

Pure Swift implementation with no Foundation dependencies, suitable for Swift Embedded and constrained environments.

## Features

- Binary32 (single precision) and binary64 (double precision) formats
- Little-endian and big-endian byte order support
- Array serialization/deserialization for multiple Float/Double values
- Zero-copy deserialization with unsafe memory operations
- Cross-module inlining via `@inlinable` and `@_transparent`
- Comprehensive special value handling (NaN, infinity, subnormals, signed zero)
- 224 tests covering edge cases, performance, and concurrency

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-ieee-754.git", from: "0.1.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "IEEE 754", package: "swift-ieee-754")
    ]
)
```

## Quick Start

```swift
import IEEE_754

// Double to bytes
let bytes = (3.14159).bytes()
// [0x6E, 0x86, 0x1B, 0xF0, 0xF9, 0x21, 0x09, 0x40]

// Bytes to Double
let value = Double(bytes: bytes)
// Optional(3.14159)
```

## Usage Examples

### Basic Serialization

```swift
import IEEE_754

// Double serialization
let value: Double = 3.141592653589793
let bytes = value.bytes()

// Double deserialization
let restored = Double(bytes: bytes)
```

### Endianness Control

```swift
// Little-endian (default)
let littleEndian = value.bytes(endianness: .little)

// Big-endian (network byte order)
let bigEndian = value.bytes(endianness: .big)

// Deserialize with matching endianness
let value = Double(bytes: bigEndian, endianness: .big)
```

### Float Operations

```swift
// Float serialization (binary32)
let float: Float = 3.14159
let bytes = float.bytes()
// [0xD0, 0x0F, 0x49, 0x40]

// Float deserialization
let restored = Float(bytes: bytes)
```

### Authoritative API

Direct access to IEEE 754 format implementations:

```swift
// Binary64 (Double)
let bytes = IEEE_754.Binary64.bytes(from: 3.14159)
let value = IEEE_754.Binary64.value(from: bytes)

// Binary32 (Float)
let bytes = IEEE_754.Binary32.bytes(from: Float(3.14))
let value = IEEE_754.Binary32.value(from: bytes)
```

### Array Extensions

```swift
// Single value serialization
let doubleBytes: [UInt8] = [UInt8](3.14159)
let floatBytes: [UInt8] = [UInt8](Float(3.14))

// Multiple Doubles from byte array
let bytes: [UInt8] = [
    0x6E, 0x86, 0x1B, 0xF0, 0xF9, 0x21, 0x09, 0x40,  // 3.14159
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x3F,  // 1.0
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40   // 2.0
]
let doubles = [Double](bytes: bytes)
// Optional([3.14159, 1.0, 2.0])

// Multiple Floats from byte array
let floatBytes: [UInt8] = [
    0xD0, 0x0F, 0x49, 0x40,  // 3.14159
    0x00, 0x00, 0x80, 0x3F,  // 1.0
    0x00, 0x00, 0x00, 0x40   // 2.0
]
let floats = [Float](bytes: floatBytes)
// Optional([3.14159, 1.0, 2.0])

// Big-endian deserialization
let bigEndianDoubles = [Double](bytes: bytes, endianness: .big)
```

### Special Values

```swift
// Infinity
let inf = Double.infinity.bytes()
let negInf = (-Double.infinity).bytes()

// NaN
let nan = Double.nan.bytes()

// Signed zero
let posZero = (0.0).bytes()
let negZero = (-0.0).bytes()

// Subnormal numbers
let subnormal = Double.leastNonzeroMagnitude.bytes()
```

## Performance

Benchmarked on Apple Silicon:

- Serialization: 0.5 microseconds per Double
- Deserialization: 0.5 microseconds per Double
- Round-trip 10,000 conversions: 5ms

Optimizations:
- Zero-copy memory operations with `withUnsafeBytes`
- Direct memory loading with endianness conversion
- Cross-module inlining for zero-cost abstractions

## IEEE 754 Conformance

Conforms to IEEE 754-2019:

- Binary interchange formats (Section 3.6)
- Binary32: 1 sign bit, 8 exponent bits, 23 significand bits (+ 1 implicit)
- Binary64: 1 sign bit, 11 exponent bits, 52 significand bits (+ 1 implicit)
- Correct special value encoding (zero, infinity, NaN, subnormal)
- Sign and payload preservation for all values

## Testing

Test suite: 224 tests in 60 suites

Coverage:
- Round-trip conversions
- Special values (infinity, NaN, signed zero)
- Edge cases (subnormals, extreme values, ULP boundaries)
- Endianness handling
- Bit pattern validation
- Array serialization/deserialization
- Performance benchmarks
- Concurrent access safety

Run tests:

```bash
swift test
```

## Requirements

- Swift 6.0 or later
- macOS 15.0+ / iOS 18.0+ / tvOS 18.0+ / watchOS 11.0+

## Related Packages

- [swift-standards](https://github.com/swift-standards/swift-standards) - Core standards package providing byte array utilities

## License

This package is licensed under the Apache License 2.0. See [LICENSE.md](LICENSE.md) for details.

## Contributing

Contributions are welcome. Please ensure all tests pass and new features include test coverage.
