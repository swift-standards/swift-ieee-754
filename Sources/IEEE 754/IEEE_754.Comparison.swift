// IEEE_754.Comparison.swift
// swift-ieee-754
//
// IEEE 754-2019 Section 5.6: Comparison Predicates
// Authoritative implementations of floating-point comparison operations

#if IEEE_754_SHIMS
    import IEEE_754_Shims
#endif

// MARK: - IEEE 754 Comparison Operations

extension IEEE_754 {
    /// IEEE 754 comparison operations (Section 5.6 & 5.10)
    ///
    /// Implements the comparison predicates defined in IEEE 754-2019.
    /// These operations compare floating-point values according to IEEE 754 rules.
    ///
    /// ## Overview
    ///
    /// The IEEE 754 standard defines several comparison predicates:
    ///
    /// ### Standard Comparisons (Section 5.6)
    /// - `compareQuietEqual` - Quiet equality (NaN returns false)
    /// - `compareQuietNotEqual` - Quiet inequality
    /// - `compareQuietLess` - Quiet less than
    /// - `compareQuietLessEqual` - Quiet less than or equal
    /// - `compareQuietGreater` - Quiet greater than
    /// - `compareQuietGreaterEqual` - Quiet greater than or equal
    ///
    /// ### Signaling Comparisons
    /// - Signaling comparisons raise exceptions on NaN inputs
    ///
    /// ### Total Order (Section 5.10)
    /// - `totalOrder` - Total ordering including NaN values
    /// - `totalOrderMag` - Total ordering by magnitude
    ///
    /// ## See Also
    ///
    /// - IEEE 754-2019 Section 5.6: Details of comparison predicates
    /// - IEEE 754-2019 Section 5.10: Details of totalOrder predicate
    public enum Comparison {}
}

// MARK: - Hierarchical Comparison Predicate Enum

extension IEEE_754.Comparison {
    /// IEEE 754 Comparison Predicate
    ///
    /// Hierarchical structure for comparison operations with better pattern matching.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let result = IEEE_754.Comparison.compare(lhs, rhs, using: .ordering(.less(orEqual: true)))
    ///
    /// switch predicate {
    /// case .equality(.equal):
    ///     // ==
    /// case .ordering(.less(let orEqual)):
    ///     // < or <=
    /// }
    /// ```
    ///
    /// ## See Also
    /// - IEEE 754-2019 Section 5.6: Details of comparison predicates
    public enum Predicate: Sendable, Equatable {
        /// Equality comparison
        case equality(EqualityMode)
        /// Ordering comparison
        case ordering(OrderingMode)
    }

    /// Unified comparison operation for Double values
    ///
    /// Implements all standard IEEE 754 comparison predicates through a single interface.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    ///   - predicate: The comparison predicate to use
    /// - Returns: The comparison result
    @inlinable
    public static func compare(_ lhs: Double, _ rhs: Double, using predicate: Predicate) -> Bool {
        switch predicate {
        case .equality(.equal):
            return lhs == rhs
        case .equality(.notEqual):
            return lhs != rhs
        case .ordering(.less(orEqual: false)):
            return lhs < rhs
        case .ordering(.less(orEqual: true)):
            return lhs <= rhs
        case .ordering(.greater(orEqual: false)):
            return lhs > rhs
        case .ordering(.greater(orEqual: true)):
            return lhs >= rhs
        }
    }

    /// Unified comparison operation for Float values
    ///
    /// Implements all standard IEEE 754 comparison predicates through a single interface.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    ///   - predicate: The comparison predicate to use
    /// - Returns: The comparison result
    @inlinable
    public static func compare(_ lhs: Float, _ rhs: Float, using predicate: Predicate) -> Bool {
        switch predicate {
        case .equality(.equal):
            return lhs == rhs
        case .equality(.notEqual):
            return lhs != rhs
        case .ordering(.less(orEqual: false)):
            return lhs < rhs
        case .ordering(.less(orEqual: true)):
            return lhs <= rhs
        case .ordering(.greater(orEqual: false)):
            return lhs > rhs
        case .ordering(.greater(orEqual: true)):
            return lhs >= rhs
        }
    }
}

extension IEEE_754.Comparison.Predicate {
    /// Equality mode
    public enum EqualityMode: Sendable, Equatable {
        /// Equal (==)
        case equal
        /// Not equal (!=)
        case notEqual
    }

