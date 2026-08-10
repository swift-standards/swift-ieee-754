// fpu_rounding.c
// CIEEE754
//
// IEEE 754-2019 Section 4.3: Rounding Direction Attributes

// The CIEEE754 FPU shim is POSIX/Darwin-only (fenv.h, pthreads). It is not a
// dependency of the "IEEE 754" target on Windows (see Package.swift + the
// IEEE_754_SHIMS define), so compile this translation unit empty there rather
// than fail on the unavailable <pthread.h>/<fenv.h> surface.
#if !defined(_WIN32)

#include "include/ieee754_fpu.h"
#include <fenv.h>

// Map IEEE754RoundingMode to C99 fesetround constants
static int ieee754_to_fe_round(IEEE754RoundingMode mode) {
    switch (mode) {
        case IEEE754_ROUND_TONEAREST:
            return FE_TONEAREST;
        case IEEE754_ROUND_DOWNWARD:
            return FE_DOWNWARD;
        case IEEE754_ROUND_UPWARD:
            return FE_UPWARD;
        case IEEE754_ROUND_TOWARDZERO:
            return FE_TOWARDZERO;
        default:
            return FE_TONEAREST;
    }
}

// Map C99 fegetround constants to IEEE754RoundingMode
static IEEE754RoundingMode fe_round_to_ieee754(int fe_mode) {
    switch (fe_mode) {
        case FE_TONEAREST:
            return IEEE754_ROUND_TONEAREST;
        case FE_DOWNWARD:
            return IEEE754_ROUND_DOWNWARD;
        case FE_UPWARD:
            return IEEE754_ROUND_UPWARD;
        case FE_TOWARDZERO:
            return IEEE754_ROUND_TOWARDZERO;
        default:
            return IEEE754_ROUND_TONEAREST;
    }
}

int ieee754_set_rounding_mode(IEEE754RoundingMode mode) {
    int fe_mode = ieee754_to_fe_round(mode);
    return fesetround(fe_mode);
}

IEEE754RoundingMode ieee754_get_rounding_mode(void) {
    int fe_mode = fegetround();
    return fe_round_to_ieee754(fe_mode);
}

#endif  // !defined(_WIN32)
