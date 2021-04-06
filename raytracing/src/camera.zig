const std = @import("std");
const rtweekend = @import("rtweekend.zig");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");

pub const camera = struct {
    origin: vec3.point3,
    lower_left_corner: vec3.point3,
    horizontal: vec3.vec3,
    vertical: vec3.vec3,

    pub fn init(lookfrom: vec3.point3, lookat: vec3.point3, vup: vec3.vec3, vfov: f64, aspect_ratio: f64) camera {
        const theta = rtweekend.degrees_to_radians(vfov);
        const h = std.math.tan(theta / 2);
        const viewport_height = 2.0 * h;
        const viewport_width = aspect_ratio * viewport_height;
        const w = lookfrom.sub(lookat).unit_vector();
        const u = vup.cross(w).unit_vector();
        const v = w.cross(u);
        const focal_length = 1.0;
        var res = camera{
            .origin = lookfrom,
            .horizontal = u.mul(f64, viewport_width),
            .vertical = v.mul(f64, viewport_height),
            // Done like this because struct fields can't refer to its struct's other fields during initialization
            .lower_left_corner = vec3.point3{},
        };
        res.lower_left_corner = res.origin.sub(res.horizontal.div(2)).sub(res.vertical.div(2)).sub(w);
        return res;
    }

    pub fn get_ray(self: *const camera, s: f64, t: f64) ray.ray {
        return ray.ray.init(self.origin, self.lower_left_corner.add(self.horizontal.mul(f64, s)).add(self.vertical.mul(f64, t)).sub(self.origin));
    }
};
