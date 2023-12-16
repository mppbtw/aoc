const std = @import("std");

const Game = struct { red: usize, green: usize, blue: usize, id: usize };

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        total += getPointValue(line);
    }

    std.debug.print("{d}\n", .{total});
}

fn getPointValue(inp: []const u8) usize {
    var card = parseCard(inp);

    var n_of_winning: usize = 0;
    for (card.numbers.items) |n| {
        if (arrayContains(card.winning, n)) {
            n_of_winning += 1;
        }
    }

    if (n_of_winning == 0)
        return 0;

    return @as(usize, 1) << @truncate(n_of_winning - 1);
}

fn arrayContains(arr: std.ArrayList(usize), target: usize) bool {
    for (arr.items) |a| {
        if (a == target)
            return true;
    }
    return false;
}

const Card = struct {
    id: usize,
    winning: std.ArrayList(usize),
    numbers: std.ArrayList(usize),
};

fn parseCard(inp: []const u8) Card {
    var alloc = std.heap.page_allocator;
    var out = Card{ .winning = std.ArrayList(usize).init(alloc), .numbers = std.ArrayList(usize).init(alloc), .id = 0 };

    var winning_chars = splitStr(splitStr(splitStr(inp, ":").items[1], "|").items[0], " ");
    for (winning_chars.items) |n| {
        std.debug.print("trying to parse the number: <{s}>\n", .{n});
        out.winning.append(std.fmt.parseInt(u8, n, 10) catch unreachable) catch unreachable;
    }

    var number_chars = splitStr(splitStr(splitStr(inp, ":").items[1], "|").items[1], " ");
    for (number_chars.items) |n| {
        std.debug.print("trying to parse the number: {s}\n", .{n});
        out.numbers.append(std.fmt.parseInt(u8, n, 10) catch unreachable) catch unreachable;
    }
    return out;
}

fn splitStr(inp: []const u8, split: []const u8) std.ArrayList([]const u8) {
    var out = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var s = std.mem.split(u8, inp, split);
    while (s.next()) |i| {
        if (!std.mem.eql(u8, i, split) and i.len != 0)
            out.append(i) catch unreachable;
    }

    return out;
}
