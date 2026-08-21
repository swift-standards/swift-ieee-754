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

#endif
