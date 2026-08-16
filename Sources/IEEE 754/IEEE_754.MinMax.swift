// IEEE_754.MinMax.swift
// swift-ieee-754
//
// IEEE 754-2019 Section 5.3 & 9.6: Minimum and Maximum Operations
// Authoritative implementations of all min/max variants

// MARK: - IEEE 754 Min/Max Operations

extension IEEE_754 {
    /// IEEE 754 minimum and maximum operations (Section 5.3, 9.6)
    ///
    /// Implements all minimum and maximum operations defined in IEEE 754-2019.
    /// These operations select between two values according to various rules
    /// for handling NaN and signed zeros.
    ///
    /// ## Overview
    ///
    /// The IEEE 754-2019 standard defines 8 variants of min/max operations:
    ///
    /// ### IEEE 754-2008 Compatible (Section 5.3.1)
    /// - `minimumNumber` / `maximumNumber` - Prefer numbers over NaN
    ///
    /// ### IEEE 754-2019 New Operations (Section 9.6)
    /// - `minimum` / `maximum` - Propagate NaN, distinguish ±0
    /// - `minimumMagnitude` / `maximumMagnitude` - By absolute value, propagate NaN
    /// - `minimumMagnitudeNumber` / `maximumMagnitudeNumber` - By absolute value, prefer numbers
    ///
    /// ## NaN Handling
    ///
    /// Different operations handle NaN differently:
    /// - `minimum`/`maximum`: If either input is NaN, return NaN
    /// - `minimumNumber`/`maximumNumber`: If one input is NaN, return the other
    ///
    /// ## Signed Zero
    ///
    /// When comparing ±0:
    /// - `minimum`: -0.0 < +0.0
    /// - `maximum`: +0.0 > -0.0
    ///
    /// ## See Also
    ///
    /// - IEEE 754-2019 Section 5.3.1: Minimum and maximum operations
    /// - IEEE 754-2019 Section 9.6: Minimum and maximum magnitude operations
    public enum MinMax {}
}

// MARK: - Hierarchical Min/Max Operation Enum

extension IEEE_754.MinMax {
    /// IEEE 754 Min/Max Operation
    ///
    /// Hierarchical structure for all 8 IEEE 754 min/max operation variants.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let result = IEEE_754.MinMax.apply(x, y, operation: .standard(.minimum))
    ///
    /// switch operation {
    /// case .standard(.minimum):
    ///     // Propagates NaN
    /// case .number(.minimum):
    ///     // Prefers numbers over NaN
    /// case .magnitude(.minimum(preferNumber: false)):
    ///     // By magnitude, propagates NaN
    /// }
    /// ```
    ///
    /// ## See Also
    /// - IEEE 754-2019 Section 5.3.1: Minimum and maximum operations
    /// - IEEE 754-2019 Section 9.6: Minimum and maximum magnitude operations
    public enum Operation: Sendable, Equatable {
        /// Standard min/max (propagates NaN)
        case standard(Mode)
        /// Number min/max (prefers numbers over NaN)
        case number(Mode)
        /// Magnitude min/max (by absolute value)
        case magnitude(Mode, preferNumber: Bool)
    }

    /// Unified min/max operation for Double values
    ///
    /// Implements all 8 IEEE 754 min/max variants through a single interface.
    ///
    /// - Parameters:
    ///   - x: First value
    ///   - y: Second value
    ///   - operation: The operation to perform
    /// - Returns: The result based on the operation
    @inlinable
    public static func apply(_ x: Double, _ y: Double, operation: Operation) -> Double {
        switch operation {
        case .standard(.minimum):
            return minimum(x, y)

        case .standard(.maximum):
            return maximum(x, y)

        case .number(.minimum):
            return minimumNumber(x, y)

        case .number(.maximum):
            return maximumNumber(x, y)

        case .magnitude(.minimum, preferNumber: false):
            return minimumMagnitude(x, y)

        case .magnitude(.maximum, preferNumber: false):
            return maximumMagnitude(x, y)

        case .magnitude(.minimum, preferNumber: true):
            return minimumMagnitudeNumber(x, y)

        case .magnitude(.maximum, preferNumber: true):
            return maximumMagnitudeNumber(x, y)
        }
    }

