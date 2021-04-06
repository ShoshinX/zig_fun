const std = @import("std");
const hittable = @import("hittable.zig");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const ray = @import("ray.zig");

pub const hittable_list = struct {
    const Self = @This();
    // pass references to the inner struct hittable interface of objects
    objects: ArrayList(*hittable.hittable),
    // interface
    hittable: hittable.hittable,

    pub fn init(allocator: *Allocator, object: ?*hittable.hittable) !hittable_list {
        var res = hittable_list{
            .objects = ArrayList(*hittable.hittable).init(allocator),
            .hittable = hittable.hittable{ .hitFn = hit },
        };
        if (object) |ptr| {
            try res.add(ptr);
        }
        return res;
    }

    pub fn clear(self: *hittable_list) void {
        self.objects.shrink(0);
    }

    pub fn add(self: *hittable_list, object: *hittable.hittable) !void {
        try self.objects.append(object);
    }

    pub fn hit(h: *hittable.hittable, r: ray.ray, t_min: f64, t_max: f64, rec: *hittable.hit_record) bool {
        // Usage of interface example:
        // var hittable_list = hittable_list.init(allocator,null);
        // var hittable = &hittable_list.hittable; the and is here so that a copy operation is avoided
        // hittable_list.hit(...);
        const self = @fieldParentPtr(Self, "hittable", h);
        var temp_rec: hittable.hit_record = undefined;
        var hit_anything: bool = false;
        var closest_so_far: f64 = t_max;

        for (self.objects.items) |object| {
            if (object.hit(r, t_min, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }
        return hit_anything;
    }
};
