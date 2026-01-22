const rl = @import("c.zig").rl;
const std = @import("std");

const FaceDirection = @import("Player.zig").FaceDirection;

const Self = @This();

globalFPS: usize = 60,

scaleFactor: u16 = 3,
texture: rl.Texture,
rectangles: []const rl.Rectangle,

currentSprite: usize = 0,
nbSprite: usize,
spriteWidth: f32,
spriteHeight: f32,

frameCounter: usize = 0,
currentFrame: usize = 0,

animationFps: usize,

pub fn CreateSpriteAnimation(
    spriteSheet: rl.Texture,
    rectangles: []const rl.Rectangle,
    animationFps: usize,
    globalFps: usize,
) Self {
    const spriteWidth: f32 = @floatFromInt(@divFloor(
        spriteSheet.width,
        @as(c_int, @intCast(rectangles.len)),
    ));
    const spriteHeight: f32 = @floatFromInt(spriteSheet.height);
    return .{
        .texture = spriteSheet,
        .rectangles = rectangles,
        .nbSprite = rectangles.len,
        .animationFps = animationFps,

        .spriteWidth = spriteWidth,
        .spriteHeight = spriteHeight,

        .globalFPS = globalFps,
    };
}

pub fn draw(
    self: *Self,
    pos: rl.Vector2,
    orientation: FaceDirection,
) void {
    self.frameCounter += 1;
    if (self.frameCounter >= @divFloor(self.globalFPS, self.animationFps)) {
        self.frameCounter = 0;
        self.currentSprite += 1;

        if (self.currentSprite > (self.nbSprite - 1)) self.currentSprite = 0;
    }
    const width: f32 = self.spriteWidth *
        @as(f32, @floatFromInt(self.scaleFactor)) *
        @as(f32, @floatFromInt(@intFromEnum(orientation)));
    rl.DrawTexturePro(
        self.texture,
        self.rectangles[self.currentSprite],
        .{
            .height = self.spriteHeight * @as(f32, @floatFromInt(self.scaleFactor)),
            .width = width,
            .x = pos.x,
            .y = pos.y,
        },
        .{ .x = 0, .y = 0 },
        0,
        rl.WHITE,
    );
}
