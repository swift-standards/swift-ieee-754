// IEEE_754.NextOperations.swift
// swift-ieee-754
//
// IEEE 754-2019 Section 5.3.1: Next Operations
// Authoritative implementations of nextUp, nextDown, and nextAfter

// MARK: - IEEE 754 Next Operations

extension IEEE_754 {
    /// IEEE 754 next operations (Section 5.3.1)
    ///
    /// Implements the next-value operations defined in IEEE 754-2019.
    /// These operations find the next representable value in a given direction.
    ///
    /// ## Overview
    ///
    /// The IEEE 754 standard defines three next operations:
    /// - `nextUp` - Next value toward positive infinity
    /// - `nextDown` - Next value toward negative infinity
    /// - `nextAfter` - Next value toward a specified target
    ///
    /// These operations are fundamental for testing boundaries, implementing
    /// interval arithmetic, and understanding floating-point precision.
    ///
    /// ## See Also
    ///
    /// - IEEE 754-2019 Section 5.3.1: Details of operations to round a floating-point datum to integral value
    /// - IEEE 754-2019 Table 5.1: Required operations
    public enum NextOperations {}
}

// MARK: - Hierarchical Next Direction Enum

extension IEEE_754.NextOperations {
    /// IEEE 754 Next Operation Direction
    ///
    /// Hierarchical structure for next-value operations with better pattern matching.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let next = IEEE_754.NextOperations.next(value, direction: .toward(.positiveInfinity))
    ///
    /// switch direction {
    /// case .toward(.positiveInfinity):
    ///     // nextUp
    /// case .toward(.negativeInfinity):
    ///     // nextDown
    /// case .toward(.value(let target)):
    ///     // nextAfter
    /// }
    /// ```
    ///
    /// ## See Also
    /// - IEEE 754-2019 Section 5.3.1: Next operations
    public enum Direction: Sendable, Equatable {
        /// Move toward a specific target
        case toward(Target)
    }

    /// Unified next operation for Double values
    ///
    /// Implements all IEEE 754 next operations through a single interface.
    ///
    /// - Parameters:
    ///   - value: The starting value
    ///   - direction: The direction to move
    /// - Returns: The next representable value in the specified direction
    @inlinable
    public static func next(_ value: Double, direction: Direction) -> Double {
        switch direction {
        case .toward(.positiveInfinity):
            return value.nextUp

        case .toward(.negativeInfinity):
            return value.nextDown

        case .toward(.value(let target)):
            return nextAfter(value, toward: target)
        }
    }

    /// Unified next operation for Float values
    ///
    /// Implements all IEEE 754 next operations through a single interface.
    ///
    /// - Parameters:
    ///   - value: The starting value
    ///   - direction: The direction to move
    /// - Returns: The next representable value in the specified direction
    @inlinable
    public static func next(_ value: Float, direction: Direction) -> Float {
        switch direction {
        case .toward(.positiveInfinity):
            return value.nextUp

        case .toward(.negativeInfinity):
            return value.nextDown

        case .toward(.value(let target)):
            return nextAfter(value, toward: Float(target))
        }
    }
}

// MARK: - Double Next Operations

extension IEEE_754.NextOperations {
    /// Next value toward positive infinity - IEEE 754 `nextUp`
    ///
    /// Returns the next representable value greater than the input. This is the
    /// smallest value strictly greater than the input in the floating-point format.
    ///
    /// - Parameter value: The starting value
    /// - Returns: The next value toward +∞
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.NextOperations.nextUp(1.0)    // 1.0000000000000002
    /// IEEE_754.NextOperations.nextUp(0.0)    // Double.leastNonzeroMagnitude
    /// IEEE_754.NextOperations.nextUp(-0.0)   // Double.leastNonzeroMagnitude
    /// ```
    ///
    /// Special cases:
    /// ```swift
    /// IEEE_754.NextOperations.nextUp(.infinity)  // .infinity
    /// IEEE_754.NextOperations.nextUp(.nan)       // .nan
    /// IEEE_754.NextOperations.nextUp(-Double.leastNonzeroMagnitude)  // -0.0
    /// ```
    @inlinable
    public static func nextUp(_ value: Double) -> Double {
        next(value, direction: .toward(.positiveInfinity))
    }

