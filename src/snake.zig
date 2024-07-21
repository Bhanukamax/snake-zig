const std = @import("std");
const c = @import("c.zig");

var elapsTime: f32 = 0;
const speed = 50;
const size: f32 = 20.0;

fn debug(value: anytype) !void {
    var buf: [1000]u8 = undefined;
    const formated = try std.fmt.bufPrint(&buf, "direction: {}", .{value});
    buf[formated.len] = 0;
    c.DrawText(&buf, 100, 100, 30, c.GRAY);
}

pub const Direction = enum {
    Up,
    Down,
    Left,
    Right,
    pub fn isOpposite(self: Direction, other: Direction) bool {
        return switch (self) {
            .Up => other == .Down,
            .Down => other == .Up,
            .Right => other == .Left,
            .Left => other == .Right,
        };
    }
};

pub fn newSnake() !Snake {
    const sizeVec = c.Vector2{ .x = size, .y = size };
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // TODO: see if possible to do this without explicitly passing the allocator
    var body: std.ArrayList(c.Vector2) = std
        .ArrayList(c.Vector2)
        .init(gpa.allocator());
    try body.append(c.Vector2{ .x = 2, .y = 2 });
    try body.append(c.Vector2{ .x = 2, .y = 1 });
    try body.append(c.Vector2{ .x = 3, .y = 1 });
    return Snake{
        .size = sizeVec,
        .direction = .Down,
        .body = body,
    };
}

pub const Snake = struct {
    body: std.ArrayList(c.Vector2),
    size: c.Vector2,
    direction: Direction,
    fn turn(self: *Snake, direction: Direction) void {
        if (direction.isOpposite(self.direction) or direction == self.direction) {
            return;
        }
        self.direction = direction;
    }
    pub fn moveSnake(self: *Snake, delta: f32) !void {
        elapsTime += delta;
        if (elapsTime > 0.2) {
            const head = self.body.pop();
            try self.body.append(head);
            const newHead = switch (self.direction) {
                .Up => c.Vector2{.x = head.x, .y = head.y - 1},
                .Down => c.Vector2{.x = head.x, .y = head.y + 1},
                .Left => c.Vector2{.x = head.x - 1, .y = head.y},
                .Right => c.Vector2{.x = head.x + 1, .y = head.y},
            };
            try self.body.append(newHead);
            _  = self.body.orderedRemove(0);
            elapsTime = 0;
        }
        try debug(self.direction);
    }
    pub fn drawSnake(self: *Snake) !void {
        for (self.body.items) |cell| {
            const cellPos =
                c.Vector2{
                .x = @floatCast(self.size.x * cell.x),
                .y = @floatCast(self.size.y * cell.y),
            };
            c.DrawRectangleV(cellPos, self.size, c.GREEN);
        }
    }
    pub fn handleKeys(self: *Snake, key: i32) void {
        _ = switch (key) {
            c.KEY_LEFT, c.KEY_J => self.turn(.Left),
            c.KEY_RIGHT, c.KEY_L => self.turn(.Right),
            c.KEY_UP, c.KEY_I => self.turn(.Up),
            c.KEY_DOWN, c.KEY_K => self.turn(.Down),
            else => undefined,
        };
    }
};
