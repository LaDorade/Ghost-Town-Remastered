const std = @import("std");
const rl = @import("c.zig").rl;
const Timer = @import("timer.zig");
const Player = @import("Player.zig");

const Obstacle = struct {
    velocity: rl.Vector2,
    hitbox: rl.Rectangle,
};

obtacleSpawnTimer: Timer = Timer.create(1, true),
obstacleList: std.ArrayList(Obstacle),
allocator: std.mem.Allocator,

const Self = @This();

pub fn init(allocator: std.mem.Allocator) !Self {
    return .{
        .allocator = allocator,
        .obstacleList = try std.ArrayList(Obstacle)
            .initCapacity(allocator, 10),
    };
}
pub fn deinit(self: *Self) void {
    self.obstacleList.deinit(self.allocator);
}

fn checkSpawn(self: *Self) !void {
    if (self.obtacleSpawnTimer.over) {
        const y = rl.GetRandomValue(20, 450);
        try self.obstacleList.append(
            self.allocator,
            .{
                .hitbox = .{
                    .x = -100,
                    .y = @floatFromInt(y),
                    .width = 80,
                    .height = 80,
                },
                .velocity = .{ .x = 200, .y = 0 },
            },
        );
        const newTime: f32 = @floatFromInt(rl.GetRandomValue(5, 15));
        self.obtacleSpawnTimer.restartWithTime(newTime / 10);
    }
}

pub fn tick(self: *Self, playList: []Player) !void {
    self.obtacleSpawnTimer.tick();
    try self.checkSpawn();

    var i = self.obstacleList.items.len;
    const dTime = rl.GetFrameTime();
    while (i > 0) : (i -= 1) {
        const ob = &self.obstacleList.items[i - 1];
        var collision = false;
        for (playList) |*player| {
            if (rl.CheckCollisionRecs(player.hurtbox, ob.hitbox)) {
                if (player.state == .Dead) {
                    continue;
                }
                collision = true;
                player.takeHit();
            }
        }
        if (ob.hitbox.x >= 900 or collision) {
            _ = self.obstacleList.swapRemove(i - 1);
        } else {
            ob.hitbox.x += ob.velocity.x * dTime;
            rl.DrawRectangleRec(
                ob.hitbox,
                rl.GRAY,
            );
        }
    }
}