    /// Next value toward negative infinity - IEEE 754 `nextDown`
    ///
    /// Returns the next representable value less than the input. This is the
    /// largest value strictly less than the input in the floating-point format.
    ///
    /// - Parameter value: The starting value
    /// - Returns: The next value toward -∞
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.NextOperations.nextDown(1.0)   // 0.9999999999999999
    /// IEEE_754.NextOperations.nextDown(0.0)   // -Double.leastNonzeroMagnitude
    /// IEEE_754.NextOperations.nextDown(-0.0)  // -Double.leastNonzeroMagnitude
    /// ```
    ///
    /// Special cases:
    /// ```swift
    /// IEEE_754.NextOperations.nextDown(-.infinity)  // -.infinity
    /// IEEE_754.NextOperations.nextDown(.nan)        // .nan
    /// ```
    @inlinable
    public static func nextDown(_ value: Double) -> Double {
        next(value, direction: .toward(.negativeInfinity))
    }

    /// Next value toward target - IEEE 754 `nextAfter`
    ///
    /// Returns the next representable value in the direction of the target.
    /// If value equals target, returns value (unchanged).
    ///
    /// - Parameters:
    ///   - value: The starting value
    ///   - target: The direction to move toward
    /// - Returns: The next value toward target
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.NextOperations.nextAfter(1.0, toward: 2.0)   // 1.0000000000000002 (nextUp)
    /// IEEE_754.NextOperations.nextAfter(1.0, toward: 0.0)   // 0.9999999999999999 (nextDown)
    /// IEEE_754.NextOperations.nextAfter(1.0, toward: 1.0)   // 1.0 (unchanged)
    /// ```
    ///
    /// Special cases:
    /// - If either value is NaN, returns NaN
    /// - If value equals target (bitwise), returns value
    /// - Properly handles signed zeros
    @inlinable
    public static func nextAfter(_ value: Double, toward target: Double) -> Double {
        // Handle NaN
        if value.isNaN || target.isNaN {
            return .nan
        }

        // If equal, return value unchanged
        if value == target {
            // Check for signed zero edge case
            if value.isZero && target.isZero && value.sign != target.sign {
                // Moving from -0.0 toward +0.0 or vice versa
                return target
            }
            return value
        }

        // Move in the appropriate direction
        return value < target ? value.nextUp : value.nextDown
    }
}

extension IEEE_754.NextOperations.Direction {
    /// Target for next operation
    public enum Target: Sendable, Equatable {
        /// Toward positive infinity (nextUp)
        case positiveInfinity
        /// Toward negative infinity (nextDown)
        case negativeInfinity
        /// Toward a specific value (nextAfter)
        case value(Double)
    }
}

extension IEEE_754.NextOperations.Direction.Target {
    /// Equality comparison for Target
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.positiveInfinity, .positiveInfinity):
            return true

        case (.negativeInfinity, .negativeInfinity):
            return true

        case (.value(let l), .value(let r)):
            return l.bitPattern == r.bitPattern  // Bitwise equality for NaN handling

        default:
            return false
        }
    }
}

// MARK: - Float Next Operations

extension IEEE_754.NextOperations {
    /// Next value toward positive infinity - IEEE 754 `nextUp`
    ///
    /// Returns the next representable value greater than the input.
    ///
    /// - Parameter value: The starting value
    /// - Returns: The next value toward +∞
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.NextOperations.nextUp(Float(1.0))   // 1.0000001
    /// IEEE_754.NextOperations.nextUp(Float(0.0))   // Float.leastNonzeroMagnitude
    /// ```
    @inlinable
    public static func nextUp(_ value: Float) -> Float {
        next(value, direction: .toward(.positiveInfinity))
    }

    /// Next value toward negative infinity - IEEE 754 `nextDown`
    ///
    /// Returns the next representable value less than the input.
    ///
    /// - Parameter value: The starting value
    /// - Returns: The next value toward -∞
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.NextOperations.nextDown(Float(1.0))   // 0.99999994
    /// IEEE_754.NextOperations.nextDown(Float(0.0))   // -Float.leastNonzeroMagnitude
    /// ```
    @inlinable
    public static func nextDown(_ value: Float) -> Float {
        next(value, direction: .toward(.negativeInfinity))
    }

    /// Next value toward target - IEEE 754 `nextAfter`
    ///
    /// Returns the next representable value in the direction of the target.
    ///
    /// - Parameters:
    ///   - value: The starting value
    ///   - target: The direction to move toward
    /// - Returns: The next value toward target
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.NextOperations.nextAfter(Float(1.0), toward: Float(2.0))  // nextUp
    /// IEEE_754.NextOperations.nextAfter(Float(1.0), toward: Float(0.0))  // nextDown
    /// ```
    @inlinable
    public static func nextAfter(_ value: Float, toward target: Float) -> Float {
        if value.isNaN || target.isNaN {
            return .nan
        }

        if value == target {
            if value.isZero && target.isZero && value.sign != target.sign {
                return target
            }
            return value
        }

        return value < target ? value.nextUp : value.nextDown
    }
}
