const std = @import("std");
const io = std.io;
const mem = std.mem;
const fmt = std.fmt;

pub fn main() !void {
    const stdout = io.getStdOut().writer();
    try stdout.print("Type in a postive n to get sum from 1 to n\n", .{});

    var buffer = [_]u8{0} ** 4096;
    const stdin = io.getStdIn().reader();
    // read is the slice from buffer that contains the required contents from input
    // try looks like it has lower precedence than orelse, so that's why the brakcets exist
    const read = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) orelse return error.KEK;
    var n = try fmt.parseInt(u32, read, 10);
    try stdout.print("sum is {}.\n", .{sum_1_to_n(n)});
}

pub fn sum_1_to_n(n: u32) u32 {
    return (n * (n + 1)) / 2;
}
