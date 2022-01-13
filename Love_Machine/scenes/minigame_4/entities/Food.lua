Class = require "libs.hump.class"

Food = Class{
	init = function(self, x, y, number)

	--defines playable area
	self.img = love.graphics.newImage( "scenes/minigame_4/img/Food_1_2.png")
	self.x = x
	self.y = y 
	self.rot = 0
	self.w = self.img:getWidth( )
	self.h = self.img:getHeight( )
	self.sy = 0.1
	self.number = number
	end
	}

function Food:update(dt)

end

function Food:draw()
	--draw Food
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.img, self.x, self.y, self.rot, 1, self.sy, self.w/2, self.h/2 )

end

return Food