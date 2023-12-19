const std = @import("std");

const Game = struct { red: usize, green: usize, blue: usize, id: usize };

const NumRange = struct {
    start: usize,
    len: usize,
};

const Map = struct {
    src_start: usize,
    dest_start: usize,
    range: usize,
};

const Almanac = struct {
    seeds: std.ArrayList(NumRange),
    seeds_to_soil: std.ArrayList(Map),
    soil_to_fertilizer: std.ArrayList(Map),
    fertilizer_to_water: std.ArrayList(Map),
    water_to_light: std.ArrayList(Map),
    light_to_temperature: std.ArrayList(Map),
    temperature_to_humidity: std.ArrayList(Map),
    humidity_to_location: std.ArrayList(Map),

    pub fn init(a: std.mem.Allocator) Almanac {
        return Almanac{
            .seeds = std.ArrayList(NumRange).init(a),
            .seeds_to_soil = std.ArrayList(Map).init(a),
            .soil_to_fertilizer = std.ArrayList(Map).init(a),
            .fertilizer_to_water = std.ArrayList(Map).init(a),
            .water_to_light = std.ArrayList(Map).init(a),
            .light_to_temperature = std.ArrayList(Map).init(a),
            .temperature_to_humidity = std.ArrayList(Map).init(a),
            .humidity_to_location = std.ArrayList(Map).init(a),
        };
    }
};

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile("./input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: usize = 0;
    _ = total;
    var lines = std.ArrayList([]const u8).init(alloc);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        lines.append(std.mem.Allocator.dupe(alloc, u8, line) catch unreachable) catch unreachable;
    }

    var almanac = parseAlmanac(lines);

    // Get all the location numbers
    var lowest_location: usize = std.math.maxInt(usize);

    for (almanac.seeds.items) |range| {
        std.debug.print("Starting the range {d} length {d}\n", .{ range.start, range.len });
        var i: usize = 0;
        while (i < range.len) : (i += 1) {
            var seed = range.start + i;
            var soil = evaluateMaps(seed, almanac.seeds_to_soil);
            var fertilizer = evaluateMaps(soil, almanac.soil_to_fertilizer);
            var water = evaluateMaps(fertilizer, almanac.fertilizer_to_water);
            var light = evaluateMaps(water, almanac.water_to_light);
            var temperature = evaluateMaps(light, almanac.light_to_temperature);
            var humidity = evaluateMaps(temperature, almanac.temperature_to_humidity);
            var location = evaluateMaps(humidity, almanac.humidity_to_location);
            if (location < lowest_location)
                lowest_location = location;
        }
    }

    std.debug.print("{d}\n", .{lowest_location});
}

