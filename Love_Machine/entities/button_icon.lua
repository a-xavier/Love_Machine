Class = require "libs.hump.class"

ButtonIcon = Class{}

function ButtonIcon:init(x, y, w, h, color, label)
	self.x = x
	self.y = y
	self.original_w = 500
	self.original_h = 500
	self.w = w
	self.width = w
	self.height = h
	self.h = h
	self.label = label or ""
	self.img = love.graphics.newImage( "img/"..color.."_button.png")
	self.scale = self.w/self.original_w
	self.alpha = 1

	self.font = love.graphics.newFont(24)

	self.inside = {}
	self.inside.x = self.x + 92 * self.scale
	self.inside.y = self.y + 74 * self.scale
	self.inside.w = (433 - 92) * self.scale
	self.inside.h = (415 - 74) * self.scale

end


function ButtonIcon:update(dt)
	self.inside.x = self.x + 92 * self.scale
	self.inside.y = self.y + 74 * self.scale
end

function ButtonIcon:draw()
	love.graphics.setColor(1,1,1, self.alpha)
	love.graphics.draw(self.img, self.x, self.y, 0,self.scale, self.scale)

	--LABEL
	if self.label ~= nil then
		local width, wrappedtext = self.font:getWrap(self.label, self.inside.w )
		local height_of_text = #wrappedtext * self.font:getHeight()
		love.graphics.setColor(1,1,1, self.alpha)
		love.graphics.setFont(self.font)
		love.graphics.printf(self.label, self.inside.x, self.inside.y + (self.inside.h - height_of_text)/2 , self.inside.w, "center")
	end
end

return ButtonIcon
