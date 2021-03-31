const std = @import("std");
const assert = std.debug.assert;
const print = std.debug.print;

pub fn main() !void {
    // Optional types
    // Values
    var foo: ?i32 = null;
    assert(foo == null);
    foo = 42;
    if (foo) |val| {
        assert(val == 42);
    }
    // if you know that foo will not be null here
    assert(foo.? == 42);
    // Pointers
    var ptr: ?*i32 = null;
    var x: i32 = 1;
    ptr = &x;
    // this dereferencing is cool
    assert(ptr.?.* == 1);

    // Error handling
    // give a default a value in case an error happens
    const oof = give_error() catch 100;
    assert(oof == 100);
    // try is the same as catch |err| return err;
    //const oof2 = try give_error();
    deferErrorExample(false) catch {};
    deferErrorExample(true) catch {};
    // Comptime
    const r1 = max(bool, true, false);
    const r2 = max(i32, 4, 2);
    const r3 = max(f64, 2.72, 3.14);
    assert(r1 == true);
    assert(r2 == 4);
    assert(r3 == 3.14);
    // Interop
    // Zig slices,pointers, arrays
    // Memory management
    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!allocator.deinit());
    const gpa = &allocator.allocator;
    const u32_ptr = try gpa.create(u32);
    errdefer gpa.destroy(u32_ptr);
    // comment to see memleak error
    defer gpa.destroy(u32_ptr);
    // uncomment to see double_free;
    // defer gpa.destroy(u32_ptr);
    // uncomment to see use after free
    // gpa.destroy(u32_ptr);
    // u32_ptr.* = 1;
}

pub fn give_error() !i32 {
    return error.Oof;
}

fn deferErrorExample(is_error: bool) !void {
    print("\nstart of function\n", .{});

    // This will always be executed on exit
    defer {
        print("end of function\n", .{});
    }

    errdefer {
        print("encountered an error!\n", .{});
    }

    if (is_error) {
        return error.DeferError;
    }
}

// Cool thing is if a branch path is known at comptime then the other branches don't get run.
fn max(comptime T: type, a: T, b: T) T {
    if (T == bool) {
        return a or b;
    } else if (a > b) {
        return a;
    } else {
        return b;
    }
}

// Allocator memory management
