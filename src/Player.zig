const rl = @import("c.zig").rl;
const Projectile = @import("Projectile.zig");

const Self = @This();

pub const Sprite = struct {
    SCALE_FACTOR: u16 = 3,
    orientation: SpriteOrientation = .RIGHT,
    texture: rl.Texture,
};
pub const SpriteOrientation = enum(i2) { RIGHT = 1, LEFT = -1 };
pub const Keys = struct {
    UP: c_int,
    DOWN: c_int,
    LEFT: c_int,
    RIGHT: c_int,
    FIRE: c_int,
};

targetVelocity: rl.Vector2 = .{ .x = 200, .y = 200 },
actualVelocity: rl.Vector2 = .{ .x = 0, .y = 0 },
/// x/y between -1 & 1
normalVelocity: rl.Vector2 = .{ .x = 0, .y = 0 },
sprite: Sprite,
keyMap: Keys,
hurtbox: rl.Rectangle,

pub fn getPosition(self: *Self) rl.Vector2 {
    return .{
        .x = self.hurtbox.x,
        .y = self.hurtbox.y,
    };
}
pub fn getWidth(self: *Self) f32 {
    return self.hurtbox.width;
}
pub fn getHeight(self: *Self) f32 {
    return self.hurtbox.height;
}
pub fn handlePlayerMovement(self: *Self, dTime: f32) void {
    self.normalVelocity = rl.Vector2{
        .x = 0,
        .y = 0,
    };
    const keys = self.keyMap;
    if (rl.IsKeyDown(keys.LEFT)) {
        self.normalVelocity.x -= 1;
        self.sprite.orientation = .LEFT;
    }
    if (rl.IsKeyDown(keys.RIGHT)) {
        self.normalVelocity.x += 1;
        self.sprite.orientation = .RIGHT;
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
pub fn drawPlayer(self: *Self) void {
    rl.DrawTexturePro(
        self.sprite.texture,
        .{
            .width = @floatFromInt(self.sprite.texture.width * @intFromEnum(self.sprite.orientation)),
            .height = @floatFromInt(self.sprite.texture.height),
            .x = 0,
            .y = 0,
        },
        .{
            .width = @floatFromInt(self.sprite.texture.width * self.sprite.SCALE_FACTOR),
            .height = @floatFromInt(self.sprite.texture.height * self.sprite.SCALE_FACTOR),
            .x = self.hurtbox.x,
            .y = self.hurtbox.y,
        },
        .{
            .x = 0,
            .y = 0,
        },
        0,
        rl.WHITE,
    );
}
pub fn fire(self: *Self) ?Projectile {
    if (rl.IsKeyPressed(self.keyMap.FIRE)) {
        const projX: f32 = self.hurtbox.x + @as(f32, @floatFromInt(@divTrunc(self.sprite.texture.width * self.sprite.SCALE_FACTOR, 2))) - 10;
        const projY: f32 = self.hurtbox.y + @as(f32, @floatFromInt(@divTrunc(self.sprite.texture.height * self.sprite.SCALE_FACTOR, 2))) - 10;
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
