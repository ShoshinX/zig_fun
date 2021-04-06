const std = @import("std");

// Constants
pub const infinity = std.math.inf(f64);
pub const pi = std.math.pi;

// Utility functions
pub fn degrees_to_radians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}

var r = std.rand.DefaultPrng.init(42);
pub fn random_double(comptime T: type, min: f64, max: f64) f64 {
    if (T == void) {
        return r.random.float(f64);
    } else if (T == f64) {
        return min + (max - min) * r.random.float(f64);
    }
}

pub fn clamp(x: f64, min: f64, max: f64) f64 {
    if (x < min) return min;
    if (x > max) return max;
    return x;
}
