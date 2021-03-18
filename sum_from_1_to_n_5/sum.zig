const std = @import("std");
const io = std.io;
const mem = std.mem;
const fmt = std.fmt;

pub fn main() !void {
    const stdout = io.getStdOut().writer();
    try stdout.print("Type in a positive n to get sum from 1 to n, where only the numbers that are divisible by 3 or 5:\n", .{});
    var buffer = [_]u8{0} ** 4096;
    const stdin = io.getStdIn().reader();
    const read = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) orelse return error.KEK;
    var n = try fmt.parseInt(u32, read, 10);
    try stdout.print("sum is {}.\n", .{sum_1_to_n(n)});
}

pub fn sum_1_to_n(n: u32) u32 {
    var i: u32 = 1;
    var sum: u32 = 0;
    while (i <= n) {
        if (i % 3 == 0 or i % 5 == 0)
            sum += i;
        i += 1;
    }
    return sum;
}
