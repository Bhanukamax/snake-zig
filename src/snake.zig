const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

var elapsTime: f32 = 0;
const speed = 50;
const size: f32 = 20.0;

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
    const sizeVec = ray.Vector2{ .x = size, .y = size };
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // TODO: see if possible to do this without explicitly passing the allocator
    var body: std.ArrayList(ray.Vector2) = std
        .ArrayList(ray.Vector2)
        .init(gpa.allocator());
    try body.append(ray.Vector2{ .x = 2, .y = 2 });
    try body.append(ray.Vector2{ .x = 2, .y = 1 });
    try body.append(ray.Vector2{ .x = 3, .y = 1 });
    return Snake{
        .size = sizeVec,
        .direction = .Down,
        .body = body,
    };
}

pub const Snake = struct {
    body: std.ArrayList(ray.Vector2),
    size: ray.Vector2,
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
                .Up => ray.Vector2{.x = head.x, .y = head.y - 1},
                .Down => ray.Vector2{.x = head.x, .y = head.y + 1},
                .Left => ray.Vector2{.x = head.x - 1, .y = head.y},
                .Right => ray.Vector2{.x = head.x + 1, .y = head.y},
            };
            try self.body.append(newHead);
            _  = self.body.orderedRemove(0);
            elapsTime = 0;
        }
        var buf: [1000]u8 = undefined;

        const formated = try std.fmt.bufPrint(&buf, "direction: {}", .{self.direction});
        buf[formated.len] = 0;

        ray.DrawText(&buf, 100, 100, 30, ray.GRAY);
    }
    pub fn drawSnake(self: *Snake) !void {
        for (self.body.items) |cell| {
            const cellPos =
                ray.Vector2{
                .x = @floatCast(self.size.x * cell.x),
                .y = @floatCast(self.size.y * cell.y),
            };
            ray.DrawRectangleV(cellPos, self.size, ray.GREEN);
        }
    }
    pub fn handleKeys(self: *Snake, key: i32) void {
        _ = switch (key) {
            ray.KEY_LEFT, ray.KEY_J => self.turn(.Left),
            ray.KEY_RIGHT, ray.KEY_L => self.turn(.Right),
            ray.KEY_UP, ray.KEY_I => self.turn(.Up),
            ray.KEY_DOWN, ray.KEY_K => self.turn(.Down),
            else => undefined,
        };
    }
};
