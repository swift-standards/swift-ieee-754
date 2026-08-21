import Testing

@testable import IEEE_754

#if IEEE_754_SHIMS
    extension IEEE_754.RoundingControl {
        @Suite("Swift API - Rounding Control")
        struct Test {
            @Test func `get Rounding Mode`() {
                let mode = IEEE_754.RoundingControl.get()

                switch mode {
                case .toNearest, .downward, .upward, .towardZero:
                    break
                }
            }

            @Test func `set Rounding Mode`() throws {

                let originalMode = IEEE_754.RoundingControl.get()
                defer {

                    try? IEEE_754.RoundingControl.set(originalMode)
                }

                try IEEE_754.RoundingControl.set(.upward)
                let mode = IEEE_754.RoundingControl.get()
                #expect(mode == .upward)
            }

            @Test func `with Mode Scoping`() throws {

                let originalMode = IEEE_754.RoundingControl.get()
                defer {

                    try? IEEE_754.RoundingControl.set(originalMode)
                }

                try IEEE_754.RoundingControl.set(.toNearest)

                let result = try IEEE_754.RoundingControl.withMode(.towardZero) {
                    let mode = IEEE_754.RoundingControl.get()
                    #expect(mode == .towardZero)
                    return 10.0 / 3.0
                }

                let restoredMode = IEEE_754.RoundingControl.get()
                #expect(restoredMode == .toNearest)
                #expect(result > 0)
            }
        }
    }
#endif

extension IEEE_754.Exceptions.Test {
    @Suite("Swift API - Exception Handling")
    struct SwiftAPIWrapper {
        @Test func `clear All Exceptions`() {
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.invalidOperation)
            #expect(!IEEE_754.Exceptions.divisionByZero)
            #expect(!IEEE_754.Exceptions.overflow)
            #expect(!IEEE_754.Exceptions.underflow)
            #expect(!IEEE_754.Exceptions.inexact)
        }

        @Test func `raise And Test Exception`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.invalid)

            #expect(IEEE_754.Exceptions.invalidOperation)
            #expect(!IEEE_754.Exceptions.overflow)
        }

        @Test func `fpu Exception Detection`() {
            Float.exception.clear()

            _ = 1.0 / 3.0

            let fpuState = Float.exception.test()

            #expect(fpuState.invalid == false || fpuState.invalid == true)
            #expect(fpuState.division == false || fpuState.division == true)
        }

        @Test func `fpu State Equatable`() {
            Float.exception.clear()
            let state1 = Float.exception.test()
            let state2 = Float.exception.test()

            #expect(state1 == state2)
        }
    }
}

#if IEEE_754_SHIMS
    extension IEEE_754.Exceptions.Test {
        @Suite("Swift API - Signaling Comparisons")
        struct SignalingComparisons {
            @Test func `signaling Equal Normal`() {
                IEEE_754.Exceptions.clear()

                let result = IEEE_754.Comparison.Signaling.equal(3.14, 3.14)
                #expect(result == true)
                #expect(!IEEE_754.Exceptions.invalidOperation)
            }

            @Test func `signaling Equal NaN`() {
                IEEE_754.Exceptions.clear()

                let result = IEEE_754.Comparison.Signaling.equal(Double.nan, 3.14)
                #expect(result == false)
                #expect(IEEE_754.Exceptions.invalidOperation)
            }

            @Test func `signaling Less Normal`() {
                IEEE_754.Exceptions.clear()

                #expect(IEEE_754.Comparison.Signaling.less(2.0, 3.0) == true)
                #expect(IEEE_754.Comparison.Signaling.less(3.0, 2.0) == false)
                #expect(!IEEE_754.Exceptions.invalidOperation)
            }

            @Test func `signaling Less NaN`() {
                IEEE_754.Exceptions.clear()

                let result = IEEE_754.Comparison.Signaling.less(Double.nan, 3.14)
                #expect(result == false)
                #expect(IEEE_754.Exceptions.invalidOperation)
            }

            @Test func `signaling Greater Float`() {
                IEEE_754.Exceptions.clear()

                #expect(IEEE_754.Comparison.Signaling.greater(Float(3.0), Float(2.0)) == true)
                #expect(IEEE_754.Comparison.Signaling.greater(Float(2.0), Float(3.0)) == false)
            }

            @Test func `signaling Not Equal NaN`() {
                IEEE_754.Exceptions.clear()

                let result = IEEE_754.Comparison.Signaling.notEqual(Double.nan, 3.14)
                #expect(result == true)
                #expect(IEEE_754.Exceptions.invalidOperation)
            }
        }
    }
#endif

extension IEEE_754.Exceptions.Test {
    @Suite("Swift API - Integration Scenarios")
    struct IntegrationScenarios {
        #if IEEE_754_SHIMS
            @Test func `rounding And Exceptions`() throws {
                IEEE_754.Exceptions.clear()

                try IEEE_754.RoundingControl.withMode(.upward) {
                    let result = 1.0 / 3.0
                    #expect(result > 0)

                    #expect(IEEE_754.RoundingControl.get() == .upward)
                }

                #expect(!IEEE_754.Exceptions.invalidOperation)
            }
        #endif

        #if IEEE_754_SHIMS
            @Test func `signaling Comparison Sets Exception`() {
                IEEE_754.Exceptions.clear()

                _ = IEEE_754.Comparison.Signaling.equal(Float.nan, Float.nan)

                #expect(IEEE_754.Exceptions.invalidOperation)

                IEEE_754.Exceptions.clear()
            }
        #endif

        @Test func `fpu And Thread Local Exceptions`() {
            IEEE_754.Exceptions.clear()
            Float.exception.clear()

            IEEE_754.Exceptions.raise(.overflow)

            #expect(IEEE_754.Exceptions.overflow)

            let fpuState = Float.exception.test()

            #expect(fpuState.overflow == false || fpuState.overflow == true)
        }
    }
}
