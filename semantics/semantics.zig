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
    const oof = give_error() catch error.dab;
    process_error(oof);
    assert(error.weewoo == error.weewoo);
    // assert(error{weewoo} == error{weewoo}); fails
    //assert(oof == 100);
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
    // Pointers
    // Changing var into const changes the type
    var i: i32 = 4;
    var ptr_t: ?*i32 = &i;
    if (ptr_t == &i) {
        ptr_t = null;
    }
    // raises an error on ptr_t.?
    // assert(ptr_t.? != &i);
    assert(ptr_t == null);
    ptr_t = &i;
    assert(ptr_t.?.* == 4);

    // Arrays
    var some_integers: [100]i32 = undefined;
    for (some_integers) |*item, index| {
        item.* = @intCast(i32, index);
    }
    assert(some_integers[50] == 50);

    // Slices
    // uncomment to show comptime abilities
    // comptime
    var size: u32 = 50;
    // slices only accept usize
    const slice_integers = some_integers[0..size];
    assert(slice_integers[30] == 30);
    // zig doesn't know at compile time if size is within bounds so it triggers runtime error
    // However, if we use comptime it triggers an error in compilation.
    // assert(slice_integers[size] == size);

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

    // Async/Await & Suspend/Resume
    var frame = async suspend_me();
    resume frame;
    // show example of async/await in ziglang's website
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

// A function accepting an error as an argument
fn process_error(a: error{dab}!i32) void {
    print("accepting error\n", .{});
}

// Suspend function
fn suspend_me() bool {
    suspend {
        // Code is still being run here
        print("I'm going to suspend!\n", .{});
    }
    // Code doesn't run here until I resume this frame
    print("I'm free!\n", .{});
    return true;
}
