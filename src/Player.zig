const rl = @import("c.zig").rl;
const Projectile = @import("Projectile.zig");
const SpriteAnimation = @import("SpriteAnimation.zig");

const Self = @This();

velocity: rl.Vector2 = .{
    .x = 200,
    .y = 200,
},
keyMap: Keys,
hurtbox: rl.Rectangle,

orientation: FaceDirection,
currentSpriteStance: PlayerSpriteStance,
currentSprite: *SpriteAnimation,
spriteList: []const SpriteAnimation,

pub const PlayerSpriteStance = enum(usize) {
    Movement = 0,
    Idle = 1,
};

pub fn handlePlayerMovement(self: *Self, dTime: f32) rl.Vector2 {
    var userVel = rl.Vector2{
        .x = 0,
        .y = 0,
    };
    const keys = self.keyMap;
    if (rl.IsKeyDown(keys.LEFT)) {
        userVel.x -= 1;
        self.orientation = .LEFT;
    }
    if (rl.IsKeyDown(keys.RIGHT)) {
        userVel.x += 1;
        self.orientation = .RIGHT;
    }
    if (rl.IsKeyDown(keys.UP)) {
        userVel.y -= 1;
    }
    if (rl.IsKeyDown(keys.DOWN)) {
        userVel.y += 1;
    }
    const norm = rl.Vector2Normalize(userVel);
    self.hurtbox.x += self.velocity.x * dTime * norm.x;
    self.hurtbox.y += self.velocity.y * dTime * norm.y;

    return userVel;
}

pub fn draw(self: *Self) void {
    self.currentSprite.draw(
        .{
            .x = self.hurtbox.x,
            .y = self.hurtbox.y,
        },
        .RIGHT,
    );
}
pub fn fire(self: *Self, playerVel: rl.Vector2) ?Projectile {
    if (rl.IsKeyPressed(self.keyMap.FIRE)) {
        const projX: f32 = self.hurtbox.x + @as(f32, @floatFromInt(@divTrunc(
            self.currentSprite.texture.width * self.currentSprite.scaleFactor,
            2,
        ))) - 10;
        const projY: f32 = self.hurtbox.y + @as(f32, @floatFromInt(@divTrunc(
            self.currentSprite.texture.height * self.currentSprite.scaleFactor,
            2,
        ))) - 10;
        var proj: Projectile = .{
            .rec = .{
                .width = 20,
                .height = 20,
                .x = projX,
                .y = projY,
            },
        };

        const norm = rl.Vector2Normalize(playerVel);
        proj.velocity.x *= norm.x;
        proj.velocity.y *= norm.y;

        return proj;
    }
    return null;
}

pub const FaceDirection = enum(i2) {
    RIGHT = 1,
    LEFT = -1,
};

pub const Keys = struct {
    UP: c_int,
    DOWN: c_int,
    LEFT: c_int,
    RIGHT: c_int,
    FIRE: c_int,
};
