#if IEEE_754_SHIMS
    import IEEE_754_Shims

    func withRoundingMode<T, E: Swift.Error>(
        _ mode: IEEE754RoundingMode,
        _ body: () throws(E) -> T
    ) throws(E) -> T {
        let originalMode = ieee754_get_rounding_mode()
        defer { ieee754_set_rounding_mode(originalMode) }

        ieee754_set_rounding_mode(mode)
        return try body()
    }

    func withClearedExceptions<T, E: Swift.Error>(_ body: () throws(E) -> T) throws(E) -> T {
        let originalExceptions = ieee754_get_exceptions()
        defer {

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

    func withRoundingModeAndClearedExceptions<T, E: Swift.Error>(
        _ mode: IEEE754RoundingMode,
        _ body: () throws(E) -> T
    ) throws(E) -> T {
        try withRoundingMode(mode) { () throws(E) -> T in
            try withClearedExceptions(body)
        }
    }

#endif
