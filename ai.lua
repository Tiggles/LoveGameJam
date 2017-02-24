
AI = {
	enemy_dead_zone = 15
}


function AI:update(dt, enemies)

	for i = 1, #enemies do

        local current_enemy = entities.enemies[i]
        current_enemy.animation:update(dt)
        local en_pos_x = current_enemy.position.x
        local en_pos_y = current_enemy.position.y

        for index, player in ipairs(entities.players) do

            if en_pos_x <= player.position.x + detection_zone_width or en_pos_x <= player.position.x - detection_zone_width then
                current_enemy.triggered = true
            else
                current_enemy.triggered = false
            end

            if current_enemy.triggered then
            	--- Horizontal movement
                if en_pos_x > player.position.x + player.width then
                    local intendedX = current_enemy.position.x - current_enemy.movement_speed * dt
                    local intendedY = current_enemy.position.y
                    local actualX, actualY, col, len = world:move(current_enemy, intendedX, intendedY)
                    current_enemy.position.x = actualX
                    current_enemy.position.y = actualY
                    current_enemy.animation = enemy_animations.punk.walk
                    current_enemy.image = e_punk_walk
                    if not current_enemy.animation.flippedH then
                        current_enemy.animation:flipH()
                    end
                elseif en_pos_x < player.position.x then

                    local intendedX = current_enemy.position.x + current_enemy.movement_speed * dt
                    local intendedY = current_enemy.position.y
                    local actualX, actualY, col, len = world:move(current_enemy, intendedX, intendedY)
                    current_enemy.position.x = actualX
                    current_enemy.position.y = actualY
                    if current_enemy.animation.flippedH then
                        current_enemy.animation:flipH()
                    end
                end

                --- Vertical movement
                if en_pos_y > player.position.y + self.enemy_dead_zone then
                    -- enemy top to down

                    local intendedX = current_enemy.position.x
                    local intendedY = current_enemy.position.y - current_enemy.movement_speed * dt
                    local actualX, actualY, col, len = world:move(current_enemy, intendedX, intendedY)
                    current_enemy.position.x = actualX
                    current_enemy.position.y = actualY
                    current_enemy.animation = enemy_animations.punk.walk
                    current_enemy.image = e_punk_walk

                elseif en_pos_y < player.position.y - self.enemy_dead_zone then
                    -- enemy down to top
                    local intendedX = current_enemy.position.x
                    local intendedY = current_enemy.position.y + current_enemy.movement_speed * dt
                    local actualX, actualY, col, len = world:move(current_enemy, intendedX, intendedY)
                    current_enemy.position.x = actualX
                    current_enemy.position.y = actualY
                    current_enemy.animation = enemy_animations.punk.walk
                    current_enemy.image = e_punk_walk
                end

                if not (en_pos_x > player.position.x + player.width or en_pos_x < player.position.x
                    or en_pos_y > player.position.y + self.enemy_dead_zone or
                    en_pos_y < player.position.y - self.enemy_dead_zone) then
                    current_enemy.animation = enemy_animations.punk.idle
                    current_enemy.image = e_punk_idle
                end

            else
                current_enemy.animation = enemy_animations.punk.idle
                current_enemy.image = e_punk_idle
            end
        end
    end
end
