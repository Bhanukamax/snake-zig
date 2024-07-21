const std = @import("std");
const snake_ = @import("snake.zig");
const ray = @cImport({
    @cInclude("raylib.h");
});

const cellSize = 20;
const gridCols = 20;
const gridRows = 20;
const width = cellSize * gridCols;
const height = cellSize * gridRows;

const Direction = snake_.Direction;

fn drawGrid() void {
    inline for (0..gridCols) |col| {
        inline for (0..gridRows) |row| {
            const x = col * cellSize;
            const y = row * cellSize;
            const color = if ((col + row) % 2 == 0) ray.RAYWHITE else ray.WHITE;
            ray.DrawRectangle(
                @intCast(x),
                @intCast(y),
                @intCast(x + cellSize),
                @intCast(y + cellSize),
                color,
            );
        }
    }
}

pub fn main() !void {
    ray.InitWindow(width, height, "Hello");
    defer ray.CloseWindow();
    ray.SetTargetFPS(120);
    var snake = try snake_.newSnake();

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();
        ray.ClearBackground(ray.WHITE);
        drawGrid();

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
