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

fn drawSnake(delta: f32) !void {
    // _ = delta;
    elapsTime += delta;

    if (elapsTime > 0.5) {
        y += size;
        elapsTime = 0;
    }
    var buf: [1000]u8 = undefined;
    const sizeVec = ray.Vector2 { .x = size, .y = size};
    const pos = ray.Vector2 { .x = 20.0, .y = y};

    ray.DrawRectangleV(pos, sizeVec, ray.BLUE);
    const formated = try std.fmt.bufPrint(&buf, "y: {d}", .{elapsTime});
    buf[formated.len] = 0;
    
    ray.DrawText(&buf, 100, 100, 30, ray.GRAY);
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    ray.InitWindow(width, height, "Hello");
    defer ray.CloseWindow();
    // ray.SetTargetFPS(60);

    while(!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();
        ray.ClearBackground(ray.WHITE);

        const delta = ray.GetFrameTime();
        
        try drawSnake(delta);
    }
}

