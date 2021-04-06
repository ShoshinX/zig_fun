const std = @import("std");
const printerr = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const rtweekend = @import("rtweekend.zig");

pub const point3 = vec3; // 3D point
pub const color = vec3; // RGB color

pub const config_random = struct {
    max: f64 = 0,
    min: f64 = 0,
};

pub const vec3 = struct {
    e: [3]f64 = [_]f64{ 0, 0, 0 },
    // From what I've read in the zig std lib, init is convention for stack based initialisation.
    pub fn init(e1: f64, e2: f64, e3: f64) vec3 {
        return vec3{ .e = [_]f64{ e1, e2, e3 } };
    }
    pub fn random(comptime config: config_random) vec3 {
        const max = config.max;
        const min = config.min;
        if (max == 0.0 and min == 0.0) {
            return vec3.init(rtweekend.random_double(void, 0, 0), rtweekend.random_double(void, 0, 0), rtweekend.random_double(void, 0, 0));
        } else {
            return vec3.init(rtweekend.random_double(f64, max, min), rtweekend.random_double(f64, max, min), rtweekend.random_double(f64, max, min));
        }
    }
    pub fn random_in_unit_sphere() vec3 {
        while (true) {
            // This is cool
            const p = vec3.random(.{ .min = -1, .max = 1 });
            if (p.length_squared() >= 1) continue;
            return p;
        }
    }
    pub fn random_unit_vector() vec3 {
        return vec3.random_in_unit_sphere().unit_vector();
    }
    pub fn random_in_hemisphere(normal: vec3) vec3 {
        const in_unit_sphere = random_in_unit_sphere();
        if (dot(in_unit_sphere, normal) > 0.0) return in_unit_sphere else return in_unit_sphere.negate();
    }
    pub fn x(self: vec3) f64 {
        return self.e[0];
    }
    pub fn y(self: vec3) f64 {
        return self.e[1];
    }
    pub fn z(self: vec3) f64 {
        return self.e[2];
    }
    pub fn negate(self: vec3) vec3 {
        return vec3.init(-self.x(), -self.y(), -self.z());
    }
    pub fn equal(self: vec3, arg1: vec3) bool {
        return self.x() == arg1.x() and self.y() == arg1.y() and self.z() == arg1.z();
    }
    pub fn addAssign(self: *vec3, arg1: vec3) void {
        var u = self;
        u.e[0] += arg1.x();
        u.e[1] += arg1.y();
        u.e[2] += arg1.z();
    }
    pub fn mulAssign(self: *vec3, arg1: f64) void {
        var u = self;
        u.e[0] *= arg1;
        u.e[1] *= arg1;
        u.e[2] *= arg1;
    }
    pub fn divAssign(self: *vec3, arg1: f64) void {
        self.mulAssign(1 / arg1);
    }
    pub fn length(self: vec3) f64 {
        return @sqrt(self.length_squared());
    }
    pub fn length_squared(self: vec3) f64 {
        return self.x() * self.x() + self.y() * self.y() + self.z() * self.z();
    }
    pub fn add(u: vec3, v: vec3) vec3 {
        return vec3.init(u.x() + v.x(), u.y() + v.y(), u.z() + v.z());
    }

    pub fn sub(u: vec3, v: vec3) vec3 {
        return vec3.init(u.x() - v.x(), u.y() - v.y(), u.z() - v.z());
    }

    pub fn mul(u: vec3, comptime T: type, v: T) vec3 {
        if (T == f64) {
            return vec3.init(u.x() * v, u.y() * v, u.z() * v);
        } else if (T == vec3) {
            return vec3.init(u.x() * v.x(), u.y() * v.y(), u.z() * v.z());
        }
    }

    pub fn div(u: vec3, v: f64) vec3 {
        return u.mul(f64, 1 / v);
    }

    pub fn dot(u: vec3, v: vec3) f64 {
        return u.x() * v.x() + u.y() * v.y() + u.z() * v.z();
    }

    pub fn cross(u: vec3, v: vec3) vec3 {
        return vec3.init(u.e[1] * v.e[2] - u.e[2] * v.e[1], u.e[2] * v.e[0] - u.e[0] * v.e[2], u.e[0] * v.e[1] - u.e[1] * v.e[0]);
    }

    pub fn unit_vector(v: vec3) vec3 {
        return div(v, v.length());
    }
    pub fn near_zero(v: vec3) bool {
        const s = 1e-8;
        return (@fabs(v.e[0]) < s) and (@fabs(v.e[1]) < s) and (@fabs(v.e[2]) < s);
    }
    pub fn reflect(v: vec3, n: vec3) vec3 {
        return v.sub(n.mul(f64, 2 * v.dot(n)));
    }
    pub fn refract(uv: vec3, n: vec3, etai_over_etat: f64) vec3 {
        const cos_theta = std.math.min(uv.negate().dot(n), 1.0);
        const r_out_perp = (uv.add(n.mul(f64, cos_theta))).mul(f64, etai_over_etat);
        const r_out_parallel = n.mul(f64, -@sqrt(@fabs(1.0 - r_out_perp.length_squared())));
        return r_out_perp.add(r_out_parallel);
    }
    pub fn random_in_unit_disk() vec3 {
        while (true) {
            var p = vec3.init(rtweekend.random_double(f64, -1, 1), rtweekend.random_double(f64, -1, 1), 0);
            if (p.length_squared() >= 1) continue;
            return p;
        }
    }
};

