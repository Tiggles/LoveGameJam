local enums = require "enums"
require "position"
local inspect = require "inspect/inspect"

Character = {}


function Character:newCharacter(x, y, health, movement_speed, attack_damage, width, height)
    local new_character = {
        position = Position:newPosition(x, y),
        health = health,
        movement_speed = movement_speed,
        attack_damage = attack_damage,
        width = width,
        height = height,
        attackTimer = 0,
        bbox = { 
            width = 0, 
            height = 0, 
            offsets_x = 0, 
            offsets_y = 0 
        },
        punch_box = {
            x = 0,
            y = 0,
            width = 0,
            height = 0,
            charYOffset = 14, 
            isActive = false
        },
        kick_box = {
            x = 0,
            y = 0,
            width = 0,
            height = 0,
            charYOffset = 30, 
            isActive = false
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

function Character:setKickBox(width, height, bodyYOffset, isActive)
    if width ~= nil then
        self.kick_box.width = width
    end
    if height ~= nil then
        self.kick_box.height = height
    end
    if bodyYOffset ~= nil then
        self.kick_box.charYOffset = bodyYOffset
    end
    if isActive ~= nil then
        self.kick_box.isActive = isActive
    end
end

function Character:setPunchBox(width, height, bodyYOffset, isActive)
    if width ~= nil then
        self.punch_box.width = width
    end
    if height ~= nil then
        self.punch_box.height = height
    end
    if bodyYOffset ~= nil then
        self.punch_box.charYOffset = bodyYOffset
    end
    if isActive ~= nil then
        self.punch_box.isActive = isActive
    end
end

function Character:getKickBoxDimensions()
    return self.kick_box.width, self.kick_box.height
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
    char:setAniState(enums.animation_states.idle)
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

function Character:setAniState(state)
    local name = self:getName()

    local charAnimations = animationAssets[name]
    local charImages = imageAssets[name]

    self.animation = charAnimations[state]
    self.image = charImages[state]
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
    self:setAniState('death')
end

function Character:punch(timer)
    local name = self:getName()

    if self.kicking then return end

    local wasFacingLeft = self:isFacingLeft()

    self:setAniState('punch')

    if wasFacingLeft then
        self:faceLeft() -- make sure we face left
    else
        self:faceRight()
    end

    if name == "player1" and not self.punching then
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
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
    elseif name == "heavy" then
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
    elseif name == "punk" and not self.punching then
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
        timer.after(self.punch_delay, function()
            self.punch_box.isActive = true
        end)
        timer.after(self.punch_delay + 0.3, function()         
            self.punching = false
        end)
        self.punching = true    
    end

end

function Character:isFacingLeft()
    return self.animation.flippedH
end

function Character:faceLeft()
    if not self:isFacingLeft() then
        self.animation:flipH()
    end
end

function Character:faceRight()
    if self:isFacingLeft() then
        self.animation:flipH()
    end
end

function Character:walk()
    self:setAniState('walk')
end

function Character:idle()
    self:setAniState('idle')
end

function Character:kick(timer)
    local name = self:getName()

    if self.punching then return end

    local wasFacingLeft = self:isFacingLeft()

    self:setAniState('kick')

    if wasFacingLeft then
        self:faceLeft()
    else
        self:faceRight()
    end

    if name == "player1" and not self.kicking then
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
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
    elseif name == "heavy" then
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
    elseif name == "punk" and not self.kicking then
        self.attackTimer = love.timer.getTime() + 0.5
        self.animation:gotoFrame(1)
        timer.after(self.punch_delay, function()
            self.kick_box.isActive = true    
        end)
        timer.after(self.punch_delay + 0.4, function()         
            self.kicking = false
        end)
        self.kicking = true
    end
end

function Character:move(movement_x, movement_y)
    local intendedX = self.position.x + movement_x
    local intendedY = self.position.y + movement_y
    local actualX, actualY, col, len = world:move(self, intendedX, intendedY)
    self.position.x = actualX; self.position.y = actualY;
end

function Character:handleAttackBoxes()
    local w, h = self:getBboxDimensions()
    local pb_right_edge, kb_right_edge 

    if self:isFacingLeft() then
        pb_right_edge = math.abs( self.punch_box.width - w ) -- because the kick/punch box isn't as wide as the person bbox
        kb_right_edge = math.abs( self.kick_box.width - w )
        self.punch_box.x = self.position.x - w + pb_right_edge; 
        self.punch_box.y = self.position.y + self.punch_box.charYOffset; 

        self.kick_box.x = self.position.x - w + kb_right_edge;  
        self.kick_box.y = self.position.y + self.kick_box.charYOffset; 

    elseif not self:isFacingLeft() then
        self.punch_box.x = self.position.x + w  
        self.punch_box.y = self.position.y + self.punch_box.charYOffset; 

        self.kick_box.x = self.position.x + w; 
        self.kick_box.y = self.position.y + self.kick_box.charYOffset;
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


