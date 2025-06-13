#ifndef _DEADLINETEST_MAIN_H
#define _DEADLINETEST_MAIN_H
#include "include/core/reactor.h"
#include "_source.h"
#include "_destination.h"
#ifndef TOP_LEVEL_PREAMBLE_16196099_H
#define TOP_LEVEL_PREAMBLE_16196099_H
#include <time.h>
#include "platform.h"
#include <stdio.h>
#include <stdlib.h>
static inline long get_time_ns() {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return ts.tv_sec * 1000000000L + ts.tv_nsec;
}
#endif
typedef struct {
    struct self_base_t base;
#line 21 "/home/tajim/dev/DeadlineTest/src-gen/DeadlineTest/_deadlinetest_main.h"
#line 22 "/home/tajim/dev/DeadlineTest/src-gen/DeadlineTest/_deadlinetest_main.h"
} _deadlinetest_main_main_self_t;
_deadlinetest_main_main_self_t* new__deadlinetest_main();
#endif // _DEADLINETEST_MAIN_H
