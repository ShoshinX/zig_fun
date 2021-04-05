const std = @import("std");
const hittable = @import("hittable.zig");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");

pub const sphere = struct {
    const Self = @This();
    hittable: hittable.hittable,
    center: vec3.point3,
    radius: f64,
    pub fn init(cen: vec3.point3, r: f64) Self {
        return Self{
            .center = cen,
            .radius = r,
            .hittable = hittable.hittable{ .hitFn = hit },
        };
    }

    fn hit(h: *hittable.hittable, r: ray.ray, t_min: f64, t_max: f64, rec: *hittable.hit_record) bool {
        // TODO:What the fuck is this?
        const self = @fieldParentPtr(Self, "hittable", h);
        const oc = r.origin().sub(self.center);
        const a = r.direction().length_squared();
        const half_b = oc.dot(r.direction());
        const c = oc.length_squared() - self.radius * self.radius;

        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) {
            return false;
        }
        const sqrtd = @sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range.
        var root = (-half_b - sqrtd) / a;
        if (root < t_min or t_max < root) {
            root = (-half_b + sqrtd) / a;
            if (root < t_min or t_max < root) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = (rec.p.sub(self.center)).div(self.radius);
        rec.set_face_normal(r, outward_normal);
        return true;
    }
};

test "sphere instantiation" {
    const s = sphere.init(vec3.vec3{}, 0);
}
