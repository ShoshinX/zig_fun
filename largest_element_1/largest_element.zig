const std = @import("std");
const io = std.io;
const mem = std.mem;
const fmt = std.fmt;
const assert = std.debug.assert;

pub fn main() !void {
    const buf = [_]i32{ 1, 2, 3, 4, 7, 5, 6, 0, 1, 9 };
    if (largest(i32, &buf, cmp_int)) |value| {
        assert(value == 9);
    } else {
        return error.KEK;
    }
}

pub fn cmp_int(a: i32, b: i32) i32 {
    return if (a > b) a else b;
}

const comparator = fn (a: type, b: type) i32;
pub fn largest(comptime T: type, buf: []const T, cmp: fn (a: T, b: T) T) ?T {
    if (buf.len < 1) {
        return null;
    }
    var max: T = buf[0];
    for (buf) |item| {
        max = cmp(max, item);
    }
    return max;
}
