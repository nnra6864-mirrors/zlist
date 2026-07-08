# Using zlist as a Module

`zlist` can be used as a small listing library when you want file data instead of terminal output.

The CLI still handles colors, icons, columns, and printing. The module gives you the raw entries so you can render or process them however you like.

## Add the Package

From your Zig project:

```bash
zig fetch --save git+https://github.com/here-Leslie-Lau/zlist
```

That updates your `build.zig.zon` for you.

Then wire the module in your `build.zig`:

```zig
const zlist_dep = b.dependency("zlist", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("zlist", zlist_dep.module("zlist"));
```

## Basic Use

```zig
const std = @import("std");
const zlist = @import("zlist");

fn printNames(allocator: std.mem.Allocator, io: std.Io, dir: std.Io.Dir) !void {
    var files = try zlist.Files.init(allocator, io, dir, .{ .path = "." });
    defer files.deinit();

    for (files.entries()) |entry| {
        std.debug.print("{s}\n", .{entry.name});
    }
}
```

`Files.init` scans a directory and stores the result. Use `files.entries()` to read the entries.

## Options

Pass `zlist.FilesOptions` as the last argument to `Files.init`.

```zig
var files = try zlist.Files.init(allocator, io, dir, .{
    .path = ".",
    .show_hidden = true,
    .sort_type = .mtime,
    .only_file = true,
});
defer files.deinit();
```

Useful options:

| Option | What it does |
| :--- | :--- |
| `show_hidden` | Include names starting with `.`. |
| `show_detail` | Load extra metadata such as size, permissions, owner, and symlink target. |
| `dir_grouping` | Group directories `.none`, `.before`, `.after` |
| `sort_type` | Sort by `.name`, `.length`, `.dir_first`, `.mtime`, or `.size`. |
| `reverse` | Reverse sort. |
| `only_dir` | Keep only directories. |
| `only_file` | Keep only files. |
| `exts` | Hide files with matching extensions. |
| `matches` | Keep names that contain one of the given strings. |
| `size_range` | Keep files in a size range. |
| `changed_within` | Keep entries changed within a duration. |
| `recursive_dir_size` | Use recursive directory sizes when detail or size sort needs them. |
| `show_git` | Load git status data when the path is inside a git repository. |

## Ownership

Call `deinit` when you are done:

```zig
var files = try zlist.Files.init(allocator, io, dir, options);
defer files.deinit();
```

A few rules of thumb:

- `Files` owns the entry names, symlink targets, owner/group caches, and git status cache.
- Entries returned by `files.entries()` are borrowed from `files`.
- Do not keep entry slices after `files.deinit()`.
- The caller owns the directory passed to `Files.init`, so the caller should close it.

No tricks here: if you create a `Files`, defer `files.deinit()`.

## Public API

The top-level import exposes:

```zig
const zlist = @import("zlist");
```

Available types:

- `zlist.File`
- `zlist.Files`
- `zlist.FilesOptions`
- `zlist.FileOptions`
- `zlist.DirGrouping`
- `zlist.SortType`
- `zlist.SizeRange`
- `zlist.GitStatus`

Most users should start with `zlist.Files.init`, `files.entries()`, and `files.deinit()`.
