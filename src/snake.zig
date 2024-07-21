const std = @import("std");
const c = @import("c.zig");
const consts = @import("const.zig");
const cellSize = consts.cellSize;

var elapsTime: f32 = 0;
const speed = 100;

fn vec(x: f32, y: f32) c.Vector2 {
    return c.Vector2{ .x = x, .y = y };
}

fn debug(value: anytype) !void {
    var buf: [1000]u8 = undefined;
    const formated = try std.fmt.bufPrint(&buf, "direction: {}", .{value});
    buf[formated.len] = 0;
    c.DrawText(&buf, 100, 100, 30, c.GRAY);
}

fn drawCell(cell: c.Vector2, size: c.Vector2, color: c.Color) void {
    const cellPos =
        c.Vector2{
        .x = @floatCast(size.x * cell.x),
        .y = @floatCast(size.y * cell.y),
    };
    c.DrawRectangleV(cellPos, size, color);
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

pub fn newSnake(allocator: *const std.mem.Allocator) !Snake {
    const sizeVec = c.Vector2{ .x = cellSize, .y = cellSize };
    // TODO: see if possible to do this without explicitly passing the allocator
    var body: std.ArrayList(c.Vector2) = std
        .ArrayList(c.Vector2)
        .init(allocator.*);
    try body.append(vec(2, 2));
    try body.append(vec(2, 1));
    try body.append(vec(3, 1));
    return Snake{
        .size = sizeVec,
        .direction = .Down,
        .body = body,
        .apple = null,
        .allocator = allocator,
    };
}

pub const Snake = struct {
    body: std.ArrayList(c.Vector2),
    size: c.Vector2,
    direction: Direction,
    apple: ?c.Vector2,
    allocator: *const std.mem.Allocator,
    pub fn deinit(self: *Snake) void{
        self.body.deinit();
    }
    fn placeApple(self: *Snake) void {
        const rand = std.crypto.random;
        if (self.apple == null) {
            const x: f32 = @floatFromInt(rand.intRangeAtMost(i32, 0, consts.gridCols - 1));
            const y: f32 = @floatFromInt(rand.intRangeAtMost(i32, 0, consts.gridRows - 1));

            self.apple = vec(x, y);
        }
    }
    fn turn(self: *Snake, direction: Direction) void {
        if (direction.isOpposite(self.direction) or direction == self.direction) {
            return;
        }
        self.direction = direction;
    }
    pub fn moveSnake(self: *Snake, delta: f32) !void {
        self.placeApple();
        elapsTime += delta;
        if (elapsTime > 0.2) {
            const head = self.body.pop();
            try self.body.append(head);
            const newHead = switch (self.direction) {
                .Up => vec(head.x, head.y - 1),
                .Down => vec(head.x, head.y + 1),
                .Left => vec(head.x - 1, head.y),
                .Right => vec(head.x + 1, head.y),
            };
            try self.body.append(newHead);
            if (newHead.x == self.apple.?.x and newHead.y == self.apple.?.y) {
                self.apple = null;
                self.placeApple();
            } else {
                _ = self.body.orderedRemove(0);
            }
            elapsTime = 0;
        }
        try debug(self.direction);
    }
    pub fn drawSnake(self: *Snake) !void {
        drawCell(vec(19,19), vec(consts.cellSize, consts.cellSize), c.BLUE);
        for (self.body.items) |cell| {
            drawCell(cell, self.size, c.GREEN);
        }
        if (self.apple) |apple| {
            drawCell(apple, self.size, c.RED);
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
