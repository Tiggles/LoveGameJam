local enums = require "enums"
require "position"

Character = {}

function Character:newCharacter(x, y, z, movement_speed, attack_damage, width, height)
    local new_character = {
        position = Position:newPosition(x, y, z),
        movement_speed = movement_speed,
        attack_damage = attack_damage,
        width = width,
        height = height
    }
    self.__index = self
    return setmetatable(new_character, self)
end

function Character:newEnemy(x, y, movement_speed, attack_damage, width, height)
    local new_enemy = Character:newCharacter(x, y, 0, movement_speed, attack_damage, width, height)
    return new_enemy
end

function new_grunt(x, y)
    return Character:newEnemy(x, y, 0, 10, 5, 64, 128)
end

function new_heavy(x, y)
    return Character:newEnemy(x, y, 0, 5, 10, 64, 128)
end

function Character:newPlayerChar(x, y, movement_speed, attack_damage)
    local new_player = Character:newCharacter(x, y, 0, movement_speed, attack_damage, 64, 128)
    new_player.control_scheme = enums.control_schemes.left_control_scheme
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
    print(lastbutton)
    local x = 0
    local y = 0
    local punch = false
    local kick = false
    local jump = false
    if joystick:isGamepadDown("dpleft") then
        x = x - 1
    else
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
    else
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
