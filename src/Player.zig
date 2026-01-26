const std = @import("std");
const rl = @import("c.zig").rl;
const Projectile = @import("Projectile.zig");
const SpriteAnimation = @import("SpriteAnimation.zig");
const Timer = @import("timer.zig");

const root = @import("root.zig");

const Self = @This();

const PlayerState = enum {
    Alive,
    Dead,
};

velocity: rl.Vector2 = .{
    .x = 200,
    .y = 200,
},

fireRateTimer: Timer = .create(0.5, true),

life: usize = 3,
state: PlayerState = .Alive,

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

fn handlePlayerMovement(self: *Self) void {
    const dTime = rl.GetFrameTime();
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

    if (self.hurtbox.x <= 0) {
        self.hurtbox.x = 0;
    } else if ((self.hurtbox.x + self.currentSprite.getCurrentSpriteWidth()) >= root.GLOBAL_WIDTH) {
        self.hurtbox.x = root.GLOBAL_WIDTH - self.currentSprite.getCurrentSpriteWidth();
    }
    if (self.hurtbox.y <= 0) {
        self.hurtbox.y = 0;
    } else if ((self.hurtbox.y + self.currentSprite.getCurrentSpriteHeight()) >= root.GLOBAL_HEIGHT) {
        self.hurtbox.y = root.GLOBAL_HEIGHT - self.currentSprite.getCurrentSpriteHeight();
    }
}

fn checkCurrentSprite(self: *Self) void {
    if (self.actualVelocity.x < 20 and self.actualVelocity.x > -20 and self.actualVelocity.y < 20 and self.actualVelocity.y > -20) {
        self.currentSpriteStance = .Idle;
    } else {
        self.currentSpriteStance = .Movement;
    }

    self.currentSprite = &self.spriteList[@intFromEnum(self.currentSpriteStance)];
}

/// Each frame logic
pub fn tick(self: *Self) void {
    self.checkCurrentSprite();
    self.hurtbox.height = self.currentSprite.getCurrentSpriteHeight();
    self.hurtbox.width = self.currentSprite.getCurrentSpriteWidth();

    if (self.state != PlayerState.Alive) {
        return;
    }

    self.handlePlayerMovement();
    self.fireRateTimer.tick();
}

pub fn takeHit(self: *Self) void {
    if (self.state == PlayerState.Dead) {
        return;
    }
    self.life -= 1;
    if (self.life <= 0) {
        self.state = PlayerState.Dead;
    }
}

pub fn draw(self: *Self) !void {
    self.currentSprite.draw(
        .{
            .x = self.hurtbox.x,
            .y = self.hurtbox.y,
        },
        self.orientation,
    );
    var buff: [20]u8 = undefined;
    @memset(&buff, 0);
    var text: []u8 = undefined;
    if (self.state == .Dead) {
        text = try std.fmt.bufPrint(&buff, "Dead", .{});
    } else {
        text = try std.fmt.bufPrint(&buff, "Lives: {}", .{self.life});
    }
    rl.DrawText(
        text.ptr,
        @intFromFloat(self.hurtbox.x),
        @intFromFloat(self.hurtbox.y),
        20,
        rl.BLACK,
    );

    // draw fire available
    if (self.fireRateTimer.over) {
        rl.DrawRectangle(
            @intFromFloat(self.hurtbox.x),
            @intFromFloat(self.hurtbox.y),
            10,
            10,
            rl.BLUE,
        );
    }
}
pub fn fire(self: *Self) ?Projectile {
    if (self.state != PlayerState.Alive) {
        return null;
    }
    if (rl.IsKeyDown(self.keyMap.FIRE) and self.fireRateTimer.over) {
        const projX: f32 = self.hurtbox.x + @as(f32, @floatFromInt(@divTrunc(
            @as(i32, @intFromFloat(self.hurtbox.width)),
            2,
        ))) - 10;
        const projY: f32 = self.hurtbox.y + @as(f32, @floatFromInt(@divTrunc(
            @as(i32, @intFromFloat(self.hurtbox.height)),
            2,
        ))) - 10;
        var proj: Projectile = .{
            .rec = .{
                .width = Projectile.DEFAULT_SIZE,
                .height = Projectile.DEFAULT_SIZE,
                .x = projX,
                .y = projY,
            },
        };

        // by using the normalizedVel from the player, the proj isn't faster in diagonal
        proj.velocity.x *= self.normalVelocity.x;
        proj.velocity.y *= self.normalVelocity.y;

        self.fireRateTimer.restart();
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
