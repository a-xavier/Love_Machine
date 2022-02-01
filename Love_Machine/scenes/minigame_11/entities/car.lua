
Car = Class{}

function Car:init(x, y, number, w, h) -- delay in seconds
	--All have a timer
	self.timer = 0
	--position size
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.player_number = number

	self.tag = "car"

	self.img = love.graphics.newImage( "scenes/minigame_11/img/player_"..tostring(self.player_number)..".png")

	self.hitbox = {}
	self.hitbox.x = self.x
	self.hitbox.y = self.y
	self.hitbox.size = 5

	--driving tags
	self.max_speed = 600
	self.max_speed_track = self.max_speed
	self.max_speed_mud = self.max_speed_track/5
	self.accel = 0
	self.speed = 350
	self.friction = 0.75
	self.on_track = true

	--deltas
	self.dx = 0
	self.dy = 0

	self.rotation = 0
	self.angle_speed = 3
	self.hump_vector =  require "libs.hump.vector"
	self.vector = {x = 0, y = 0}

	if self.player_number == 1 then
		self.player_color = {0, 1, 0}
		self.left_key = "s"
		self.right_key = "f"
		self.accel_key = "d"
	elseif self.player_number == 2 then
		self.player_color = {1, 0, 0}
		self.left_key = "j"
		self.right_key = "l"
		self.accel_key = "k"
	end

	--Sound
	self.engine_sound =  love.audio.newSource( "scenes/minigame_11/sound/car_sound.ogg", "static")
	self.engine_volume = 0.35
	self.engine_sound:setVolume(self.engine_volume)
	self.engine_pitch = 2
	self.engine_sound:setPitch(self.engine_pitch)

	self.crash_sound =  love.audio.newSource( "scenes/minigame_11/sound/car_crash.ogg", "static")
	self.crash_volume = 0.35
	self.crash_timer = 0
	self.crash_sound:setVolume(self.crash_volume)

	--particle
	self.smoke = love.graphics.newImage( "scenes/minigame_7/img/smoke.png")
	self.particle_system = love.graphics.newParticleSystem(self.smoke, 10000)
	self.particle_system:setParticleLifetime(0.1, 1) -- Particles live at least 2s and at most 5s.
	self.particle_system:setEmissionRate(100)
	self.particle_system:setSizes( 1, 2, 1, 0.1 )
	self.particle_system:setLinearAcceleration(-5,5,-5,5) -- Random movement in all directions.
	self.particle_system:setColors(1, 1, 1, 1, 0.7, 0.7, 0.7, 0) -- Fade to transparency.
	self.particle_system:setRotation(-2*math.pi, 2*math.pi )
	--self.particle_system:setLinearDamping( 0, 1 )
	self.smoke_pos = {}
	self.smoke_pos.x = 0
	self.smoke_pos.y = 0

	--GAME TAGS
	self.current_lap = 0
	self.current_lap_time = 0
	self.chekpoint_number = 0
end


function Car:update(dt)
	--Update timer
	self.timer = self.timer + dt

	self.current_lap_time = self.current_lap_time + dt

	--Rotation
	if love.keyboard.isDown(self.left_key) then
		self.rotation = self.rotation - self.angle_speed * dt
	end
	if love.keyboard.isDown(self.right_key) then
		self.rotation = self.rotation + self.angle_speed * dt
	end
	self.rotation = self.rotation%(2*math.pi)

	if love.keyboard.isDown(self.accel_key) then
		self.accel = self.accel + self.speed * dt
		self.angle_speed = 2.5 - 1.5 * (self.accel/self.max_speed) -- harder to steer with more speed

	else
		self.accel = self.accel * (1 - math.min(dt*self.friction, 1))
		self.angle_speed = 2.5
	end

	if self.on_track == false then
		self.max_speed = self.max_speed_mud
	elseif self.on_track == true then
		self.max_speed = self.max_speed_track
	end

	self.accel = math.min(self.accel, self.max_speed )

	if self.accel > 15 and self.on_track == true then
		self.engine_sound:setPitch(self.engine_pitch * self.accel/self.max_speed)
		self.engine_sound:play()
	elseif self.accel > 15 and self.on_track == false then
		self.engine_sound:setPitch(self.engine_pitch /4)
		self.engine_sound:play()
	else
		self.engine_sound:stop()
	end
	--Update movement
	self.vector = self.hump_vector.fromPolar(self.rotation + (math.pi/2),self.accel)

	self.x = self.x + self.vector.x * dt
	self.y = self.y + self.vector.y * dt

	--Update hitbox position
	self.hitbox.x = self.x
	self.hitbox.y = self.y

	--Particle system
	self.smoke_pos =  self.hump_vector.fromPolar(self.rotation + (math.pi/2), - 80)
	--self.particle_system:setLinearAcceleration(0,0,-self.accel,-self.accel)
	self.particle_system:setPosition(self.x +self.smoke_pos.x, self.y + self.smoke_pos.y)

	self.particle_system:setEmissionRate(self.accel/15)

	self.particle_system:update(dt)
	if self.accel > 15 then
		self.particle_system:start()
	else
		self.particle_system:stop()
	end

	--Crash sound
	if self.crash_timer ~= 0 then
		self.crash_timer = self.crash_timer + dt

		if self.crash_timer > 2 then self.crash_timer = 0 end
	end


