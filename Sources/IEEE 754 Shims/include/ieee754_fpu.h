#ifndef IEEE754_FPU_H
#define IEEE754_FPU_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// =============================================================================
// MARK: - Rounding Modes
// =============================================================================

/// IEEE 754-2019 Rounding Direction Attributes (Section 4.3)
///
/// Maps to C99 fesetround() rounding modes from <fenv.h>
typedef enum {
    /// Round to nearest, ties to even (roundTiesToEven)
    /// Default rounding mode - IEEE 754-2019 Section 4.3.1
    IEEE754_ROUND_TONEAREST = 0,

    /// Round toward negative infinity (roundTowardNegative)
    /// IEEE 754-2019 Section 4.3.2
    IEEE754_ROUND_DOWNWARD = 1,

    /// Round toward positive infinity (roundTowardPositive)
    /// IEEE 754-2019 Section 4.3.2
    IEEE754_ROUND_UPWARD = 2,

    /// Round toward zero (roundTowardZero)
    /// IEEE 754-2019 Section 4.3.2
    IEEE754_ROUND_TOWARDZERO = 3
} IEEE754RoundingMode;

/// Set the floating-point rounding mode for the current thread
///
/// Changes the FPU rounding direction for all subsequent floating-point
/// operations in the current thread.
///
/// - Parameter mode: The rounding mode to set
/// - Returns: 0 on success, non-zero on error
///
/// IEEE 754-2019 Section 4.3.3: "Users can change the rounding direction"
int ieee754_set_rounding_mode(IEEE754RoundingMode mode);

/// Get the current floating-point rounding mode
///
/// - Returns: The current rounding mode
IEEE754RoundingMode ieee754_get_rounding_mode(void);

// =============================================================================
// MARK: - Exception Flags
// =============================================================================

/// IEEE 754-2019 Exception Flags (Section 7)
///
/// Each field is 0 (not raised) or 1 (raised)
typedef struct {
    /// Invalid operation (Section 7.2)
    /// Examples: sqrt(-1), 0/0, ∞-∞, operations on signaling NaN
    uint8_t invalid;

    /// Division by zero (Section 7.3)
    /// Examples: finite/0.0 → ±∞
    uint8_t divByZero;

    /// Overflow (Section 7.4)
    /// Result too large to represent
    uint8_t overflow;

    /// Underflow (Section 7.5)
    /// Non-zero result too small to represent as normal
    uint8_t underflow;

    /// Inexact (Section 7.6)
    /// Rounded result differs from exact mathematical result
    uint8_t inexact;
} IEEE754Exceptions;

/// Exception flag identifiers for individual operations
typedef enum {
    IEEE754_EXCEPTION_INVALID = 0,
    IEEE754_EXCEPTION_DIVBYZERO = 1,
    IEEE754_EXCEPTION_OVERFLOW = 2,
    IEEE754_EXCEPTION_UNDERFLOW = 3,
    IEEE754_EXCEPTION_INEXACT = 4
} IEEE754ExceptionFlag;

// =============================================================================
// MARK: - Thread-Local Exception State
// =============================================================================

/// Raise an exception flag in thread-local storage
///
/// Sets the specified exception flag for the current thread.
///
/// - Parameter flag: The exception flag to raise (0-4)
///
/// Note: This manages thread-local software exception state, separate from
/// hardware FPU exception flags.
void ieee754_raise_exception(IEEE754ExceptionFlag flag);

/// Test if an exception flag is raised in thread-local storage
///
/// - Parameter flag: The exception flag to test (0-4)
/// - Returns: 1 if raised, 0 if not raised
int ieee754_test_exception(IEEE754ExceptionFlag flag);

/// Clear a specific exception flag in thread-local storage
///
/// - Parameter flag: The exception flag to clear (0-4)
void ieee754_clear_exception(IEEE754ExceptionFlag flag);

/// Get all thread-local exception flags
///
/// - Returns: Structure containing all exception flag states
IEEE754Exceptions ieee754_get_exceptions(void);

/// Clear all thread-local exception flags
void ieee754_clear_all_exceptions(void);

// =============================================================================
// MARK: - Hardware FPU Exception Detection
// =============================================================================

/// Test hardware FPU exception flags
///
/// Queries the FPU's exception status register for raised exceptions.
/// This detects exceptions from actual floating-point operations.
///
/// - Returns: Structure containing hardware exception states
///
/// Note: Call this immediately after an operation to detect exceptions.
/// The FPU exception flags persist until explicitly cleared.
IEEE754Exceptions ieee754_test_fpu_exceptions(void);

/// Clear hardware FPU exception flags
///
/// Resets all exception flags in the FPU status register.
void ieee754_clear_fpu_exceptions(void);

// =============================================================================
// MARK: - Signaling Comparisons
// =============================================================================

/// Signaling equality comparison
///
/// Returns 1 if x == y, 0 otherwise.
/// Raises invalid exception if either operand is NaN (quiet or signaling).
///
/// - Parameters:
///   - x: First operand
///   - y: Second operand
/// - Returns: 1 if equal, 0 otherwise
///
/// IEEE 754-2019 Section 5.6.1: compareSignalingEqual
int ieee754_signaling_equal(double x, double y);

/// Signaling less-than comparison
///
/// Returns 1 if x < y, 0 otherwise.
/// Raises invalid exception if either operand is NaN.
///
/// IEEE 754-2019 Section 5.6.1: compareSignalingLess
int ieee754_signaling_less(double x, double y);

/// Signaling less-than-or-equal comparison
///
/// Returns 1 if x <= y, 0 otherwise.
/// Raises invalid exception if either operand is NaN.
///
/// IEEE 754-2019 Section 5.6.1: compareSignalingLessEqual
int ieee754_signaling_less_equal(double x, double y);

/// Signaling greater-than comparison
///
/// Returns 1 if x > y, 0 otherwise.
/// Raises invalid exception if either operand is NaN.
///
/// IEEE 754-2019 Section 5.6.1: compareSignalingGreater
int ieee754_signaling_greater(double x, double y);

/// Signaling greater-than-or-equal comparison
///
/// Returns 1 if x >= y, 0 otherwise.
/// Raises invalid exception if either operand is NaN.
///
/// IEEE 754-2019 Section 5.6.1: compareSignalingGreaterEqual
int ieee754_signaling_greater_equal(double x, double y);

/// Signaling not-equal comparison
///
/// Returns 1 if x != y, 0 otherwise.
/// Raises invalid exception if either operand is NaN.
///
/// IEEE 754-2019 Section 5.6.1: compareSignalingNotEqual
int ieee754_signaling_not_equal(double x, double y);

// =============================================================================
// MARK: - Float Variants
// =============================================================================

/// Float (binary32) signaling comparisons
int ieee754_signaling_equal_f(float x, float y);
int ieee754_signaling_less_f(float x, float y);
int ieee754_signaling_less_equal_f(float x, float y);
int ieee754_signaling_greater_f(float x, float y);
int ieee754_signaling_greater_equal_f(float x, float y);
int ieee754_signaling_not_equal_f(float x, float y);

#ifdef __cplusplus
}
#endif

#endif // IEEE754_FPU_H
