Bike = Class{}

function Bike:init(x, y, number, w, h) -- delay in seconds
	--All have a timer
	self.timer = 0
	--position size
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.player_number = number
	self.speed = 500
	--for bump purpose
	self.pos = {}
	self.pos.x = self.x
	self.pos.y = self.y
	self.pos.w = self.w
	self.pos.h = self.h
	self.pos.player_number = self.player_number
	self.pos.crashed = false

	self.tag = "player_"..tostring(self.player_number)
	self.pos.tag = self.tag

	--vectors
	self.hump_vector = require "libs.hump.vector"
	self.vector = self.hump_vector.new(0,0)

	--image
	self.img = love.graphics.newImage("scenes/minigame_13/img/player_"..tostring(self.player_number)..".png")

	self.can_turn = true

	self.turn_sound = love.audio.newSource( "scenes/minigame_13/sound/turn.ogg", "static")
	self.turn_sound:setVolume(0.35)

	--CONTAINER FOR POINTS
	self.point_container = {}
	self.point_step = 1/15
	self.point_timer = 0
	self.rectangle_holder = {}
	self.polygon_holder = {}
	self.polygon_holder.up_points = {}
	self.polygon_holder.down_points = {}
	self.polygon_holder.final_points = {}

	-- KEYS
	if self.player_number == 1 then
		self.left_key = "s"
		self.right_key = "f"
		self.r = 0
		self.color = {0.1, 0.6, 0.9}
	elseif self.player_number == 2 then
		self.left_key = "j"
		self.right_key = "l"
		self.r = math.pi
		self.color = {0.9, 0.1, 0.2}
	end
end


function Bike:update(dt)
	--Update timer
	self.timer = self.timer + dt

 if self.pos.crashed == false then
		self.vector = self.hump_vector.fromPolar(self.r, self.speed)
		self.x = self.x + self.vector.x * dt
		self.y = self.y + self.vector.y * dt

		self.point_timer = self.point_timer + dt
		if self.point_timer >= self.point_step then
			self.point_timer = 0
			if #self.rectangle_holder <= 1 then
				new_rectangle = {x = self.x, y = self.y, r = self.r, w = 10, h = 10}
				new_rectangle.index = #self.rectangle_holder
			else
				--print("Player "..tostring(self.player_number).." X : "..tostring(self.x).."  previous x: "..tostring(self.rectangle_holder[(#self.rectangle_holder-1)].x))
				--print(#self.rectangle_holder)
				--print("P"..tostring(self.player_number).." "..self.r%math.pi)
				if self.r%math.pi < 0.0001 then --if going horizontal
					new_rectangle = {x = self.x, y = self.y, r = self.r, w = self.rectangle_holder[(#self.rectangle_holder-1)].x - self.x , h = 10}
				else
					new_rectangle = {x = self.x, y = self.y, r = self.r, w = 10, h =  self.rectangle_holder[(#self.rectangle_holder-1)].y - self.y}
				end
			end
			--rectify all
			if new_rectangle.w < 0 then
				new_rectangle.w = math.abs(new_rectangle.w)
				new_rectangle.x = new_rectangle.x - new_rectangle.w
			end
			if new_rectangle.h < 0 then
				new_rectangle.h = math.abs(new_rectangle.h)
				new_rectangle.y = new_rectangle.y - new_rectangle.h
			end
			new_rectangle.tag = "player_"..tostring(self.player_number).."_rectangle"
			new_rectangle.index = #self.rectangle_holder
			table.insert(self.rectangle_holder, new_rectangle)
			minigame_13.world:add(new_rectangle, new_rectangle.x, new_rectangle.y, new_rectangle.w, new_rectangle.h)
		end

		--for bump purpose
		self.pos.x = self.x
		self.pos.y = self.y
		self.pos.w = self.w
		self.pos.h = self.h
	end



end

function Bike:draw()
	--print trail
	love.graphics.setColor(self.color)
	for _, v in pairs(self.rectangle_holder) do
		love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
	end

	if self.pos.crashed == false then
		love.graphics.setColor(1,1,1)
		--love.graphics.push()
		--love.graphics.translate(self.x, self.y)
		--love.graphics.rotate(self.r)
		--love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h )
		--love.graphics.pop()
		--love.graphics.setColor(1,0,0)
		--love.graphics.rectangle("fill", self.pos.x, self.pos.y, 5, 5)
		love.graphics.draw(self.img, self.x, self.y, self.r, 1, 1, self.w/2, self.h/2)
	end


end

function Bike:handle_press(key)
	if minigame_13.phase == "active" then
		if key == self.left_key and self.can_turn == true then
			self.r = self.r - math.pi/2
			self.can_turn = false
			self.turn_sound:setPitch(math.random(80, 120)/100)
			self.turn_sound:play()
		end
		if key == self.right_key and self.can_turn == true then
			self.r = self.r + math.pi/2
			self.can_turn = false
			self.turn_sound:setPitch(math.random(80, 120)/100)
			self.turn_sound:play()
		end

		if key == "space" then
			self.speed = 0
		end
	end

end

function Bike:handle_release(key)
	if key == self.left_key then
		self.can_turn = true
	end
	if key == self.right_key then
		self.can_turn = true
	end
end

return Bike
