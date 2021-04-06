const assert = @import("std").debug.assert;

const Struct1 = struct {
    a: i32 = 0,
    b: i32 = 0,
    c: i32 = 0,
    d: i32 = 0,
};
fn changeStruct(a: *Struct1) void {
    var b = Struct1{ .a = 2, .b = 3, .c = 4 };
    a.* = b;
}
test "passing structs by value and changing the structs from inside" {
    var structTest1 = Struct1{};
    var res = Struct1{ .a = 2, .b = 3, .c = 4 };
    changeStruct(&structTest1);
    assert(structTest1.a == res.a);
    assert(structTest1.b == res.b);
    assert(structTest1.c == res.c);
}