fn parseAlmanac(lines: std.ArrayList([]const u8)) Almanac {
    // Iterate over lines
    var a = Almanac.init(std.heap.page_allocator);
    var seed_chars = splitStr(splitStr(lines.items[0], ":").items[1], " ");

    var i: usize = 0;
    while (i < seed_chars.items.len) : (i += 1) {
        var start = std.fmt.parseInt(usize, seed_chars.items[i], 10) catch unreachable;

        i += 1;

        var range = std.fmt.parseInt(usize, seed_chars.items[i], 10) catch unreachable;
        a.seeds.append(NumRange{ .start = start, .len = range }) catch unreachable;
    }

    var read_pos: usize = 0;
    // Get to the first map set
    while (!std.mem.eql(u8, lines.items[read_pos], "seed-to-soil map:")) : (read_pos += 1) {}
    read_pos += 1;

    // Read this map set
    while (lines.items[read_pos].len != 0) : (read_pos += 1) {
        var sections = splitStr(lines.items[read_pos], " ");
        var m = Map{ .range = 0, .src_start = 0, .dest_start = 0 };
        m.dest_start = std.fmt.parseInt(usize, sections.items[0], 10) catch unreachable;
        m.src_start = std.fmt.parseInt(usize, sections.items[1], 10) catch unreachable;
        m.range = std.fmt.parseInt(usize, sections.items[2], 10) catch unreachable;

        a.seeds_to_soil.append(m) catch unreachable;
    }

    // Skip past the empty line and next header
    read_pos += 2;

    // Read this map set... you get the point, do this for every other map set
    while (lines.items[read_pos].len != 0) : (read_pos += 1) {
        var sections = splitStr(lines.items[read_pos], " ");
        var m = Map{ .range = 0, .src_start = 0, .dest_start = 0 };
        m.dest_start = std.fmt.parseInt(usize, sections.items[0], 10) catch unreachable;
        m.src_start = std.fmt.parseInt(usize, sections.items[1], 10) catch unreachable;
        m.range = std.fmt.parseInt(usize, sections.items[2], 10) catch unreachable;

        a.soil_to_fertilizer.append(m) catch unreachable;
    }

    read_pos += 2;
    while (lines.items[read_pos].len != 0) : (read_pos += 1) {
        var sections = splitStr(lines.items[read_pos], " ");
        var m = Map{ .range = 0, .src_start = 0, .dest_start = 0 };
        m.dest_start = std.fmt.parseInt(usize, sections.items[0], 10) catch unreachable;
        m.src_start = std.fmt.parseInt(usize, sections.items[1], 10) catch unreachable;
        m.range = std.fmt.parseInt(usize, sections.items[2], 10) catch unreachable;

        a.fertilizer_to_water.append(m) catch unreachable;
    }

    read_pos += 2;
    while (lines.items[read_pos].len != 0) : (read_pos += 1) {
        var sections = splitStr(lines.items[read_pos], " ");
        var m = Map{ .range = 0, .src_start = 0, .dest_start = 0 };
        m.dest_start = std.fmt.parseInt(usize, sections.items[0], 10) catch unreachable;
        m.src_start = std.fmt.parseInt(usize, sections.items[1], 10) catch unreachable;
        m.range = std.fmt.parseInt(usize, sections.items[2], 10) catch unreachable;

        a.water_to_light.append(m) catch unreachable;
    }

    read_pos += 2;
    while (lines.items[read_pos].len != 0) : (read_pos += 1) {
        var sections = splitStr(lines.items[read_pos], " ");
        var m = Map{ .range = 0, .src_start = 0, .dest_start = 0 };
        m.dest_start = std.fmt.parseInt(usize, sections.items[0], 10) catch unreachable;
        m.src_start = std.fmt.parseInt(usize, sections.items[1], 10) catch unreachable;
        m.range = std.fmt.parseInt(usize, sections.items[2], 10) catch unreachable;

        a.light_to_temperature.append(m) catch unreachable;
    }

    read_pos += 2;
    while (lines.items[read_pos].len != 0) : (read_pos += 1) {
        var sections = splitStr(lines.items[read_pos], " ");
        var m = Map{ .range = 0, .src_start = 0, .dest_start = 0 };
        m.dest_start = std.fmt.parseInt(usize, sections.items[0], 10) catch unreachable;
        m.src_start = std.fmt.parseInt(usize, sections.items[1], 10) catch unreachable;
        m.range = std.fmt.parseInt(usize, sections.items[2], 10) catch unreachable;

        a.temperature_to_humidity.append(m) catch unreachable;
    }

    // We can jog along to the end now not worrying about the empty line
    read_pos += 2;
    while (lines.items.len > read_pos) : (read_pos += 1) {
        var sections = splitStr(lines.items[read_pos], " ");
        var m = Map{ .range = 0, .src_start = 0, .dest_start = 0 };
        m.dest_start = std.fmt.parseInt(usize, sections.items[0], 10) catch unreachable;
        m.src_start = std.fmt.parseInt(usize, sections.items[1], 10) catch unreachable;
        m.range = std.fmt.parseInt(usize, sections.items[2], 10) catch unreachable;

        a.humidity_to_location.append(m) catch unreachable;
    }

    return a;
}

// Only 1 line (not a whole map set)
fn parseMap(inp: []const u8) Map {
    var s = splitStr(inp, " ");
    return Map{ .dest_start = s[0], .src_start = s[1], .range = s[2] };
}

fn evaluateMaps(n: usize, maps: std.ArrayList(Map)) usize {
    for (maps.items) |map| {
        if (n >= map.src_start and n <= map.src_start + map.range) {
            return map.dest_start + (n - map.src_start);
        }
    }

    // No maps apply to this nummah
    return n;
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
