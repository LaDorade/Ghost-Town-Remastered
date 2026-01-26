const std = @import("std");
const rl = @import("c.zig").rl;

const root = @import("root.zig");
const Timer = @import("timer.zig");

const Self = @This();

pub const DEFAULT_SIZE = 10;

timer_sec: Timer = Timer.create(2, true),
velocity: rl.Vector2 = .{
    .x = 400,
    .y = 400,
},
rec: rl.Rectangle = .{
    .height = Self.DEFAULT_SIZE,
    .width = Self.DEFAULT_SIZE,
    .x = 0,
    .y = 0,
},

pub fn handlePosition(self: *Self) void {
    const dTime = rl.GetFrameTime();
    self.rec.x += self.velocity.x * dTime;
    self.rec.y += self.velocity.y * dTime;
}

pub fn draw(self: *const Self) void {
    rl.DrawCircleV(
        .{ .x = self.rec.x, .y = self.rec.y },
        self.rec.height,
        rl.ColorAlpha(rl.BLACK, 1 - self.timer_sec.completionRatio()),
    );
}

fn isOutOfBound(self: *const Self) bool {
    return self.rec.x > (root.GLOBAL_WIDTH + 100) or
        self.rec.x < -100 or
        self.rec.y > (root.GLOBAL_HEIGHT + 100) or
        self.rec.y < -100;
}

pub fn tick(self: *Self) void {
    self.timer_sec.tick();
}

pub fn shouldBeDestroyed(self: *Self) bool {
    return self.isOutOfBound() or self.timer_sec.over;
}