    /// Unified min/max operation for Float values
    ///
    /// Implements all 8 IEEE 754 min/max variants through a single interface.
    ///
    /// - Parameters:
    ///   - x: First value
    ///   - y: Second value
    ///   - operation: The operation to perform
    /// - Returns: The result based on the operation
    @inlinable
    public static func apply(_ x: Float, _ y: Float, operation: Operation) -> Float {
        switch operation {
        case .standard(.minimum):
            return minimum(x, y)

        case .standard(.maximum):
            return maximum(x, y)

        case .number(.minimum):
            return minimumNumber(x, y)

        case .number(.maximum):
            return maximumNumber(x, y)

        case .magnitude(.minimum, preferNumber: false):
            return minimumMagnitude(x, y)

        case .magnitude(.maximum, preferNumber: false):
            return maximumMagnitude(x, y)

        case .magnitude(.minimum, preferNumber: true):
            return minimumMagnitudeNumber(x, y)

        case .magnitude(.maximum, preferNumber: true):
            return maximumMagnitudeNumber(x, y)
        }
    }
}

extension IEEE_754.MinMax.Operation {
    /// Min or Max mode
    public enum Mode: Sendable, Equatable {
        /// Select minimum value
        case minimum
        /// Select maximum value
        case maximum
    }
}

// MARK: - Double Min/Max Operations

extension IEEE_754.MinMax {
    // MARK: Standard Min/Max (NaN propagation)

    /// Minimum - IEEE 754-2019 `minimum`
    ///
    /// Returns the smaller of two values. Propagates NaN (returns NaN if either
    /// input is NaN). Distinguishes between signed zeros: minimum(-0.0, +0.0) = -0.0.
    ///
    /// - Parameters:
    ///   - x: First value
    ///   - y: Second value
    /// - Returns: The minimum value
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.MinMax.minimum(3.14, 2.71)     // 2.71
    /// IEEE_754.MinMax.minimum(-0.0, 0.0)      // -0.0
    /// IEEE_754.MinMax.minimum(.nan, 3.14)     // .nan
    /// IEEE_754.MinMax.minimum(3.14, .nan)     // .nan
    /// ```
    @inlinable
    public static func minimum(_ x: Double, _ y: Double) -> Double {
        // Handle NaN - propagate NaN
        if x.isNaN || y.isNaN {
            return .nan
        }

        // Handle signed zeros: minimum(-0.0, +0.0) should be -0.0
        if x.isZero && y.isZero {
            return (x.sign == .minus || y.sign == .minus) ? -0.0 : 0.0
        }

        return x < y ? x : y
    }

    /// Maximum - IEEE 754-2019 `maximum`
    ///
    /// Returns the larger of two values. Propagates NaN. Distinguishes between
    /// signed zeros: maximum(-0.0, +0.0) = +0.0.
    ///
    /// - Parameters:
    ///   - x: First value
    ///   - y: Second value
    /// - Returns: The maximum value
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.MinMax.maximum(3.14, 2.71)     // 3.14
    /// IEEE_754.MinMax.maximum(-0.0, 0.0)      // 0.0
    /// IEEE_754.MinMax.maximum(.nan, 3.14)     // .nan
    /// ```
    @inlinable
    public static func maximum(_ x: Double, _ y: Double) -> Double {
        // Handle NaN - propagate NaN
        if x.isNaN || y.isNaN {
            return .nan
        }

        // Handle signed zeros: maximum(-0.0, +0.0) should be +0.0
        if x.isZero && y.isZero {
            return (x.sign == .plus || y.sign == .plus) ? 0.0 : -0.0
        }

        return x > y ? x : y
    }

    // MARK: Number Min/Max (Prefer numbers over NaN)

    /// Minimum Number - IEEE 754-2008 `minNum`
    ///
    /// Returns the smaller of two values. If exactly one is NaN, returns the
    /// other value. If both are NaN, returns NaN.
    ///
    /// - Parameters:
    ///   - x: First value
    ///   - y: Second value
    /// - Returns: The minimum value, preferring numbers over NaN
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.MinMax.minimumNumber(3.14, 2.71)     // 2.71
    /// IEEE_754.MinMax.minimumNumber(.nan, 3.14)     // 3.14
    /// IEEE_754.MinMax.minimumNumber(3.14, .nan)     // 3.14
    /// IEEE_754.MinMax.minimumNumber(.nan, .nan)     // .nan
    /// ```
    @inlinable
    public static func minimumNumber(_ x: Double, _ y: Double) -> Double {
        // If exactly one is NaN, return the other
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }

