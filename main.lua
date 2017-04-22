local enums = require "enums"
local bump = require "bump/bump"
local anim8 = require "anim8/anim8"
local Timer = require "hump.timer"
local inspect = require "inspect/inspect"
require "character"
require "helper_functions"
require "ai"
require "scoring"

in_focus = false
debug = true
screen_values = { width = 1600, height = 960 }
game_speed = 1
detection_zone_width = 200
debug_font_size = 16
game_over = false

love.window.setMode( screen_values.width, screen_values.height, { resizable = true, vsync = true, minwidth = 1600, minheight= 960 , fullscreen = false })
love.window.setTitle( "Wrong Neighborhood" )

gameoverColors =  {
    G = 255,
    B = 255
}

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

camera_rectangle = {
    position = {
        x = 0,
        y = 0
    },
    width = screen_values.width,
    height = screen_values.height
}


function love.focus(focus)
    in_focus = focus
end

function love.load(arg)

    -- Load Textures
    font = love.graphics.newFont("Assets/PressStart2P.ttf", debug_font_size)
    love.graphics.setFont(font)
    world = bump.newWorld()
    images = {}

    STD_CHR_WIDTH, STD_CHR_HEIGHT = 76, 104

    player1 = Character:newPlayerChar(100, screen_values.height * 0.7, 200, 10, 1, STD_CHR_WIDTH, STD_CHR_HEIGHT)

    local torso_spacing = 25
    local head_room = 58
    local leg_length = 20

    player1:setBboxDimensions(
        player1.width - (torso_spacing * 2), -- frame width of animation has a padding of 2 * torso spacing to make all frame equal width
        player1.height - head_room, -- frame width of animation has a padding head_room (space over the head) to make all frame equal height
        { -- bounding box frame offsets, for drawing the frame
            x = torso_spacing,
            y = head_room - leg_length
        }
    )

    table.insert(entities.players, player1)

    Score:setupTimer(0)
    Score:setupScoreCount(0)

    imageAssets = {
        player1 = {
            idle = love.graphics.newImage("Assets/miniplayer_idle.png"),
            punch = love.graphics.newImage("Assets/miniplayer_punch.png"),
            walk = love.graphics.newImage("Assets/miniplayer_walk.png"),
            kick = love.graphics.newImage("Assets/miniplayer_kick.png"),
            death = love.graphics.newImage("Assets/miniplayer_death.png")
        },
        punk = {
            idle = love.graphics.newImage("Assets/minienemy1_idle.png"),
            punch = love.graphics.newImage("Assets/minienemy1_punch.png"),
            walk = love.graphics.newImage("Assets/minienemy1_walk.png"),
            kick = love.graphics.newImage("Assets/minienemy1_kick.png"),
            death = love.graphics.newImage("Assets/minienemy1_death.png")
        },
        heavy = {
            idle = love.graphics.newImage("Assets/minienemy2_idle.png"),
            kick = love.graphics.newImage("Assets/minienemy2_kick.png"),
            punch = love.graphics.newImage("Assets/minienemy2_punch.png"),
            walk = love.graphics.newImage("Assets/minienemy2_walk.png")
        }
    }


    local char = imageAssets['player1']
    local h = anim8.newGrid(STD_CHR_WIDTH, STD_CHR_HEIGHT, char.idle:getWidth(), char.idle:getHeight())
    local j = anim8.newGrid(STD_CHR_WIDTH, STD_CHR_HEIGHT, char.punch:getWidth(), char.punch:getHeight())
    local k = anim8.newGrid(STD_CHR_WIDTH, STD_CHR_HEIGHT, char.walk:getWidth(), char.walk:getHeight())
    local l = anim8.newGrid(STD_CHR_WIDTH, STD_CHR_HEIGHT, char.kick:getWidth(), char.kick:getHeight())
    local m = anim8.newGrid(64, 104, char.death:getWidth(), char.death:getHeight())

    char = imageAssets['punk']
    local epi = anim8.newGrid(STD_CHR_WIDTH, STD_CHR_HEIGHT, char.idle:getWidth(), char.idle:getHeight())
    local epk = anim8.newGrid(STD_CHR_WIDTH, STD_CHR_HEIGHT, char.kick:getWidth(), char.kick:getHeight())
    local epp = anim8.newGrid(STD_CHR_WIDTH, STD_CHR_HEIGHT, char.punch:getWidth(), char.punch:getHeight())
    local epw = anim8.newGrid(STD_CHR_WIDTH, STD_CHR_HEIGHT, char.walk:getWidth(), char.walk:getHeight())
    local epd = anim8.newGrid(STD_CHR_WIDTH, STD_CHR_HEIGHT, char.death:getWidth(), char.death:getHeight())

    char = imageAssets['heavy']
    local ehi = anim8.newGrid(64, 104, char.idle:getWidth(), char.idle:getHeight())
    local ehk = anim8.newGrid(64, 104, char.kick:getWidth(), char.kick:getHeight())
    local ehp = anim8.newGrid(64, 104, char.punch:getWidth(), char.punch:getHeight())
    local ehw = anim8.newGrid(64, 104, char.walk:getWidth(), char.walk:getHeight())

    animationAssets = {
        player1 = {
            idle = anim8.newAnimation(h('1-4', 1), 0.25),
            punch = anim8.newAnimation(j('1-4', 1), 0.1),
            walk = anim8.newAnimation(k('1-4', 1), 0.1),
            kick = anim8.newAnimation(l('1-4', 1), 0.1),
            death = anim8.newAnimation(m('1-4', 1), 0.25, "pauseAtEnd")
        },
        punk = {
            idle = anim8.newAnimation(epi('1-4', 1), 0.25),
            kick = anim8.newAnimation(epk('1-4', 1), 0.1),
            punch = anim8.newAnimation(epp('1-4', 1), 0.1),
            walk = anim8.newAnimation(epw('1-4', 1), 0.1),
            death = anim8.newAnimation(epd('1-6', 1), 0.25, "pauseAtEnd")
        },
        heavy = {
            idle = anim8.newAnimation(ehi('1-4', 1), 0.25),
            kick = anim8.newAnimation(ehk('1-4', 1), 0.1),
            punch = anim8.newAnimation(ehp('1-4', 1), 0.1),
            walk = anim8.newAnimation(ehw('1-4', 1), 0.1)
        }
    }
    -- Init map
    cars = love.graphics.newImage("Assets/cars.png")
    green_car = love.graphics.newQuad(0, 0, 128, 128, cars:getWidth(), cars:getHeight())
    yellow_car = love.graphics.newQuad(128, 0, 128, 128, cars:getWidth(), cars:getHeight())
    red_car = love.graphics.newQuad(256, 0, 128, 128, cars:getWidth(), cars:getHeight())
    blue_car = love.graphics.newQuad(256 + 128, 0, 128, 128, cars:getWidth(), cars:getHeight())

    obstacles = love.graphics.newImage("Assets/obstacles_small.png")
    standing_barrel = love.graphics.newQuad(0, 0, 64, 64, obstacles:getWidth(), obstacles:getHeight())
    vertical_barrel = love.graphics.newQuad(64, 0, 64, 64, obstacles:getWidth(), obstacles:getHeight())
    diagonal_barrel = love.graphics.newQuad(128, 0, 64, 64, obstacles:getWidth(), obstacles:getHeight())
    barricade_quad = love.graphics.newQuad(128 + 64, 0, 64, 64, obstacles:getWidth(), obstacles:getHeight())

    street = love.graphics.newImage("Assets/asphalt.png")
    asphalt = love.graphics.newQuad(0, 0, 64, 64, street:getWidth(), street:getHeight())
    plank_and_sidewalk = love.graphics.newQuad(64, 0, 64, 64, street:getWidth(), street:getHeight())
    plank = love.graphics.newQuad(128, 0, 64, 64, street:getWidth(), street:getHeight())
    plank_top = love.graphics.newQuad(192, 0, 64, 64, street:getWidth(), street:getHeight())
    gutter = love.graphics.newQuad(192 + 64, 0, 64, 64, street:getWidth(), street:getHeight())
    sidewalk = love.graphics.newQuad(192 + 64 * 2, 0, 64, 64, street:getWidth(), street:getHeight())
    street_lines = love.graphics.newQuad(192 + 64 * 3, 0, 64, 64, street:getWidth(), street:getHeight())

    player1:setAniState('idle')

    --- put your persons here

    local punk_enemy = new_punk(600, 600, STD_CHR_WIDTH, STD_CHR_HEIGHT)

    punk_enemy:setBboxDimensions(
        player1.width - (torso_spacing * 2), -- frame width of animation has a padding of 2 * torso spacing to make all frame equal width
        player1.height - head_room, -- frame width of animation has a padding head_room (space over the head) to make all frame equal height
        { -- bounding box frame offsets, for drawing the frame
            x = torso_spacing,
            y = head_room - leg_length
        }
    )

    table.insert(entities.enemies, punk_enemy)

    punk_enemy = new_punk(700, 650, STD_CHR_WIDTH, STD_CHR_HEIGHT)

    punk_enemy:setBboxDimensions(
        player1.width - (torso_spacing * 2), -- frame width of animation has a padding of 2 * torso spacing to make all frame equal width
        player1.height - head_room, -- frame width of animation has a padding head_room (space over the head) to make all frame equal height
        { -- bounding box frame offsets, for drawing the frame
            x = torso_spacing,
            y = head_room - leg_length
        }
    )

    table.insert(entities.enemies, punk_enemy)

    for index, enemy in ipairs(entities.enemies) do
        enemy:faceLeft()
    end

    init_world(world)
