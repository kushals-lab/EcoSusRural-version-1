// fault_manager.h - records fault events with timestamps for the session log.
// Keeps a small ring buffer; the app drains it as alert/fault envelopes.
#pragma once
#include <Arduino.h>
#include "dryer_types.h"

struct FaultEvent {
  uint32_t ts;
  FaultCode code;
  bool cleared;
};

class FaultManager {
 public:
  void begin();
  void raise(FaultCode c);   // log event; dedupes consecutive same code
  void clear(FaultCode c);
  bool active(FaultCode c) const;
  FaultCode highest() const;
  const FaultEvent* recent(uint8_t& count) const;

 private:
  static const uint8_t CAP = 16;
  FaultEvent ring_[CAP];
  uint8_t head_ = 0;
  uint8_t count_ = 0;
  uint16_t activeMask_ = 0;
};