        // Same as minimum for non-NaN values
        if x.isZero && y.isZero {
            return (x.sign == .minus || y.sign == .minus) ? -0.0 : 0.0
        }

        return x < y ? x : y
    }

    /// Maximum Number - IEEE 754-2008 `maxNum`
    ///
    /// Returns the larger of two values. If exactly one is NaN, returns the
    /// other value.
    ///
    /// - Parameters:
    ///   - x: First value
    ///   - y: Second value
    /// - Returns: The maximum value, preferring numbers over NaN
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.MinMax.maximumNumber(3.14, 2.71)     // 3.14
    /// IEEE_754.MinMax.maximumNumber(.nan, 3.14)     // 3.14
    /// IEEE_754.MinMax.maximumNumber(3.14, .nan)     // 3.14
    /// ```
    @inlinable
    public static func maximumNumber(_ x: Double, _ y: Double) -> Double {
        // If exactly one is NaN, return the other
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }

        // Same as maximum for non-NaN values
        if x.isZero && y.isZero {
            return (x.sign == .plus || y.sign == .plus) ? 0.0 : -0.0
        }

        return x > y ? x : y
    }

    // MARK: Magnitude Min/Max (By absolute value)

    /// Minimum Magnitude - IEEE 754-2019 `minimumMagnitude`
    ///
    /// Returns the value with smaller magnitude (absolute value). Propagates NaN.
    /// If magnitudes are equal, uses sign as tiebreaker.
    ///
    /// - Parameters:
    ///   - x: First value
    ///   - y: Second value
    /// - Returns: The value with minimum magnitude
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.MinMax.minimumMagnitude(3.14, -2.71)   // -2.71 (smaller magnitude)
    /// IEEE_754.MinMax.minimumMagnitude(-3.14, 3.14)   // -3.14 (tie, prefer negative)
    /// IEEE_754.MinMax.minimumMagnitude(.nan, 3.14)    // .nan
    /// ```
    @inlinable
    public static func minimumMagnitude(_ x: Double, _ y: Double) -> Double {
        // Propagate NaN
        if x.isNaN || y.isNaN {
            return .nan
        }

        let xMag = Swift.abs(x)
        let yMag = Swift.abs(y)

        if xMag < yMag {
            return x
        } else if yMag < xMag {
            return y
        } else {
            // Equal magnitudes: use standard minimum for tiebreaker
            return minimum(x, y)
        }
    }

    /// Maximum Magnitude - IEEE 754-2019 `maximumMagnitude`
    ///
    /// Returns the value with larger magnitude (absolute value). Propagates NaN.
    ///
    /// - Parameters:
    ///   - x: First value
    ///   - y: Second value
    /// - Returns: The value with maximum magnitude
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.MinMax.maximumMagnitude(3.14, -2.71)   // 3.14 (larger magnitude)
    /// IEEE_754.MinMax.maximumMagnitude(-3.14, 2.71)   // -3.14 (larger magnitude)
    /// ```
    @inlinable
    public static func maximumMagnitude(_ x: Double, _ y: Double) -> Double {
        // Propagate NaN
        if x.isNaN || y.isNaN {
            return .nan
        }

        let xMag = Swift.abs(x)
        let yMag = Swift.abs(y)

        if xMag > yMag {
            return x
        } else if yMag > xMag {
            return y
        } else {
            // Equal magnitudes: use standard maximum for tiebreaker
            return maximum(x, y)
        }
    }

    /// Minimum Magnitude Number - IEEE 754-2019 `minimumMagnitudeNumber`
    ///
    /// Returns the value with smaller magnitude. If exactly one is NaN, returns
    /// the other value.
    ///
    /// - Parameters:
    ///   - x: First value
    ///   - y: Second value
    /// - Returns: The value with minimum magnitude, preferring numbers over NaN
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.MinMax.minimumMagnitudeNumber(3.14, -2.71)   // -2.71
    /// IEEE_754.MinMax.minimumMagnitudeNumber(.nan, 3.14)    // 3.14
    /// ```
    @inlinable
    public static func minimumMagnitudeNumber(_ x: Double, _ y: Double) -> Double {
        // Prefer numbers over NaN
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }

        return minimumMagnitude(x, y)
    }

    /// Maximum Magnitude Number - IEEE 754-2019 `maximumMagnitudeNumber`
    ///
    /// Returns the value with larger magnitude. If exactly one is NaN, returns
    /// the other value.
    ///
    /// - Parameters:
    ///   - x: First value
    ///   - y: Second value
    /// - Returns: The value with maximum magnitude, preferring numbers over NaN
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.MinMax.maximumMagnitudeNumber(3.14, -2.71)   // 3.14
    /// IEEE_754.MinMax.maximumMagnitudeNumber(.nan, 3.14)    // 3.14
    /// ```
    @inlinable
    public static func maximumMagnitudeNumber(_ x: Double, _ y: Double) -> Double {
        // Prefer numbers over NaN
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }

        return maximumMagnitude(x, y)
    }
}

