
AI = {
	enemy_dead_zone_y = 15,
    enemy_dead_zone_x = 15
}

function AI:attack(currentEnemy, timer)
    local choice = math.random(0, 3)
    if choice <= 2 then
        currentEnemy:punch(timer)
    else
        currentEnemy:kick(timer)
    end
end


function AI:update(dt, scoreTable, timer)

	for i, currentEnemy in ipairs(entities.enemies) do

        currentEnemy.animation:update(dt)
        local en_pos_x = currentEnemy.position.x
        local en_pos_y = currentEnemy.position.y

        for index, player in ipairs(entities.players) do

            local w, h = player:getBboxDimensions() 

            if en_pos_x <= player.position.x + detection_zone_width or en_pos_x <= player.position.x - detection_zone_width then
                currentEnemy.triggered = true
            else
                currentEnemy.triggered = false
            end

            if currentEnemy.triggered then
            	--- Horizontal movement
                if en_pos_x > player.position.x + w + self.enemy_dead_zone_x then
                    local intendedX = currentEnemy.position.x - currentEnemy.movement_speed * dt
                    local intendedY = currentEnemy.position.y
                    local actualX, actualY, col, len = world:move(currentEnemy, intendedX, intendedY)
                    currentEnemy.position.x = actualX
                    currentEnemy.position.y = actualY
                    currentEnemy:setAniState('walk')
                    
                    currentEnemy:faceLeft()

                elseif en_pos_x < player.position.x then

                    local intendedX = currentEnemy.position.x + currentEnemy.movement_speed * dt
                    local intendedY = currentEnemy.position.y
                    local actualX, actualY, col, len = world:move(currentEnemy, intendedX, intendedY)
                    currentEnemy.position.x = actualX
                    currentEnemy.position.y = actualY
                    
                    currentEnemy:faceRight()
                end

                --- Vertical movement
                if en_pos_y > player.position.y + self.enemy_dead_zone_y then
                    -- enemy top to down

                    local intendedX = currentEnemy.position.x
                    local intendedY = currentEnemy.position.y - currentEnemy.movement_speed * dt
                    local actualX, actualY, col, len = world:move(currentEnemy, intendedX, intendedY)
                    currentEnemy.position.x = actualX
                    currentEnemy.position.y = actualY
                    currentEnemy:setAniState('walk')

                elseif en_pos_y < player.position.y - self.enemy_dead_zone_y then
                    -- enemy down to top
                    local intendedX = currentEnemy.position.x
                    local intendedY = currentEnemy.position.y + currentEnemy.movement_speed * dt
                    local actualX, actualY, col, len = world:move(currentEnemy, intendedX, intendedY)
                    currentEnemy.position.x = actualX
                    currentEnemy.position.y = actualY
                    currentEnemy:setAniState('walk')
                end

                if not (en_pos_x > player.position.x + w + self.enemy_dead_zone_y or en_pos_x < player.position.x
                    or en_pos_y > player.position.y + self.enemy_dead_zone_y or
                    en_pos_y < player.position.y - self.enemy_dead_zone_y) then
                    self:attack(currentEnemy, timer)
                    --currentEnemy:setAniState('idle')
                end

            else
                -- not triggered
                currentEnemy:setAniState('idle')
            end

            if player.punch_box.isActive then

                if check_collision({ position = { x = player.punch_box.x, y = player.punch_box.y}, width = player.punch_box.width, height = player.punch_box.height}, currentEnemy) then

                    scoreTable:pushScore(100)

                    if player:isFacingLeft() then
                        local intendedX = currentEnemy.position.x - 100
                        local intendedY = currentEnemy.position.y
                        local actualX, actualY, col, len = world:move(currentEnemy, intendedX, intendedY)
                        currentEnemy.position.x = actualX; currentEnemy.position.y = actualY
                    else 
                        local intendedX = currentEnemy.position.x + 100
                        local intendedY = currentEnemy.position.y
                        local actualX, actualY, col, len = world:move(currentEnemy, intendedX, intendedY)
                        currentEnemy.position.x = actualX; currentEnemy.position.y = actualY
                    end 
                end
            end

            if player.kick_box.isActive then

                if check_collision({ position = { x = player.kick_box.x, y = player.kick_box.y}, width = player.kick_box.width, height = player.kick_box.height}, currentEnemy) then
                    
                    scoreTable:pushScore(200)

                    if player.facingLeft then
                        currentEnemy:move(-300, 0)
                    else 
                        currentEnemy:move(300, 0)
                    end 
                end
            end
        end
        currentEnemy:handleAttackBoxes()
    end
end
