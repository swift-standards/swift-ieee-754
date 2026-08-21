import Testing

@testable import IEEE_754

extension IEEE_754.Exceptions {
    @Suite("IEEE_754.Exceptions - Flag Operations", .serialized)
    struct Test {
        @Test func `Raise And Test Invalid`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.invalid)
            #expect(IEEE_754.Exceptions.test(.invalid))
            #expect(!IEEE_754.Exceptions.test(.overflow))
        }

        @Test func `Raise And Test Division By Zero`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.divisionByZero)
            #expect(IEEE_754.Exceptions.test(.divisionByZero))
            #expect(!IEEE_754.Exceptions.test(.invalid))
        }

        @Test func `Raise And Test Overflow`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.overflow)
            #expect(IEEE_754.Exceptions.test(.overflow))
            #expect(!IEEE_754.Exceptions.test(.underflow))
        }

        @Test func `Raise And Test Underflow`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.underflow)
            #expect(IEEE_754.Exceptions.test(.underflow))
            #expect(!IEEE_754.Exceptions.test(.overflow))
        }

        @Test func `Raise And Test Inexact`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.inexact)
            #expect(IEEE_754.Exceptions.test(.inexact))
            #expect(!IEEE_754.Exceptions.test(.invalid))
        }

        @Test func `Clear Specific Flag`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.invalid)
            IEEE_754.Exceptions.raise(.overflow)
            #expect(IEEE_754.Exceptions.test(.invalid))
            #expect(IEEE_754.Exceptions.test(.overflow))

            IEEE_754.Exceptions.clear(.invalid)
            #expect(!IEEE_754.Exceptions.test(.invalid))
            #expect(IEEE_754.Exceptions.test(.overflow))
        }

        @Test func `Clear All Flags`() {
            IEEE_754.Exceptions.raise(.invalid)
            IEEE_754.Exceptions.raise(.divisionByZero)
            IEEE_754.Exceptions.raise(.overflow)
            IEEE_754.Exceptions.raise(.underflow)
            IEEE_754.Exceptions.raise(.inexact)

            IEEE_754.Exceptions.clear()

            #expect(!IEEE_754.Exceptions.test(.invalid))
            #expect(!IEEE_754.Exceptions.test(.divisionByZero))
            #expect(!IEEE_754.Exceptions.test(.overflow))
            #expect(!IEEE_754.Exceptions.test(.underflow))
            #expect(!IEEE_754.Exceptions.test(.inexact))
        }

        @Test func `Multiple Flags`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.invalid)
            IEEE_754.Exceptions.raise(.overflow)
            IEEE_754.Exceptions.raise(.inexact)

            #expect(IEEE_754.Exceptions.test(.invalid))
            #expect(IEEE_754.Exceptions.test(.overflow))
            #expect(IEEE_754.Exceptions.test(.inexact))
            #expect(!IEEE_754.Exceptions.test(.underflow))
            #expect(!IEEE_754.Exceptions.test(.divisionByZero))
        }

        @Test func `Any Raised When No Flags`() {
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.raised.any)
        }

        @Test func `Any Raised When One Flag Set`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.overflow)
            #expect(IEEE_754.Exceptions.raised.any)
        }

        @Test func `Any Raised When Multiple Flags`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.invalid)
            IEEE_754.Exceptions.raise(.inexact)
            #expect(IEEE_754.Exceptions.raised.any)
        }

        @Test func `Get Raised Flags When None`() {
            IEEE_754.Exceptions.clear()
            let raised = IEEE_754.Exceptions.raised.flags
            #expect(raised.isEmpty)
        }

        @Test func `Get Raised Flags When One`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.overflow)
            let raised = IEEE_754.Exceptions.raised.flags
            #expect(raised.count == 1)
            #expect(raised.contains(.overflow))
        }

        @Test func `Get Raised Flags When Multiple`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.invalid)
            IEEE_754.Exceptions.raise(.overflow)
            IEEE_754.Exceptions.raise(.inexact)
            let raised = IEEE_754.Exceptions.raised.flags
            #expect(raised.count == 3)
            #expect(raised.contains(.invalid))
            #expect(raised.contains(.overflow))
            #expect(raised.contains(.inexact))
        }

        @Test func `Get Raised Flags When All`() {
            IEEE_754.Exceptions.clear()
            for flag in IEEE_754.Exceptions.Flag.allCases {
                IEEE_754.Exceptions.raise(flag)
            }
            let raised = IEEE_754.Exceptions.raised.flags
            #expect(raised.count == 5)
        }
    }
}