end

function init_world(world)
    local bbox_width, bbox_height

    for i = 1, #entities.players, 1 do
        local player = entities.players[i]
        player.name = "player" .. i

        bbox_width, bbox_height = player:getBboxDimensions()
        world:add( player, player.position.x, player.position.y, bbox_width, bbox_height)
        player:setKickBox(26, 20) -- Set the width and height of the punch kick boxes
        player:setPunchBox(22, 16)
    end

    for i = 1, #entities.enemies, 1 do
        local enemy = entities.enemies[i]

        bbox_width, bbox_height = enemy:getBboxDimensions()
        enemy.name = "enemy" .. enemy.kind .. i
        world:add( enemy, enemy.position.x, enemy.position.y, bbox_width, bbox_height)
        enemy:setKickBox(26, 20)
        enemy:setPunchBox(22, 16)
    end

    for i = 0, 275, 1 do
        table.insert(entities.road.planks_top, { position = { x = i * 58, y = screen_values.height * (2/5) - 94 - 64 }, width = 64, height = 64 })
        table.insert(entities.road.planks, { position = { x = i * 58, y = screen_values.height * (2/5) - 94 }, width = 64, height = 64 })
        table.insert(entities.road.plank_and_sidewalk, { position = { x = i * 58, y = screen_values.height * (2/5) - 30 }, width = 64, height = 64 })
        table.insert(entities.road.sidewalk, { position = { x = i * 58, y = screen_values.height * (2/5) + 34 }, width = 64, height = 64 })
        table.insert(entities.road.gutter, { position = { x = i * 58, y = screen_values.height * (2/5) + 98 }, width = 64, height = 64 })
        table.insert(entities.road.street, { position = { x = i * 58, y = screen_values.height * (2/5) + 98 + 64 }, width = 64, height = 64 })
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

    if not game_over then
        Score:updateTimer(dt)
        Score:updateScoreCount(dt)
    end
    
    Timer.update(dt)

    -- For each player update
    for i, player in ipairs(entities.players) do

        if not game_over then
            --check if game is over
            game_over = not (game_over or player:isAlive())
        end

        player.animation:update(dt)

        if player:isAlive() then
            x, y, punch, kick = player:updatePlayer()

            if not punch and not kick and player.attackTimer < love.timer.getTime() then
                player:move(
                    player.movement_speed * game_speed * x * dt,
                    player.movement_speed * game_speed * y * dt
                )
            end

            if x < 0 then
                player:faceLeft()
            end

            if 0 < x then
                player:faceRight()
            end

            if punch and player.attackTimer < love.timer.getTime() then
                player:punch(Timer)
            end

            if kick and player.attackTimer < love.timer.getTime() then
                player:kick(Timer)
            end

            if (x ~= 0 or y ~= 0) and player.attackTimer < love.timer.getTime() then
                player:goToState('walk')
            elseif (player.attackTimer < love.timer.getTime()) then
                player:goToState('idle')
            end

            player:handleAttackBoxes()
        else
            player:death()
        end

    end


    if game_over then
        gameoverColors.G = math.max(gameoverColors.G - dt * 148, 0)
        gameoverColors.B = math.max(gameoverColors.B - dt * 148, 0)
    end

    AI:update(dt, Score, Timer)