    /// Ordering mode
    public enum OrderingMode: Sendable, Equatable {
        /// Less than, optionally or equal
        case less(orEqual: Bool)
        /// Greater than, optionally or equal
        case greater(orEqual: Bool)
    }
}

// MARK: - Double Comparison Operations

extension IEEE_754.Comparison {
    /// Quiet equality comparison - IEEE 754 `compareQuietEqual`
    ///
    /// Returns true if values are equal. Returns false if either value is NaN.
    /// Treats +0.0 and -0.0 as equal.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if values are equal
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Comparison.isEqual(3.14, 3.14)    // true
    /// IEEE_754.Comparison.isEqual(0.0, -0.0)     // true
    /// IEEE_754.Comparison.isEqual(.nan, .nan)    // false
    /// IEEE_754.Comparison.isEqual(3.14, 2.71)    // false
    /// ```
    @inlinable
    public static func isEqual(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .equality(.equal))
    }

    /// Quiet inequality comparison - IEEE 754 `compareQuietNotEqual`
    ///
    /// Returns true if values are not equal. Returns true if either value is NaN.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if values are not equal
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Comparison.isNotEqual(3.14, 2.71)  // true
    /// IEEE_754.Comparison.isNotEqual(.nan, 3.14)  // true
    /// IEEE_754.Comparison.isNotEqual(3.14, 3.14)  // false
    /// ```
    @inlinable
    public static func isNotEqual(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .equality(.notEqual))
    }

    /// Quiet less than comparison - IEEE 754 `compareQuietLess`
    ///
    /// Returns true if lhs < rhs. Returns false if either value is NaN.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if lhs < rhs
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Comparison.isLess(2.71, 3.14)   // true
    /// IEEE_754.Comparison.isLess(3.14, 2.71)   // false
    /// IEEE_754.Comparison.isLess(.nan, 3.14)   // false
    /// ```
    @inlinable
    public static func isLess(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .ordering(.less(orEqual: false)))
    }

    /// Quiet less than or equal comparison - IEEE 754 `compareQuietLessEqual`
    ///
    /// Returns true if lhs <= rhs. Returns false if either value is NaN.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if lhs <= rhs
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Comparison.isLessEqual(2.71, 3.14)  // true
    /// IEEE_754.Comparison.isLessEqual(3.14, 3.14)  // true
    /// IEEE_754.Comparison.isLessEqual(3.14, 2.71)  // false
    /// ```
    @inlinable
    public static func isLessEqual(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .ordering(.less(orEqual: true)))
    }

    /// Quiet greater than comparison - IEEE 754 `compareQuietGreater`
    ///
    /// Returns true if lhs > rhs. Returns false if either value is NaN.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if lhs > rhs
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Comparison.isGreater(3.14, 2.71)  // true
    /// IEEE_754.Comparison.isGreater(2.71, 3.14)  // false
    /// ```
    @inlinable
    public static func isGreater(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .ordering(.greater(orEqual: false)))
    }

    /// Quiet greater than or equal comparison - IEEE 754 `compareQuietGreaterEqual`
    ///
    /// Returns true if lhs >= rhs. Returns false if either value is NaN.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if lhs >= rhs
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Comparison.isGreaterEqual(3.14, 2.71)  // true
    /// IEEE_754.Comparison.isGreaterEqual(3.14, 3.14)  // true
    /// IEEE_754.Comparison.isGreaterEqual(2.71, 3.14)  // false
    /// ```
    @inlinable
    public static func isGreaterEqual(_ lhs: Double, _ rhs: Double) -> Bool {
        compare(lhs, rhs, using: .ordering(.greater(orEqual: true)))
    }

    /// Total order predicate - IEEE 754 `totalOrder`
    ///
    /// Implements the totalOrder predicate that defines a total ordering over
    /// all floating-point values, including NaN and signed zeros.
    ///
    /// The ordering is:
    /// - -NaN < -Infinity < -Finite < -0.0 < +0.0 < +Finite < +Infinity < +NaN
    /// - NaN values are ordered by their payload
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if lhs is ordered before rhs in total order
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Comparison.totalOrder(-0.0, 0.0)        // true (-0 < +0)
    /// IEEE_754.Comparison.totalOrder(.nan, 3.14)       // false (NaN is largest)
    /// IEEE_754.Comparison.totalOrder(-.infinity, 0.0)  // true
    /// ```
    @inlinable
    public static func totalOrder(_ lhs: Double, _ rhs: Double) -> Bool {
        lhs.isTotallyOrdered(belowOrEqualTo: rhs)
    }

    /// Total order magnitude predicate - IEEE 754 `totalOrderMag`
    ///
    /// Like totalOrder, but compares absolute values. Implements a total
    /// ordering based on magnitude.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if |lhs| is ordered before |rhs| in total order
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Comparison.totalOrderMag(-3.14, 2.71)  // false (3.14 > 2.71)
    /// IEEE_754.Comparison.totalOrderMag(2.71, -3.14)  // true (2.71 < 3.14)
    /// ```
    @inlinable
    public static func totalOrderMag(_ lhs: Double, _ rhs: Double) -> Bool {
        lhs.magnitude.isTotallyOrdered(belowOrEqualTo: rhs.magnitude)
    }
}

