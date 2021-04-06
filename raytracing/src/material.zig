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

pub const dielectric = struct {
    const Self = @This();
    ir: f64,
    material: material,
    pub fn init(index_of_refraction: f64) dielectric {
        return dielectric{
            .ir = index_of_refraction,
            .material = material{ .scatterFn = scatter },
        };
    }
    pub fn scatter(m: *material, r_in: ray.ray, rec: hittable.hit_record, attenuation: *vec3.color, scattered: *ray.ray) bool {
        const self = @fieldParentPtr(Self, "material", m);
        attenuation.* = vec3.color.init(1, 1, 1);
        const refraction_ratio = if (rec.front_face) (1.0 / self.ir) else self.ir;
        const unit_direction = r_in.direction().unit_vector();
        const cos_theta = std.math.min(unit_direction.negate().dot(rec.normal), 1.0);
        const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);

        const cannot_refract = refraction_ratio * sin_theta > 1.0;
        var direction: vec3.vec3 = undefined;
        if (cannot_refract or reflectance(cos_theta, refraction_ratio) > rtweekend.random_double(void, 0, 0)) direction = unit_direction.reflect(rec.normal) else direction = unit_direction.refract(rec.normal, refraction_ratio);
        scattered.* = ray.ray.init(rec.p, direction);
        return true;
    }

    fn reflectance(cosine: f64, ref_idx: f64) f64 {
        // Use Schlick's approximation for reflectance
        var r0: f64 = (1 - ref_idx) / (1 + ref_idx);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(f64, (1 - cosine), 5);
    }
};
