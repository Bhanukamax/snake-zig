const std = @import("std");
const c = @import("c.zig");
const consts = @import("const.zig");
const cellSize = consts.cellSize;
const gridCols = consts.gridCols;
const gridRows = consts.gridRows;

var elapsTime: f32 = 0;
const speed = 100;

fn vec(x: f32, y: f32) c.Vector2 {
    return c.Vector2{ .x = x, .y = y };
}

fn getRandomCell() c.Vector2 {
    const rand = std.crypto.random;
    return vec(
        @floatFromInt(rand.intRangeAtMost(i32, 0, consts.gridCols - 1)),
        @floatFromInt(rand.intRangeAtMost(i32, 0, consts.gridRows - 1)),
    );
}

fn debug(value: anytype) !void {
    var buf: [1000]u8 = undefined;
    const formated = try std.fmt.bufPrint(&buf, "direction: {}", .{value});
    buf[formated.len] = 0;
    c.DrawText(&buf, 100, 100, 30, c.GRAY);
}

fn drawCell(cell: c.Vector2, size: c.Vector2, color: c.Color) void {
    const cellPos = vec(
        @floatCast(size.x * cell.x),
        @floatCast(size.y * cell.y),
    );
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

const GameState = enum {
    Playing,
    GameOver,
    Pause,
};

pub fn newSnake(allocator: *const std.mem.Allocator) !Snake {
    const sizeVec = vec(cellSize, cellSize);
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
        .state = .Playing,
    };
}

pub const Snake = struct {
    body: std.ArrayList(c.Vector2),
    size: c.Vector2,
    direction: Direction,
    apple: ?c.Vector2,
    allocator: *const std.mem.Allocator,
    state: GameState,
    pub fn deinit(self: *Snake) void {
        self.body.deinit();
    }
    fn isSnakeBody(self: *Snake, target: c.Vector2) bool {
        for (self.body.items) |item| {
            if (item.x == target.x and item.y == target.y) return true;
        }
        return false;
    }
    fn placeApple(self: *Snake) void {
        if (self.apple == null) {
            var target = getRandomCell();
            while (self.isSnakeBody(target)) {
                target = getRandomCell();
            }
            self.apple = target;
        }
    }
    fn turn(self: *Snake, direction: Direction) void {
        if (direction.isOpposite(self.direction) or direction == self.direction) {
            return;
        }
        self.direction = direction;
    }
    pub fn moveSnake(self: *Snake, delta: f32) !void {
        if (self.state != .Playing) {
            return;
        }
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

            // End state
            if (newHead.x < 0 or newHead.x > consts.gridRows - 1 or newHead.y < 0 or newHead.y > gridCols - 1) {
                self.state = .GameOver;
                return;
            }

            try self.body.append(newHead);
            const isEatingApple = newHead.x == self.apple.?.x and newHead.y == self.apple.?.y;
            // Eating the apple
            if (isEatingApple) {
                self.apple = null;
                self.placeApple();
            } else {
                _ = self.body.orderedRemove(0);
            }
            elapsTime = 0;
        }
    }
    pub fn draw(self: *Snake) !void {
        drawCell(vec(19, 19), vec(consts.cellSize, consts.cellSize), c.BLUE);
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
