const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const width = 500;
const height = 400;
const speed = 50;
const size: f32 = 20.0;

var y: f32 = 10;
var elapsTime: f32 = 0;

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
};

const Snake = struct {
    pos: ray.Vector2,
    size: ray.Vector2,
    direction: Direction,
    pub fn changeDirection(self: *Snake, direction: Direction) void {
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
};

fn newSnake() Snake {
    const sizeVec = ray.Vector2{ .x = size, .y = size };
    const pos = ray.Vector2{ .x = 20.0, .y = 20.0 };
    return Snake{ .pos = pos, .size = sizeVec, .direction = Direction.Down };
}

pub fn main() !void {
    ray.InitWindow(width, height, "Hello");
    defer ray.CloseWindow();
    ray.SetTargetFPS(120);
    var snake = newSnake();

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();
        ray.ClearBackground(ray.WHITE);

        ray.DrawFPS(100, 200);
        const delta = ray.GetFrameTime();

        _ = switch (ray.GetKeyPressed()) {
            ray.KEY_LEFT => snake.changeDirection(Direction.Left),
            ray.KEY_RIGHT => snake.changeDirection(Direction.Right),
            ray.KEY_UP => snake.changeDirection(Direction.Up),
            ray.KEY_DOWN => snake.changeDirection(Direction.Down),
            else => undefined,
        };
        try snake.drawSnake();
        try snake.moveSnake(delta);
    }
}
