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
};

pub fn newSnake() Snake {
    const sizeVec = ray.Vector2{ .x = size, .y = size };
    const pos = ray.Vector2{ .x = 20.0, .y = 20.0 };
    return Snake{ .pos = pos, .size = sizeVec, .direction = Direction.Down };
}

pub const Snake = struct {
    pos: ray.Vector2,
    size: ray.Vector2,
    direction: Direction,
    fn changeDirection(self: *Snake, direction: Direction) void {
        self.direction = direction;
    }
    pub fn moveSnake(self: *Snake, delta: f32) !void {
        elapsTime += delta;
        if (elapsTime > 0.2) {
            switch (self.direction) {
                Direction.Up => self.pos.y -= size,
                Direction.Down => self.pos.y += size,
                Direction.Left => self.pos.x -= size,
                Direction.Right => self.pos.x += size,
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
        _ = switch(key) {
            ray.KEY_LEFT => self.changeDirection(Direction.Left),
            ray.KEY_RIGHT => self.changeDirection(Direction.Right),
            ray.KEY_UP => self.changeDirection(Direction.Up),
            ray.KEY_DOWN => self.changeDirection(Direction.Down),
            else => undefined,
        };
    }
};
