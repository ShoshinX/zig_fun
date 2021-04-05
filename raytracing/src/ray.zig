const std = @import("std");
const vec3 = @import("vec3.zig");

pub const ray = struct {
    orig: *const vec3.point3,
    dir: *const vec3.vec3,
    pub fn init(orig: *const vec3.point3, dir: *const vec3.vec3) ray {
        return ray{ .orig = orig, .dir = dir };
    }
    pub fn origin(self: *const ray) *const vec3.point3 {
        return self.orig;
    }
    pub fn direction(self: *const ray) *const vec3.vec3 {
        return self.dir;
    }
    pub fn at(self: *ray, t: f64) vec3.vec3 {
        return vec3.add(self.orig, vec3.mul(self.dir, t));
    }
};
