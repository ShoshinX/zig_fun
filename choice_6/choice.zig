const std = @import("std");
const io = std.io;
const mem = std.mem;
const fmt = std.fmt;

pub fn main() !void {
    const stdout = io.getStdOut().writer();
    try stdout.print("Type a positive integer: ", .{});
    var buffer = [_]u8{0} ** 4096;
    const stdin = io.getStdIn().reader();
    const read = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) orelse return error.KEK;
    var n = try fmt.parseInt(u32, read, 10);
    try stdout.print("1: sum 1 to n\n2: prod 1 to n: ", .{});
    const choice = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) orelse return error.KEK;
    if (mem.eql(u8, choice, "1")) {
        try stdout.print("sum: {}.\n", .{sum(n)});
    } else if (mem.eql(u8, choice, "2")) {
        try stdout.print("prod: {}.\n", .{prod(n)});
    } else {
        try stdout.print("Choose 1 xor 2.\n", .{});
    }
}

pub fn sum(n: u32) u32 {
    return (n * (n + 1)) / 2;
}

pub fn prod(n: u32) u32 {
    var i: u32 = 1;
    var product: u32 = 1;
    while (i <= n) {
        product *%= i;
        i += 1;
    }
    return product;
}
