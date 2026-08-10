// IEEE_754_Shims+Extensions.swift
// swift-ieee-754
//
// Swift convenience wrappers for IEEE 754 Shims C APIs
//
// Provides scoped APIs that guarantee cleanup and prevent test pollution

#if IEEE_754_SHIMS
    import IEEE_754_Shims

    /// Scoped rounding mode execution
    ///
    /// Executes a closure with a specific FPU rounding mode, then automatically
    /// restores the original mode - even if the closure throws.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let result = withRoundingMode(.towardZero) {
    ///     return 10.0 / 3.0  // Rounded toward zero
    /// }
    /// // Original rounding mode automatically restored
    /// ```
    ///
    /// ## Safety
    ///
    /// This is the preferred way to change rounding modes in tests and application
    /// code. It guarantees the rounding mode is restored, preventing pollution of
    /// global FPU state.
    ///
    /// - Parameters:
    ///   - mode: The rounding mode to use during execution
    ///   - body: The closure to execute with the specified rounding mode
    /// - Returns: The value returned by the closure
    /// - Throws: Any error thrown by the closure
    func withRoundingMode<T, E: Swift.Error>(
        _ mode: IEEE754RoundingMode,
        _ body: () throws(E) -> T
    ) throws(E) -> T {
        let originalMode = ieee754_get_rounding_mode()
        defer { ieee754_set_rounding_mode(originalMode) }

        ieee754_set_rounding_mode(mode)
        return try body()
    }

    /// Scoped exception state execution
    ///
    /// Executes a closure with cleared exception state, then automatically
    /// restores the original exception flags - even if the closure throws.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// withClearedExceptions {
    ///     let result = 1.0 / 0.0  // Raises divByZero
    ///     // Exception state is isolated to this scope
    /// }
    /// // Original exception state automatically restored
    /// ```
    ///
    /// - Parameter body: The closure to execute with cleared exceptions
    /// - Returns: The value returned by the closure
    /// - Throws: Any error thrown by the closure
    func withClearedExceptions<T, E: Swift.Error>(_ body: () throws(E) -> T) throws(E) -> T {
        let originalExceptions = ieee754_get_exceptions()
        defer {
            // Restore original exception state
            ieee754_clear_all_exceptions()
            if originalExceptions.invalid != 0 {
                ieee754_raise_exception(IEEE754_EXCEPTION_INVALID)
            }
            if originalExceptions.divByZero != 0 {
                ieee754_raise_exception(IEEE754_EXCEPTION_DIVBYZERO)
            }
            if originalExceptions.overflow != 0 {
                ieee754_raise_exception(IEEE754_EXCEPTION_OVERFLOW)
            }
            if originalExceptions.underflow != 0 {
                ieee754_raise_exception(IEEE754_EXCEPTION_UNDERFLOW)
            }
            if originalExceptions.inexact != 0 {
                ieee754_raise_exception(IEEE754_EXCEPTION_INEXACT)
            }
        }

        ieee754_clear_all_exceptions()
        return try body()
    }

    /// Scoped rounding mode and exception state execution
    ///
    /// Executes a closure with a specific rounding mode and cleared exceptions,
    /// then automatically restores both - even if the closure throws.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let result = withRoundingModeAndClearedExceptions(.upward) {
    ///     return 1.0 / 3.0
    /// }
    /// // Both rounding mode and exceptions automatically restored
    /// ```
    ///
    /// - Parameters:
    ///   - mode: The rounding mode to use during execution
    ///   - body: The closure to execute
    /// - Returns: The value returned by the closure
    /// - Throws: Any error thrown by the closure
    func withRoundingModeAndClearedExceptions<T, E: Swift.Error>(
        _ mode: IEEE754RoundingMode,
        _ body: () throws(E) -> T
    ) throws(E) -> T {
        try withRoundingMode(mode) { () throws(E) -> T in
            try withClearedExceptions(body)
        }
    }

#endif
