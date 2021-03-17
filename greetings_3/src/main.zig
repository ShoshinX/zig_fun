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
    const cnt = try stdin.read(&inputBuf);
    const line = std.mem.trimRight(u8, inputBuf[0..cnt], "\n");
    const alice = "Alice";
    const bob = "Bob";
    if (std.mem.eql(u8, line, alice) or std.mem.eql(u8, line, bob)) {
        try stdout.print("Hi, {}!\n", .{line});
    } else {
        try stdout.print("Sorry, you're not the right person. Bring Bob or Alice next time :)!\n", .{});
    }
}
