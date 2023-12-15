const std = @import("std");

const max_red: usize = 12;
const max_green: usize = 13;
const max_blue: usize = 14;

const Game = struct { red: usize, green: usize, blue: usize, id: usize };

pub fn main() !void {
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var g = parseGame(line);

        total +=  g.red * g.blue * g.green;
    }

    std.debug.print("{d}\n", .{total});
}

fn parseGame(inp: []u8) Game {
    var game = Game{ .id = 0, .red = 0, .blue = 0, .green = 0 };

    // 01234567
    // Game 123:
    game.id = std.fmt.parseInt(u8, splitStr(splitStr(inp, ":").items[0], " ").items[1], 10) catch unreachable;

    // Stuff to the right of the 'Game 123:' stuff
    var handfuls = splitStr(splitStr(inp, ":").items[1], ";").items;
    for (handfuls) |handful| {
        var res = parseHandful(handful);
        if (res.red > game.red) {
            game.red = res.red;
        }
        if (res.green > game.green) {
            game.green = res.green;
        }
        if (res.blue > game.blue) {
            game.blue = res.blue;
        }
    }

    std.debug.print("Game: '{d}', red: {d}, blue: {d}, green: {d}\n", .{ game.id, game.red, game.blue, game.green });
    return game;
}

const Handful = struct {
    green: usize,
    blue: usize,
    red: usize,
};

fn parseHandful(inp: []const u8) Handful {
    var out = Handful{ .green = 0, .blue = 0, .red = 0 };
    var sections = splitStr(inp, ",");
    for (sections.items) |sec| {
        var col = splitStr(sec, " ").items[2];
        var number = splitStr(sec, " ").items[1];

        if (std.mem.eql(u8, col, "red")) {
            out.red = std.fmt.parseInt(u8, number, 10) catch unreachable;
        } else if (std.mem.eql(u8, col, "blue")) {
            out.blue = std.fmt.parseInt(u8, number, 10) catch unreachable;
        } else if (std.mem.eql(u8, col, "green")) {
            out.green = std.fmt.parseInt(u8, number, 10) catch unreachable;
        }
    }

    std.debug.print("Handful: green: {d}, red: {d}, blue: {d}\n", .{ out.green, out.red, out.blue });
    return out;
}

fn splitStr(inp: []const u8, split: []const u8) std.ArrayList([]const u8) {
    var out = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var s = std.mem.split(u8, inp, split);
    while (s.next()) |i| {
        out.append(i) catch unreachable;
    }

    return out;
}