end

function love.draw()
    love.graphics.scale(h_scale, v_scale)

    Score:drawTimer()
    Score:drawScoreCount()

    if debug then
        debug_info()
    end
    -- Draw each animation and object within the frame
    local x_offset, y_offset
    if (locked_camera) then

    else
        x_offset = (entities.players[1].position.x - (screen_values.width / 2))
        y_offset = 0

        camera_rectangle.position.x = x_offset
        camera_rectangle.position.y = y_offset

        love.graphics.translate(-x_offset, y_offset)
    end


    --- background ---

    --Draw top of planks

    for i = 1, #entities.road.planks_top do
        local pands = entities.road.planks_top[i]
        if check_collision(pands, camera_rectangle) then
            love.graphics.draw(street, plank_top, pands.position.x, pands.position.y)
        end
    end

    -- planks
    for i = 1, #entities.road.planks do
        local pands = entities.road.planks[i]
        if check_collision(pands, camera_rectangle) then
            love.graphics.draw(street, plank, pands.position.x, pands.position.y)
        end
    end

    -- Draw plank and sidewalk combo
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

    -- Draw gutter flipped

    for i = 1, #entities.road.gutter do
        local g = entities.road.gutter[i]
        if check_collision(g, camera_rectangle) then
            love.graphics.draw(street, gutter, g.position.x + 64, g.position.y + 7 * 64, math.pi)
        end
    end

    for i = 1, #entities.road.street do
        local s = entities.road.street[i]
        if check_collision(s, camera_rectangle) then
            love.graphics.draw(street, asphalt, s.position.x, s.position.y)
            love.graphics.draw(street, asphalt, s.position.x, s.position.y + 64)
            love.graphics.draw(street, asphalt, s.position.x, s.position.y + 64 * 3)
            love.graphics.draw(street, asphalt, s.position.x, s.position.y + 64 * 4)
        end
    end

    for i = 1, #entities.road.street_lines do
        local sl = entities.road.street_lines[i]
        if check_collision(sl, camera_rectangle) then
            love.graphics.draw(street, street_lines, sl.position.x, sl.position.y)
        end
    end


    --- end of background ---

    for i = 1, #entities.road.barricades do
        local barricade = entities.road.barricades[i]
        if check_collision(barricade, camera_rectangle) then
            love.graphics.draw(obstacles, barricade_quad, barricade.position.x, barricade.position.y)
        end
    end

    for i = 1, #entities.enemies do
        local enemy = entities.enemies[i]
        if check_collision(enemy, camera_rectangle) then
            local x, y = enemy:getBboxPosition()
            enemy.animation:draw(enemy.image, x, y, 0, 1, 1)
        end
    end

    
    for i = 1, #entities.players do
        local player = entities.players[i]
        local x, y = player:getBboxPosition()
        player.animation:draw(player.image, x, y, 0, 1, 1)
    end

    if game_over then
        love.graphics.setColor(255, gameoverColors.G, gameoverColors.B, 255)
    end

    if debug then
        draw_debuxes()
        love.graphics.rectangle("fill", 5, 0, 1, screen_values.height)
        love.graphics.rectangle("fill", 5, screen_values.height * (2/5), screen_values.width * 10, 1)
        love.graphics.rectangle("fill", 5, screen_values.height * 0.9, screen_values.width * 10, 1)
        love.graphics.rectangle("fill", screen_values.width * 10, 0, 1, screen_values.height)

        local w, h = entities.players[1]:getBboxDimensions()

        love.graphics.rectangle("line", entities.players[1].position.x + detection_zone_width, 0, 1, screen_values.height )
        love.graphics.rectangle("line", entities.players[1].position.x + w - detection_zone_width, 0, 1, screen_values.height )
    end
