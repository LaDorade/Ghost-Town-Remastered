const rl = @import("c.zig").rl;
const std = @import("std");

const FaceDirection = @import("Player.zig").FaceDirection;

const Self = @This();

globalFPS: usize = 60,

scaleFactor: u16 = 3,

// time related
frameCounter: usize = 0,
currentFrame: usize = 0,
animationFps: usize,

// texture
texture: rl.Texture = undefined,
texturePath: [*:0]const u8,

// size of a sprite
nbSprite: usize = undefined,
currentSprite: usize = 0,
oneSpriteWidth: f32,
oneSpriteHeight: f32,

frameRectangles: []const rl.Rectangle,

pub fn load(self: *Self) void {
    self.texture = rl.LoadTexture(self.texturePath);
    self.nbSprite = self.frameRectangles.len;
}
pub fn unload(self: *Self) void {
    rl.UnloadTexture(self.texture);
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

    var source = self.frameRectangles[self.currentSprite];
    source.width *= @as(f32, @floatFromInt(@intFromEnum(orientation)));
    rl.DrawTexturePro(
        self.texture,
        source,
        .{
            .height = self.oneSpriteHeight * @as(f32, @floatFromInt(self.scaleFactor)),
            .width = self.oneSpriteWidth * @as(f32, @floatFromInt(self.scaleFactor)),
            .x = pos.x,
            .y = pos.y,
        },
        .{ .x = 0, .y = 0 },
        0,
        rl.WHITE,
    );
}

// Sprite List //
pub var playerWalkSprite: Self = .{
    .texturePath = "./assets/player/walk.png",
    .animationFps = 12,
    .oneSpriteHeight = 30,
    .oneSpriteWidth = 30,

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
pub var playerIdleSprite: Self = .{
    .texturePath = "./assets/player/idle.png",
    .animationFps = 12,
    .oneSpriteHeight = 30,
    .oneSpriteWidth = 30,

    .frameRectangles = &[_]rl.Rectangle{
        rl.Rectangle{ .x = 0, .y = 0, .height = 30, .width = 30 },
    },
};
