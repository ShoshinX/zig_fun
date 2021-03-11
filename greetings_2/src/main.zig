const builtin = @import("builtin");
const std = @import("std");
const io = std.io;
const fmt = std.fmt;

pub fn main() anyerror!void {
    const stdout = io.getStdOut().outStream();
    const stdin = io.getStdIn();
    const msg = "Hi, what's your name? ";

    var inputBuf: [4096]u8 = undefined;

    try stdout.print(msg, .{});
    const name = try stdin.read(&inputBuf);
    // TODO: fix printing words that are uninitialised
    try stdout.print("Hi, {}!\n", .{inputBuf});
}
