// IEEE_754.Exceptions.swift
// swift-ieee-754
//
// IEEE 754-2019 Section 7: Exception Handling
// Authoritative implementations for IEEE 754 exception flags

public import Dependency_Primitives
public import Synchronization

// MARK: - IEEE 754 Exception Handling

extension IEEE_754 {
    /// IEEE 754 Exception Handling (Section 7)
    ///
    /// Implements the five exception flags defined in IEEE 754-2019 Section 7.
    ///
    /// ## Overview
    ///
    /// The IEEE 754 standard defines five exceptional conditions that can occur
    /// during floating-point operations:
    ///
    /// - **Invalid Operation**: Domain errors (e.g., sqrt(-1), 0/0, ∞-∞)
    /// - **Division by Zero**: Finite non-zero ÷ zero
    /// - **Overflow**: Result too large to represent
    /// - **Underflow**: Non-zero result too small to represent as normal
    /// - **Inexact**: Rounded result differs from exact mathematical result
    ///
    /// ## Thread Safety
    ///
    /// Exception state is maintained in a thread-safe shared store using Swift's
    /// Synchronization.Mutex (Foundation-free). All operations are atomic and safe
    /// to call from multiple threads.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Test exception flags
    /// if IEEE_754.Exceptions.test(.invalid) {
    ///     print("Invalid operation detected")
    /// }
    ///
    /// // Clear all flags
    /// IEEE_754.Exceptions.clear()
    ///
    /// // Clear specific flag
    /// IEEE_754.Exceptions.clear(.overflow)
    ///
    /// // Check if any exception is raised
    /// if IEEE_754.Exceptions.raised.any {
    ///     print("Some exception occurred")
    /// }
    /// ```
    ///
    /// ## Limitations
    ///
    /// Swift's standard floating-point operations do not raise IEEE 754 exceptions.
    /// This implementation provides:
    /// - Manual exception flag setting for user operations
    /// - A single, portable exception-flag store shared by every thread and task
    /// - Query and clear operations
    ///
    /// To integrate with actual operations, wrap arithmetic operations with
    /// result checking and manual flag raising.
    ///
    /// ## Store Model
    ///
    /// `raise`/`test`/`clear` read and write **exactly one** store: the
    /// `Synchronization.Mutex`-protected `ExceptionState` resolved through
    /// `Dependency.Scope`. Outside an explicitly-established test scope this
    /// resolves to a single process-global instance — the flags are **not**
    /// thread-local; raising a flag on one thread or task is immediately
    /// visible to every other thread and task that reads it. Inside an
    /// explicit test scope (`Dependency.Scope` with `isTestContext == true`),
    /// each scope gets its own isolated instance; that scope is inherited by
    /// structured child `Task {}`s but is **not** inherited by a manually
    /// spawned `Thread`/`pthread_create`.
    ///
    /// The optional C shim (`IEEE_754_SHIMS`) additionally exposes genuinely
    /// per-OS-thread exception flags (`ieee754_raise_exception` /
    /// `ieee754_test_exception` / `ieee754_clear_exception`, backed by
    /// `pthread_getspecific`) and hardware FPU flags
    /// (`ieee754_test_fpu_exceptions`, backed by `<fenv.h>`). Neither is read
    /// nor written by `raise`/`test`/`clear` above — they are separate,
    /// opt-in stores for callers who specifically need OS-thread-local or
    /// hardware-FPU semantics. Because they are keyed to the OS thread and
    /// not the Swift task, they are unsound to rely on across a suspension
    /// point: a `Task` may resume on a different OS thread after `await`,
    /// silently reading a different thread's flags.
    ///
    /// ## See Also
    ///
    /// - IEEE 754-2019 Section 7: Exceptions
    /// - IEEE 754-2019 Section 8: Alternate exception handling attributes
    public enum Exceptions {}
}

// MARK: - Exception Flag Type

