const std = @import("std");
const rl = @import("c.zig").rl;
const Timer = @import("timer.zig");
const Player = @import("Player.zig");

const CastState = enum {
    Inactive,
    Casting,
    Acting,
};

radius: f32 = 100,
pos: rl.Vector2,
cast_timer: Timer = .create(1, true),
duration_timer: Timer = .create(1, false),
state: CastState = .Casting,

const Self = @This();

pub fn create(x: anytype, y: anytype, radius: anytype) Self {
    const parsedX: f32 = switch (@TypeOf(x)) {
        f32 => x,
        f64 => @floatCast(x),
        i8, i16, i32, u8, u16, u32, usize, c_int => @floatFromInt(x),
        else => @compileError("Not number type"),
    };
    const parsedY: f32 = switch (@TypeOf(y)) {
        f32 => y,
        f64 => @floatCast(y),
        i8, i16, i32, u8, u16, u32, usize, c_int => @floatFromInt(y),
        else => @compileError("Not number type"),
    };
    const parsedRadius: f32 = switch (@TypeOf(radius)) {
        f32 => radius,
        f64 => @floatCast(radius),
        i8, i16, i32, u8, u16, u32, usize, c_int => @floatFromInt(radius),
        else => @compileError("Not number type"),
    };
    return .{
        .radius = parsedRadius,
        .pos = .{
            .x = parsedX,
            .y = parsedY,
        },
    };
}

pub fn tick(self: *Self) void {
    switch (self.state) {
        .Inactive => {
            return;
        },
        .Casting => {
            self.cast_timer.tick();
            if (self.cast_timer.over) {
                self.state = .Acting;
                self.duration_timer.start();
            }
        },
        .Acting => {
            self.duration_timer.tick();
            if (self.duration_timer.over) {
                self.state = .Inactive;
            }
        },
    }
}

pub fn draw(self: *Self) void {
    switch (self.state) {
        .Inactive => {
            return;
        },
        .Casting => {
            rl.DrawCircleV(
                self.pos,
                self.radius,
                rl.ColorAlpha(rl.ORANGE, self.cast_timer.completionRatio()),
            );
        },
        .Acting => {
            rl.DrawCircleV(
                self.pos,
                self.radius,
                rl.RED,
            );
        },
    }
}
