
Score = {
	timer = {
		font_size = 26,
		countType = 'up',
		text_align = 'left',
		font = nil,
		position = { x = 0, y = 0 },
		current_time = 0,
		prefix = 'Time: ',
		overflow_limit = 2000
	},
	score_count = {
		current_score = 0,
		overflow_limit = 2000,
		text_align = 'left',
		prefix = 'Score: ',
		font_size = 26,
		position = { x = 0, y = 0 },
		font = nil,
		score_points_queue = {},
		multiplier = {
			multiplier_suffix = 'x',
			multiplier = 1,
			position = { x = 0, y =  0 },
			font_size = 26,
			minimum_multiplier = 1
		}
	}
}

local function poll_score(score_table)
	if #score_table.score_count.score_points_queue > 0 then
		local stuff = score_table.score_count.score_points_queue[1]
		table.remove(score_table.score_count.score_points_queue, 1)
		return stuff
	else
		return  nil
	end
end


function Score:setupTimer(start_time, font, font_size, position)
	self.timer.font_size = font_size ~= nil and font_size or 24
	self.timer.current_time = start_time ~= nil and start_time or 0
	
	if self.timer.font == nil then
		self.timer.font = love.graphics.newFont("Assets/PressStart2P.ttf", 
			self.timer.font_size)
	else
		self.timer.font = font
	end
	if position ~= nil then
		self.timer.position = position
	else
		local prefix_length = self.timer.font:getWidth(self.timer.prefix)
		local text_length = self.timer.font:getWidth(tostring(self.timer.current_time))
		self.timer.position = { x = love.graphics.getWidth() / 2 - text_length / 2 - prefix_length / 2,
			y = 40 }    
	end
end

function Score:setupScoreCount(start_score, font, font_size, position)
	self.score_count.font_size = font_size ~= nil and font_size or 24
	self.score_count.current_score = start_score ~= nil and start_score or 0

	if self.score_count.font == nil then
		self.score_count.font = love.graphics.newFont("Assets/PressStart2P.ttf", self.score_count.font_size)
	else
		self.score_count.font = font
	end
	if position ~= nil then
		self.timer.position = position
	else
		local prefix_length = self.score_count.font:getWidth(self.score_count.prefix)
		local text_length = self.timer.font:getWidth(tostring(self.score_count.current_score))
		self.score_count.position = {x = love.graphics.getWidth() / 2 - text_length / 2 - prefix_length / 2,
			y = 45 + self.score_count.font_size}
	end
end

function Score:setupMultiplier(minimum_multiplier)
	if minimum_multiplier ~= nil then
		self.score_count.multiplier.multiplier = minimum_multiplier
	end
	self.score_count.multiplier.position = { x = 30, y = 50 }
end

function Score:addToMultiplier(value)
	self.score_count.multiplier.multiplier = math.max(self.score_count.multiplier.multiplier + value, self.score_count.multiplier.minimum_multiplier)
end

function Score:getCurrentGameTime()
	return self.timer.current_time
end

function Score:drawTimer()

	local old_font = love.graphics.getFont()
	love.graphics.setFont(self.timer.font)
	love.graphics.printf(self.timer.prefix .. string.format("%02.1f", self.timer.current_time), self.timer.position.x, 
		self.timer.position.y, self.timer.overflow_limit, self.timer.text_align)
	love.graphics.setFont(old_font)
end

function Score:updateTimer(dt)
	if self.timer.countType == 'up' then
		self.timer.current_time = (self.timer.current_time + dt)
	elseif self.timer.countType == 'down' and self.timer.current_time > 0 then
	    self.timer.current_time = (self.timer.current_time - dt)
	end
end

function Score:pushScore(points)
	table.insert(self.score_count.score_points_queue, points)
end

function Score:getCurrentScore()
	return self.score_count.current_score
end

function Score:resetMultiplier()
	self.score_count.multiplier.multiplier = self.score_count.multiplier.minimum_multiplier
end

function Score:updateScoreCount(dt)
	local point = poll_score(self)
	while point ~= nil do
		self.score_count.current_score = self.score_count.current_score + point 
		point = poll_score(self)
	end
end

function Score:drawScoreCount()
	local old_font = love.graphics.getFont()
	love.graphics.setFont(self.timer.font)
	love.graphics.printf(self.score_count.prefix .. string.format("%05d", self.score_count.current_score), self.score_count.position.x,
		self.score_count.position.y, self.score_count.overflow_limit, self.score_count.text_align)
	love.graphics.setFont(old_font)
end

function Score:drawMultiplier()
	local old_font = love.graphics.getFont()
	love.graphics.setFont(self.timer.font)
	love.graphics.printf(string.format("%i", self.score_count.multiplier.multiplier) .. self.score_count.multiplier.multiplier_suffix, self.score_count.multiplier.position.x,
		self.score_count.multiplier.position.y, self.score_count.overflow_limit, self.score_count.text_align)
	love.graphics.setFont(old_font)
end