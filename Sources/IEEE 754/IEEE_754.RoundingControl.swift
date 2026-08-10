// IEEE_754.RoundingControl.swift
// swift-ieee-754
//
// IEEE 754-2019 Section 4.3: Rounding Direction Attributes

#if IEEE_754_SHIMS
    import IEEE_754_Shims

    extension IEEE_754 {
        /// Dynamic rounding mode control
        ///
        /// Controls the floating-point rounding direction for the current thread.
        ///
        /// ## Overview
        ///
        /// IEEE 754-2019 Section 4.3.3 states: "Users can change the rounding direction."
        /// This type provides thread-safe access to the hardware FPU rounding mode.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Get current rounding mode
        /// let mode = IEEE_754.RoundingControl.get()
        ///
        /// // Set rounding mode
        /// try IEEE_754.RoundingControl.set(.upward)
        ///
        /// // Use scoped rounding
        /// try IEEE_754.RoundingControl.withMode(.towardZero) {
        ///     let result = 10.0 / 3.0  // Rounded toward zero
        ///     print(result)
        /// }
        /// ```
        ///
        /// ## Thread Safety
        ///
        /// Rounding mode changes affect only the current thread. Each thread has
        /// independent rounding mode state.
        ///
        /// ## See Also
        ///
        /// - IEEE 754-2019 Section 4.3: Rounding-direction attributes
        @frozen
        public enum RoundingControl {}
    }

    extension IEEE_754.RoundingControl {
        /// IEEE 754 rounding modes
        ///
        /// Maps directly to IEEE 754-2019 Section 4.3 rounding direction attributes.
        public enum Mode: Sendable, Equatable {
            /// Round to nearest, ties to even (roundTiesToEven)
            ///
            /// The default rounding mode. When the exact result is exactly halfway
            /// between two representable values, rounds to the one with an even
            /// least significant bit.
            ///
            /// IEEE 754-2019 Section 4.3.1
            case toNearest

            /// Round toward negative infinity (roundTowardNegative)
            ///
            /// Always rounds downward, toward -∞.
            ///
            /// IEEE 754-2019 Section 4.3.2
            case downward

            /// Round toward positive infinity (roundTowardPositive)
            ///
            /// Always rounds upward, toward +∞.
            ///
            /// IEEE 754-2019 Section 4.3.2
            case upward

            /// Round toward zero (roundTowardZero)
            ///
            /// Always truncates, rounding toward zero.
            ///
            /// IEEE 754-2019 Section 4.3.2
            case towardZero

            internal init(cValue: IEEE754RoundingMode) {
                switch cValue {
                case IEEE754_ROUND_TONEAREST: self = .toNearest
                case IEEE754_ROUND_DOWNWARD: self = .downward
                case IEEE754_ROUND_UPWARD: self = .upward
                case IEEE754_ROUND_TOWARDZERO: self = .towardZero
                default: self = .toNearest  // Fallback to default
                }
            }
        }

        /// Errors that can occur when setting rounding mode
        public enum Error: Swift.Error {
            /// Failed to set rounding mode (FPU returned error)
            case setFailed
        }

        /// Get the current rounding mode for this thread
        ///
        /// - Returns: The current rounding mode
        ///
        /// ## Example
        ///
        /// ```swift
        /// let mode = IEEE_754.RoundingControl.get()
        /// print(mode)  // .toNearest (default)
        /// ```
        public static func get() -> Mode {
            let cMode = ieee754_get_rounding_mode()
            return Mode(cValue: cMode)
        }

        /// Set the rounding mode for this thread
        ///
        /// - Parameter mode: The rounding mode to set
        /// - Throws: `Error.setFailed` if the FPU cannot set the mode
        ///
        /// ## Example
        ///
        /// ```swift
        /// try IEEE_754.RoundingControl.set(.upward)
        /// let result = 1.0 / 3.0  // Rounded upward
        /// ```
        ///
        /// ## Thread Safety
        ///
        /// This only affects the current thread. Other threads maintain their
        /// own rounding mode.
        public static func set(_ mode: Mode) throws(Error) {
            let result = ieee754_set_rounding_mode(mode.cValue)
            if result != 0 {
                throw Error.setFailed
            }
        }

        /// Execute a closure with a specific rounding mode
        ///
        /// Sets the rounding mode, executes the closure, then restores the
        /// original rounding mode.
        ///
        /// - Parameters:
        ///   - mode: The rounding mode to use during closure execution
        ///   - body: The closure to execute
        /// - Returns: The value returned by the closure
        /// - Throws: Any error from the closure
        ///
        /// ## Example
        ///
        /// ```swift
        /// let result = try IEEE_754.RoundingControl.withMode(.towardZero) {
        ///     return 10.0 / 3.0  // Rounded toward zero: 3.333...333
        /// }
        /// // Rounding mode is automatically restored here
        /// ```
        public static func withMode<T, E: Swift.Error>(
            _ mode: Mode,
            _ body: () throws(E) -> T
        ) throws(E) -> T {
            let originalMode = get()
            try? set(mode)
            defer {
                try? set(originalMode)
            }
            return try body()
        }
    }

    extension IEEE_754.RoundingControl.Mode {
        internal var cValue: IEEE754RoundingMode {
            switch self {
            case .toNearest: return IEEE754_ROUND_TONEAREST
            case .downward: return IEEE754_ROUND_DOWNWARD
            case .upward: return IEEE754_ROUND_UPWARD
            case .towardZero: return IEEE754_ROUND_TOWARDZERO
            }
        }
    }

#endif
