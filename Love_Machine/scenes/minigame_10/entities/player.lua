local Player = Class{}

function Player:init(x, y, number, w, h) -- delay in seconds
	--All have a timer
	self.timer = 0
	--position size
	self.x = x
	self.try_x = x
	self.y = y
	self.try_y = y
	self.w = w
	self.h = h
	self.player_number = number
	self.tag = "player"
	self.feety = self.y + self.h
	self.last_platform = 1

	self.tween_bump = nil

 --IMAGE
	 self.img = {}
	 self.img.spritesheet = love.graphics.newImage( "scenes/minigame_10/img/braid_og_2_3.png")
	 self.img.quads = {}
	 self.img.current_quad = 1
	 for i = 0, 26, 1 do
		 local quad = love.graphics.newQuad(0 + i * 100, 0, 100, 100, 2700, 100)
		 table.insert(self.img.quads, quad)
	 end

	self.sound_jump = love.audio.newSource( "scenes/minigame_6/sound/jump_start.ogg", "static")
	self.sound_land = love.audio.newSource( "scenes/minigame_6/sound/jump_land.ogg", "static")
	self.sound_jump_played = false
	self.sound_land_played = true

	if self.player_number == 1 then
		self.color = {0.5,1,0.5}
		self.left_key = "s"
		self.jump_key = "d"
		self.right_key = "f"
	else
		self.color = {1,0.5,0.5}
		self.left_key = "j"
		self.jump_key = "k"
		self.right_key = "l"
	end

	--For physics in general
	self.mass = 750
	self.vely = 0
	self.velx = 0
	self.friction = 10
	self.max_vel = 800
	self.max_vely = -1500
	self.speed = 2000
	self.gravity = 9.81
	self.on_ground = true
	--tags for jump
	self.jump = {}
	self.jump.has_jump = true
	self.jump.jump_signal = false
	self.jump.jump_started = false
	self.jump.jump_finished = true
	self.jump.release = true
	self.jump.timer = 0
	self.jump.timer_max = 0.15
	self.jump.force = -19000
	self.jump.max_height = 450

	--left right speed
end


function Player:update(dt)
	--Update timer
	self.timer = self.timer + dt

	--tween
	if self.tween_bump ~= nil then
		self.tween_bump:update(dt)
		if self.tween_bump:update(dt) == true then --remoe tween when finished
			self.tween_bump = nil
		end
	end


	--ANIMATION
	if self.timer >= (1/60) and math.abs(self.velx) > 5 then
		self.timer = 0
		self.img.current_quad = self.img.current_quad + 1
	elseif math.abs(self.velx) < 5 then
		self.img.current_quad = 10
	end
	if self.img.current_quad > #self.img.quads then self.img.current_quad = 1 end

	--START Left right moving
	if love.keyboard.isDown(self.left_key) then
		-- Change of direction
		if self.velx >= 150 then self.velx = 150 end
		self.velx = math.max(self.velx + (-self.speed * dt), -self.max_vel)
	end

	if love.keyboard.isDown(self.right_key) then
		if self.velx <= -150 then self.velx = -150 end
		self.velx = math.min( self.velx + (self.speed * dt), self.max_vel)
	end

	--Intertia friction left right
	if love.keyboard.isDown(self.left_key) == false and love.keyboard.isDown(self.right_key) == false then
			self.velx = self.velx * (1 - math.min(dt*self.friction, 1))
	end
	--limit speed
	self.x = self.x + self.velx * dt

	--END LEFT RIGHT

	--Reapear on the edges
	if self.x >= global_width then
			self.x = 0
			minigame_10.world:update(self, 0, self.y)
	end
	if (self.x + self.w) <= -1 then
		self.x = global_width
		minigame_10.world:update(self, global_width, self.y)
	end

	--JUMP PHYSICS START
	if love.keyboard.isDown(self.jump_key) and (self.jump.has_jump == true) then
		self.jump.jump_signal = true
		self.jump.timer = self.jump.timer + dt
		self.on_ground = false

		if (self.jump.timer <= self.jump.timer_max ) and (self.jump.has_jump == true) then
			self.vely = self.vely + self.jump.force * dt * (-math.log10(self.jump.timer))
		end
	else
		self.jump.jump_signal = false
	end

	--physics
	if self.on_ground == true then
		self.vely  = 1 --low gravity
	else
		self.vely = self.vely + (self.gravity * self.mass * dt)
	end

	self.y = self.y + self.vely * dt
	self.vely = math.max(self.vely, self.max_vely)
	--JUMP PHYSICS END
	--update-feet
	self.feety = self.y + self.h

end

function Player:draw()

	--sprite
	love.graphics.setColor(self.color)
	if self.velx >= 0 then
		love.graphics.draw(self.img.spritesheet, self.img.quads[self.img.current_quad], self.x - 45 , self.y - 30)
	else
		love.graphics.draw(self.img.spritesheet, self.img.quads[self.img.current_quad], self.x - 45 + 100 , self.y - 30, 0, -1, 1)
	end

	--hitbox
	love.graphics.setColor(0.1, 1, 0.8, 1)
	--love.graphics.rectangle("fill", self.x , self.y, self.w  , self.h)
	if minigame_10.phase == "intro" then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.setFont(minigame_10.font)
		love.graphics.print(self.player_number, self.x + self.w/2 - minigame_10.font:getWidth(tostring(self.player_number))/2, self.y - 200)
	end
end

function Player:handle_collisions(cols)

	--if NO COLLISIONS
	if #cols == 0 then self.on_ground = false end

	for _, v in pairs(cols) do --resolve collisions
		--IF Collision with flood going down and already release button
		if (v.other.tag == "floor" or v.other.tag == "player")  and (self.vely > 50) then
			self.last_platform = v.other.index

			if (self.jump.release == true) then --only get jump if release the jump key
				self.jump.has_jump = true
				self.jump.timer = 0
				self.on_ground = true
			end

			--if bump on edge of hole - bump with a tween
			if (v.other.tag == "floor") and (v.other.index > 1) and  ((self.x > minigame_10.platforms.platform_holder[v.other.index].hole_x_left-5) and (self.x + self.w < minigame_10.platforms.platform_holder[v.other.index].hole_x_right + 5) ) then
				if v.other.side == "left" and self.tween == nil then
					self.tween_bump = tween.new(0.5, self, {x = self.x+minigame_10.platforms.measures.hole_size/2}, "outCubic")
					v.other.physics = "bouncy"
					print("Tween")
				elseif v.other.side == "right" and self.tween == nil then
					self.tween_bump = tween.new(0.5, self, {x = self.x-minigame_10.platforms.measures.hole_size/2}, "outCubic")
					print("Tween")
					v.other.physics = "bouncy"
				end
			elseif (v.other.tag == "floor") and (v.other.index > 1) then
				v.other.physics = "solid"
			end

			if self.sound_land_played == false then
				self.sound_land_played = true
				self.sound_jump_played = false
				local pitch = math.random(80, 120)/100
				self.sound_land:setPitch(pitch)
				self.sound_land:play()
			end

		--if collision with floor and going up
		elseif v.other.tag == "floor" and (self.vely < 0) then
			self.vely  = minigame_10.speed   + 10

		end

	end
	--delete colissions?
	cols = nil
end -- END HANDLE COLLISION

return Player
