Class = require "libs.hump.class"
Food = require "scenes.minigame_4.entities.Food"

Plate = Class{
	init = function(self, x, y, radius)

	--defines playable area
	self.area = {} 
	self.area.x = x
	self.area.y = y
	self.area.radius = radius
	self.area.r = radius

	self.food_number = 15
	self.food_holder = {}
	math.randomseed(os.time())
	for i = 1, self.food_number, 1 do
		local r = (self.area.r - 100) * math.sqrt(math.random())
		local theta = math.random() * 2 * math.pi
		local new_x =  self.area.x + r * math.cos(theta)
		new_food = Food(new_x, -300, i)
		table.insert(self.food_holder, new_food)
	end
	self.food_left = nil

	end
	}

function Plate:update(dt)

end

function Plate:draw()
	--draw plate
	love.graphics.setColor(0.95,0.95,0.95)
	love.graphics.circle( "fill", self.area.x, self.area.y, self.area.r )
	love.graphics.setColor(0,0,0)
	love.graphics.circle( "line", self.area.x, self.area.y, self.area.r * (2/3))
	love.graphics.setColor(1,1,1)
	love.graphics.circle( "fill", self.area.x, self.area.y, self.area.r * (2/3) -1 )
	
	--draw food
	for k, v in pairs(self.food_holder) do
		v:draw()
	end

end

return Plate