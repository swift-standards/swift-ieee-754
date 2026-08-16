// signaling_compare.c
// IEEE 754 Shims
//
// IEEE 754-2019 Section 5.6.1: Signaling Comparison Predicates

// The IEEE 754 Shims FPU shim is POSIX/Darwin-only (fenv.h, pthreads). It is not a
// dependency of the "IEEE 754" target on Windows (see Package.swift + the
// IEEE_754_SHIMS define), so compile this translation unit empty there rather
// than fail on the unavailable <pthread.h>/<fenv.h> surface.
#if !defined(_WIN32)

#include "include/ieee754_fpu.h"
#include <fenv.h>
#include <math.h>

// =============================================================================
// MARK: - Double (binary64) Signaling Comparisons
// =============================================================================

int ieee754_signaling_equal(double x, double y) {
    // Check for NaN - if either is NaN, raise invalid exception
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;  // IEEE 754: NaN comparisons always return false
    }

    return x == y;
}

int ieee754_signaling_less(double x, double y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;
    }

    return x < y;
}

int ieee754_signaling_less_equal(double x, double y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;
    }

    return x <= y;
}

int ieee754_signaling_greater(double x, double y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;
    }

    return x > y;
}

int ieee754_signaling_greater_equal(double x, double y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;
    }

    return x >= y;
}

int ieee754_signaling_not_equal(double x, double y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 1;  // IEEE 754: NaN is not equal to anything (including itself)
    }

    return x != y;
}

// =============================================================================
// MARK: - Float (binary32) Signaling Comparisons
// =============================================================================

int ieee754_signaling_equal_f(float x, float y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;
    }

    return x == y;
}

int ieee754_signaling_less_f(float x, float y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;
    }

    return x < y;
}

int ieee754_signaling_less_equal_f(float x, float y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;
    }

    return x <= y;
}

int ieee754_signaling_greater_f(float x, float y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;
    }

    return x > y;
}

int ieee754_signaling_greater_equal_f(float x, float y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;
    }

    return x >= y;
}

int ieee754_signaling_not_equal_f(float x, float y) {
    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 1;
    }

    return x != y;
}

#endif  // !defined(_WIN32)
