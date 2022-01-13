Class = require "libs.hump.class"

Generator = Class{}
local bump = require 'libs.bump'

function Generator:init(area, number_of_obstacles, speed, delay) -- delay in seconds

	self.timer = 0
	self.cycle_complete = false
	self.delay = delay
	self.time_holder = {}
	
	self.obstacle_holder_left = {}
	self.obstacle_holder_moving = {}
	
	self.obstacle_types = {{w = 100, h = 100},--small easy
						  {w = 250, h = 50}, -- low wide
						  {w = 50, h = 150}} -- high narrow
	for i=1, number_of_obstacles, 1 do
		new_obstacle = {}
		new_obstacle.delay = delay + (math.random(50, 150))/100
		new_obstacle.type = math.random(1, 3)
		new_obstacle.h = self.obstacle_types[new_obstacle.type].h
		new_obstacle.w = self.obstacle_types[new_obstacle.type].w
		new_obstacle.x = area.x + area.w -- after right edge x
		new_obstacle.y = area.y + area.h - new_obstacle.h
		new_obstacle.speed = speed
		new_obstacle.id = i
		new_obstacle.start_moving = false
		new_obstacle.tag = "obstacle"
		table.insert(self.obstacle_holder_left, new_obstacle)
		if #self.time_holder == 0 then 
			table.insert(self.time_holder, new_obstacle.delay)
		else
			table.insert(self.time_holder, self.time_holder[i-1] + new_obstacle.delay)
		end
	end

end


function Generator:update(dt)
	self.timer = self.timer + dt
	
	for k, v in pairs(self.obstacle_holder_moving) do 
		v.x = v.x - v.speed * dt
	end
	
end

function Generator:draw()
	for k, v in pairs(self.obstacle_holder_moving) do 
		love.graphics.setColor(0.5,0.5,0.5)
		love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
		love.graphics.setColor(1,1,1)
	
	end
end

return Generator