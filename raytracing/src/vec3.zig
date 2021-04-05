const std = @import("std");
const printerr = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;

pub const point3 = vec3; // 3D point
pub const color = vec3; // RGB color

pub const vec3 = struct {
    e: [3]f64 = [_]f64{ 0, 0, 0 },
    // From what I've read in the zig std lib, init is convention for stack based initialisation.
    pub fn init(e1: f64, e2: f64, e3: f64) vec3 {
        return vec3{ .e = [_]f64{ e1, e2, e3 } };
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