// MARK: - Float Comparison Operations

extension IEEE_754.Comparison {
    /// Quiet equality comparison - IEEE 754 `compareQuietEqual`
    ///
    /// Returns true if values are equal. Returns false if either value is NaN.
    /// Treats +0.0 and -0.0 as equal.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if values are equal
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Comparison.isEqual(Float(3.14), Float(3.14))  // true
    /// IEEE_754.Comparison.isEqual(Float(0.0), Float(-0.0))   // true
    /// IEEE_754.Comparison.isEqual(Float.nan, Float.nan)      // false
    /// ```
    @inlinable
    public static func isEqual(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .equality(.equal))
    }

    /// Quiet inequality comparison - IEEE 754 `compareQuietNotEqual`
    ///
    /// Returns true if values are not equal. Returns true if either value is NaN.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if values are not equal
    @inlinable
    public static func isNotEqual(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .equality(.notEqual))
    }

    /// Quiet less than comparison - IEEE 754 `compareQuietLess`
    ///
    /// Returns true if lhs < rhs. Returns false if either value is NaN.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if lhs < rhs
    @inlinable
    public static func isLess(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .ordering(.less(orEqual: false)))
    }

    /// Quiet less than or equal comparison - IEEE 754 `compareQuietLessEqual`
    ///
    /// Returns true if lhs <= rhs. Returns false if either value is NaN.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if lhs <= rhs
    @inlinable
    public static func isLessEqual(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .ordering(.less(orEqual: true)))
    }

    /// Quiet greater than comparison - IEEE 754 `compareQuietGreater`
    ///
    /// Returns true if lhs > rhs. Returns false if either value is NaN.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if lhs > rhs
    @inlinable
    public static func isGreater(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .ordering(.greater(orEqual: false)))
    }

    /// Quiet greater than or equal comparison - IEEE 754 `compareQuietGreaterEqual`
    ///
    /// Returns true if lhs >= rhs. Returns false if either value is NaN.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if lhs >= rhs
    @inlinable
    public static func isGreaterEqual(_ lhs: Float, _ rhs: Float) -> Bool {
        compare(lhs, rhs, using: .ordering(.greater(orEqual: true)))
    }

    /// Total order predicate - IEEE 754 `totalOrder`
    ///
    /// Implements the totalOrder predicate that defines a total ordering over
    /// all floating-point values, including NaN and signed zeros.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if lhs is ordered before rhs in total order
    @inlinable
    public static func totalOrder(_ lhs: Float, _ rhs: Float) -> Bool {
        lhs.isTotallyOrdered(belowOrEqualTo: rhs)
    }

    /// Total order magnitude predicate - IEEE 754 `totalOrderMag`
    ///
    /// Like totalOrder, but compares absolute values. Implements a total
    /// ordering based on magnitude.
    ///
    /// - Parameters:
    ///   - lhs: Left-hand value
    ///   - rhs: Right-hand value
    /// - Returns: true if |lhs| is ordered before |rhs| in total order
    @inlinable
    public static func totalOrderMag(_ lhs: Float, _ rhs: Float) -> Bool {
        lhs.magnitude.isTotallyOrdered(belowOrEqualTo: rhs.magnitude)
    }
}

// MARK: - Signaling Comparisons

