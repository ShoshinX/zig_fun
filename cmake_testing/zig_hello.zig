const std = @import("std");
const io = std.io;

pub fn main() !void {
    const stdout = io.getStdOut().outStream();
    try stdout.print("Hello! :)\n", .{});
}
