const std = @import("std");
const snake_ = @import("snake.zig");
const ray = @cImport({
    @cInclude("raylib.h");
});

const width = 500;
const height = 400;

const Direction = snake_.Direction;

pub fn main() !void {
    ray.InitWindow(width, height, "Hello");
    defer ray.CloseWindow();
    ray.SetTargetFPS(120);
    var snake = snake_.newSnake();

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();
        ray.ClearBackground(ray.WHITE);

        ray.DrawFPS(100, 200);
        const delta = ray.GetFrameTime();

        const pressedKey = ray.GetKeyPressed();
        _ = switch (pressedKey) {
            ray.KEY_J,
            ray.KEY_K,
            ray.KEY_L,
            ray.KEY_I,
            ray.KEY_LEFT,
            ray.KEY_RIGHT,
            ray.KEY_UP,
            ray.KEY_DOWN,
            => snake.handleKeys(pressedKey),
            else => {},
        };

        try snake.drawSnake();
        try snake.moveSnake(delta);
    }
}
