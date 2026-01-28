const std = @import("std");
const rl = @import("c.zig").rl;

const Player = @import("Player.zig");
const Projectile = @import("Projectile.zig");
const SpriteAnimation = @import("SpriteAnimation.zig");
const Timer = @import("timer.zig");
const Obstacle = @import("Obstacle.zig");
const DamageArea = @import("DamageArea.zig");

const player1Keys: Player.Keys = .{
    .UP = rl.KEY_W,
    .DOWN = rl.KEY_S,
    .LEFT = rl.KEY_A,
    .RIGHT = rl.KEY_D,
    .FIRE = rl.KEY_LEFT_SHIFT,
};

const player2Keys: Player.Keys = .{
    .UP = rl.KEY_I,
    .DOWN = rl.KEY_K,
    .LEFT = rl.KEY_J,
    .RIGHT = rl.KEY_L,
    .FIRE = rl.KEY_RIGHT_SHIFT,
};

pub const GLOBAL_WIDTH = 800;
pub const GLOBAL_HEIGHT = 600;

pub fn run() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const GLOBAL_FPS = 60;

    rl.InitWindow(GLOBAL_WIDTH, GLOBAL_HEIGHT, "game");
    defer rl.CloseWindow();
    rl.SetTargetFPS(GLOBAL_FPS);
    rl.SetTraceLogLevel(rl.LOG_DEBUG);

    // Sprite loading
    SpriteAnimation.playerWalkSprite.load();
    SpriteAnimation.playerIdleSprite.load();
    defer SpriteAnimation.playerWalkSprite.unload();
    defer SpriteAnimation.playerIdleSprite.unload();

    var spriteList = [_]SpriteAnimation{
        SpriteAnimation.playerWalkSprite,
        SpriteAnimation.playerIdleSprite,
    };
    const player1 = Player{
        .id = 1,
        .spriteList = spriteList[0..],
        .orientation = .RIGHT,
        .currentSpriteStance = .Idle,
        .currentSprite = undefined,
        .keyMap = player1Keys,
        .hurtbox = .{
            .x = 300,
            .y = 300,
        },
    };

    var playList = [_]Player{
        player1,
    };

    var projList = try std.ArrayList(Projectile)
        .initCapacity(allocator, 10);
    defer projList.deinit(allocator);

    var obstacleHanlder = try Obstacle.init(allocator);
    defer obstacleHanlder.deinit();

    var damageAreaList = try std.ArrayList(DamageArea)
        .initCapacity(allocator, 10);
    defer damageAreaList.deinit(allocator);
    var areaCreation_timer = Timer.create(1, true);

    var bonus = true;

    rl.SetRandomSeed(2);
    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();
        rl.ClearBackground(rl.RAYWHITE);

        // players gestion
        for (&playList) |*player| {
            player.tick();

            if (player.fire()) |proj| {
                try projList.append(allocator, proj);
                rl.TraceLog(
                    rl.LOG_DEBUG,
                    "Proj created with x: %.2f, y: %.2f, velX: %.2f, velY: %.2f",
                    proj.rec.x,
                    proj.rec.y,
                    proj.velocity.x,
                    proj.velocity.y,
                );
            }
        }

        // Proj gestion
        var i: usize = projList.items.len;
        while (i > 0) : (i -= 1) {
            const proj = &projList.items[i - 1];
            proj.tick();
            if (proj.shouldBeDestroyed()) {
                _ = projList.swapRemove(i - 1);
                rl.TraceLog(rl.LOG_DEBUG, "Proj deleted");
            } else {
                proj.handlePosition();
                proj.draw();
            }
        }

        // bonus
        if (bonus) {
            const bonusRec = rl.Rectangle{
                .x = 400,
                .y = 400,
                .height = 30,
                .width = 30,
            };
            rl.DrawRectangleRec(
                bonusRec,
                rl.GREEN,
            );

            for (&playList) |*player| {
                if (rl.CheckCollisionRecs(player.hurtbox, bonusRec)) {
                    player.targetVelocity.x += 100;
                    player.targetVelocity.y += 100;
                    player.fireRateTimer.initialVal_sec = 0.25;
                    bonus = false;
                    break;
                }
            }
        }

        // obstacles
        try obstacleHanlder.tick(&playList);

        // damager areas
        {
            areaCreation_timer.tick();
            if (areaCreation_timer.over) {
                try damageAreaList.append(
                    allocator,
                    .create(
                        rl.GetRandomValue(0, GLOBAL_WIDTH),
                        rl.GetRandomValue(0, GLOBAL_HEIGHT),
                        rl.GetRandomValue(70, 130),
                    ),
                );
                areaCreation_timer.restartWithTime(
                    @as(f32, @floatFromInt(rl.GetRandomValue(80, 170))) / 100,
                );
            }
            i = damageAreaList.items.len;
            while (i > 0) : (i -= 1) {
                const da = &damageAreaList.items[i - 1];
                da.tick();
                if (da.state == .Inactive) {
                    _ = damageAreaList.swapRemove(i - 1);
                }
                if (da.state != .Acting) {
                    continue;
                }
                for (&playList) |*pl| {
                    const collide = rl.CheckCollisionCircleRec(da.pos, da.radius, pl.hurtbox);
                    if (pl.state == .Dead) {
                        continue;
                    }
                    if (collide) {
                        pl.takeHit();
                        _ = damageAreaList.swapRemove(i - 1);
                        rl.TraceLog(
                            rl.LOG_DEBUG,
                            rl.TextFormat(
                                "Player %d took a hit from DamageArea",
                                pl.id,
                            ),
                        );
                        break;
                    }
                }
            }
            for (damageAreaList.items) |*da| {
                da.draw();
            }
        }

        // draw players last to be on top
        for (&playList) |*p| {
            try p.draw();
        }

        // UI
        rl.DrawRectangle(
            0,
            0,
            200,
            60,
            rl.BLUE,
        );
        for (&playList, 0..) |p, ind| {
            var buff: [20]u8 = undefined;
            @memset(&buff, 0);
            var text: []u8 = undefined;
            if (p.state == .Dead) {
                text = try std.fmt.bufPrint(&buff, "P{}: Dead", .{ind + 1});
            } else {
                text = try std.fmt.bufPrint(&buff, "P{} Lives: {}", .{ ind + 1, p.life });
            }
            rl.DrawText(
                text.ptr,
                10,
                @intCast(10 * (ind + 1)),
                20,
                rl.BLACK,
            );
        }
    }
}
