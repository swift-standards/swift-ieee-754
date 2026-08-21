#if IEEE_754_SHIMS
    import IEEE_754_Shims

    extension IEEE_754 {

        @frozen
        public enum RoundingControl {}
    }

    extension IEEE_754.RoundingControl {

        public enum Mode: Sendable, Equatable {

            case toNearest

            case downward

            case upward

            case towardZero

            internal init(cValue: IEEE754RoundingMode) {
                switch cValue {
                case IEEE754_ROUND_TONEAREST: self = .toNearest
                case IEEE754_ROUND_DOWNWARD: self = .downward
                case IEEE754_ROUND_UPWARD: self = .upward
                case IEEE754_ROUND_TOWARDZERO: self = .towardZero
                default: self = .toNearest
                }
            }
        }

        public enum Error: Swift.Error {

            case setFailed
        }

        public static func get() -> Mode {
            let cMode = ieee754_get_rounding_mode()
            return Mode(cValue: cMode)
        }

        public static func set(_ mode: Mode) throws(Error) {
            let result = ieee754_set_rounding_mode(mode.cValue)
            if result != 0 {
                throw Error.setFailed
            }
        }

        public static func withMode<T, E: Swift.Error>(
            _ mode: Mode,
            _ body: () throws(E) -> T
        ) throws(E) -> T {
            let originalMode = get()
            do {
                try set(mode)
            } catch {
                preconditionFailure("The requested IEEE 754 rounding mode is unsupported")
            }
            defer {
                do {
                    try set(originalMode)
                } catch {
                    preconditionFailure("The original IEEE 754 rounding mode could not be restored")
                }
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
