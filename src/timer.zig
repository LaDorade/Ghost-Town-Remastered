const std = @import("std");
const rl = @import("c.zig").rl;

initialVal_sec: f32,
elapsed_sec: f32,
ticking: bool = false,
over: bool = false,

const Self = @This();

pub fn create(time_sec: f32, autoStart: bool) Self {
    return .{
        .initialVal_sec = time_sec,
        .elapsed_sec = 0,
        .ticking = autoStart,
    };
}

pub fn createFromAnimationFrame(framePerSec: usize, autoStart: bool) Self {
    return .{
        .initialVal_sec = 1.0 / @as(f32, framePerSec),
        .elapsed_sec = 0,
        .ticking = autoStart,
    };
}

pub fn start(self: *Self) void {
    self.ticking = true;
}
pub fn restart(self: *Self) void {
    self.elapsed_sec = 0;
    self.ticking = true;
    self.over = false;
}

/// near 0 when starting, near 1 when end
pub fn completionRatio(self: *const Self) f32 {
    return rl.Remap(
        self.elapsed_sec,
        0,
        self.initialVal_sec,
        0,
        1,
    );
}

/// Called 1 times per frame
pub fn tick(self: *Self) void {
    if (!self.ticking or self.over) return;

    self.elapsed_sec += rl.GetFrameTime();
    if (self.elapsed_sec >= self.initialVal_sec) {
        self.ticking = false;
        self.over = true;
    }
}
