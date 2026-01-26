const std = @import("std");
const rl = @import("c.zig").rl;

const Player = @import("Player.zig");
const Projectile = @import("Projectile.zig");
const SpriteAnimation = @import("SpriteAnimation.zig");

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

pub fn run() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const GLOBAL_FPS = 60;

    rl.InitWindow(800, 600, "game");
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
        .spriteList = spriteList[0..],
        .orientation = .RIGHT,
        .currentSpriteStance = .Idle,
        .currentSprite = undefined,
        .keyMap = player1Keys,
        .hurtbox = .{},
    };

    var playList = [_]Player{
        player1,
    };

    var projList = try std.ArrayList(Projectile)
        .initCapacity(allocator, 10);
    defer projList.deinit(allocator);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();
        rl.ClearBackground(rl.RAYWHITE);

        const dTime = rl.GetFrameTime();

        // players gestion
        for (&playList) |*player| {
            player.handlePlayerMovement(
                dTime,
            );

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
                proj.handlePosition(
                    dTime,
                );
                proj.draw();
            }
        }

        // draw players last to be on top
        for (&playList) |*p| {
            p.draw();
        }
    }
}
