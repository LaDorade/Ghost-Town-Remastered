const rl = @import("c.zig").rl;

const Timer = @import("timer.zig");

const Self = @This();

timer_sec: Timer = Timer.create(2, true),
velocity: rl.Vector2 = .{
    .x = 400,
    .y = 400,
},
rec: rl.Rectangle = .{
    .height = 20,
    .width = 20,
    .x = 0,
    .y = 0,
},

pub fn handlePosition(self: *Self, dTime: f32) void {
    self.rec.x += self.velocity.x * dTime;
    self.rec.y += self.velocity.y * dTime;
}

pub fn draw(self: *const Self) void {
    rl.DrawRectangleRec(
        self.rec,
        rl.BLACK,
    );
}

fn isOutOfBound(self: *const Self) bool {
    return self.rec.x > 900 or
        self.rec.x < -100 or
        self.rec.y > 700 or
        self.rec.y < -100;
}

pub fn tick(self: *Self) void {
    self.timer_sec.tick();
}

pub fn shouldBeDestroyed(self: *Self) bool {
    return self.isOutOfBound() or self.timer_sec.over;
}
