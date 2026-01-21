const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
    @cDefine("RAYMATH_IMPLEMENTATION", {});
    @cInclude("raymath.h");
});

const Player = struct {
    const FRAME_NUMBER = 7;

    velocity: rl.Vector2 = .{
        .x = 200,
        .y = 200,
    },
    orientation: SpriteOrientation = .RIGHT,
    position: rl.Vector2,
    texture: rl.Texture,
    keyMap: PlayerKeys,

    sourceRec: rl.Rectangle,
    currentFrame: c_int = 0,
    frameCounter: c_int = 0,
    frameSpeed: c_int = 7,
    spriteTint: rl.Color = rl.WHITE,
};
const SpriteOrientation = enum(i2) {
    RIGHT = 1,
    LEFT = -1,
};
const SCALE_FACTOR = 3;
const PlayerKeys = struct {
    UP: c_int,
    DOWN: c_int,
    LEFT: c_int,
    RIGHT: c_int,
    FIRE: c_int,
};

const Projectile = struct {
    velocity: rl.Vector2 = .{
        .x = 400,
        .y = 400,
    },
    rec: rl.Rectangle = .{
        .height = 20,
        .width = 20,
        .x = 0,
        .y = 0,
    },
};

const player1Keys: PlayerKeys = .{
    .UP = rl.KEY_W,
    .DOWN = rl.KEY_S,
    .LEFT = rl.KEY_A,
    .RIGHT = rl.KEY_D,
    .FIRE = rl.KEY_LEFT_SHIFT,
};

const player2Keys: PlayerKeys = .{
    .UP = rl.KEY_I,
    .DOWN = rl.KEY_K,
    .LEFT = rl.KEY_J,
    .RIGHT = rl.KEY_L,
    .FIRE = rl.KEY_RIGHT_SHIFT,
};

fn handlePlayerMovement(player: *Player, dTime: f32) rl.Vector2 {
    var userVel = rl.Vector2{
        .x = 0,
        .y = 0,
    };
    const keys = player.keyMap;
    if (rl.IsKeyDown(keys.LEFT)) {
        userVel.x -= 1;
        player.orientation = .LEFT;
    }
    if (rl.IsKeyDown(keys.RIGHT)) {
        userVel.x += 1;
        player.orientation = .RIGHT;
    }
    if (rl.IsKeyDown(keys.UP)) {
        userVel.y -= 1;
    }
    if (rl.IsKeyDown(keys.DOWN)) {
        userVel.y += 1;
    }
    const norm = rl.Vector2Normalize(userVel);
    player.position.x += player.velocity.x * dTime * norm.x;
    player.position.y += player.velocity.y * dTime * norm.y;

    return userVel;
}

fn drawPlayer(player: *Player) void {
    player.frameCounter += 1;
    if (player.frameCounter >= @divFloor(60, player.frameSpeed)) {
        player.frameCounter = 0;
        player.currentFrame += 1;

        if (player.currentFrame > (Player.FRAME_NUMBER - 1)) player.currentFrame = 0;

        player.sourceRec.x = @floatFromInt(player.currentFrame * @divExact(player.texture.width, Player.FRAME_NUMBER));
    }
    player.sourceRec.width = @floatFromInt(@divExact(player.texture.width, Player.FRAME_NUMBER) * @intFromEnum(player.orientation));
    rl.DrawTexturePro(
        player.texture,
        player.sourceRec,
        .{
            .x = player.position.x,
            .y = player.position.y,
            .width = @floatFromInt(@divExact(player.texture.width, Player.FRAME_NUMBER) * SCALE_FACTOR),
            .height = @floatFromInt(player.texture.height * SCALE_FACTOR),
        },
        .{
            .x = 0,
            .y = 0,
        },
        0,
        player.spriteTint,
    );
}

fn handleProjectilePosition(proj: *Projectile, dTime: f32) void {
    proj.rec.x += proj.velocity.x * dTime;
    proj.rec.y += proj.velocity.y * dTime;
}

fn drawProjectile(proj: *const Projectile) void {
    rl.DrawRectangleRec(
        proj.*.rec,
        rl.BLACK,
    );
}

fn isOutOfBound(proj: *const Projectile) bool {
    return proj.*.rec.x > 900 or
        proj.*.rec.x < -100 or
        proj.*.rec.y > 700 or
        proj.*.rec.y < -100;
}

pub fn run() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    rl.InitWindow(800, 600, "game");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    const texture = rl.LoadTexture("./assets/sprite.png");
    defer rl.UnloadTexture(texture);

    const player1 = Player{
        .position = .{
            .x = 0,
            .y = 0,
        },
        .texture = texture,
        .keyMap = player1Keys,
        .sourceRec = .{
            .x = 0,
            .y = 0,
            .width = @floatFromInt(@divExact(texture.width, Player.FRAME_NUMBER) * @intFromEnum(SpriteOrientation.RIGHT)),
            .height = @floatFromInt(texture.height),
        },
    };
    const player2 = Player{
        .position = .{ .x = 0, .y = 0 },
        .texture = texture,
        .keyMap = player2Keys,
        .sourceRec = .{
            .x = 0,
            .y = 0,
            .width = @floatFromInt(@divExact(texture.width, Player.FRAME_NUMBER) * @intFromEnum(SpriteOrientation.RIGHT)),
            .height = @floatFromInt(texture.height),
        },
        .spriteTint = rl.BLUE,
    };
    var playList = [2]Player{
        player1,
        player2,
    };

    var projList = try std.ArrayList(Projectile).initCapacity(
        allocator,
        10,
    );
    defer projList.deinit(allocator);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.RAYWHITE);

        const dTime = rl.GetFrameTime();

        // players gestion
        for (&playList) |*p| {
            const playerVel = handlePlayerMovement(
                p,
                dTime,
            );

            if (rl.IsKeyPressed(p.keyMap.FIRE)) {
                var proj: Projectile = .{
                    .rec = .{
                        .width = 20,
                        .height = 20,
                        .x = p.position.x + @as(f32, @floatFromInt(@divTrunc(p.texture.width * SCALE_FACTOR, 2))) - 10,
                        .y = p.position.y + @as(f32, @floatFromInt(@divTrunc(p.texture.height * SCALE_FACTOR, 2))) - 10,
                    },
                };

                const norm = rl.Vector2Normalize(playerVel);
                proj.velocity.x *= norm.x;
                proj.velocity.y *= norm.y;

                try projList.append(allocator, proj);
                std.debug.print("Proj created with x: {d}, y: {d}, velX: {d:.2}\n", .{
                    proj.rec.x,
                    proj.rec.y,
                    proj.velocity.x,
                });
            }
        }

        // Proj gestion
        var i: usize = projList.items.len;
        while (i > 0) : (i -= 1) {
            const p = &projList.items[i - 1];
            if (isOutOfBound(p)) {
                _ = projList.swapRemove(i - 1);
                std.debug.print("Proj deleted\n", .{});
            } else {
                handleProjectilePosition(
                    p,
                    dTime,
                );
                drawProjectile(p);
            }
        }

        // draw players last to be on top
        for (&playList) |*p| {
            drawPlayer(p);
        }
    }
}
