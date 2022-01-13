Class = require "libs.hump.class"

Player = Class{}

function Player:init(x, y, number) -- delay in seconds
	--All have a timer 
	self.timer = 0
	--position size
	self.x = x
	self.y = y
	self.w = 150
	self.h = 300
	self.player_number = number
	self.good_timer = 0 
	self.good_timer_max = 0.25
	self.good_bad_string = nil
	
	self.hit_window = 0.05 -- in seconds window of time to Hit, x2 because - and + window are good
	
	self.current_input = nil
	self.current_input_index = 0
	self.final_sequence = {}
	self.sequence_length = nil
	self.key_registered = false
	self.beat_counter = 0
	
	self.no_input_timer = 0
	self.no_input_timer_max = minigame_8.music.beat_timer + minigame_8.music.beat_timer/2
	
	self.good = love.audio.newSource( "scenes/minigame_8/sound/good.ogg", "static")
	self.bad = love.audio.newSource( "scenes/minigame_8/sound/bad.ogg", "static")
	self.ok = love.audio.newSource( "scenes/minigame_8/sound/ok.ogg", "static")
	
	self.star = love.graphics.newImage( "scenes/minigame_8/img/star.png")
	self.ps =love.graphics.newParticleSystem( self.star, 10000 )
	self.ps:setParticleLifetime(0.1, 1) -- Particles live at least 2s and at most 5s.
	self.ps:setEmissionRate(250)
	self.ps:setSizes( 0.1, 2)
	self.ps:setRotation(-math.pi, math.pi)
	self.particle_speed = 5000
	self.ps:setLinearAcceleration(-self.particle_speed , -self.particle_speed , self.particle_speed , self.particle_speed  ) -- Random movement in all directions.
	self.ps:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.
	self.ps:setLinearDamping( 0, 5 )
	
	-- Scores 
	self.score = 0
	
	self.score_bar = {}
	self.score_bar.w = self.w
	self.score_bar.h = 15
	self.score_bar.x = self.x
	self.score_bar.y = self.y - 10 - self.score_bar.h
end


