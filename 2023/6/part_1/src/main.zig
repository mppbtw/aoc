const std = @import("std");

const Game = struct { red: usize, green: usize, blue: usize, id: usize };

const Race = struct {
    time: usize,
    record: usize,
};

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var lines = std.ArrayList([]const u8).init(alloc);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        lines.append(std.mem.Allocator.dupe(alloc, u8, line) catch unreachable) catch unreachable;
    }

    var chart = std.ArrayList(Race).init(alloc);
    var times = splitStr(lines.items[0], " ").items[1..];
    var distances = splitStr(lines.items[1], " ").items[1..];
    var i: usize = 0;
    while (i < times.len) : (i += 1) {
        chart.append(Race{
            .time = std.fmt.parseInt(usize, times[i], 10) catch unreachable,
            .record = std.fmt.parseInt(usize, distances[i], 10) catch unreachable,
        }) catch unreachable;
    }

    var total: usize = 1;
    for (chart.items) |r| {
        total *= getWinningPressTimes(r).items.len;
    }
    std.debug.print("{d}\n", .{total});
}

fn product(nums: []usize) usize {
    var total: usize = 1;
    for (nums) |num| {
        total *= num;
    }
    return total;
}

fn getWinningPressTimes(r: Race) std.ArrayList(usize) {
    var out = std.ArrayList(usize).init(std.heap.page_allocator);

    var press: usize = 0;
    while (press < r.time) : (press += 1) {
        var distance = (r.time - press) * press;
        if (distance > r.record) {
            out.append(distance) catch unreachable;
        } else if (out.items.len != 0) { // The end of winning times
            return out;
        }
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