// MARK: - Float Min/Max Operations

extension IEEE_754.MinMax {
    // MARK: Standard Min/Max (NaN propagation)

    /// Minimum - IEEE 754-2019 `minimum`
    @inlinable
    public static func minimum(_ x: Float, _ y: Float) -> Float {
        if x.isNaN || y.isNaN {
            return .nan
        }
        if x.isZero && y.isZero {
            return (x.sign == .minus || y.sign == .minus) ? -0.0 : 0.0
        }
        return x < y ? x : y
    }

    /// Maximum - IEEE 754-2019 `maximum`
    @inlinable
    public static func maximum(_ x: Float, _ y: Float) -> Float {
        if x.isNaN || y.isNaN {
            return .nan
        }
        if x.isZero && y.isZero {
            return (x.sign == .plus || y.sign == .plus) ? 0.0 : -0.0
        }
        return x > y ? x : y
    }

    // MARK: Number Min/Max (Prefer numbers over NaN)

    /// Minimum Number - IEEE 754-2008 `minNum`
    @inlinable
    public static func minimumNumber(_ x: Float, _ y: Float) -> Float {
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }
        if x.isZero && y.isZero {
            return (x.sign == .minus || y.sign == .minus) ? -0.0 : 0.0
        }
        return x < y ? x : y
    }

    /// Maximum Number - IEEE 754-2008 `maxNum`
    @inlinable
    public static func maximumNumber(_ x: Float, _ y: Float) -> Float {
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }
        if x.isZero && y.isZero {
            return (x.sign == .plus || y.sign == .plus) ? 0.0 : -0.0
        }
        return x > y ? x : y
    }

    // MARK: Magnitude Min/Max (By absolute value)

    /// Minimum Magnitude - IEEE 754-2019 `minimumMagnitude`
    @inlinable
    public static func minimumMagnitude(_ x: Float, _ y: Float) -> Float {
        if x.isNaN || y.isNaN {
            return .nan
        }
        let xMag = Swift.abs(x)
        let yMag = Swift.abs(y)
        if xMag < yMag {
            return x
        } else if yMag < xMag {
            return y
        } else {
            return minimum(x, y)
        }
    }

    /// Maximum Magnitude - IEEE 754-2019 `maximumMagnitude`
    @inlinable
    public static func maximumMagnitude(_ x: Float, _ y: Float) -> Float {
        if x.isNaN || y.isNaN {
            return .nan
        }
        let xMag = Swift.abs(x)
        let yMag = Swift.abs(y)
        if xMag > yMag {
            return x
        } else if yMag > xMag {
            return y
        } else {
            return maximum(x, y)
        }
    }

    /// Minimum Magnitude Number - IEEE 754-2019 `minimumMagnitudeNumber`
    @inlinable
    public static func minimumMagnitudeNumber(_ x: Float, _ y: Float) -> Float {
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }
        return minimumMagnitude(x, y)
    }

    /// Maximum Magnitude Number - IEEE 754-2019 `maximumMagnitudeNumber`
    @inlinable
    public static func maximumMagnitudeNumber(_ x: Float, _ y: Float) -> Float {
        if x.isNaN && !y.isNaN {
            return y
        }
        if y.isNaN && !x.isNaN {
            return x
        }
        if x.isNaN && y.isNaN {
            return .nan
        }
        return maximumMagnitude(x, y)
    }
}
