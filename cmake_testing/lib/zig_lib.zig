const std = @import("std");
const io = std.io;
pub fn second_hello() !void {
    const stdout = io.getStdOut().outStream();
    try stdout.print("Second Hello dabber >:)\n", .{});
}