extension IEEE_754.Exceptions {
    /// IEEE 754 Exception Flags
    ///
    /// Hierarchical structure for the five IEEE 754 exception types.
    ///
    /// ## Exception Types
    ///
    /// - `invalid`: Invalid operation (domain error)
    /// - `divisionByZero`: Division of finite non-zero by zero
    /// - `overflow`: Result exceeds maximum representable value
    /// - `underflow`: Non-zero result smaller than minimum normal
    /// - `inexact`: Rounded result differs from exact result
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Raise an exception
    /// IEEE_754.Exceptions.raise(.invalid)
    ///
    /// // Test for exception
    /// if IEEE_754.Exceptions.test(.overflow) {
    ///     // Handle overflow
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - IEEE 754-2019 Section 7.2: Invalid operation
    /// - IEEE 754-2019 Section 7.3: Division by zero
    /// - IEEE 754-2019 Section 7.4: Overflow
    /// - IEEE 754-2019 Section 7.5: Underflow
    /// - IEEE 754-2019 Section 7.6: Inexact
    public enum Flag: Sendable, Equatable, CaseIterable {
        /// Invalid operation exception (IEEE 754-2019 Section 7.2)
        ///
        /// Raised for operations with invalid operands, such as:
        /// - sqrt(-1)
        /// - 0.0 / 0.0
        /// - ∞ - ∞
        /// - ∞ / ∞
        /// - 0.0 * ∞
        /// - Invalid conversions
        case invalid

        /// Division by zero exception (IEEE 754-2019 Section 7.3)
        ///
        /// Raised when dividing a finite non-zero number by zero:
        /// - 1.0 / 0.0 → +∞
        /// - -1.0 / 0.0 → -∞
        case divisionByZero

        /// Overflow exception (IEEE 754-2019 Section 7.4)
        ///
        /// Raised when the result magnitude is too large to represent:
        /// - Double.greatestFiniteMagnitude * 2.0
        /// - exp(1000)
        case overflow

        /// Underflow exception (IEEE 754-2019 Section 7.5)
        ///
        /// Raised when a non-zero result is too small to represent as normal:
        /// - Double.leastNormalMagnitude / 2.0
        /// - Results in subnormal range
        case underflow

        /// Inexact exception (IEEE 754-2019 Section 7.6)
        ///
        /// Raised when the result differs from the exact mathematical result:
        /// - 1.0 / 3.0 (cannot be represented exactly)
        /// - Any operation requiring rounding
        case inexact
    }
}

// MARK: - Flag CustomStringConvertible

extension IEEE_754.Exceptions.Flag: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalid: return "invalid"
        case .divisionByZero: return "divisionByZero"
        case .overflow: return "overflow"
        case .underflow: return "underflow"
        case .inexact: return "inexact"
        }
    }
}

// MARK: - Exception State Store

extension IEEE_754.Exceptions {
    /// Exception state container
    @usableFromInline
    final class ExceptionState: @unchecked Sendable {
        @usableFromInline
        let state: Mutex<Flags> = Mutex(Flags())

        @usableFromInline
        init() {}
    }

    /// Exception state resolved from dependency scope.
    ///
    /// In live context, returns the process-global instance.
    /// In test context, returns a fresh per-scope instance for isolation.
    @usableFromInline
    static var state: ExceptionState {
        Dependency.Scope.current[ExceptionState.self]
    }
}

extension IEEE_754.Exceptions.ExceptionState {
    @usableFromInline
    struct Flags {
        var invalid: Bool = false
        var divisionByZero: Bool = false
        var overflow: Bool = false
        var underflow: Bool = false
        var inexact: Bool = false
    }

    /// Process-global exception state (backward compatible).
    @usableFromInline
    static let _global = IEEE_754.Exceptions.ExceptionState()
}

// MARK: - ExceptionState Dependency.Key

extension IEEE_754.Exceptions.ExceptionState: Dependency.Key {
    @usableFromInline
    typealias Value = IEEE_754.Exceptions.ExceptionState