#if IEEE_754_SHIMS
    extension IEEE_754.Comparison {
        /// Signaling comparison operations
        ///
        /// Implements IEEE 754-2019 Section 5.6.1 signaling comparison predicates.
        ///
        /// ## Overview
        ///
        /// Signaling comparisons differ from quiet comparisons in that they raise
        /// the invalid operation exception when either operand is NaN (quiet or signaling).
        ///
        /// This is useful for detecting unexpected NaN values in computational pipelines,
        /// as the exception can be caught and handled.
        ///
        /// ## Example
        ///
        /// ```swift
        /// IEEE_754.Exceptions.clear()
        ///
        /// let result = IEEE_754.Comparison.Signaling.equal(Double.nan, 3.14)
        /// // result = false
        /// // IEEE_754.Exceptions.invalidOperation = true
        /// ```
        ///
        /// ## Exception Store
        ///
        /// Each wrapper below detects the NaN operand itself and calls
        /// `IEEE_754.Exceptions.raise(.invalid)` explicitly, so the flag lands
        /// in `IEEE_754.Exceptions`' single canonical store (see its "Store
        /// Model" documentation) and is visible through `test`/`invalidOperation`
        /// with the same semantics as any other flag. The underlying C
        /// function (`ieee754_signaling_*`) additionally raises its own,
        /// separate C-shim thread-local and hardware FPU flags as a side
        /// effect of its C-level implementation — those remain independent,
        /// opt-in stores, not read by `IEEE_754.Exceptions`.
        ///
        /// ## See Also
        ///
        /// - IEEE 754-2019 Section 5.6.1: Signaling comparison predicates
        /// - IEEE 754-2019 Section 7.2: Invalid operation exception
        @frozen
        public enum Signaling {}
    }

    extension IEEE_754.Comparison.Signaling {
        // MARK: - Double (binary64) Comparisons

        /// Signaling equality comparison for Double
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs == rhs, false otherwise (including NaN)
        ///
        /// If either operand is NaN, raises invalid exception and returns false.
        public static func equal(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_equal(lhs, rhs) != 0
        }

        /// Signaling less than comparison for Double
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs < rhs
        ///
        /// If either operand is NaN, raises invalid exception and returns false.
        public static func less(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_less(lhs, rhs) != 0
        }

        /// Signaling less than or equal comparison for Double
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs <= rhs
        ///
        /// If either operand is NaN, raises invalid exception and returns false.
        public static func lessEqual(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_less_equal(lhs, rhs) != 0
        }

        /// Signaling greater than comparison for Double
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs > rhs
        ///
        /// If either operand is NaN, raises invalid exception and returns false.
        public static func greater(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_greater(lhs, rhs) != 0
        }

        /// Signaling greater than or equal comparison for Double
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs >= rhs
        ///
        /// If either operand is NaN, raises invalid exception and returns false.
        public static func greaterEqual(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_greater_equal(lhs, rhs) != 0
        }

        /// Signaling not equal comparison for Double
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs != rhs
        ///
        /// If either operand is NaN, raises invalid exception and returns true
        /// (since NaN is not equal to anything, including itself).
        public static func notEqual(_ lhs: Double, _ rhs: Double) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_not_equal(lhs, rhs) != 0
        }

        // MARK: - Float (binary32) Comparisons

        /// Signaling equality comparison for Float
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs == rhs, false otherwise (including NaN)
        ///
        /// If either operand is NaN, raises invalid exception and returns false.
        public static func equal(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_equal_f(lhs, rhs) != 0
        }

        /// Signaling less than comparison for Float
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs < rhs
        ///
        /// If either operand is NaN, raises invalid exception and returns false.
        public static func less(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_less_f(lhs, rhs) != 0
        }

        /// Signaling less than or equal comparison for Float
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs <= rhs
        ///
        /// If either operand is NaN, raises invalid exception and returns false.
        public static func lessEqual(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_less_equal_f(lhs, rhs) != 0
        }

        /// Signaling greater than comparison for Float
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs > rhs
        ///
        /// If either operand is NaN, raises invalid exception and returns false.
        public static func greater(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_greater_f(lhs, rhs) != 0
        }

        /// Signaling greater than or equal comparison for Float
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs >= rhs
        ///
        /// If either operand is NaN, raises invalid exception and returns false.
        public static func greaterEqual(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_greater_equal_f(lhs, rhs) != 0
        }

        /// Signaling not equal comparison for Float
        ///
        /// - Parameters:
        ///   - lhs: Left-hand value
        ///   - rhs: Right-hand value
        /// - Returns: true if lhs != rhs
        ///
        /// If either operand is NaN, raises invalid exception and returns true
        /// (since NaN is not equal to anything, including itself).
        public static func notEqual(_ lhs: Float, _ rhs: Float) -> Bool {
            if lhs.isNaN || rhs.isNaN { IEEE_754.Exceptions.raise(.invalid) }
            return ieee754_signaling_not_equal_f(lhs, rhs) != 0
        }
    }
#endif
