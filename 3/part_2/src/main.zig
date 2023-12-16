const std = @import("std");

const symbols = [_]u8{ '$', '%', '/', '&', '~', '-', '+', '_', '@', '+', '#', '*', '=' };
const digits = [_]u8{ '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' };

const Point = struct {
    x: usize,
    y: usize,
};

const Gear = struct {
    p: Point,
    numbers: std.ArrayList(usize),
};

pub fn main() !void {
    var alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var asterisks = std.ArrayList(Gear).init(alloc);

    var buf: [1024]u8 = undefined;
    var lines = std.ArrayList([]const u8).init(alloc);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        lines.append(std.mem.Allocator.dupe(alloc, u8, line) catch unreachable) catch unreachable;
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
                var surrounding_chars = std.ArrayList(Point).init(std.heap.page_allocator);

                // Char on the right
                if (lines.items[0].len - 1 > j + num_offset)
                    surrounding_chars.append(Point{ .x = j + num_offset, .y = i }) catch unreachable;

                // Char on the left
                if (j > 0)
                    surrounding_chars.append(Point{ .y = i, .x = j - 1 }) catch unreachable;

                // Chars on the top
                if (i > 0) { // Ensure it's not the top line

                    // Top right
                    if (lines.items[0].len - 1 > j + num_offset)
                        surrounding_chars.append(Point{ .y = i - 1, .x = j + num_offset }) catch unreachable;

                    // Top left
                    if (j > 0)
                        surrounding_chars.append(Point{ .y = i - 1, .x = j - 1 }) catch unreachable;

                    // All of the ones at the top
                    var q: usize = 0;
                    while (q < num_offset) : (q += 1) {
                        surrounding_chars.append(Point{ .y = i - 1, .x = j + q }) catch unreachable;
                    }
                }

                // Chars on the bottom
                if (lines.items.len - 1 != i) { // Ensure it's not the bottom line

                    // bottom right
                    if (lines.items[0].len - 1 > j + num_offset)
                        surrounding_chars.append(Point{ .y = i + 1, .x = j + num_offset }) catch unreachable;

                    // bottom left
                    if (j > 0)
                        surrounding_chars.append(Point{ .y = i + 1, .x = j - 1 }) catch unreachable;

                    // All of the ones at the bottom
                    var q: usize = 0;
                    while (q < num_offset) : (q += 1) {
                        surrounding_chars.append(Point{ .y = i + 1, .x = j + q }) catch unreachable;
                    }
                }

                for (surrounding_chars.items) |ch| {
                    if (lines.items[ch.y][ch.x] == '*') {
                        // Check the if it's already been found
                        var q: usize = 0;
                        var ugly_skip_antipattern = false;
                        while (q < asterisks.items.len) : (q += 1) {
                            if (asterisks.items[q].p.x == ch.x and asterisks.items[q].p.y == ch.y) {
                                asterisks.items[q].numbers.append(number) catch unreachable;
                                std.debug.print("   numbers: {d}\n", .{asterisks.items[q].numbers.items});
                                ugly_skip_antipattern = true;
                            }
                        }

                        if (!ugly_skip_antipattern) {
                            var numbers = std.ArrayList(usize).init(alloc);
                            numbers.append(number) catch unreachable;
                            asterisks.append(Gear{ .p = Point{ .x = ch.x, .y = ch.y }, .numbers = numbers }) catch unreachable;
                        }
                    }
                }

                j += num_offset;
            }
        }
    }

    // Remove gears which aren't adjacent to exactly 2 numbers
    var total: usize = 0;
    for (asterisks.items) |a| {
        if (a.numbers.items.len == 2) {
            std.debug.print("GEAR DETECTED\n", .{});
            total += a.numbers.items[0] * a.numbers.items[1];
        }
    }

    std.debug.print("{d}\n", .{total});
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
