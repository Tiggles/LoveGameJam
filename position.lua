Position = {}

function Position:newPosition(x, y)
    local position = {
        x = x,
        y = y
    }
    self.__index = self
    return setmetatable(position, self)
end
