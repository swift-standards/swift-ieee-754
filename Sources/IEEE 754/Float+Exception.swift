#if IEEE_754_SHIMS
    import IEEE_754_Shims
#endif

extension Float {

    public enum Exception {}

    public static var exception: Exception.Type { Exception.self }
}

extension Float.Exception {

    public struct State: Sendable, Equatable {

        public let invalid: Bool

        public let division: Bool

        public let overflow: Bool

        public let underflow: Bool

        public let inexact: Bool

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

extension Float.Exception {

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

    public static func clear() {
        #if IEEE_754_SHIMS
            ieee754_clear_fpu_exceptions()
        #endif
    }
}
