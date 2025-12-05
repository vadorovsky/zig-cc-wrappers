const std = @import("std");
const options = @import("wrapper_options");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var argv = std.ArrayList([]const u8).empty;
    defer argv.deinit(allocator);

    try argv.append(allocator, "zig");
    try argv.append(allocator, if (options.use_cpp) "c++" else "cc");

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.next(); // drop argv[0] (program name)
    while (args.next()) |arg| {
        try argv.append(allocator, arg);
    }

    var child = std.process.Child.init(argv.items, allocator);
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;

    const term = try child.spawnAndWait();

    switch (term) {
        .Exited => |code| std.process.exit(code),
        .Signal => |sig| {
            std.log.err("zig terminated via signal {}", .{sig});
            std.process.exit(@intCast(128 + sig));
        },
        else => {
            std.log.err("zig terminated unexpectedly: {s}", .{@tagName(term)});
            std.process.exit(1);
        },
    }
}
