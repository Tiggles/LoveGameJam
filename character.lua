local enums = require "enums"
require "position"

Character = {}

function Character:newCharacter(x, y, health, movement_speed, attack_damage, width, height)
    local new_character = {
        position = Position:newPosition(x, y),
        health = health,
        movement_speed = movement_speed,
        attack_damage = attack_damage,
        width = width,
        height = height,
        bbox = { 
            width = 0, 
            height = 0, 
            offsets_x = 0, 
            offsets_y = 0 
        }
    }
    self.__index = self
    return setmetatable(new_character, self)
end

function Character:newEnemy(x, y, health, movement_speed, attack_damage, width, height)
    local new_enemy = Character:newCharacter(x, y, health, movement_speed, attack_damage, width, height)
    return new_enemy
end

function Character:setBboxDimensions(width, height, offsets)
    if offsets ~= nil then
        self.bbox.offsets_x = offsets.x
        self.bbox.offsets_y = offsets.y
    end

    if width ~= nil then
        self.bbox.width = width        
    end
    if width ~= nil then
        self.bbox.height = height
    end
end

function Character:getBboxDimensions()
    return self.bbox.width, self.bbox.height
end

function Character:getBboxPosition()
    return self.position.x - self.bbox.offsets_x, self.position.y - self.bbox.offsets_y
end


function new_punk(x, y, width, height)
    local char = Character:newEnemy(x, y, 50, 200, 10, width, height)
    char.kind = "punk"
    char.animation = enemy_animations.punk.idle
    char.image = e_punk_idle
    char.kick_delay = 0.4
    char.punch_delay = 0.24
    return char
end

function new_heavy(x, y, width, height)
    local char = Character:newEnemy(x, y, 50, 5, 10, width, height)
    char.kind = "heavy"
    char.kick_delay = 0.45
    char.punch_delay = 0.27
    return char
end

function Character:Update()
    if not self.trigged then return end;

    if self.kind == "heavy" then

    end
    if self.kind == "punk" then

    end
end

function Character:getName()
    if self.kind == "player" then
        return string.format(self.kind .. "%i", self.id)
    end 
    return self.kind
end

function Character:newPlayerChar(x, y, movement_speed, attack_damage, id, width, height)
    local new_player = Character:newCharacter(x, y, 100, movement_speed, attack_damage, width, height)
    new_player.control_scheme = enums.control_schemes.left_control_scheme
    new_player.punching = false; new_player.kicking = false;
    new_player.kind = "player"
    new_player.id = id
    new_player.kick_delay = 0.4
    new_player.punch_delay = 0.24
    return new_player
end

function Character:updatePlayer(delta_time)
    if (enums.control_schemes.left_control_scheme == self.control_scheme) then
        return update_as_left()
    elseif (enums.control_schemes.right_control_scheme == self.control_scheme) then
        return update_as_right()
    elseif (enums.control_schemes.controller == self.control_scheme) then
        return update_as_controller()
    end
end

function Character:death()
    name = self:getName()

    if name == "player1" then
        self.animation = player1_animations.death
        self.image = p1_death
    elseif name == "player2" then
        self.animation = player2_animations.death
        self.image = p2_death
    elseif name == "heavy" then
        self.animation = enemy_animations.fatty.deathx
        self.image = ehd
    elseif name == "punk" then
        self.animation = enemy_animations.punk.death
        self.image = epd
    end
end

function Character:punch(timer)
    name = self:getName()

    if self.kicking then return end

    if name == "player1" and not self.punching then

        self.animation = player1_animations.punch
        self.image = p1_punch
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
        timer.after(self.punch_delay, function()
            self.punch_box.isActive = true
        end)
        timer.after(self.punch_delay + 0.3, function()         
            self.punching = false
        end)
        self.punching = true
    elseif name == "player2" then
        self.animation = player2_animations.punch
        self.image = p2_punch
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
    elseif name == "heavy" then
        self.animation = enemy_animations.fatty.punch
        self.image = ehp
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
    elseif name == "punk" then
        self.animation = enemy_animations.punk.punch
        self.image = epp
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)    
    end

end

function Character:walk()
    name = self:getName()
    if name == "player1" then

    elseif name == "player2" then
        --do
    elseif name == "heavy" then
        --do
    elseif name == "punk" then
        self.animation = enemy_animations.punk.walk
        self.image = epw
    end
end

