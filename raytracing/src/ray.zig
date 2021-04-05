const std = @import("std");
const vec3 = @import("vec3.zig");

pub const ray = struct {
    orig: vec3.point3,
    dir: vec3.vec3,
    pub fn init(orig: vec3.point3, dir: vec3.vec3) ray {
        return ray{ .orig = orig, .dir = dir };
    }
    pub fn origin(self: ray) vec3.point3 {
        return self.orig;
    }
    pub fn direction(self: ray) vec3.vec3 {
        return self.dir;
    }
    pub fn at(self: ray, t: f64) vec3.vec3 {
        return self.orig.add(self.dir.mul(f64, t));
    }
};
