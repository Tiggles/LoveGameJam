local enums = require "enums"
local bump = require "bump/bump"
local anim8 = require "anim8/anim8"
require "character"
require "helper_functions"

in_focus = false
debug = true
screen_values = { width = 1600, height = 960 }
game_speed = 1

love.window.setMode( screen_values.width, screen_values.height, { resizable = true, vsync = true, minwidth = 1600, minheight= 960 , fullscreen = false })
love.window.setTitle( "Streets of Bitterness" )

entities = {
    players = {},
    enemies = {},
    objects = {},
    road = {
        sidewalk = {},
        street = {},
        street_lines = {},
        planks = {},
        planks_top = {},
        plank_and_sidewalk = {},
        barricades = {},
        gutter = {},
        flipped_gutter = {}
    },
    background = {}
}


function love.focus(focus)
    in_focus = focus
end

function love.load(arg)
    -- Load Textures
    world = bump.newWorld()
    table.insert(entities.players, Character:newPlayerChar(100, screen_values.height * 0.7, 200, 10))

    p1_idle = love.graphics.newImage("Assets/miniplayer_idle.png")
    local h = anim8.newGrid(64, 104, p1_idle:getWidth(), p1_idle:getHeight())
    p1_punch = love.graphics.newImage("Assets/miniplayer_punch.png")
    local j = anim8.newGrid(64, 104, p1_punch:getWidth(), p1_punch:getHeight())
    p1_walk = love.graphics.newImage("Assets/miniplayer_walk.png")
    local k = anim8.newGrid(64, 104, p1_punch:getWidth(), p1_punch:getHeight())
    p1_kick = love.graphics.newImage("Assets/miniplayer_kick.png")
    local l = anim8.newGrid(64, 104, p1_kick:getWidth(), p1_kick:getHeight())

    player1_animations = {
        idle = anim8.newAnimation(h('1-4', 1), 0.25),
        punch = anim8.newAnimation(j('1-4', 1), 0.1),
        walk = anim8.newAnimation(k('1-4', 1), 0.1),
        run = "",
        kick = anim8.newAnimation(l('1-4', 1), 0.1)
    }

    entities.players[1].animation = player1_animations.idle
    entities.players[1].facingLeft = false
    entities.players[1].image = p1_idle
    entities.players[1].attackTimer = 0

    player2_animations = {

    }

    enemy_animations = {

    }
    -- Init map
    barricade_img = love.graphics.newImage("Assets/barricade.png")
    street = love.graphics.newImage("Assets/asphalt.png")
    print("qyadd")
    asphalt = love.graphics.newQuad(0, 0, 64, 64, street:getWidth(), street:getHeight())
    plank_and_sidewalk = love.graphics.newQuad(64, 0, 64, 64, street:getWidth(), street:getHeight())
    plank = love.graphics.newQuad(128, 0, 64, 64, street:getWidth(), street:getHeight())
    plank_top = love.graphics.newQuad(192, 0, 64, 64, street:getWidth(), street:getHeight())
    gutter = love.graphics.newQuad(192 + 64, 0, 64, 64, street:getWidth(), street:getHeight())
    sidewalk = love.graphics.newQuad(192 + 64 * 2, 0, 64, 64, street:getWidth(), street:getHeight())
    street_lines = love.graphics.newQuad(192 + 64 * 3, 0, 64, 64, street:getWidth(), street:getHeight())
    init_world(world)
end