function Character:idle()
    name = self:getName()

    if name == "player1" then

    elseif name == "player2" then
        self.animation = enemy_animations.player2.idle
        self.image = p2_idle
    elseif name == "heavy" then
        self.animation = enemy_animations.fatty.idle
        self.image = ehi
    elseif name == "punk" then
        self.animation = enemy_animations.punk.idle
        self.image = epi
    end
end

function Character:kick(timer)
    name = self:getName()

    if self.punching then return end

    if name == "player1" and not self.kicking then
        self.animation = player1_animations.kick
        self.image = p1_kick
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
        timer.after(self.punch_delay, function()
            self.kick_box.isActive = true    
        end)
        timer.after(self.punch_delay + 0.4, function()         
            self.kicking = false
        end)
        self.kicking = true
    elseif name == "player2" then
        self.animation = player2_animations.kick
        self.image = p2_kick
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
    elseif name == "heavy" then
        self.animation = enemy_animations.fatty.kick
        self.image = ehk
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
    elseif name == "punk" then
        self.animation = enemy_animations.punk.kick
        self.image = epk
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
    end
end

function Character:move(movement_x, movement_y)
    local intendedX = self.position.x + movement_x
    local intendedY = self.position.y + movement_y
    local actualX, actualY, col, len = world:move(self, intendedX, intendedY)
    self.position.x = actualX; self.position.y = actualY;
end

function Character:handleAttackBoxes()
    if self.facingLeft then
        self.punch_box.x = self.position.x - self.width / 2; 
        self.punch_box.y = self.position.y + 16; --self.punch_box.width = 50; self.punch_box.height = 20
    elseif not self.facingLeft then
        self.punch_box.x = self.position.x + self.width / 2; 
        self.punch_box.y = self.position.y + 16; --self.punch_box.width = 50; self.punch_box.height = 20
    end
    
    if self.facingLeft then
        --print("ha", self.width / 2, self.kick_box.width)
        self.kick_box.x = self.position.x - self.width / 2; 
        self.kick_box.y = self.position.y + 40; --self.kick_box.width = 40; self.kick_box.height = 40
    elseif not self.facingLeft then
        self.kick_box.x = self.position.x + self.width / 2; 
        self.kick_box.y = self.position.y + 40; --self.kick_box.width = 40; self.kick_box.height = 40
    end

    if self.attackTimer < love.timer.getTime() then
        self.kick_box.isActive = false
        self.punch_box.isActive = false
    end
end

function update_as_left(delta_time)
    local x = 0
    local y = 0
    local punch = false
    local kick = false
    local jump = false
    if love.keyboard.isDown("a") then
        x = x - 1
    end
    if love.keyboard.isDown("d") then
        x = x + 1
    end
    if love.keyboard.isDown("w") then
        y = y - 1
    end
    if love.keyboard.isDown("s") then
        y = y + 1
    end
    if love.keyboard.isDown("q") then
        punch = true
    end
    if love.keyboard.isDown("e") then
        kick = true
    end
    return x, y, punch, kick
end

function update_as_right(delta_time)
    local x = 0
    local y = 0
    local punch = false
    local kick = false
    local jump = false
    if love.keyboard.isDown("j") then
        x = x - 1
    end
    if love.keyboard.isDown("l") then
        x = x + 1
    end
    if love.keyboard.isDown("i") then
        y = y - 1
    end
    if love.keyboard.isDown("k") then
        y = y + 1
    end
    if love.keyboard.isDown("u") then
        punch = true
    end
    if love.keyboard.isDown("o") then
        kick = true
    end
    return x, y, punch, kick
end

function update_as_controller(delta_time)
    if love.joystick.getJoystickCount() == 0 then return end

    local joystick = love.joystick.getJoysticks()[1]
    local x = 0
    local y = 0
    local punch = false
    local kick = false
    local jump = false
    if joystick:isGamepadDown("dpleft") then
        x = x - 1
    elseif math.abs(joystick:getAxis( 1 )) > 0.2 then 
        x = joystick:getAxis( 1 )
    end
    if joystick:isGamepadDown("dpright") then
        x = x + 1
    end
    if joystick:isGamepadDown("dpup") then
        y = y - 1
    end
    if joystick:isGamepadDown("dpdown") then
        y = y + 1
    elseif math.abs(joystick:getAxis( 2 )) > 0.2 then 
        y = joystick:getAxis( 2 )
    end
    if joystick:isDown(3) then
        punch = true
    end
    if joystick:isDown(4) then
        kick = true
    end
    return x, y, punch, kick
end
