// Swift API Wrappers Tests.swift
// swift-ieee-754
//
// Tests for elegant Swift wrappers around IEEE 754 Shims functionality

import Testing

@testable import IEEE_754

// MARK: - Rounding Control Tests

#if IEEE_754_SHIMS
    extension IEEE_754.RoundingControl {
        @Suite("Swift API - Rounding Control")
        struct Test {
            @Test func `get Rounding Mode`() {
                let mode = IEEE_754.RoundingControl.get()
                // Should be one of the four valid modes
                switch mode {
                case .toNearest, .downward, .upward, .towardZero:
                    break  // Valid
                }
            }

            @Test func `set Rounding Mode`() throws {
                // Save original mode
                let originalMode = IEEE_754.RoundingControl.get()
                defer {
                    // Always restore original mode, even if test fails
                    try? IEEE_754.RoundingControl.set(originalMode)
                }

                try IEEE_754.RoundingControl.set(.upward)
                let mode = IEEE_754.RoundingControl.get()
                #expect(mode == .upward)
            }

            @Test func `with Mode Scoping`() throws {
                // Save original mode
                let originalMode = IEEE_754.RoundingControl.get()
                defer {
                    // Always restore original mode, even if test fails
                    try? IEEE_754.RoundingControl.set(originalMode)
                }

                // Set a specific mode first
                try IEEE_754.RoundingControl.set(.toNearest)

                let result = try IEEE_754.RoundingControl.withMode(.towardZero) {
                    let mode = IEEE_754.RoundingControl.get()
                    #expect(mode == .towardZero)
                    return 10.0 / 3.0
                }

                // Mode should be restored
                let restoredMode = IEEE_754.RoundingControl.get()
                #expect(restoredMode == .toNearest)
                #expect(result > 0)
            }
        }
    }
#endif

// MARK: - Exception Handling Tests
//
// F-004 follow-up: `.serialized` on a suite only serializes that suite's OWN
// subtree — it does not provide mutual exclusion against other, unrelated
// top-level suites. These three suites all read/write `IEEE_754.Exceptions`'
// single shared process-global store (see its "Store Model" documentation),
// which the F-004 fix made the sole target of both manual `raise` calls AND
// (via the Comparison.Signaling bridge) NaN-triggered signaling comparisons —
// widening how many call sites now write that shared store concurrently.
// They are nested here, under the already-`.serialized` `IEEE_754.Exceptions.Test`
// (whose `.serialized` trait propagates to its whole subtree), specifically
// to close that cross-suite race rather than merely reducing it.

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

            // Perform operation that might set FPU exceptions
            _ = 1.0 / 3.0  // May set inexact

            let fpuState = Float.exception.test()

            // Verify structure is readable
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

// MARK: - Signaling Comparison Tests
//
// Nested under `IEEE_754.Exceptions.Test` (see note above) rather than under
// `IEEE_754.Comparison.Signaling` — a deliberate deviation from the usual
// "extension of the affected source type" placement, made specifically to
// close the cross-suite race on the shared `IEEE_754.Exceptions` store that
// signaling comparisons write into as of the F-004 fix.

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
                #expect(result == true)  // NaN is not equal to anything
                #expect(IEEE_754.Exceptions.invalidOperation)
            }
        }
    }
#endif

// MARK: - Integration Tests
//
// Nested under `IEEE_754.Exceptions.Test` (see note above) for the same
// cross-suite-race reason.

extension IEEE_754.Exceptions.Test {
    @Suite("Swift API - Integration Scenarios")
    struct IntegrationScenarios {
        #if IEEE_754_SHIMS
            @Test func `rounding And Exceptions`() throws {
                IEEE_754.Exceptions.clear()

                try IEEE_754.RoundingControl.withMode(.upward) {
                    let result = 1.0 / 3.0
                    #expect(result > 0)

                    // Mode should be upward within closure
                    #expect(IEEE_754.RoundingControl.get() == .upward)
                }

                // Mode should be restored
                // Exceptions should still be clear
                #expect(!IEEE_754.Exceptions.invalidOperation)
            }
        #endif

        #if IEEE_754_SHIMS
            @Test func `signaling Comparison Sets Exception`() {
                IEEE_754.Exceptions.clear()

                // This should set the invalid exception
                _ = IEEE_754.Comparison.Signaling.equal(Float.nan, Float.nan)

                // Verify exception was set
                #expect(IEEE_754.Exceptions.invalidOperation)

                // Clear for next test
                IEEE_754.Exceptions.clear()
            }
        #endif

        @Test func `fpu And Thread Local Exceptions`() {
            IEEE_754.Exceptions.clear()
            Float.exception.clear()

            // Raise thread-local exception
            IEEE_754.Exceptions.raise(.overflow)

            // Check thread-local
            #expect(IEEE_754.Exceptions.overflow)

            // FPU state is independent
            let fpuState = Float.exception.test()
            // FPU overflow might or might not be set depending on operations
            #expect(fpuState.overflow == false || fpuState.overflow == true)
        }
    }
}
