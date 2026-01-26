const rl = @import("c.zig").rl;
const std = @import("std");

const FaceDirection = @import("Player.zig").FaceDirection;
const Timer = @import("timer.zig");

const Self = @This();

globalFPS: usize = 60,

scaleFactor: u16 = 3,

// time related
timer_sec: Timer,

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

pub fn getCurrentSpriteHeight(self: *const Self) f32 {
    return self.oneSpriteHeight * @as(f32, @floatFromInt(self.scaleFactor));
}
pub fn getCurrentSpriteWidth(self: *const Self) f32 {
    return self.oneSpriteWidth * @as(f32, @floatFromInt(self.scaleFactor));
}

pub fn draw(
    self: *Self,
    pos: rl.Vector2,
    orientation: FaceDirection,
) void {
    self.timer_sec.tick();

    if (self.timer_sec.over) {
        self.currentSprite += 1;
        if (self.currentSprite > (self.nbSprite - 1)) self.currentSprite = 0;

        self.timer_sec.restart();
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
    .timer_sec = Timer.createFromAnimationFrame(12, true),
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
    .texturePath = "./assets/player/idleSheet.png",
    .timer_sec = Timer.createFromAnimationFrame(12, true),
    .oneSpriteHeight = 30,
    .oneSpriteWidth = 30,

    .frameRectangles = &[_]rl.Rectangle{
        // start
        rl.Rectangle{ .x = 0, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 0, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 0, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 0, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 0, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 0, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 0, .y = 0, .height = 30, .width = 30 },
        // wink
        rl.Rectangle{ .x = 30, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 30, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 30, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 60, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 60, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 60, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 90, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 90, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 90, .y = 0, .height = 30, .width = 30 },
        // tap 1
        rl.Rectangle{ .x = 120, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 150, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 180, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 210, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 240, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 270, .y = 0, .height = 30, .width = 30 },
        // tap 2
        rl.Rectangle{ .x = 300, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 330, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 360, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 390, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 420, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 450, .y = 0, .height = 30, .width = 30 },
        // head switch
        rl.Rectangle{ .x = 480, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 480, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 480, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 510, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 510, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 510, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 510, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 540, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 540, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 540, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 540, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 540, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 570, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 570, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 570, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 600, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 600, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 600, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 630, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 630, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 630, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 630, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 630, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 630, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 630, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 630, .y = 0, .height = 30, .width = 30 },
        // arm thing
        rl.Rectangle{ .x = 660, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 660, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 690, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 690, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 690, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 690, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 690, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 690, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 690, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 690, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 720, .y = 0, .height = 30, .width = 30 },
        rl.Rectangle{ .x = 720, .y = 0, .height = 30, .width = 30 },
    },
};
