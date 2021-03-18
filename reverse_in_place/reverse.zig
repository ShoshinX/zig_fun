const std = @import("std");
const mem = std.mem;
const assert = std.debug.assert;
const stdout = std.io.getStdOut().writer();
pub fn main() !void {
    var buf1 = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    var buf1reversed = [_]i32{ 9, 8, 7, 6, 5, 4, 3, 2, 1 };
    if (reverse(i32, &buf1)) |_| {
        assert(mem.eql(i32, &buf1, &buf1reversed));
    } else {
        assert(false);
    }
}

pub fn reverse(comptime T: type, buf: []T) ?void {
    if (buf.len < 1) {
        return null;
    }
    var i: usize = 0;
    var j: usize = buf.len - 1;
    while (i < j) {
        var temp: T = buf[i];
        buf[i] = buf[j];
        buf[j] = temp;
        i += 1;
        j -= 1;
    }
}
