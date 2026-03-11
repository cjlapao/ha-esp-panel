#pragma once

inline float calculate_arc_angle(float val, float min_val, float max_val, float start_angle, float end_angle) {
  if (max_val <= min_val) return start_angle;
  float clamped = val;
  if (clamped < min_val) clamped = min_val;
  if (clamped > max_val) clamped = max_val;
  float ratio = (clamped - min_val) / (max_val - min_val);
  return start_angle + (ratio * (end_angle - start_angle));
}