extension IEEE_754.Exceptions.Test {
    @Suite("IEEE_754.Exceptions - Compatibility Properties", .serialized)
    struct Compatibility {
        @Test func `Invalid Operation Property`() {
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.invalidOperation)
            IEEE_754.Exceptions.raise(.invalid)
            #expect(IEEE_754.Exceptions.invalidOperation)
        }

        @Test func `Division By Zero Property`() {
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.divisionByZero)
            IEEE_754.Exceptions.raise(.divisionByZero)
            #expect(IEEE_754.Exceptions.divisionByZero)
        }

        @Test func `Overflow Property`() {
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.overflow)
            IEEE_754.Exceptions.raise(.overflow)
            #expect(IEEE_754.Exceptions.overflow)
        }

        @Test func `Underflow Property`() {
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.underflow)
            IEEE_754.Exceptions.raise(.underflow)
            #expect(IEEE_754.Exceptions.underflow)
        }

        @Test func `Inexact Property`() {
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.inexact)
            IEEE_754.Exceptions.raise(.inexact)
            #expect(IEEE_754.Exceptions.inexact)
        }
    }
}

extension IEEE_754.Exceptions.Test {
    @Suite("IEEE_754.Exceptions - Flag Enum")
    struct FlagEnum {
        @Test func `Flag Description`() {
            #expect(IEEE_754.Exceptions.Flag.invalid.description == "invalid")
            #expect(IEEE_754.Exceptions.Flag.divisionByZero.description == "divisionByZero")
            #expect(IEEE_754.Exceptions.Flag.overflow.description == "overflow")
            #expect(IEEE_754.Exceptions.Flag.underflow.description == "underflow")
            #expect(IEEE_754.Exceptions.Flag.inexact.description == "inexact")
        }

        @Test func `Flag Equality`() {
            #expect(IEEE_754.Exceptions.Flag.invalid == .invalid)
            #expect(IEEE_754.Exceptions.Flag.invalid != .overflow)
        }

        @Test func `All Cases Count`() {
            #expect(IEEE_754.Exceptions.Flag.allCases.count == 5)
        }

        @Test func `All Cases Contains All`() {
            let allCases = IEEE_754.Exceptions.Flag.allCases
            #expect(allCases.contains(.invalid))
            #expect(allCases.contains(.divisionByZero))
            #expect(allCases.contains(.overflow))
            #expect(allCases.contains(.underflow))
            #expect(allCases.contains(.inexact))
        }
    }
}

extension IEEE_754.Exceptions.Test {
    @Suite("IEEE_754.Exceptions - Idempotency", .serialized)
    struct Idempotency {
        @Test func `Raising Twice Has No Effect`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.invalid)
            #expect(IEEE_754.Exceptions.test(.invalid))

            IEEE_754.Exceptions.raise(.invalid)
            #expect(IEEE_754.Exceptions.test(.invalid))
        }

        @Test func `Clearing Twice Has No Effect`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.overflow)
            IEEE_754.Exceptions.clear(.overflow)
            #expect(!IEEE_754.Exceptions.test(.overflow))

            IEEE_754.Exceptions.clear(.overflow)
            #expect(!IEEE_754.Exceptions.test(.overflow))
        }

        @Test func `Clear All On Empty State Has No Effect`() {
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.raised.any)
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.raised.any)
        }
    }
}

