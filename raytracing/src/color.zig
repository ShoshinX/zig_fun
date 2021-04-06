const std = @import("std");
const vec3 = @import("vec3.zig");
const rtweekend = @import("rtweekend.zig");

pub fn write_color(ostream: std.fs.File.Writer, pixel_color: vec3.color, samples_per_pixel: i64) !void {
    var r = pixel_color.x();
    var g = pixel_color.y();
    var b = pixel_color.z();

    // Divide  the color by the number of samples
    const scale = 1.0 / @intToFloat(f64, samples_per_pixel);
    r = @sqrt(r * scale);
    g = @sqrt(g * scale);
    b = @sqrt(b * scale);
    // Write the translated [0,255] value of each color component
    try ostream.print("{} {} {}\n", .{ @floatToInt(i64, 256 * rtweekend.clamp(r, 0.0, 0.999)), @floatToInt(i64, 256 * rtweekend.clamp(g, 0.0, 0.999)), @floatToInt(i64, 256 * rtweekend.clamp(b, 0.0, 0.999)) });
}
