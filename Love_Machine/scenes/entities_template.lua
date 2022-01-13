Class = require "libs.hump.class"

Entity = Class{}

function Entity:init(x, y, number) -- delay in seconds
	--All have a timer 
	self.timer = 0
	--position size
	self.x = x
	self.y = y
	self.player_number = number
end


function Entity:update(dt)
	--Update timer
	self.timer = self.timer + dt
	
end

function Entity:draw()

end

return Entity