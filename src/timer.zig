const rl = @import("c.zig").rl;

initialVal_sec: f32,
elapsed_sec: f32,
ticking: bool = false,
over: bool = false,

const Self = @This();

pub fn create(time_sec: f32, autoStart: bool) Self {
    return .{
        .initialVal_sec = time_sec,
        .elapsed_sec = time_sec,
        .ticking = autoStart,
    };
}

pub fn start(self: *Self) void {
    self.ticking = true;
}

/// Called 1 times per frame
pub fn tick(self: *Self) void {
    if (!self.ticking or self.over) return;

    self.elapsed_sec -= rl.GetFrameTime();
    if (self.elapsed_sec <= 0) {
        self.ticking = false;
        self.over = true;
    }
}
