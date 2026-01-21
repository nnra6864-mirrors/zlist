const std = @import("std");
const mem = std.mem;

pub const File = struct {
    const Self = @This();
    is_dir: bool,
    is_exec: bool,
    is_hidden: bool,
    name: []const u8,

    pub fn init(entry: *const std.Io.Dir.Entry) Self {
        const is_dir: bool = (entry.kind == .directory);

        return .{
            .is_hidden = (entry.name[0] == '.'),
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

    pub fn getColor(self: Self) []const u8 {
        if (self.is_dir) {
            // 普通蓝色 (文件夹)
            return Color.light_blue;
        } else if (self.is_exec) {
            // 黄色 (可执行)
            return Color.light_green;
        } else {
            // 黄色
            return Color.light_yellow;
        }
    }

    pub fn getIcon(self: Self) []const u8 {
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
            }

            // default file icon
            return " ";
        }
    }
};
