const std = @import("std");
const stdout = std.io.getStdOut().writer();

fn find(path: []u8, text: []const u8, allocator: std.mem.Allocator) !void {
    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        try stdout.print("Failed to open file: {s}", .{@errorName(err)});
        return;
    };
    defer file.close();

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize)) catch |err| {
        try stdout.print("Failed to read file: {s}", .{@errorName(err)});
        return;
    }) |line| {
        defer allocator.free(line);
        var lines = std.mem.split(u8, line, " ");
        while (lines.next()) |item| {
            if (std.mem.eql(u8, item, text)) {
                try stdout.print("{s}\n", .{line});
            }
        }
    }   
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len > 2) {
        try find(args[1], args[2], allocator);
    } else {
        try stdout.print("Usage: grepz [file] [file]\n", .{});
    }
}

