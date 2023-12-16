const std = @import("std");

const Game = struct { red: usize, green: usize, blue: usize, id: usize };

const Card = struct {
    id: usize,
    winning: std.ArrayList(usize),
    numbers: std.ArrayList(usize),
};

pub fn main() !void {
    var alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var cards = std.ArrayList(Card).init(alloc);
    var copies = std.AutoHashMap(usize, usize).init(alloc);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        cards.append(parseCard(line)) catch unreachable; // The input is already sorted
        copies.put(cards.getLast().id, 1) catch unreachable;
    }

    var total: usize = 0;

    for (cards.items) |card| {
        // Do this for every copy of the card
        var wins = howManyWinning(card);

        //std.debug.print("Number of copies for card.id: {d} is {d} and it as {d} wins\n", .{ card.id, copies.get(card.id).?, wins });
        // For every copy of the card
        var i: usize = 0;
        while (i < copies.get(card.id).?) : (i += 1) {
            total += 1;
            //std.debug.print("processing a copy of card {d}\n", .{card.id});
            var q: usize = 1;
            // Make new copies of the next cards
            while (q <= wins) : (q += 1) {
                //std.debug.print("   adding a copy of card '{d}'\n", .{card.id + q});
                var current_copies = copies.get(card.id + q).?;
                copies.put(card.id + q, current_copies + 1) catch unreachable;
            }
        }
    }

    std.debug.print("{d}\n", .{total});
}

fn howManyWinning(c: Card) usize {
    var total: usize = 0;
    for (c.numbers.items) |n| {
        if (arrayContains(c.winning, n))
            total += 1;
    }
    return total;
}

fn arrayContains(arr: std.ArrayList(usize), target: usize) bool {
    for (arr.items) |a| {
        if (a == target)
            return true;
    }
    return false;
}

fn parseCard(inp: []const u8) Card {
    var alloc = std.heap.page_allocator;
    var out = Card{ .winning = std.ArrayList(usize).init(alloc), .numbers = std.ArrayList(usize).init(alloc), .id = 0 };

    out.id = std.fmt.parseInt(usize, splitStr(splitStr(inp, ":").items[0], " ").items[1], 10) catch unreachable;

    var winning_chars = splitStr(splitStr(splitStr(inp, ":").items[1], "|").items[0], " ");
    for (winning_chars.items) |n| {
        out.winning.append(std.fmt.parseInt(u8, n, 10) catch unreachable) catch unreachable;
    }

    var number_chars = splitStr(splitStr(splitStr(inp, ":").items[1], "|").items[1], " ");
    for (number_chars.items) |n| {
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
