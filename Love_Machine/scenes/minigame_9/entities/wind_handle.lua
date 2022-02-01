Class = require "libs.hump.class"
local tween = require "libs.tween"
WindHandle = Class{}

function WindHandle:init(x, y, wind, timer) -- delay in seconds
	--position size
	self.circle = {}
	self.circle.r = 100
	self.circle.x = x
	self.circle.y = y
	
	self.wind = wind
	
	self.timer = timer 
	
	
	self.arrow = {}
	self.arrow.x = self.circle.x
	self.arrow.y = self.circle.y
	self.arrow.img = love.graphics.newImage( "scenes/minigame_9/img/arrow.png")
	self.arrow.w = self.arrow.img:getWidth()
	self.arrow.h = self.arrow.img:getHeight()
	if wind.direction == 1 then
		self.arrow.angle = 0
	else 
		self.arrow.angle = math.pi
	end
	
	self.tween = nil
	
end


function WindHandle:update(dt)
	if self.timer == 0 then 
		if self.wind.direction == 1 then
			goal = 0
		elseif self.wind.direction == -1 then
			goal = math.pi
		end
	self.tween = tween.new(0.1, self.arrow, {angle = goal}, "outBounce")
	end
	if self.tween ~= nil then 
		self.tween:update(dt)
		if self.tween:update(dt) == true then 
			self.tween = nil
		end
	end
	
end

function WindHandle:draw()
	--DRAW Circle 
	love.graphics.setColor(0,0,0)
	love.graphics.circle("fill", self.circle.x, self.circle.y, self.circle.r + 5)
	love.graphics.setColor(1,1,1)
	love.graphics.circle("fill", self.circle.x, self.circle.y, self.circle.r)
	love.graphics.draw(self.arrow.img, self.arrow.x, self.arrow.y, self.arrow.angle, 1, 1, self.arrow.w/2, self.arrow.h/2)

end

return WindHandle