// vec3 utility function

pub fn printVec3(ostream: std.fs.File.Writer, v: vec3) !void {
    try ostream.print("{} {} {}", .{ v.x(), v.y(), v.z() });
}

test "accessing vec3.x" {
    var p: vec3 = vec3{};
    assert(p.x() == 0);
}

test "negate vec3" {
    var p: vec3 = vec3.init(1, 1, 1);
    var q: vec3 = p.negate();
    assert(q.equal(vec3.init(-1, -1, -1)));
}

test "addAssign" {
    var p: vec3 = vec3.init(1, 1, 1);
    var q: vec3 = vec3.init(1, 2, 3);
    p.addAssign(q);
    assert(p.equal(vec3.init(2, 3, 4)));
}

test "mulAssign" {
    var p: vec3 = vec3.init(1, 2, 3);
    p.mulAssign(3);
    assert(p.equal(vec3.init(3, 6, 9)));
}

test "divAssign" {
    var p: vec3 = vec3.init(3, 6, 9);
    p.divAssign(3);
    assert(p.equal(vec3.init(1, 2, 3)));
}

test "length" {
    var p: vec3 = vec3.init(2, 3, 4);
    var q: vec3 = vec3.init(-2, -3, -4);
    assert(p.length() == @sqrt(4.0 + 9.0 + 16.0));
    assert(q.length() == @sqrt(4.0 + 9.0 + 16.0));
}

test "AddVec3" {
    var p: vec3 = vec3.init(2, 3, 4);
    var q: vec3 = vec3.init(-2, -3, -4);
    assert(p.add(q).equal(vec3.init(0, 0, 0)));
}

test "mulVec3" {
    var p: vec3 = vec3.init(2, 3, 4);
    var q: vec3 = vec3.init(-2, -3, -4);
    const d = 3.0;
    assert(p.mul(vec3, q).equal(vec3.init(-4, -9, -16)));
    assert(p.mul(f64, d).equal(vec3.init(6, 9, 12)));
}

test "divVec3" {
    var p: vec3 = vec3.init(
        3,
        3,
        3,
    );
    const d = 3.0;
    assert(p.div(d).equal(vec3.init(1, 1, 1)));
}

test "dot" {
    var p: vec3 = vec3.init(1, 2, 3);
    var q: vec3 = vec3.init(2, 3, 4);
    assert(p.dot(q) == 20);
}

test "cross" {
    var p: *vec3 = &vec3.init(1, 2, 3);
    var q: *vec3 = &vec3.init(2, 3, 4);
    assert(p.cross(q.*).equal(vec3.init(-1, 2, -1)));
}

test "unit_vector" {
    // doesn't work with (2,2,2);
    var p: *vec3 = &vec3.init(3, 3, 3);
    assert(p.unit_vector().equal(vec3.init(1.0 / @sqrt(3.0), 1.0 / @sqrt(3.0), 1.0 / @sqrt(3.0))));
}
