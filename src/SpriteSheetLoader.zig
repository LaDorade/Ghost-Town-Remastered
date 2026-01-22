const std = @import("std");
const rl = @import("c.zig").rl;

const Self = @This();

texturePath: [*:0]const u8,
nbFrame: usize,

frameWidth: usize,
frameHeight: usize,

frameRectangles: []const rl.Rectangle,

// Sprite List //

pub const playerWalkSprite: Self = .{
    .texturePath = "./assets/player/walk.png",
    .frameHeight = 30,
    .frameWidth = 30,
    .nbFrame = 7,

    .frameRectangles = &[_]rl.Rectangle{
        rl.Rectangle{ .x = 0, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 30, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 60, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 90, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 120, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 150, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 180, .y = 0, .height = 30, .width = 30 },
    },
};
pub const playerIdleSprite: Self = .{
    .texturePath = "./assets/player/idle.png",
    .frameHeight = 30,
    .frameWidth = 30,
    .nbFrame = 1,

    .frameRectangles = &[_]rl.Rectangle{
        rl.Rectangle{ .x = 0, .y = 0, .height = 30, .width = 30 },
    },
};

comptime {
    if (playerWalkSprite.frameRectangles.len != playerWalkSprite.nbFrame) {
        const errMsg = std.fmt.comptimePrint("Frame Number: {}, Number of Rectangles: {}\n", .{
            playerWalkSprite.nbFrame,
            playerWalkSprite.frameRectangles,
        });
        @compileError("Created a sprite animation with mismatching frame number and number of rectangles\n" ++ errMsg);
    }
}
