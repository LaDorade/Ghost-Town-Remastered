const rl = @import("c.zig").rl;
const Projectile = @import("Projectile.zig");
const SpriteAnimation = @import("SpriteAnimation.zig");

const Self = @This();

velocity: rl.Vector2 = .{
    .x = 200,
    .y = 200,
},

orientation: FaceDirection,
currentSpriteStance: PlayerSpriteStance,
currentSprite: *SpriteAnimation,
spriteList: []SpriteAnimation,

targetVelocity: rl.Vector2 = .{ .x = 200, .y = 200 },
actualVelocity: rl.Vector2 = .{ .x = 0, .y = 0 },
/// x/y between -1 & 1
normalVelocity: rl.Vector2 = .{ .x = 0, .y = 0 },
keyMap: Keys,
hurtbox: rl.Rectangle,

pub fn handlePlayerMovement(self: *Self, dTime: f32) void {
    self.normalVelocity = rl.Vector2{
        .x = 0,
        .y = 0,
    };
    const keys = self.keyMap;
    if (rl.IsKeyDown(keys.LEFT)) {
        self.normalVelocity.x -= 1;
        self.orientation = .LEFT;
    }
    if (rl.IsKeyDown(keys.RIGHT)) {
        self.normalVelocity.x += 1;
        self.orientation = .RIGHT;
    }
    if (rl.IsKeyDown(keys.UP)) {
        self.normalVelocity.y -= 1;
    }
    if (rl.IsKeyDown(keys.DOWN)) {
        self.normalVelocity.y += 1;
    }
    // ensure we don't have more speed in diagonal
    self.normalVelocity = rl.Vector2Normalize(self.normalVelocity);

    self.actualVelocity = rl.Vector2Lerp(
        self.actualVelocity,
        rl.Vector2Multiply(self.targetVelocity, self.normalVelocity),
        0.25,
    );
    self.hurtbox.x += self.actualVelocity.x * dTime;
    self.hurtbox.y += self.actualVelocity.y * dTime;
}

fn checkCurrentSprite(self: *Self) void {
    if (self.actualVelocity.x < 20 and self.actualVelocity.x > -20 and self.actualVelocity.y < 20 and self.actualVelocity.y > -20) {
        self.currentSpriteStance = .Idle;
    } else {
        self.currentSpriteStance = .Movement;
    }

    self.currentSprite = &self.spriteList[@intFromEnum(self.currentSpriteStance)];
}

pub fn draw(self: *Self) void {
    self.checkCurrentSprite();
    self.currentSprite.draw(
        .{
            .x = self.hurtbox.x,
            .y = self.hurtbox.y,
        },
        self.orientation,
    );
}
pub fn fire(self: *Self) ?Projectile {
    if (rl.IsKeyPressed(self.keyMap.FIRE)) {
        const projX: f32 = self.hurtbox.x + @as(f32, @floatFromInt(@divTrunc(
            @as(i32, @intFromFloat(self.currentSprite.oneSpriteWidth)) * self.currentSprite.scaleFactor,
            2,
        ))) - 10;
        const projY: f32 = self.hurtbox.y + @as(f32, @floatFromInt(@divTrunc(
            @as(i32, @intFromFloat(self.currentSprite.oneSpriteHeight)) * self.currentSprite.scaleFactor,
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

        // by using the normalizedVel from the player, the proj isn't faster in diagonal
        proj.velocity.x *= self.normalVelocity.x;
        proj.velocity.y *= self.normalVelocity.y;

        return proj;
    }
    return null;
}

pub const PlayerSpriteStance = enum(usize) {
    Movement = 0,
    Idle = 1,
};
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
