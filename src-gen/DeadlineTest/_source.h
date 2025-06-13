#ifndef _SOURCE_H
#define _SOURCE_H
#include "include/core/reactor.h"
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
    token_type_t type;
    lf_token_t* token;
    size_t length;
    bool is_present;
    lf_port_internal_t _base;
    int64_t value;
    #ifdef FEDERATED
    #ifdef FEDERATED_DECENTRALIZED
    tag_t intended_tag;
    #endif
    interval_t physical_time_of_arrival;
    #endif
} _source_y_t;
typedef struct {
    struct self_base_t base;
    #line 17 "/home/tajim/dev/DeadlineTest/src/DeadlineTest.lf"
    interval_t period;
#line 35 "/home/tajim/dev/DeadlineTest/src-gen/DeadlineTest/_source.h"
    #line 21 "/home/tajim/dev/DeadlineTest/src/DeadlineTest.lf"
    int count;
    #line 22 "/home/tajim/dev/DeadlineTest/src/DeadlineTest.lf"
    int64_t last_send_time;
#line 40 "/home/tajim/dev/DeadlineTest/src-gen/DeadlineTest/_source.h"
    _source_y_t _lf_y;
    int _lf_y_width;
    reaction_t _lf__reaction_0;
    trigger_t _lf__t;
    reaction_t* _lf__t_reactions[1];
} _source_self_t;
_source_self_t* new__source();
#endif // _SOURCE_H