end

function Car:draw()
	--DRAW RECTANGLE CAR
	--love.graphics.setColor(self.player_color)
	love.graphics.setColor(1,1,1)
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	love.graphics.rotate(self.rotation)
	--love.graphics.rectangle("fill", -self.w/2, -self.h/1.25, self.w, self.h)
	love.graphics.draw(self.img,  -self.w/2, -self.h/1.25)
	--particle system
	love.graphics.pop()
	--DRAW vector for direction and force
	love.graphics.setColor(0.7, 0.7, 0.7)
	--love.graphics.line(self.x, self.y, self.x +  self.vector.x/3 , self.y + self.vector.y/3)
	love.graphics.setFont(default_font)
	--love.graphics.print(self.accel, self.x, self.y)
	--Hitbox
	love.graphics.setColor(1,1,1)
	--love.graphics.rectangle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.size, self.hitbox.size)

	love.graphics.draw(self.particle_system, 0, 0)

end

function Car:handle_collisions(cols)
	for k, v in pairs(cols) do
		--IF IN CONTACT WITHH TRACKS
		if v.other.tag == "track" then
			self.on_track = true
		--IF HIT A BARRIER
		elseif v.other.tag == "barrier" then
			self.accel = 0
			if self.crash_timer == 0 then
				self.crash_sound:play()
				self.crash_timer = self.crash_timer + 0.001
			end
		--IF HIT THE START LINE
	elseif v.other.tag == "start" and self.vector.y > 0 then
			if self.current_lap == 0 then
				self.current_lap = 1
			elseif self.current_lap ~= 0 and self.chekpoint_number == #minigame_11.racetrack.checkpoint_holder  then
				if self.player_number == 1 and v.other.tag_counted_player_1 == false then
					-- Take into account the fact that we crossed the finish line only once
					v.other.tag_counted_player_1 = true
					-- Get the time for the lap and put it in the tim holder
					minigame_11.time_lap_holder.p1[self.current_lap] = self.current_lap_time
					-- Reset the time for the Lap
					self.current_lap_time = 0
					--Increment the number of the lap
					self.current_lap = self.current_lap + 1
					--Reset the checkpoint counter
					self.chekpoint_number = 0
					--Reset checkpoint counts
					for k, v in pairs(minigame_11.racetrack.checkpoint_holder) do
						v.tag_counted_player_1 = false
					end
				elseif self.player_number == 2 and v.other.tag_counted_player_2 == false then
					v.other.tag_counted_player_2 = true
					minigame_11.time_lap_holder.p2[self.current_lap] = self.current_lap_time
					self.current_lap_time = 0
					self.current_lap = self.current_lap + 1
					self.chekpoint_number = 0
					--Reset checkpoint counts
					for k, v in pairs(minigame_11.racetrack.checkpoint_holder) do
						v.tag_counted_player_2 = false
					end
				end
			else
				print("DIDNT HIT ALL CHECKPOINTS")
			end
		--IF HIT A CHECKPOINT
	elseif v.other.tag == "checkpoint"  then
			if self.player_number == 1 and v.other.tag_counted_player_1 == false then
				v.other.tag_counted_player_1 = true
				self.chekpoint_number = self.chekpoint_number + 1
				minigame_11.racetrack.start_line.tag_counted_player_1 = false
			elseif self.player_number == 2 and v.other.tag_counted_player_2 == false then
				v.other.tag_counted_player_2 = true
				self.chekpoint_number = self.chekpoint_number + 1
				minigame_11.racetrack.start_line.tag_counted_player_2 = false
			end
		end
	end

	if next(cols) == nil then --if empty
		self.on_track = false
	end
	--remove collisions?
	cols = nil
end -- END COLLISION HANDLING

return Car