extension IEEE_754.Exceptions.Test {
    @Suite("IEEE_754.Exceptions - Flag Independence", .serialized)
    struct Independence {
        @Test func `Flags Are Independent`() {
            IEEE_754.Exceptions.clear()

            IEEE_754.Exceptions.raise(.invalid)
            #expect(IEEE_754.Exceptions.test(.invalid))
            #expect(!IEEE_754.Exceptions.test(.divisionByZero))
            #expect(!IEEE_754.Exceptions.test(.overflow))
            #expect(!IEEE_754.Exceptions.test(.underflow))
            #expect(!IEEE_754.Exceptions.test(.inexact))

            IEEE_754.Exceptions.raise(.overflow)
            #expect(IEEE_754.Exceptions.test(.invalid))
            #expect(!IEEE_754.Exceptions.test(.divisionByZero))
            #expect(IEEE_754.Exceptions.test(.overflow))
            #expect(!IEEE_754.Exceptions.test(.underflow))
            #expect(!IEEE_754.Exceptions.test(.inexact))
        }

        @Test func `Clearing One Flag Does Not Affect Others`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.invalid)
            IEEE_754.Exceptions.raise(.overflow)
            IEEE_754.Exceptions.raise(.inexact)

            IEEE_754.Exceptions.clear(.overflow)

            #expect(IEEE_754.Exceptions.test(.invalid))
            #expect(!IEEE_754.Exceptions.test(.overflow))
            #expect(IEEE_754.Exceptions.test(.inexact))
        }
    }
}

extension IEEE_754.Exceptions.Test {
    @Suite("IEEE_754.Exceptions - Thread Independence", .serialized)
    struct Thread {
        @Test func `Initial State Is Clean`() {
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.raised.any)
        }

        @Test func `State Can Be Set And Queried`() {
            IEEE_754.Exceptions.clear()
            IEEE_754.Exceptions.raise(.invalid)
            #expect(IEEE_754.Exceptions.test(.invalid))
            IEEE_754.Exceptions.clear()
            #expect(!IEEE_754.Exceptions.test(.invalid))
        }

        @Test func `Raised Flag Is Visible Across Sibling Tasks Without An Explicit Scope`() async {
            IEEE_754.Exceptions.clear()

            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    IEEE_754.Exceptions.raise(.divisionByZero)
                }
            }

            #expect(IEEE_754.Exceptions.test(.divisionByZero))

            IEEE_754.Exceptions.clear()
        }
    }
}

#if IEEE_754_SHIMS
    import IEEE_754_Shims

    extension IEEE_754.Exceptions.Test {
        @Suite("IEEE_754.Exceptions - Single Store Discipline", .serialized)
        struct SingleStoreDiscipline {
            @Test func `Raise Does Not Leak Into C Shim Thread Local Store`() {
                ieee754_clear_all_exceptions()
                IEEE_754.Exceptions.clear()

                IEEE_754.Exceptions.raise(.overflow)

                #expect(IEEE_754.Exceptions.test(.overflow))
                #expect(
                    ieee754_test_exception(IEEE754_EXCEPTION_OVERFLOW) == 0,
                    "raise(_:) must write exactly one store; the C-shim thread-local store must stay untouched."
                )

                ieee754_clear_all_exceptions()
            }

            @Test func `C Shim Thread Local Raise Is Not Visible Through Swift Test`() {
                ieee754_clear_all_exceptions()
                IEEE_754.Exceptions.clear()

                ieee754_raise_exception(IEEE754_EXCEPTION_INVALID)

                #expect(
                    !IEEE_754.Exceptions.test(.invalid),
                    "test(_:) must read exactly one store; it must not observe the separate C-shim thread-local store."
                )

                ieee754_clear_all_exceptions()
            }

            @Test func `Clear Does Not Touch C Shim Thread Local Store`() {
                ieee754_clear_all_exceptions()
                IEEE_754.Exceptions.clear()

                ieee754_raise_exception(IEEE754_EXCEPTION_UNDERFLOW)
                IEEE_754.Exceptions.raise(.underflow)
                IEEE_754.Exceptions.clear(.underflow)

                #expect(!IEEE_754.Exceptions.test(.underflow))
                #expect(
                    ieee754_test_exception(IEEE754_EXCEPTION_UNDERFLOW) == 1,
                    "clear(_:) must clear exactly the Swift-side store; the C-shim thread-local store is separate and opt-in."
                )

                ieee754_clear_all_exceptions()
            }
        }
    }
#endif
