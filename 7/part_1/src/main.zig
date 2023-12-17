const std = @import("std");

const Hand = struct { cards: []u8, bid: usize };

const HandType = u8;

const HighCard = 0;
const OnePair = 1;
const TwoPair = 2;
const ThreeKind = 3;
const FullHouse = 4;
const FourKind = 5;
const FiveKind = 6;

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var lines = std.ArrayList([]const u8).init(alloc);
    var hands = std.ArrayList(Hand).init(alloc);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        lines.append(std.mem.Allocator.dupe(alloc, u8, line) catch unreachable) catch unreachable;
        hands.append(parseHand(line)) catch unreachable;
    }

    // Order each hand
    quickSort(Hand, hands.items, compareHands);

    var total: u128 = 0;
    var i: usize = 0;
    while (i < hands.items.len) : (i += 1) {
        total += hands.items[i].bid * (i + 1);
    }
    std.debug.print("{d}\n", .{total});
}

// They cant be the same hand, btw
fn compareHands(a: Hand, b: Hand) bool {
    var a_type = categoriseHand(a);
    var b_type = categoriseHand(b);

    if (a_type > b_type) {
        return false;
    }
    if (a_type < b_type) {
        return true;
    }

    // Uh-oh! They have the same type: time to compare the cards individually
    var i: u8 = 0;
    while (i < 5) : (i += 1) {
        if (a.cards[i] > b.cards[i])
            return false;

        if (a.cards[i] < b.cards[i])
            return true;
    }

    // We dont need to stress over the equal case, this isnt in the dataset
    return true;
}

fn categoriseHand(h: Hand) HandType {
    // Check for n of a kind
    var freqs = std.AutoHashMap(u8, u8).init(std.heap.page_allocator);
    var i: u8 = 0;
    while (i <= 14) : (i += 1) {
        freqs.put(i, 0) catch unreachable;
    }
    for (h.cards) |card| {
        freqs.put(card, freqs.get(card).? + 1) catch unreachable;
    }

    i = 0;
    var highest_count: u8 = 0;
    while (i <= 14) : (i += 1) {
        if (highest_count < freqs.get(i).?) {
            highest_count = freqs.get(i).?;
        }
    }

    if (highest_count == 5)
        return FiveKind;

    if (highest_count == 4)
        return FourKind;

    if (highest_count == 3) {
        i = 0;
        while (i <= 14) : (i += 1) {
            if (freqs.get(i).? == 2)
                return FullHouse;
        }
        return ThreeKind;
    }

    if (highest_count == 2) {
        var number_of_pairs: u8 = 0;
        i = 0;
        while (i <= 14) : (i += 1) {
            if (freqs.get(i).? == 2)
                number_of_pairs += 1;
        }

        if (number_of_pairs == 2)
            return TwoPair;

        return OnePair;
    }

    return HighCard;
}

fn parseHand(inp: []const u8) Hand {
    var sections = splitStr(inp, " ");
    var bid = std.fmt.parseInt(usize, sections.items[1], 10) catch undefined;
    var cards: [5]u8 = undefined;
    var i: usize = 0;
    while (i < cards.len) : (i += 1) {
        cards[i] = cardCharToInt(sections.items[0][i]);
    }
    return Hand{
        .bid = bid,
        .cards = std.mem.Allocator.dupe(std.heap.page_allocator, u8, &cards) catch unreachable,
    };
}

fn cardCharToInt(inp: u8) u8 {
    return switch (inp) {
        '0' => 0,
        '1' => 1,
        '2' => 2,
        '3' => 3,
        '4' => 4,
        '5' => 5,
        '6' => 6,
        '7' => 7,
        '8' => 8,
        '9' => 9,
        'T' => 10,
        'J' => 11,
        'Q' => 12,
        'K' => 13,
        'A' => 14,
        else => 0,
    };
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

// From https://github.com/alichraghi/zort
fn quickSort(
    comptime T: type,
    arr: []T,
    comptime cmp: fn (lhs: T, rhs: T) bool,
) void {
    return quickSortAdvanced(T, arr, 0, @max(arr.len, 1) - 1, cmp);
}

pub fn quickSortAdvanced(
    comptime T: type,
    arr: []T,
    left: usize,
    right: usize,
    comptime cmp: fn (lhs: T, rhs: T) bool,
) void {
    if (left >= right) return;
    const pivot = getPivot(T, arr, left, right, cmp);
    var i = left;
    var j = left;
    while (j < right) : (j += 1) {
        if (cmp(arr[j], pivot)) {
            std.mem.swap(T, &arr[i], &arr[j]);
            i += 1;
        }
    }
    std.mem.swap(T, &arr[i], &arr[right]);
    quickSortAdvanced(T, arr, left, @max(i, 1) - 1, cmp);
    quickSortAdvanced(T, arr, i + 1, right, cmp);
}

fn getPivot(
    comptime T: type,
    arr: []T,
    left: usize,
    right: usize,
    comptime cmp: fn (lhs: T, rhs: T) bool,
) T {
    const mid = (left + right) / 2;
    if (cmp(arr[mid], arr[left])) std.mem.swap(T, &arr[mid], &arr[left]);
    if (cmp(arr[right], arr[left])) std.mem.swap(T, &arr[right], &arr[left]);
    if (cmp(arr[mid], arr[right])) std.mem.swap(T, &arr[mid], &arr[right]);
    return arr[right];
}
