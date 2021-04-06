const std = @import("std");

// Constants
pub const infinity = std.math.inf(f64);
pub const pi = std.math.pi;

// Utility functions
pub fn degrees_to_radians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}
