const std = @import("std");
const print = std.io.getStdOut().outStream().print;
const printerr = std.io.getStdErr().outStream().print;
const assert = std.debug.assert;

const color = @import("color.zig");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");

pub fn hit_sphere(center: vec3.point3, radius: f64, r: ray.ray) f64 {
    const oc = r.origin().sub(center);
    const a = r.direction().length_squared();
    const half_b = oc.dot(r.direction());
    const c = oc.length_squared() - (radius * radius);
    const discriminant = half_b * half_b - a * c;
    if (discriminant < 0) {
        return -1.0;
    } else {
        return (-half_b - @sqrt(discriminant)) / a;
    }
}

pub fn ray_color(r: ray.ray) vec3.color {
    var t = hit_sphere(vec3.point3.init(0, 0, -1), 0.5, r);
    if (t > 0.0) {
        const N = r.at(t).sub(vec3.vec3.init(0, 0, -1)).unit_vector();
        return vec3.color.init(N.x() + 1, N.y() + 1, N.z() + 1).mul(f64, 0.5);
    }
    var unit_direction: vec3.vec3 = r.direction().unit_vector();
    t = 0.5 * (unit_direction.y() + 1.0);
    return vec3.color.init(1, 1, 1).mul(f64, 1.0 - t).add(vec3.color.init(0.5, 0.7, 1.0).mul(f64, t));
}

pub fn main() anyerror!void {
    // Image
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;
    const image_height = @floatToInt(i64, image_width / aspect_ratio);

    // Camera
    const viewport_height = 2.0;
    const viewport_width = aspect_ratio * viewport_height;
    const focal_length = 1.0;

    const origin = vec3.point3{};
    const horizontal = vec3.vec3.init(viewport_width, 0, 0);
    const vertical = vec3.vec3.init(0, viewport_height, 0);
    var lower_left_corner = origin.sub(horizontal.div(2)).sub(vertical.div(2)).sub(vec3.vec3.init(0, 0, focal_length));

    // Render

    try print("P3\n{} {}\n255\n", .{ image_width, image_height });

    var j: i64 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        try printerr("\rScanlines remaining: {} ", .{j});
        var i: i64 = 0;
        while (i < image_width) : (i += 1) {
            const u = @intToFloat(f64, i) / @intToFloat(f64, image_width - 1);
            const v = @intToFloat(f64, j) / @intToFloat(f64, image_height - 1);
            const r = ray.ray.init(origin, lower_left_corner.add(horizontal.mul(f64, u)).add(vertical.mul(f64, v)).sub(origin));
            const pixel_color = ray_color(r);
            try color.write_color(std.io.getStdOut().writer(), pixel_color);
        }
    }
    try printerr("\nDone.\n", .{});
}
