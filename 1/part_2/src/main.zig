const std = @import("std");

const ascii_digits = [_]u8{ '1', '2', '3', '4', '5', '6', '7', '8', '9' };

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var digits = getDigits(line);
        total += (10 * digits.items[0]) + digits.items[digits.items.len - 1];
        std.debug.print("{d}\n", .{(10 * digits.items[0]) + digits.items[digits.items.len - 1]});
    }

    std.debug.print("{d}\n", .{total});
}

fn getDigits(inp: []u8) std.ArrayList(u8) {
    var read_pos: usize = 0;
    var out = std.ArrayList(u8).init(std.heap.page_allocator);
    while (read_pos < inp.len) : (read_pos += 1) {

        // Check normal digits
        var char_digit: u8 = getDigitFromChar(inp[read_pos]);
        if (char_digit != 0) {
            out.append(char_digit) catch unreachable;
            continue;
        }

        // Check spelt-out digits
        var peek_count: u8 = 1;
        while (true) {
            if (read_pos + peek_count >= inp.len + 1) {
                break;
            }
            var possible = getPossibleDigits(inp[read_pos .. read_pos + peek_count]);
            defer possible.deinit();
            if (possible.items.len == 0) {
                break;
            }
            if (possible.items.len == 1 and nameOfDigit(possible.getLast()).len == peek_count) {
                out.append(possible.getLast()) catch unreachable;
                break;
            }
            peek_count += 1;
        }
    }
    return out;
}

// The input is a slice of the relevant parts to match,
// not the whole line
fn getPossibleDigits(inp: []const u8) std.ArrayList(u8) {
    var out = std.ArrayList(u8).init(std.heap.page_allocator);
    var i: u8 = 0;
    while (i < 9) : (i += 1) {
        if (inp.len > nameOfDigit(i + 1).len) {
            continue;
        }
        var relevant_slice = nameOfDigit(i + 1)[0..inp.len];
        if (std.mem.eql(u8, relevant_slice, inp)) {
            out.append(i + 1) catch unreachable;
        }
    }
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
