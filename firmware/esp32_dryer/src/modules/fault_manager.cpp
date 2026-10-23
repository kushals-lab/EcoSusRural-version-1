// fault_manager.cpp - ring-buffer fault log with dedupe + active mask.
#include "modules/fault_manager.h"

void FaultManager::begin() {
  head_ = 0; count_ = 0; activeMask_ = 0;
}

void FaultManager::raise(FaultCode c) {
  uint16_t bit = (uint16_t)(1u << ((int)c % 16));
  if (activeMask_ & bit) return;  // already active; don't spam the log
  activeMask_ |= bit;
  ring_[head_].ts = millis();
  ring_[head_].code = c;
  ring_[head_].cleared = false;
  head_ = (head_ + 1) % CAP;
  if (count_ < CAP) count_++;
}

void FaultManager::clear(FaultCode c) {
  activeMask_ &= ~((uint16_t)(1u << ((int)c % 16)));
}

bool FaultManager::active(FaultCode c) const {
  return (activeMask_ & (uint16_t)(1u << ((int)c % 16))) != 0;
}

FaultCode FaultManager::highest() const {
  if (activeMask_ == 0) return FaultCode::None;
  for (int bit = 15; bit >= 0; --bit)
    if (activeMask_ & (1u << bit)) return (FaultCode)bit;
  return FaultCode::None;
}

const FaultEvent* FaultManager::recent(uint8_t& count) const {
  count = count_;
  return ring_;
}
