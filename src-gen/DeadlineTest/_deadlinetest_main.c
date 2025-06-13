#include "include/api/schedule.h"
#include "low_level_platform/api/low_level_platform.h"
#include "include/DeadlineTest/DeadlineTest.h"
#include "_deadlinetest_main.h"
// ***** Start of method declarations.
// ***** End of method declarations.
_deadlinetest_main_main_self_t* new__deadlinetest_main() {
    _deadlinetest_main_main_self_t* self = (_deadlinetest_main_main_self_t*)lf_new_reactor(sizeof(_deadlinetest_main_main_self_t));

    return self;
}
