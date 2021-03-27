const std = @import("std");
const io = std.io;
const lib = @import("lib/zig_lib.zig");

pub fn main() !void {
    const stdout = io.getStdOut().outStream();
    try stdout.print("Hello! :)\n", .{});
    try lib.second_hello();
}
