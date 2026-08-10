// fpu_exceptions.c
// CIEEE754
//
// IEEE 754-2019 Section 7: Hardware FPU Exception Detection

// The CIEEE754 FPU shim is POSIX/Darwin-only (fenv.h, pthreads). It is not a
// dependency of the "IEEE 754" target on Windows (see Package.swift + the
// IEEE_754_SHIMS define), so compile this translation unit empty there rather
// than fail on the unavailable <pthread.h>/<fenv.h> surface.
#if !defined(_WIN32)

#include "include/ieee754_fpu.h"
#include <fenv.h>

IEEE754Exceptions ieee754_test_fpu_exceptions(void) {
    int flags = fetestexcept(FE_ALL_EXCEPT);

    IEEE754Exceptions ex;
    ex.invalid = (flags & FE_INVALID) ? 1 : 0;
    ex.divByZero = (flags & FE_DIVBYZERO) ? 1 : 0;
    ex.overflow = (flags & FE_OVERFLOW) ? 1 : 0;
    ex.underflow = (flags & FE_UNDERFLOW) ? 1 : 0;
    ex.inexact = (flags & FE_INEXACT) ? 1 : 0;

    return ex;
}

void ieee754_clear_fpu_exceptions(void) {
    feclearexcept(FE_ALL_EXCEPT);
}

#endif  // !defined(_WIN32)
