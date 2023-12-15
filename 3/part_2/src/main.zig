const std = @import("std");

const symbols = [_]u8{ '$', '%', '/', '&', '~', '-', '+', '_', '@', '+', '#', '*', '=' };
const digits = [_]u8{ '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' };

pub fn main() !void {
    var alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: usize = 0;
    var lines = std.ArrayList([]const u8).init(alloc);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.debug.print("line: {s}\n", .{line});
        lines.append(std.mem.Allocator.dupe(alloc, u8, line) catch unreachable) catch unreachable;
        std.debug.print("appended line: {s}\n", .{lines.items});
    }

    var i: usize = 0;
    while (i < lines.items.len) : (i += 1) {
        var j: usize = 0;
        while (j < lines.items[0].len) : (j += 1) {
            if (isDigit(lines.items[i][j])) {
                var num_offset: usize = 0;
                while (true) {
                    if (lines.items[0].len > j + num_offset) {
                        if (isDigit(lines.items[i][j + num_offset])) {
                            num_offset += 1;
                        } else {
                            break;
                        }
                    } else {
                        break;
                    }
                }

                // Parse what the number is
                var number = std.fmt.parseInt(usize, lines.items[i][j .. j + num_offset], 10) catch unreachable;

                // Get the surrounding slots
                var surrounding_chars = std.ArrayList(u8).init(std.heap.page_allocator);

                // Char on the right
                if (lines.items[0].len - 1 > j + num_offset)
                    surrounding_chars.append(lines.items[i][j + num_offset]) catch unreachable;

                // Char on the left
                if (j > 0)
                    surrounding_chars.append(lines.items[i][j - 1]) catch unreachable;

                // Chars on the top
                if (i > 0) { // Ensure it's not the top line

                    // Top right
                    if (lines.items[0].len - 1 > j + num_offset)
                        surrounding_chars.append(lines.items[i - 1][j + num_offset]) catch unreachable;

                    // Top left
                    if (j > 0)
                        surrounding_chars.append(lines.items[i - 1][j - 1]) catch unreachable;

                    // All of the ones at the top
                    var q: usize = 0;
                    while (q < num_offset) : (q += 1) {
                        surrounding_chars.append(lines.items[i - 1][j + q]) catch unreachable;
                    }
                }

                // Chars on the bottom
                if (lines.items.len - 1 != i) { // Ensure it's not the bottom line

                    // bottom right
                    if (lines.items[0].len - 1 > j + num_offset)
                        surrounding_chars.append(lines.items[i + 1][j + num_offset]) catch unreachable;

                    // bottom left
                    if (j > 0)
                        surrounding_chars.append(lines.items[i + 1][j - 1]) catch unreachable;

                    // All of the ones at the bottom
                    var q: usize = 0;
                    while (q < num_offset) : (q += 1) {
                        surrounding_chars.append(lines.items[i + 1][j + q]) catch unreachable;
                    }
                }

                for (surrounding_chars.items) |ch| {
                    if (isSymbol(ch)) {
                        total += number;
                    }
                }

                std.debug.print("Surrounding: {c}\n", .{surrounding_chars.items});
                j += num_offset;
            }
        }
    }
    std.debug.print("{d}\n", .{total});
}

fn isSymbol(inp: u8) bool {
    for (symbols) |s| {
        if (inp == s)
            return true;
    }
    return false;
}

fn parseDigit(inp: u8) u8 {
    return inp - 48;
}

fn isDigit(inp: u8) bool {
    for (digits) |d| {
        if (inp == d)
            return true;
    }
    return false;
}