function init_world(world)
    for i = 1, #entities.enemies, 1 do
        local enemy = entities.enemies[i]
        world:add( { name = "enemy" }, enemy.position.x, enemy.position.y, enemy.width, enemy.height)
    end
    for i = 1, #entities.players, 1 do
        local player = entities.players[i]
        player.name = "player"..i
        world:add( player , player.position.x, player.position.y, player.width, player.height)
    end
    for i = #entities.objects, -1, 1 do
        local object = entities.objects[i]
        world:add( { name = "object" }, object.position.x, object.position.y, object.width, object.height)
    end

    for i = 0, 275, 1 do
        table.insert(entities.road.planks_top, { position = { x = i * 58, y = screen_values.height * (2/5) - 94 - 64 }, width = 64, height = 64 })
        table.insert(entities.road.planks, { position = { x = i * 58, y = screen_values.height * (2/5) - 94 }, width = 64, height = 64 })
        table.insert(entities.road.plank_and_sidewalk, { position = { x = i * 58, y = screen_values.height * (2/5) - 30 }, width = 64, height = 64 })
        table.insert(entities.road.sidewalk, { position = { x = i * 58, y = screen_values.height * (2/5) + 34 }, width = 64, height = 64 })
        table.insert(entities.road.gutter, { position = { x = i * 58, y = screen_values.height * (2/5) + 98 }, width = 64, height = 64 })
        table.insert(entities.road.street, { position = { x = i * 58, y = screen_values.height * (2/5) + 98 + 64 }, width = 64, height = 64 })
        table.insert(entities.road.street, { position = { x = i * 58, y = screen_values.height * (2/5) + 98 + 64 * 2 }, width = 64, height = 64 })
        table.insert(entities.road.street, { position = { x = i * 58, y = screen_values.height * (2/5) + 98 + 64 * 4 }, width = 64, height = 64 })
        table.insert(entities.road.street, { position = { x = i * 58, y = screen_values.height * (2/5) + 98 + 64 * 5 }, width = 64, height = 64 })
        table.insert(entities.road.street_lines, { position = { x = i * 58, y = screen_values.height * (2/5) + 98 + 64 * 3 }, width = 64, height = 64 })
    end

    world:add( { name = "left bounding box"}, 5, 0, 1, screen_values.height)
    world:add( { name = "top bounding box"}, 5, screen_values.height * (2/5), screen_values.width * 10, 1)
    world:add( { name = "bottom bounding box"}, 5, screen_values.height * 0.9, screen_values.width * 10, 1)
    world:add( { name = "right bounding box"}, screen_values.width * 10, 0, 1, screen_values.height)

    world:add( { name = "1st left barricade"}, 5, 500, 64, 64)
    table.insert(entities.road.barricades, { position = { x = 5, y = 500 }, width = 64, height = 64 })
    world:add( { name = "2nd left barricade"}, 5, 500 + 64, 64, 64)
    table.insert(entities.road.barricades, { position = { x = 5, y = 500 + 64 }, width = 64, height = 64 })
    world:add( { name = "3rd left barricade"}, 5, 500 + 64 * 2, 64, 64)
    table.insert(entities.road.barricades, { position = { x = 5, y = 500 + 64 * 2 }, width = 64, height = 64 })
    world:add( { name = "4rd left barricade"}, 5, 500 + 64 * 3, 64, 64)
    table.insert(entities.road.barricades, { position = { x = 5, y = 500 + 64 * 3 }, width = 64, height = 64 })
    world:add( { name = "5th left barricade"}, 5, 500 + 64 * 4, 64, 64)
    table.insert(entities.road.barricades, { position = { x = 5, y = 500 + 64 * 4 }, width = 64, height = 64 })
    world:add( { name = "6th left barricade"}, 5, 500 + 64 * 5, 64, 64)
    table.insert(entities.road.barricades, { position = { x = 5, y = 500 + 64 * 5 }, width = 64, height = 64 })

    world:add( { name = "1st right barricade"}, screen_values.width * 10 - (5 + 64), 500, 64, 64)
    table.insert(entities.road.barricades, { position = { x = screen_values.width * 10 - (5 + 64), y = 500 }, width = 64, height = 64 })
    world:add( { name = "2nd right barricade"}, screen_values.width * 10 - (5 + 64), 500 + 64, 64, 64)
    table.insert(entities.road.barricades, { position = { x = screen_values.width * 10 - (5 + 64), y = 500 + 64 }, width = 64, height = 64 })
    world:add( { name = "3rd right barricade"}, screen_values.width * 10 - (5 + 64), 500 + 64 * 2, 64, 64)
    table.insert(entities.road.barricades, { position = { x = screen_values.width * 10 - (5 + 64), y = 500 + 64 * 2 }, width = 64, height = 64 })
    world:add( { name = "4rd right barricade"}, screen_values.width * 10 - (5 + 64), 500 + 64 * 3, 64, 64)
    table.insert(entities.road.barricades, { position = { x = screen_values.width * 10 - (5 + 64), y = 500 + 64 * 3 }, width = 64, height = 64 })
    world:add( { name = "5th right barricade"}, screen_values.width * 10 - (5 + 64), 500 + 64 * 4, 64, 64)
    table.insert(entities.road.barricades, { position = { x = screen_values.width * 10 - (5 + 64), y = 500 + 64 * 4 }, width = 64, height = 64 })
    world:add( { name = "6th right barricade"}, screen_values.width * 10 - (5 + 64), 500 + 64 * 5, 64, 64)
    table.insert(entities.road.barricades, { position = { x = screen_values.width * 10 - (5 + 64), y = 500 + 64 * 5 }, width = 64, height = 64 })

