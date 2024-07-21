const std = @import("std");
const c = @import("c.zig");
const snake_ = @import("snake.zig");

const consts =  @import("const.zig");
const cellSize  = consts.cellSize ;
const gridCols  = consts.gridCols ;
const gridRows  = consts.gridRows ;
const width  = consts.width ;
const height  = consts.height ;

const Direction = snake_.Direction;

fn drawGrid() void {
    inline for (0..gridCols) |col| {
        inline for (0..gridRows) |row| {
            const x = col * cellSize;
            const y = row * cellSize;
            const color = if ((col + row) % 2 == 0) c.RAYWHITE else c.WHITE;
            c.DrawRectangle(
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
    c.InitWindow(width, height, "Hello");
    defer c.CloseWindow();
    c.SetTargetFPS(120);
    var snake = try snake_.newSnake();

    while (!c.WindowShouldClose()) {
        c.BeginDrawing();
        defer c.EndDrawing();
        c.ClearBackground(c.WHITE);
        drawGrid();

        c.DrawFPS(100, 200);
        const delta = c.GetFrameTime();

        const pressedKey = c.GetKeyPressed();
        _ = switch (pressedKey) {
            c.KEY_J,
            c.KEY_K,
            c.KEY_L,
            c.KEY_I,
            c.KEY_LEFT,
            c.KEY_RIGHT,
            c.KEY_UP,
            c.KEY_DOWN,
            => snake.handleKeys(pressedKey),
            else => {},
        };

        try snake.drawSnake();
        try snake.moveSnake(delta);
    }
}
