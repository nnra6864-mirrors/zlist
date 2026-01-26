const std = @import("std");
const mem = std.mem;

pub const File = struct {
    const Self = @This();
    is_dir: bool,
    is_exec: bool,
    is_hidden: bool,
    name: []const u8,

    /// Initialize a File from a directory entry. Returns null if the entry is hidden and show_hidden is false.
    pub inline fn init(entry: *const std.Io.Dir.Entry, show_hidden: bool) ?Self {
        const is_dir: bool = (entry.kind == .directory);
        const is_hidden: bool = (entry.name[0] == '.');

        if (!show_hidden and is_hidden) {
            return null;
        }

        return .{
            .is_hidden = is_hidden,
            .is_dir = is_dir,
            .is_exec = false,
            .name = entry.name,
        };
    }

    pub fn nameLessThan(_: void, lhs: Self, rhs: Self) bool {
        return std.ascii.orderIgnoreCase(lhs.name, rhs.name) == .lt;
    }

    const Color = struct {
        const reset = "\x1b[0m";
        const light_blue = "\x1b[94m";
        const light_green = "\x1b[92m";
        const cyan = "\x1b[36m";
        const light_magenta = "\x1b[95m";
        const light_yellow = "\x1b[93m";
        const red = "\x1b[31m";
        const white = "\x1b[37m";
    };

    pub inline fn getColor(self: Self) []const u8 {
        // TODO: add more colors based on file type
        if (self.is_dir) {
            // blue (directory)
            return Color.light_blue;
        } else {
            // default file color
            return Color.light_yellow;
        }
    }

    pub inline fn getIcon(self: Self) []const u8 {
        if (self.is_dir) {
            return " ";
        } else {
            if (std.mem.endsWith(u8, self.name, ".zig")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".go")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".c")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".json")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".md")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".py")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".toml")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".yaml")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".js")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".ts")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".html")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".css")) {
                return " ";
            } else if (std.mem.endsWith(u8, self.name, ".java")) {
                return " ";
            }

            // default file icon
            return " ";
        }
    }

    ///  Print a single file item to the provided writer.
    pub inline fn print_single_item(self: Self, writer: *std.Io.Writer, max_display_len: usize) !void {
        const icon = self.getIcon();
        try writer.print("  {s}{s} {s:<[3]}\x1b[0m", .{ self.getColor(), icon, self.name, max_display_len - icon.len + 1 });
    }
};
