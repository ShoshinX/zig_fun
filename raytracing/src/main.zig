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

pub fn random_scene(allocator: *std.mem.Allocator) !*hittable_list.hittable_list {
    var world: hittable_list.hittable_list = try hittable_list.hittable_list.init(allocator, null);

    var material_ground = material.lambertian.init(vec3.color.init(0.5, 0.5, 0.5));
    try world.add(&sphere.sphere.init(vec3.point3.init(0, -1000, 0), 1000, &material_ground.material).hittable);

    var a: i64 = -11;
    while (a < 11) : (a += 1) {
        var b: i64 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = rtweekend.random_double(void, 0, 0);
            const center = vec3.point3.init(@intToFloat(f64, a) + 0.9 * rtweekend.random_double(void, 0, 0), 0.2, @intToFloat(f64, b) + 0.9 * rtweekend.random_double(void, 0, 0));
            if ((center.sub(vec3.vec3.init(4, 0.2, 0))).length() > 0.9) {
                var sphere_material: *material.material = undefined;
                if (choose_mat < 0.8) {
                    const albedo = vec3.color.random(.{});
                    sphere_material = &material.lambertian.init(albedo).material;
                    try world.add(&sphere.sphere.init(center, 0.2, sphere_material).hittable);
                } else if (choose_mat < 0.95) {
                    const albedo = vec3.color.random(.{ .max = 0.5, .min = 1 });
                    const fuzz = rtweekend.random_double(f64, 0, 0.5);
                    sphere_material = &material.metal.init(albedo, fuzz).material;
                    try world.add(&sphere.sphere.init(center, 0.2, sphere_material).hittable);
                } else {
                    sphere_material = &material.dielectric.init(1.5).material;
                    try world.add(&sphere.sphere.init(center, 0.2, sphere_material).hittable);
                }
            }
        }
    }

    var material1 = material.dielectric.init(1.5);
    try world.add(&sphere.sphere.init(vec3.vec3.init(0, 1, 0), 1, &material1.material).hittable);
    var material2 = material.lambertian.init(vec3.color.init(0.4, 0.2, 0.1));
    try world.add(&sphere.sphere.init(vec3.vec3.init(-4, 1, 0), 1, &material2.material).hittable);
    var material3 = material.metal.init(vec3.color.init(0.7, 0.6, 0.5), 0.0);
    try world.add(&sphere.sphere.init(vec3.vec3.init(4, 1, 0), 1, &material3.material).hittable);

    return &world;
}

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
    const aspect_ratio = 3.0 / 2.0;
    const image_width = 1200;
    const image_height = @floatToInt(i64, image_width / aspect_ratio);
    const samples_per_pixel = 10;
    const max_depth = 50;

    // Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!gpa.deinit());
    var allocator = &gpa.allocator;
    // World
    var world: hittable_list.hittable_list = try hittable_list.hittable_list.init(allocator, null);

    var material_ground = material.lambertian.init(vec3.color.init(0.5, 0.5, 0.5));
    try world.add(&sphere.sphere.init(vec3.point3.init(0, -1000, 0), 1000, &material_ground.material).hittable);

    var a: i64 = -11;
    while (a < 11) : (a += 1) {
        var b: i64 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = rtweekend.random_double(void, 0, 0);
            const center = vec3.point3.init(@intToFloat(f64, a) + 0.9 * rtweekend.random_double(void, 0, 0), 0.2, @intToFloat(f64, b) + 0.9 * rtweekend.random_double(void, 0, 0));
            if ((center.sub(vec3.vec3.init(4, 0.2, 0))).length() > 0.9) {
                var sphere_material: *material.material = undefined;
                if (choose_mat < 0.8) {
                    const albedo = vec3.color.random(.{});
                    sphere_material = &material.lambertian.init(albedo).material;
                    try world.add(&sphere.sphere.init(center, 0.2, sphere_material).hittable);
                } else if (choose_mat < 0.95) {
                    const albedo = vec3.color.random(.{ .max = 0.5, .min = 1 });
                    const fuzz = rtweekend.random_double(f64, 0, 0.5);
                    sphere_material = &material.metal.init(albedo, fuzz).material;
                    try world.add(&sphere.sphere.init(center, 0.2, sphere_material).hittable);
                } else {
                    sphere_material = &material.dielectric.init(1.5).material;
                    try world.add(&sphere.sphere.init(center, 0.2, sphere_material).hittable);
                }
            }
        }
    }

    var material1 = material.dielectric.init(1.5);
    try world.add(&sphere.sphere.init(vec3.vec3.init(0, 1, 0), 1, &material1.material).hittable);
    var material2 = material.lambertian.init(vec3.color.init(0.4, 0.2, 0.1));
    try world.add(&sphere.sphere.init(vec3.vec3.init(-4, 1, 0), 1, &material2.material).hittable);
    var material3 = material.metal.init(vec3.color.init(0.7, 0.6, 0.5), 0.0);
    try world.add(&sphere.sphere.init(vec3.vec3.init(4, 1, 0), 1, &material3.material).hittable);
    // var world: hittable_list.hittable_list = try hittable_list.hittable_list.init(allocator, null);
    defer world.clear();

    // Camera
    const lookfrom = vec3.vec3.init(13, 2, 3);
    const lookat = vec3.vec3.init(0, 0, 0);
    const vup = vec3.vec3.init(0, 1, 0);
    const dist_to_focus = 10.0;
    const aperture = 0.1;
    const cam = camera.camera.init(lookfrom, lookat, vup, 20.0, aspect_ratio, aperture, dist_to_focus);

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
