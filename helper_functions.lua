function check_collision(self, other)
	local self_left = self.position.x
    local self_right = self.position.x + self.width
    local self_top = self.position.y
    local self_bottom = self.position.y + self.height

    local other_left = other.position.x
    local other_right = other.position.x + other.width
    local other_top = other.position.y
    local other_bottom = other.position.y + other.height

    if self_right >= other_left and
    self_left <= other_right and
    self_bottom >= other_top and
    self_top <= other_bottom then
        return true
    else
        return false
    end
end

function update_gameSpeed(game_speed, delta_time, time_rising)
    if time_rising then
        return math.min(game_speed + delta_time, 1)
    else
        return math.max(game_speed - delta_time, 0.5)
    end
end

function table_clone(old)
    new = {}
    for k, v in ipairs(old) do
        new[k] = v
    end
    return new
end