end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit();
    end
    -- For each object update

    -- For each enemy update
    print("Enemies count: " .. #entities.enemies)
    for i = #entities.enemies, -1, 1 do
        local enemy = entities.enemies[i]
        enemy:updateEnemy()
    end

    entities.players[1].animation:update(dt)

    -- For each player update
    for i = 1, #entities.players, 1 do
        local player = entities.players[i]
        local actualX = player.position.x
        local actualY = player.position.y
        player.name = "player"..i
        x, y, punch, kick = player:updatePlayer()
        if not punch and not kick and player.attackTimer < love.timer.getTime() then
            intendedX = player.position.x + player.movement_speed * game_speed * x * dt
            intendedY = player.position.y + player.movement_speed * game_speed * y * dt
            actualX, actualY, cols, len = world:move(player, intendedX, intendedY)
        end
        if punch and player.attackTimer < love.timer.getTime() then
            player.animation = player1_animations.punch
            player.image = p1_punch
            player.attackTimer = love.timer.getTime() + 0.5
            player.animation:gotoFrame(1)
        end

        if kick and player.attackTimer < love.timer.getTime() then
            player.animation = player1_animations.kick
            player.image = p1_kick
            player.attackTimer = love.timer.getTime() + 0.5
            player.animation:gotoFrame(1)
        end

        if ((x ~= 0 or y ~= 0) and player.attackTimer < love.timer.getTime()) then
            player.animation = player1_animations.walk
            player.image = p1_walk
        elseif (player.attackTimer < love.timer.getTime()) then
            player.animation = player1_animations.idle
            player.image = p1_idle
        end

        if (x < 0 and not player.animation.flippedH) then
            player.animation:flipH()
        elseif (x > 0 and player.animation.flippedH) then
            player.animation:flipH()
        end
        player.position.x = actualX; player.position.y = actualY;
    end
end

function love.draw()
    love.graphics.scale(h_scale, v_scale)
    if debug then
        debug_info()
    end
    -- Draw each animation and object within the frame
    local x_offset, y_offset
    if (locked_camera) then

    else
        --local average_x = 0
        --for i = 1, #entities.players do
        --    average_x = average_x + (entities.players[i].position.x - (screen_values.width / 2))
        --end
        --average_x = average_x / #entities.players
        x_offset = (entities.players[1].position.x - (screen_values.width / 2))
        y_offset = (entities.players[1].position.y - (screen_values.height / 2))

        camera_rectangle = {
            position = {
                x = x_offset,
                y = y_offset
            },
            width = screen_values.width,
            height = screen_values.height
        }
    end

    love.graphics.translate(-x_offset, -y_offset)

    for i = 1, #entities.road.planks do
        local pands = entities.road.planks[i]
        if check_collision(pands, camera_rectangle) then
            love.graphics.draw(street, plank, pands.position.x, pands.position.y)
        end
    end

    for i = 1, #entities.road.planks_top do
        local pands = entities.road.planks_top[i]
        if check_collision(pands, camera_rectangle) then
            love.graphics.draw(street, plank_top, pands.position.x, pands.position.y)
        end
    end

    for i = 1, #entities.road.plank_and_sidewalk do
        local pands = entities.road.plank_and_sidewalk[i]
        if check_collision(pands, camera_rectangle) then
            love.graphics.draw(street, plank_and_sidewalk, pands.position.x, pands.position.y)
        end
    end

    for i = 1, #entities.road.sidewalk do
        local sw = entities.road.sidewalk[i]
        if check_collision(sw, camera_rectangle) then
            love.graphics.draw(street, sidewalk, sw.position.x, sw.position.y)
        end
    end

    for i = 1, #entities.road.gutter do
        local g = entities.road.gutter[i]
        if check_collision(g, camera_rectangle) then
            love.graphics.draw(street, gutter, g.position.x, g.position.y)
        end
    end

    for i = 1, #entities.road.street do
        local s = entities.road.street[i]
        if check_collision(s, camera_rectangle) then
            love.graphics.draw(street, asphalt, s.position.x, s.position.y)
        end
    end

    for i = 1, #entities.road.street_lines do
        local sl = entities.road.street_lines[i]
        if check_collision(sl, camera_rectangle) then
            love.graphics.draw(street, street_lines, sl.position.x, sl.position.y)
        end
    end

    for i = 1, #entities.road.barricades do
        local barricade = entities.road.barricades[i]
        if check_collision(barricade, camera_rectangle) then
            love.graphics.draw(barricade_img, barricade.position.x, barricade.position.y, 0, 1, 1, 0, 0, 0, 0)
        end
    end
    for i = 1, #entities.enemies do
        local enemy = entities.enemies[i]
        if check_collision(enemy, camera_rectangle) then
            love.graphics.rectangle("fill", enemy.position.x, enemy.position.y, enemy.width, enemy.height)
        end
        --enemy.animation:draw(enemy.image, enemy.position.x, enemy.position.y, 0, 1, 1)
    end
    for i = #entities.objects, -1, 1 do

    end
    for i = 1, #entities.players do
        local player = entities.players[i]
        player.animation:draw(player.image, player.position.x, player.position.y, 0, 1, 1)
    end


    if false then
        love.graphics.rectangle("fill", 5, 0, 1, screen_values.height)
        love.graphics.rectangle("fill", 5, screen_values.height * (2/5), screen_values.width * 10, 1)
        love.graphics.rectangle("fill", 5, screen_values.height * 0.9, screen_values.width * 10, 1)
        love.graphics.rectangle("fill", screen_values.width * 10, 0, 1, screen_values.height)
    end
end

function love.resize(width, height)
	h_scale = width / screen_values.width
	v_scale = height / screen_values.height
end

function debug_info()

    love.graphics.printf("FPS: " .. love.timer.getFPS(), 20, 10, 1000, "left" )
    love.graphics.printf("Player1.x: " .. entities.players[1].position.x, 20, 20, 1000, "left" )
    love.graphics.printf("Player1.y: " .. entities.players[1].position.y, 20, 30, 1000, "left" )
end
