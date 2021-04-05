const std = @import("std");
const vec3 = @import("vec3.zig");

pub fn write_color(ostream: std.fs.File.Writer, pixel_color: *const vec3.color) !void {
    // Write the translated [0,255] value of each color component
    try ostream.print("{} {} {}\n", .{ @floatToInt(i64, 255.999 * pixel_color.x()), @floatToInt(i64, 255.999 * pixel_color.y()), @floatToInt(i64, 255.999 * pixel_color.z()) });
}
