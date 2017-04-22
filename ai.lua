
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
    local actualX, actualY, col, len

	for i, currentEnemy in ipairs(entities.enemies) do

        currentEnemy.animation:update(dt)

        if currentEnemy:isAlive() then
            for index, player in ipairs(entities.players) do

                local w, h = player:getBboxDimensions() 

                if currentEnemy.position.x <= player.position.x + detection_zone_width and
                    currentEnemy.position.x >= player.position.x + w - detection_zone_width and player:isAlive() then
                    currentEnemy.triggered = true
                else
                    currentEnemy.triggered = false
                end

                if currentEnemy.triggered then

                    if not (
                        currentEnemy.position.x > player.position.x + w + self.enemy_dead_zone_x or 
                        currentEnemy.position.x < player.position.x - w - self.enemy_dead_zone_x or 
                        currentEnemy.position.y > player.position.y + self.enemy_dead_zone_y or
                        currentEnemy.position.y < player.position.y - self.enemy_dead_zone_y
                        ) then
                        -- current enemy within "striking distance"

                        if currentEnemy.position.x > player.position.x + (w / 2) then
                            -- if the enemy is on the right of the player, face left
                            currentEnemy:faceLeft()
                        else
                            -- else face right
                            currentEnemy:faceRight()
                        end

                        self:attack(currentEnemy, timer)

                        -- change this to something useful
                        currentEnemy:checkCollision(
                            player, 
                            function(me, other)
                                other:looseHealth(me.attack_damage * 0.1)
                            end, 
                            function(me, other)
                                other:looseHealth(me.attack_damage * 0.2)
                            end
                        )

                        --currentEnemy:setAniState('idle')
                    else
                        -- else we move to get to the striking distance

                    	--- Horizontal movement
                        if currentEnemy.position.x > player.position.x + w + self.enemy_dead_zone_x then

                            currentEnemy:move(-currentEnemy.movement_speed * dt, 0)

                            currentEnemy:setAniState('walk')
                            currentEnemy:faceLeft()

                        elseif currentEnemy.position.x < player.position.x - w - self.enemy_dead_zone_x then

                            currentEnemy:move(currentEnemy.movement_speed * dt, 0)

                            currentEnemy:setAniState('walk')
                            currentEnemy:faceRight()
                        end

                        --- Vertical movement
                        if currentEnemy.position.y > player.position.y + self.enemy_dead_zone_y then
                            -- enemy top to down

                            currentEnemy:move(0, -currentEnemy.movement_speed * dt)
                            currentEnemy:setAniState('walk')

                        elseif currentEnemy.position.y < player.position.y - self.enemy_dead_zone_y then
                            -- enemy down to top

                            currentEnemy:move(0, currentEnemy.movement_speed * dt)
                            currentEnemy:setAniState('walk')
                        end
                    end

                else
                    -- not triggered
                    currentEnemy:goToState('idle')
                end

                player:checkCollision(
                    currentEnemy, 
                    function(me, other)
                        other.health = other.health - me.attack_damage * 0.1
                    end, 
                    function(me, other)
                        other.health = other.health - me.attack_damage * 0.2
                    end
                )

            end
            currentEnemy:handleAttackBoxes()
        else
            currentEnemy:death()
        end
    end
end
