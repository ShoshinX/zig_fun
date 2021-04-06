const std = @import("std");
const ray = @import("ray.zig");
const vec3 = @import("vec3.zig");
const material = @import("material.zig");

pub const hit_record = struct {
    p: vec3.point3,
    normal: vec3.vec3,
    mat_ptr: *material.material,
    t: f64,
    front_face: bool,

    pub fn set_face_normal(h: *hit_record, r: ray.ray, outward_normal: vec3.vec3) void {
        h.front_face = r.direction().dot(outward_normal) < 0;
        h.normal = if (h.front_face) outward_normal else outward_normal.negate();
    }
};

pub const hittable = struct {
    const Self = @This();
    hitFn: fn (h: *hittable, r: ray.ray, t_min: f64, t_max: f64, rec: *hit_record) bool,
    pub fn hit(h: *hittable, r: ray.ray, t_min: f64, t_max: f64, rec: *hit_record) bool {
        return h.hitFn(h, r, t_min, t_max, rec);
    }
};