end

function love.resize(width, height)
	h_scale = width / screen_values.width
	v_scale = height / screen_values.height
end

function draw_debuxes()
    local colItems, len = world:getItems()
    for i = 1, len do
        local x,y,w,h = world:getRect(colItems[i])
        love.graphics.rectangle("line", x, y, w, h)
    end

    for index, player in ipairs(entities.players) do

        -- lines for the frame box (e.g. where the animation frame was without any bounding box)
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.rectangle("line", player.position.x, player.position.y, player.width, player.height)
        love.graphics.setColor(r, g, b, a)

        --- bounding box for kicking and punching
        if player.punch_box.isActive then
            love.graphics.rectangle("fill", player.punch_box.x, player.punch_box.y, player.punch_box.width, player.punch_box.height)
        else
            love.graphics.rectangle("line", player.punch_box.x, player.punch_box.y, player.punch_box.width, player.punch_box.height)
        end
        if player.kick_box.isActive then
            love.graphics.rectangle("fill", player.kick_box.x, player.kick_box.y, player.kick_box.width, player.kick_box.height)
        else
            love.graphics.rectangle("line", player.kick_box.x, player.kick_box.y, player.kick_box.width, player.kick_box.height)
        end
    end

    for index, enemy in ipairs(entities.enemies) do

        -- lines for the frame box (e.g. where the animation frame was without any bounding box)
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.rectangle("line", enemy.position.x, enemy.position.y, enemy.width, enemy.height)
        love.graphics.setColor(r,g,b,a)

        --- bounding box for kicking and punching
        if enemy.punch_box.isActive then
            love.graphics.rectangle("fill", enemy.punch_box.x, enemy.punch_box.y, enemy.punch_box.width, enemy.punch_box.height)
        else
            love.graphics.rectangle("line", enemy.punch_box.x, enemy.punch_box.y, enemy.punch_box.width, enemy.punch_box.height)
        end
        if enemy.kick_box.isActive then
            love.graphics.rectangle("fill", enemy.kick_box.x, enemy.kick_box.y, enemy.kick_box.width, enemy.kick_box.height)
        else
            love.graphics.rectangle("line", enemy.kick_box.x, enemy.kick_box.y, enemy.kick_box.width, enemy.kick_box.height)
        end
    end
