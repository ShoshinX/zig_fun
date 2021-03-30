/// Doc comments
/// MIT license
// normal comment
const std = @import("std");
const assert = std.debug.assert;
const expect = std.testing.expect;

const Struct_example = struct {
    num1: i32,
    num2: i32,
};

pub fn main() !void {
    const a = 2; // const does not need to specify type
    assert(a == 2);
    var b: i32 = 3; // var needs to specify type
    b += 66;
    assert(b == 69);

    var c: ?i32 = null;
    if (c) |val| {
        assert(val == 42);
    } else {
        assert(c == null);
    }

    c = 42;
    if (c) |val| {
        assert(val == 42);
    } else {
        assert(c == null);
    }

    const ayy_true = try error_optional(true);
    assert(ayy_true == null);
    // Found a bug
    // const ayy_false = error_optional(false) catch {};
    // assert(ayy_false == {});
    const ayy_false = error_optional(false) catch |err| {
        assert(err == error.oof);
    };
    return error.lmao;
}

pub fn error_optional(a1: bool) !?void {
    if (a1) {
        return null;
    } else {
        return error.oof;
    }
}
