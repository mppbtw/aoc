const std = @import("std");

const digits = [_]u8{ '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' };

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {

        // Get the first digit
        var first: u8 = undefined;
        for (line) |ch| {
            if (isDigit(ch)) {
                first = try std.fmt.parseInt(u8, &[_]u8{ch}, 10);
                break;
            }
        }

        // Get the second one (just go backwards)
        var second: u8 = undefined;
        var i: usize = line.len;
        while (i > 0) {
            i -= 1;
            if (isDigit(line[i])) {
                second = try std.fmt.parseInt(u8, &[_]u8{line[i]}, 10);
                break;
            }
        }

        total += (10 * first) + second;
    }

    std.debug.print("{d}\n", .{total});
}

pub fn isDigit(n: u8) bool {
    for (digits) |digit| {
        if (digit == n) {
            return true;
        }
    }
    return false;
}
