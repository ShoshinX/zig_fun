const std = @import("std");
const rtweekend = @import("rtweekend.zig");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");

pub const camera = struct {
    origin: vec3.point3,
    lower_left_corner: vec3.point3,
    horizontal: vec3.vec3,
    vertical: vec3.vec3,

    pub fn init() camera {
        const aspect_ratio = 16.0 / 9.0;
        const viewport_height = 2.0;
        const viewport_width = aspect_ratio * viewport_height;
        const focal_length = 1.0;
        var res = camera{
            .origin = vec3.point3{},
            .horizontal = vec3.vec3.init(viewport_width, 0.0, 0.0),
            .vertical = vec3.vec3.init(0, viewport_height, 0),
            // Done like this because struct fields can't refer to its struct's other fields during initialization
            .lower_left_corner = vec3.point3{},
        };
        res.lower_left_corner = res.origin.sub(res.horizontal.div(2)).sub(res.vertical.div(2)).sub(vec3.vec3.init(0, 0, focal_length));
        return res;
    }

    pub fn get_ray(self: *const camera, u: f64, v: f64) ray.ray {
        return ray.ray.init(self.origin, self.lower_left_corner.add(self.horizontal.mul(f64, u)).add(self.vertical.mul(f64, v)).sub(self.origin));
    }
};