end

function debug_info()

    love.graphics.printf("FPS: " .. love.timer.getFPS(), 20, 1 * debug_font_size, 1000, "left" )
    love.graphics.printf("Player1.x: " .. entities.players[1].position.x, 20, 2 * debug_font_size, 1000, "left" )
    love.graphics.printf("Player1.y: " .. entities.players[1].position.y, 20, 3 * debug_font_size, 1000, "left" )
    love.graphics.printf("enemy1.x: " .. entities.enemies[1].position.x, 20, 4 * debug_font_size, 1000, "left" )
    love.graphics.printf("enemy1.y: " .. entities.enemies[1].position.y, 20, 5 * debug_font_size, 1000, "left" )
    love.graphics.printf("enemy1 within trigger field? " .. tostring(entities.enemies[1].position.x <= entities.players[1].position.x + detection_zone_width),
        20, 6 * debug_font_size, 1000, "left")
    love.graphics.printf("enemy1 triggered? " .. tostring(entities.enemies[1].triggered), 20, 7 * debug_font_size, 1000, "left")
    love.graphics.printf("Facing left? " .. tostring(entities.players[1]:isFacingLeft()), 20, 8 * debug_font_size, 1000, "left")
    love.graphics.printf("player health " .. (entities.players[1].health), 20, 9 * debug_font_size, 1000, "left")
    love.graphics.printf("enemy health " .. (entities.enemies[1].health), 20, 10 * debug_font_size, 1000, "left")
end
