const std = @import("std");
const print = std.io.getStdOut().outStream().print;
const printerr = std.io.getStdErr().outStream().print;
const assert = std.debug.assert;

const color = @import("color.zig");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");
const hittable_list = @import("hittable_list.zig");
const sphere = @import("sphere.zig");
const rtweekend = @import("rtweekend.zig");
const hittable = @import("hittable.zig");
const camera = @import("camera.zig");
const material = @import("material.zig");

pub fn ray_color(r: ray.ray, world: *hittable.hittable, depth: i64) vec3.color {
    var rec: hittable.hit_record = undefined;
    if (depth <= 0) return vec3.color{};
    // Surprisingly, changing 0 to 0.001 saves 80% of the time used for processing
    if (world.hit(r, 0.001, rtweekend.infinity, &rec)) {
        var scattered: ray.ray = undefined;
        var attenuation: vec3.color = undefined;
        if (rec.mat_ptr.scatter(r, rec, &attenuation, &scattered)) {
            return attenuation.mul(vec3.vec3, ray_color(scattered, world, depth - 1));
        }
        return vec3.color{};
    }
    var unit_direction: vec3.vec3 = r.direction().unit_vector();
    const t = 0.5 * (unit_direction.y() + 1.0);
    return vec3.color.init(1, 1, 1).mul(f64, 1.0 - t).add(vec3.color.init(0.5, 0.7, 1.0).mul(f64, t));
}

pub fn main() anyerror!void {
    // Image
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;
    const image_height = @floatToInt(i64, image_width / aspect_ratio);
    const samples_per_pixel = 100;
    const max_depth = 50;

    // Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!gpa.deinit());
    var allocator = &gpa.allocator;
    // World
    var world: hittable_list.hittable_list = try hittable_list.hittable_list.init(allocator, null);
    defer world.clear();

    var material_ground = material.lambertian.init(vec3.color.init(0.8, 0.8, 0.0));
    var material_center = material.lambertian.init(vec3.color.init(0.7, 0.3, 0.3));
    var material_left = material.metal.init(vec3.color.init(0.8, 0.8, 0.8));
    var material_right = material.metal.init(vec3.color.init(0.8, 0.6, 0.2));
    var sphere1 = sphere.sphere.init(vec3.point3.init(0, -100.5, -1), 100, &material_ground.material);
    var sphere2 = sphere.sphere.init(vec3.point3.init(0, 0, -1), 0.5, &material_center.material);
    var sphere3 = sphere.sphere.init(vec3.point3.init(-1, 0, -1), 0.5, &material_left.material);
    var sphere4 = sphere.sphere.init(vec3.point3.init(1, 0, -1), 0.5, &material_right.material);
    try world.add(&sphere1.hittable);
    try world.add(&sphere2.hittable);
    try world.add(&sphere3.hittable);
    try world.add(&sphere4.hittable);

    // Camera
    const cam = camera.camera.init();

    // Render
    try print("P3\n{} {}\n255\n", .{ image_width, image_height });

    var j: i64 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        try printerr("\rScanlines remaining: {} ", .{j});
        var i: i64 = 0;
        while (i < image_width) : (i += 1) {
            var pixel_color: vec3.color = vec3.color.init(0, 0, 0);
            var s: i64 = 0;
            while (s < samples_per_pixel) : (s += 1) {
                const u = (@intToFloat(f64, i) + rtweekend.random_double(void, 0, 0)) / @intToFloat(f64, image_width - 1);
                const v = (@intToFloat(f64, j) + rtweekend.random_double(void, 0, 0)) / @intToFloat(f64, image_height - 1);
                const r = cam.get_ray(u, v);
                const worldHittable = &world.hittable;
                pixel_color.addAssign(ray_color(r, worldHittable, max_depth));
            }
            try color.write_color(std.io.getStdOut().writer(), pixel_color, samples_per_pixel);
        }
    }
    try printerr("\nDone.\n", .{});
}
