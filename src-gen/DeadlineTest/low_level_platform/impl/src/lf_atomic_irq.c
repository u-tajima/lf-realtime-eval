/**
 * @file
 * @author Erling Rennemo Jellum
 * @brief Implements the atomics API by disabling interrupts. Typically used for platforms that
 * do not support atomic operations.
 *
 * The platforms need to implement `lf_enable_interrupts_nested`
 * and `lf_disable_interrupts_nested`.
 */
#if defined(PLATFORM_ARDUINO) || defined(PLATFORM_NRF52) || defined(PLATFORM_ZEPHYR) || defined(PLATFORM_RP2040) ||    \
    defined(PLATFORM_FLEXPRET) || defined(PLATFORM_PATMOS)

#include "platform/lf_atomic.h"
#include "low_level_platform.h"

// Forward declare the functions for enabling/disabling interrupts. Must be
// implemented in the platform support file of the target.
int lf_disable_interrupts_nested();
int lf_enable_interrupts_nested();

int lf_atomic_fetch_add(int* ptr, int value) {
  lf_disable_interrupts_nested();
  int res = *ptr;
  *ptr += value;
  lf_enable_interrupts_nested();
  return res;
}

int64_t lf_atomic_fetch_add64(int64_t* ptr, int64_t value) {
  lf_disable_interrupts_nested();
  int64_t res = *ptr;
  *ptr += value;
  lf_enable_interrupts_nested();
  return res;
}

int lf_atomic_add_fetch(int* ptr, int value) {
  lf_disable_interrupts_nested();
  int res = *ptr + value;
  *ptr = res;
  lf_enable_interrupts_nested();
  return res;
}

int64_t lf_atomic_add_fetch64(int64_t* ptr, int64_t value) {
  lf_disable_interrupts_nested();
  int64_t res = *ptr + value;
  *ptr = res;
  lf_enable_interrupts_nested();
  return res;
}

bool lf_atomic_bool_compare_and_swap(int* ptr, int oldval, int newval) {
  lf_disable_interrupts_nested();
  bool res = false;
  if ((*ptr) == oldval) {
    *ptr = newval;
    res = true;
  }
  lf_enable_interrupts_nested();
  return res;
}

bool lf_atomic_bool_compare_and_swap64(int64_t* ptr, int64_t oldval, int64_t newval) {
  lf_disable_interrupts_nested();
  bool res = false;
  if ((*ptr) == oldval) {
    *ptr = newval;
    res = true;
  }
  lf_enable_interrupts_nested();
  return res;
}

int lf_atomic_val_compare_and_swap(int* ptr, int oldval, int newval) {
  lf_disable_interrupts_nested();
  int res = *ptr;
  if ((*ptr) == oldval) {
    *ptr = newval;
  }
  lf_enable_interrupts_nested();
  return res;
}

int64_t lf_atomic_val_compare_and_swap64(int64_t* ptr, int64_t oldval, int64_t newval) {
  lf_disable_interrupts_nested();
  int64_t res = *ptr;
  if ((*ptr) == oldval) {
    *ptr = newval;
  }
  lf_enable_interrupts_nested();
  return res;
}

#endif
