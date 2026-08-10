// Float+Exception.swift
// swift-ieee-754
//
// Hardware floating-point exception state for Float

#if IEEE_754_SHIMS
    import IEEE_754_Shims
#endif

// MARK: - Float.Exception Namespace

extension Float {
    /// Hardware floating-point exception state accessor
    ///
    /// Provides access to the CPU's floating-point unit exception flags.
    /// These flags are set automatically by the hardware during floating-point
    /// operations.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// Float.exception.clear()
    /// _ = 1.0 / 0.0  // Raises hardware division by zero
    ///
    /// let state = Float.exception.test()
    /// if state.division {
    ///     print("Division by zero detected")
    /// }
    /// ```
    ///
    /// ## Note
    ///
    /// Float and Double share the same hardware FPU, so `Float.exception.test()`
    /// and `Double.exception.test()` return the same state.
    public enum Exception {}

    /// Hardware floating-point exception accessor
    public static var exception: Exception.Type { Exception.self }
}

// MARK: - Float.Exception.State

extension Float.Exception {
    /// Hardware floating-point exception state
    ///
    /// Represents the current state of the CPU's floating-point unit
    /// exception flags. These flags are set automatically during
    /// floating-point operations.
    public struct State: Sendable, Equatable {
        /// Invalid operation flag
        public let invalid: Bool

        /// Division by zero flag
        public let division: Bool

        /// Overflow flag
        public let overflow: Bool

        /// Underflow flag
        public let underflow: Bool

        /// Inexact flag
        public let inexact: Bool

        /// Memberwise initializer
        public init(
            invalid: Bool,
            division: Bool,
            overflow: Bool,
            underflow: Bool,
            inexact: Bool
        ) {
            self.invalid = invalid
            self.division = division
            self.overflow = overflow
            self.underflow = underflow
            self.inexact = inexact
        }
    }
}

// MARK: - Float.Exception.State Internal Init

#if IEEE_754_SHIMS
    extension Float.Exception.State {
        internal init(cState: IEEE754Exceptions) {
            self.init(
                invalid: cState.invalid != 0,
                division: cState.divByZero != 0,
                overflow: cState.overflow != 0,
                underflow: cState.underflow != 0,
                inexact: cState.inexact != 0
            )
        }
    }
#endif

// MARK: - Float.Exception Methods

extension Float.Exception {
    /// Test hardware FPU exception flags
    ///
    /// Queries the CPU's floating-point unit for exception flags.
    ///
    /// - Returns: Current FPU exception state
    ///
    /// ## Example
    ///
    /// ```swift
    /// let state = Float.exception.test()
    /// if state.overflow {
    ///     print("FPU overflow detected")
    /// }
    /// ```
    public static func test() -> State {
        #if IEEE_754_SHIMS
            let cState = ieee754_test_fpu_exceptions()
            return State(cState: cState)
        #else
            return State(
                invalid: false,
                division: false,
                overflow: false,
                underflow: false,
                inexact: false
            )
        #endif
    }

    /// Clear hardware FPU exception flags
    ///
    /// Clears all exception flags in the CPU's floating-point unit.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Float.exception.clear()
    /// // All hardware FPU exception flags are now clear
    /// ```
    public static func clear() {
        #if IEEE_754_SHIMS
            ieee754_clear_fpu_exceptions()
        #endif
    }
}
