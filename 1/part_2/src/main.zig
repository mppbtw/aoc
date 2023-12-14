const std = @import("std");

const ascii_digits = [_]u8{ '1', '2', '3', '4', '5', '6', '7', '8', '9' };
const ascii_digit_names = [_][]u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var digits = getDigits(line);
        std.debug.print("digits found: {d}\n", .{digits.items});
        total += (10 * digits.items[0]) + digits.items[digits.items.len - 1];
    }

    std.debug.print("{d}\n", .{total});
}

fn getDigits(inp: []u8) std.ArrayList(u8) {
    var read_pos: usize = 0;
    var out = std.ArrayList(u8).init(std.heap.page_allocator);
    for (inp) |ch| {

        // Check normal digits
        var char_digit: u8 = getDigitFromChar(ch);
        if (char_digit != 0) {
            std.debug.print("digit (1): {d}\n", .{char_digit});
            out.append(char_digit) catch unreachable;
            continue;
        }

        // Check spelt-out digits
        var peek_count: u8 = 0;
        while (true) {
            var possible = getPossibleDigits(inp[read_pos .. read_pos + peek_count]);
            defer possible.deinit();
            if (possible.items.len == 0) {
                break;
            }
            if (possible.items.len == 1 and nameOfDigit(possible.getLast()).len == peek_count) {
                std.debug.print("digit (2): {d}\n", .{possible.getLast()});
                out.append(possible.getLast()) catch unreachable;
                break;
            }
            peek_count += 1;
        }
        read_pos += 1;
    }
    return out;
}

fn getPossibleDigits(inp: []u8) std.ArrayList(u8) {
    _ = inp;
    var out = std.ArrayList(u8).init(std.heap.page_allocator);
    return out;
}

fn nameOfDigit(n: u8) []const u8 {
    switch (n) {
        1 => return "one",
        2 => return "two",
        3 => return "three",
        4 => return "four",
        5 => return "five",
        6 => return "six",
        7 => return "seven",
        8 => return "eight",
        9 => return "nine",
        else => return "",
    }
}

fn getDigitFromChar(ch: u8) u8 {
    var i: u8 = 0;
    for (ascii_digits) |d| {
        if (ch == d) {
            return i + 1;
        }
        i += 1;
    }
    return 0;
}