function Player:update(dt)
	--Update timer
	self.timer = self.timer + dt
	
	--Particle system
	self.ps:update(dt)
	
	--GOOD PRINTER
	if self.good_timer~= 0 then self.good_timer = self.good_timer + dt end
	if self.good_timer >= self.good_timer_max then self.good_timer = 0 end
	
	
	--update sequence inputing
	--Only on certain beats ?
	if (minigame_8.phase == "reproduce") and (#self.final_sequence < #minigame_8.conductor.sequence) then
	
		if self.key_registered == true then self.current_input = nil end
		
		self.distance_to_beat = math.min((minigame_8.music.beat_timer - minigame_8.music.alpha_timer), minigame_8.music.alpha_timer)
		--print(self.distance_to_beat)

		-- IF THERE IS AN INPUT
		if self.current_input ~= nil then
				--reset no input timer
				self.no_input_timer = 0
				self.current_input_index = self.current_input_index + 1 -- MOVE INDEX OF MOVE UP 
				print("P"..self.player_number.." input "..tostring(self.current_input_index).." |"..tostring(self.current_input).." | "..tostring(minigame_8.conductor.sequence[self.current_input_index]).."to beat: "..self.distance_to_beat)
				table.insert(self.final_sequence, self.current_input) -- USELESS
				self.key_registered = true
				--Play sound if good or bad
				--Sounds
				
				--IF RIGHT INPUT
				if (self.current_input == minigame_8.conductor.sequence[self.current_input_index]) then 
					--IF ON TIME
					if self.distance_to_beat <= self.hit_window then
						self.good:stop()
						self.good:play()
						self.good_timer = self.good_timer + dt --start printing timer
						self.good_bad_string = "GOOD"
						self.score = self.score + 2
					--IF LATE OR EARLY
					else 
						self.ok:stop()
						self.ok:play()
						--start printing timer
						self.good_timer = self.good_timer + dt 
						self.good_bad_string = "OK"
						self.score = self.score + 1
					
					end
				--IF BAD INPUT
				else
					self.bad:stop()
					self.bad:play()
					self.good_bad_string = "BAD"
					self.good_timer = self.good_timer + dt
				end
				--TMP
				print("full input sequence : "..table.concat(self.final_sequence, ", "))
				
		--if not input skip after one beat
		elseif self.current_input == nil then 
			self.no_input_timer = self.no_input_timer + dt
			if self.no_input_timer >= self.no_input_timer_max then 
				self.no_input_timer = 0 
				self.current_input_index = self.current_input_index + 1
				self.good_bad_string = "MISS"
				self.good_timer = self.good_timer + dt 
			end
		end
	end
	
	if minigame_8.phase == "reproduce" then
			--COUNT BEATS TO END THE REPRODUCE PHASE 
		if minigame_8.music.beat_signal == true then 
			self.beat_counter = self.beat_counter + 1 
			--print(self.beat_counter)
			--print(#minigame_8.conductor.sequence)
		end 
	end
	
	--SCORE 
	if self.score >= minigame_8.target_points then self.score = minigame_8.target_points end

end -- End UPDATE

function Player:reset()
	self.current_input = nil
	self.current_input_index = 0
	self.final_sequence = {}
	self.sequence_length = nil
	self.key_registered = false
	self.beat_counter = 0
	self.no_input_timer = 0 
end

function Player:handle_keypress(key)

	if self.key_registered == false then 
			if self.player_number == 1 then 
				if key == "s" then 
					self.current_input = "left"
				elseif key == "d" then 
					self.current_input = "up"
				elseif key == "f" then 
					self.current_input = "right"
				end
			end
			
			if self.player_number == 2 then 
				if key == "j" then 
					self.current_input = "left"
				elseif key == "k" then 
					self.current_input = "up"
				elseif key == "l" then 
					self.current_input = "right"
				end
			end
		
	end

end

function Player:handle_keyrelease(key)

	if self.player_number == 1 then 
		if key == "s" then 
			self.key_registered = false
		elseif key == "d" then 
			self.key_registered = false
		elseif key == "f" then 
			self.key_registered = false
		end
	end
	
	if self.player_number == 2 then 
		if key == "j" then 
			self.key_registered = false
		elseif key == "k" then 
			self.key_registered = false
		elseif key == "l" then 
			self.key_registered = false
		end
	end

end

function Player:initialise_sequence()
	self.current_input = nil
	self.final_sequence = {}
	self.sequence_length = nil
end

function Player:draw()
	love.graphics.setColor(1,1,1)
	
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h) -- Player
	
		if self.good_timer~= 0 then
			love.graphics.setFont(minigame_8.font_small)
			if self.good_bad_string == "GOOD" then
				love.graphics.setColor(0,1,0)
				self.ps:start()
			end
			if self.good_bad_string == "MISS" then love.graphics.setColor(1,0,0.5) end
			if self.good_bad_string == "BAD" then love.graphics.setColor(1,0,0) end
			if self.good_bad_string == "OK" then love.graphics.setColor(0,0,1) end
			love.graphics.printf(self.good_bad_string, self.x, self.y , self.w, "center")
		else
			self.ps:stop()
		end
		
		--Particle system
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.ps, self.x + self.w/2, self.y + self.h/2)
		
		--SCORE BAR
		
		--outside
		love.graphics.setColor(0.5,0.5,0.5)
		love.graphics.rectangle("fill", self.score_bar.x, self.score_bar.y, self.score_bar.w, self.score_bar.h)
		
		--inside
		love.graphics.setColor(0.1,0.5,0.9)
		love.graphics.rectangle("fill", self.score_bar.x, self.score_bar.y, self.score_bar.w * (self.score/minigame_8.target_points), self.score_bar.h)
		
end

return Player