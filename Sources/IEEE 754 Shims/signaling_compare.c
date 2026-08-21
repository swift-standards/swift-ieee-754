#if !defined(_WIN32)

#include "include/ieee754_fpu.h"
#include <fenv.h>
#include <math.h>

int ieee754_signaling_equal(double x, double y) {

    if (isnan(x) || isnan(y)) {
        feraiseexcept(FE_INVALID);
        ieee754_raise_exception(IEEE754_EXCEPTION_INVALID);
        return 0;
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
        return 1;
    }

    return x != y;
}

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

#endif
