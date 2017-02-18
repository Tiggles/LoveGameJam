local enums = require "enums"
local bump = require "bump/bump"
local anim8 = require "anim8/anim8"
require "character"
require "helper_functions"

in_focus = false
debug = true
screen_values = { width = 1600, height = 960 }
game_speed = 1

love.window.setMode( screen_values.width, screen_values.height, { resizable = false, vsync = true, minwidth = 1600, minheight= 960 , fullscreen = false })
love.window.setTitle( "Streets of Bitterness" )

entities = {
    players = {},
    enemies = {},
    objects = {},
    road = {
        side_walk = {},
        barricades = {}
    },
    background = {}
}


function love.focus(focus)
    in_focus = focus
end

function love.load(arg)
    -- Load Textures
    world = bump.newWorld()
    table.insert(entities.players, Character:newPlayerChar(screen_values.width / 2, screen_values.height * 0.8, 1500, 10))
    table.insert(entities.enemies, new_grunt(500, 300))



    --coin_image = love.graphics.newImage("Assets/coin.png")
    --local h = anim8.newGrid(64, 64, coin_image:getWidth(), coin_image:getHeight())
    --table.insert(entities.animations, anim8.newAnimation(h('1-64', 1), 0.02))


    p1_idle = love.graphics.newImage("Assets/miniplayer_idle.png")
    local h = anim8.newGrid(64, 104, p1_idle:getWidth(), p1_idle:getHeight())

    player1_animations = {
        idle = anim8.newAnimation(h('1-4', 1), 0.25),
        punch = "",
        kick = "",
        run = ""
    }


    entities.players[1].animation = player1_animations.idle
    entities.players[1].facingLeft = false

    player2_animations = {

    }

    enemy_animations = {

    }
    -- Assets/player1_idle.png
    -- Assets/player1_kick.png
    -- Assets/player1_punch.png
    init_world(world)
    -- Init map
    sidewalk_img = love.graphics.newImage("Assets/sidewalk.png")
    barricade_img = love.graphics.newImage("Assets/barricade.png")
    -- Init objects
    for i = 0, 276 do
        table.insert(entities.road.side_walk, {
            position = {
                x = 58 * i,
                y = 510
            },
            width = 64,
            height = 64
         })
    end
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
        player.name = "player"..i
        x, y, punch, kick = player:updatePlayer()
        local intendedX = player.position.x + player.movement_speed * game_speed * x * dt
        local intendedY = player.position.y + player.movement_speed * game_speed * y * dt
        local actualX, actualY, cols, len = world:move(player, intendedX, intendedY)
        if (x < 0 and not facingLeft) then
            player.animation:flipH()
            player.facingLeft = true
        elseif (x > 0 and facingLeft) then
            player.animation:flipH()
            player.facingLeft = false
        end
        player.position.x = actualX; player.position.y = actualY;
    end
    -- For each animation update (move up?)
end

function love.draw()

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
        x_offset = (entities.players[1].position.x - (screen_values.width / 2))--(average_x - (screen_values.width / 2))
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

    for i = 1, #entities.road.side_walk do
        local sidewalk_slab = entities.road.side_walk[i]
        print("DEBUG")
        print(sidewalk_slab)
        print(#entities.road.side_walk)
        print(sidewalk_slab.position.x)
        if check_collision(sidewalk_slab, camera_rectangle) then
            love.graphics.draw(sidewalk_img, sidewalk_slab.position.x, sidewalk_slab.position.y, 0, 1, 1, 0, 0, 0, 0)
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
        player.animation:draw(p1_idle, player.position.x, player.position.y, 0, 1, 1)
    end

    if debug then
        love.graphics.rectangle("fill", 5, 0, 1, screen_values.height)
        love.graphics.rectangle("fill", 5, screen_values.height * (2/5), screen_values.width * 10, 1)
        love.graphics.rectangle("fill", 5, screen_values.height * 0.9, screen_values.width * 10, 1)
        love.graphics.rectangle("fill", screen_values.width * 10, 0, 1, screen_values.height)
    end
end

function love.resize(w, h)
    -- Disallow resize for now
end

function debug_info()

    love.graphics.printf("FPS: " .. love.timer.getFPS(), 20, 10, 1000, "left" )
    love.graphics.printf("Player1.x: " .. entities.players[1].position.x, 20, 20, 1000, "left" )
    love.graphics.printf("Player1.y: " .. entities.players[1].position.y, 20, 30, 1000, "left" )
end