    @usableFromInline
    static var liveValue: IEEE_754.Exceptions.ExceptionState { _global }

    @usableFromInline
    static var testValue: IEEE_754.Exceptions.ExceptionState { .init() }
}

// MARK: - ExceptionState Methods

extension IEEE_754.Exceptions.ExceptionState {
    @usableFromInline
    func set(_ flag: IEEE_754.Exceptions.Flag) {
        state.withLock { flags in
            switch flag {
            case .invalid: flags.invalid = true
            case .divisionByZero: flags.divisionByZero = true
            case .overflow: flags.overflow = true
            case .underflow: flags.underflow = true
            case .inexact: flags.inexact = true
            }
        }
    }

    @usableFromInline
    func clear(_ flag: IEEE_754.Exceptions.Flag) {
        state.withLock { flags in
            switch flag {
            case .invalid: flags.invalid = false
            case .divisionByZero: flags.divisionByZero = false
            case .overflow: flags.overflow = false
            case .underflow: flags.underflow = false
            case .inexact: flags.inexact = false
            }
        }
    }

    @usableFromInline
    func get(_ flag: IEEE_754.Exceptions.Flag) -> Bool {
        state.withLock { flags in
            switch flag {
            case .invalid: return flags.invalid
            case .divisionByZero: return flags.divisionByZero
            case .overflow: return flags.overflow
            case .underflow: return flags.underflow
            case .inexact: return flags.inexact
            }
        }
    }

    @usableFromInline
    func clearAll() {
        state.withLock { flags in
            flags.invalid = false
            flags.divisionByZero = false
            flags.overflow = false
            flags.underflow = false
            flags.inexact = false
        }
    }
}

// MARK: - Exception Operations

extension IEEE_754.Exceptions {
    /// Raise an exception flag
    ///
    /// Sets the specified exception flag.
    ///
    /// - Parameter flag: The exception flag to raise
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Exceptions.raise(.invalid)
    /// ```
    ///
    /// Note: This operation is thread-safe. It operates on exactly one store
    /// (see "Store Model" on `IEEE_754.Exceptions`); it does not touch the
    /// separate, opt-in C-shim thread-local or hardware FPU flags.
    public static func raise(_ flag: Flag) {
        state.set(flag)
    }

    /// Test if an exception flag is raised
    ///
    /// Checks whether the specified exception flag is currently set.
    ///
    /// - Parameter flag: The exception flag to test
    /// - Returns: true if the flag is raised, false otherwise
    ///
    /// Example:
    /// ```swift
    /// if IEEE_754.Exceptions.test(.overflow) {
    ///     print("Overflow occurred")
    /// }
    /// ```
    public static func test(_ flag: Flag) -> Bool {
        state.get(flag)
    }

    /// Clear an exception flag
    ///
    /// Resets the specified exception flag.
    ///
    /// - Parameter flag: The exception flag to clear
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Exceptions.clear(.overflow)
    /// ```
    public static func clear(_ flag: Flag) {
        state.clear(flag)
    }

    /// Clear all exception flags
    ///
    /// Resets all five exception flags to their initial (unraised) state.
    ///
    /// Example:
    /// ```swift
    /// IEEE_754.Exceptions.clear()
    /// ```
    public static func clear() {
        state.clearAll()
    }

}

// MARK: - Compatibility Properties

extension IEEE_754.Exceptions {
    /// Check if invalid operation exception is raised
    @inlinable
    public static var invalidOperation: Bool {
        test(.invalid)
    }

    /// Check if division by zero exception is raised
    @inlinable
    public static var divisionByZero: Bool {
        test(.divisionByZero)
    }

    /// Check if overflow exception is raised
    @inlinable
    public static var overflow: Bool {
        test(.overflow)
    }

    /// Check if underflow exception is raised
    @inlinable
    public static var underflow: Bool {
        test(.underflow)
    }

    /// Check if inexact exception is raised
    @inlinable
    public static var inexact: Bool {
        test(.inexact)
    }
}
