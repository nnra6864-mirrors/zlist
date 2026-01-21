const std = @import("std");
const mem = std.mem;

const file = @import("file.zig");

pub const Files = struct {
    const Self = @This();

    allocator: mem.Allocator,
    io: std.Io,
    items: std.ArrayList(file.File),
    stdout: *std.Io.Writer,

    /// init a Files from a directory
    pub fn init(allocator: mem.Allocator, io: std.Io, dir: std.Io.Dir) !Self {
        // stdout
        var stdout_buf: [1024]u8 = undefined;
        var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buf);
        const stdout = &stdout_writer.interface;

        var files = try std.ArrayList(file.File).initCapacity(allocator, 32);

        var it = dir.iterate();
        while (try it.next(io)) |entry| {
            try files.append(allocator, file.File.init(&entry));
        }

        // sort files by name
        mem.sortUnstable(file.File, files.items, {}, file.File.nameLessThan);

        return .{
            .allocator = allocator,
            .io = io,
            .items = files,
            .stdout = stdout,
        };
    }

    pub fn deinit(self: *Self) void {
        self.items.deinit(self.allocator);
    }

    pub fn list(self: Self) !void {
        for (self.items.items) |val| {
            if (val.is_hidden) {
                continue;
            }

            try self.stdout.print("  {s}{s} {s:<5}\x1b[0m\t", .{ val.getColor(), val.getIcon(), val.name });
        }

        try self.stdout.print("\n", .{});
        try self.stdout.flush();
    }
};
