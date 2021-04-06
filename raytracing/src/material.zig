const std = @import("std");
const rtweekend = @import("rtweekend.zig");
const hittable = @import("hittable.zig");
const ray = @import("ray.zig");
const vec3 = @import("vec3.zig");

pub const material = struct {
    scatterFn: fn (m: *material, r_in: ray.ray, rec: hittable.hit_record, attenuation: *vec3.color, scattered: *ray.ray) bool,
    pub fn scatter(m: *material, r_in: ray.ray, rec: hittable.hit_record, attenuation: *vec3.color, scattered: *ray.ray) bool {
        return m.scatterFn(m, r_in, rec, attenuation, scattered);
    }
};

pub const lambertian = struct {
    const Self = @This();
    albedo: vec3.color,
    material: material,
    pub fn init(a: vec3.color) lambertian {
        return lambertian{
            .albedo = a,
            .material = material{ .scatterFn = scatter },
        };
    }
    pub fn scatter(m: *material, r_in: ray.ray, rec: hittable.hit_record, attenuation: *vec3.color, scattered: *ray.ray) bool {
        const self = @fieldParentPtr(Self, "material", m);
        var scatter_direction = rec.normal.add(vec3.vec3.random_unit_vector());
        if (scatter_direction.near_zero()) scatter_direction = rec.normal;
        scattered.* = ray.ray.init(rec.p, scatter_direction);
        attenuation.* = self.albedo;
        return true;
    }
};

pub const metal = struct {
    const Self = @This();
    albedo: vec3.color,
    material: material,
    fuzz: f64,
    pub fn init(a: vec3.color, f: f64) metal {
        return metal{
            .albedo = a,
            .fuzz = if (f < 1) f else 1,
            .material = material{ .scatterFn = scatter },
        };
    }
    pub fn scatter(m: *material, r_in: ray.ray, rec: hittable.hit_record, attenuation: *vec3.color, scattered: *ray.ray) bool {
        const self = @fieldParentPtr(Self, "material", m);
        const reflected = r_in.direction().unit_vector().reflect(rec.normal);
        scattered.* = ray.ray.init(rec.p, reflected.add(vec3.vec3.random_in_unit_sphere().mul(f64, self.fuzz)));
        attenuation.* = self.albedo;
        // limited precision here to speed things up
        return scattered.direction().dot(rec.normal) > 0.0001;
    }
};
