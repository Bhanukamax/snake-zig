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
        return switch(self) {
            .Up => other == .Down,
            .Down => other == .Up,
            .Right => other == .Left,
            .Left => other == .Right,
        };
    }
};

pub fn newSnake() Snake {
    const sizeVec = ray.Vector2{ .x = size, .y = size };
    const pos = ray.Vector2{ .x = 20.0, .y = 20.0 };
    return Snake{ .pos = pos, .size = sizeVec, .direction = .Down };
}

pub const Snake = struct {
    pos: ray.Vector2,
    size: ray.Vector2,
    direction: Direction,
    fn turn(self: *Snake, direction: Direction) void {
        if (direction == self.direction) {
            return;
        }
        if (direction.isOpposite(self.direction)) {
            return;
        }
        self.direction = direction;
    }
    pub fn moveSnake(self: *Snake, delta: f32) !void {
        elapsTime += delta;
        if (elapsTime > 0.2) {
            switch (self.direction) {
                .Up => self.pos.y -= size,
                .Down => self.pos.y += size,
                .Left => self.pos.x -= size,
                .Right => self.pos.x += size,
            }
            elapsTime = 0;
        }
        var buf: [1000]u8 = undefined;

        const formated = try std.fmt.bufPrint(&buf, "direction: {}", .{self.direction});
        buf[formated.len] = 0;

        ray.DrawText(&buf, 100, 100, 30, ray.GRAY);
    }
    pub fn drawSnake(self: *Snake) !void {
        ray.DrawRectangleV(self.pos, self.size, ray.BLUE);
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
