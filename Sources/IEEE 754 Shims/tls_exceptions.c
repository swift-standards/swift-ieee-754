#if !defined(_WIN32)

#include "include/ieee754_fpu.h"
#include <pthread.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    uint8_t invalid;
    uint8_t divByZero;
    uint8_t overflow;
    uint8_t underflow;
    uint8_t inexact;
} ThreadExceptionState;

static pthread_key_t exception_key;
static pthread_once_t key_once = PTHREAD_ONCE_INIT;

static void cleanup_thread_exceptions(void* state) {
    free(state);
}

static void make_exception_key(void) {
    pthread_key_create(&exception_key, cleanup_thread_exceptions);
}

static ThreadExceptionState* get_thread_state(void) {
    pthread_once(&key_once, make_exception_key);

    ThreadExceptionState* state = pthread_getspecific(exception_key);
    if (!state) {
        state = calloc(1, sizeof(ThreadExceptionState));
        pthread_setspecific(exception_key, state);
    }

    return state;
}

void ieee754_raise_exception(IEEE754ExceptionFlag flag) {
    ThreadExceptionState* state = get_thread_state();

    switch (flag) {
        case IEEE754_EXCEPTION_INVALID:
            state->invalid = 1;
            break;
        case IEEE754_EXCEPTION_DIVBYZERO:
            state->divByZero = 1;
            break;
        case IEEE754_EXCEPTION_OVERFLOW:
            state->overflow = 1;
            break;
        case IEEE754_EXCEPTION_UNDERFLOW:
            state->underflow = 1;
            break;
        case IEEE754_EXCEPTION_INEXACT:
            state->inexact = 1;
            break;
    }
}

int ieee754_test_exception(IEEE754ExceptionFlag flag) {
    ThreadExceptionState* state = get_thread_state();

    switch (flag) {
        case IEEE754_EXCEPTION_INVALID:
            return state->invalid;
        case IEEE754_EXCEPTION_DIVBYZERO:
            return state->divByZero;
        case IEEE754_EXCEPTION_OVERFLOW:
            return state->overflow;
        case IEEE754_EXCEPTION_UNDERFLOW:
            return state->underflow;
        case IEEE754_EXCEPTION_INEXACT:
            return state->inexact;
        default:
            return 0;
    }
}

void ieee754_clear_exception(IEEE754ExceptionFlag flag) {
    ThreadExceptionState* state = get_thread_state();

    switch (flag) {
        case IEEE754_EXCEPTION_INVALID:
            state->invalid = 0;
            break;
        case IEEE754_EXCEPTION_DIVBYZERO:
            state->divByZero = 0;
            break;
        case IEEE754_EXCEPTION_OVERFLOW:
            state->overflow = 0;
            break;
        case IEEE754_EXCEPTION_UNDERFLOW:
            state->underflow = 0;
            break;
        case IEEE754_EXCEPTION_INEXACT:
            state->inexact = 0;
            break;
    }
}

IEEE754Exceptions ieee754_get_exceptions(void) {
    ThreadExceptionState* state = get_thread_state();

    IEEE754Exceptions ex;
    ex.invalid = state->invalid;
    ex.divByZero = state->divByZero;
    ex.overflow = state->overflow;
    ex.underflow = state->underflow;
    ex.inexact = state->inexact;

    return ex;
}

void ieee754_clear_all_exceptions(void) {
    ThreadExceptionState* state = get_thread_state();
    memset(state, 0, sizeof(ThreadExceptionState));
}

#endif
