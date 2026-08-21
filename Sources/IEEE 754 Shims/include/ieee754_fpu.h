#ifndef IEEE754_FPU_H
#define IEEE754_FPU_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {

    IEEE754_ROUND_TONEAREST = 0,

    IEEE754_ROUND_DOWNWARD = 1,

    IEEE754_ROUND_UPWARD = 2,

    IEEE754_ROUND_TOWARDZERO = 3
} IEEE754RoundingMode;

int ieee754_set_rounding_mode(IEEE754RoundingMode mode);

IEEE754RoundingMode ieee754_get_rounding_mode(void);

typedef struct {

    uint8_t invalid;

    uint8_t divByZero;

    uint8_t overflow;

    uint8_t underflow;

    uint8_t inexact;
} IEEE754Exceptions;

typedef enum {
    IEEE754_EXCEPTION_INVALID = 0,
    IEEE754_EXCEPTION_DIVBYZERO = 1,
    IEEE754_EXCEPTION_OVERFLOW = 2,
    IEEE754_EXCEPTION_UNDERFLOW = 3,
    IEEE754_EXCEPTION_INEXACT = 4
} IEEE754ExceptionFlag;

void ieee754_raise_exception(IEEE754ExceptionFlag flag);

int ieee754_test_exception(IEEE754ExceptionFlag flag);

void ieee754_clear_exception(IEEE754ExceptionFlag flag);

IEEE754Exceptions ieee754_get_exceptions(void);

void ieee754_clear_all_exceptions(void);

IEEE754Exceptions ieee754_test_fpu_exceptions(void);

void ieee754_clear_fpu_exceptions(void);

int ieee754_signaling_equal(double x, double y);

int ieee754_signaling_less(double x, double y);

int ieee754_signaling_less_equal(double x, double y);

int ieee754_signaling_greater(double x, double y);

int ieee754_signaling_greater_equal(double x, double y);

int ieee754_signaling_not_equal(double x, double y);

int ieee754_signaling_equal_f(float x, float y);
int ieee754_signaling_less_f(float x, float y);
int ieee754_signaling_less_equal_f(float x, float y);
int ieee754_signaling_greater_f(float x, float y);
int ieee754_signaling_greater_equal_f(float x, float y);
int ieee754_signaling_not_equal_f(float x, float y);

#ifdef __cplusplus
}
#endif

#endif
