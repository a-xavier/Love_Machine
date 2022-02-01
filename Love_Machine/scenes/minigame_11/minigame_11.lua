minigame_11 = {}

function minigame_11:init()
	self.scene_type = "type"
	self.scene_name = "name"

	--Entities
	local Car = require "scenes.minigame_11.entities.car"
	local car_width = 50
	local car_height = 100
	local Racetrack = require "scenes.minigame_11.entities.racetrack"
	local bump = require 'libs.bump'

	--Cars
	self.player_1 = Car(90, 300, 1, car_width, car_height)
	self.player_2 = Car(160, 200, 2, car_width, car_height)

	--FONTS
	self.font = love.graphics.newFont("fonts/race1/RACE1 Brannt NCV.ttf", 150)
	self.ui_font = love.graphics.newFont("fonts/racer/RACER___.TTF", 25)

	--Racetrack

	self.racetrack = Racetrack()

	self.number_of_laps = 3
	self.time_lap_holder = {}
	self.time_lap_holder.p1 = {"--:--:--", "--:--:--", "--:--:--"}
	self.time_lap_holder.p2 = {"--:--:--", "--:--:--", "--:--:--"}

	--bACKGROUND
	self.background = love.graphics.newImage( "scenes/minigame_11/img/racetrack.png")

	--music
	self.bg_music = love.audio.newSource( "scenes/minigame_11/sound/racetrack.ogg", "stream")
	self.bg_music:setLooping(true)
	self.bg_volume = 0.35
	self.bg_music:setVolume(self.bg_volume)

	self.low_horn = love.audio.newSource( "scenes/minigame_11/sound/low_horn.ogg", "static")
	self.high_horn = love.audio.newSource( "scenes/minigame_11/sound/high_horn.ogg", "static")
	self.horn_timer = 0

	-- --HUMP WORLD
	self.world = bump.newWorld(50)
	--Add all to world
	self.world:add(self.player_1, self.player_1.x, self.player_1.y, self.player_1.hitbox.size, self.player_1.hitbox.size)
	self.world:add(self.player_2, self.player_2.x, self.player_2.y, self.player_2.hitbox.size, self.player_2.hitbox.size)

	for k, v in pairs(self.racetrack.rectangle_holder) do
		self.world:add(v, v.x, v.y, v.w, v.h)
	end

	for k, v in pairs(self.racetrack.barrier_holder) do
		self.world:add(v, v.x, v.y, v.w, v.h)
	end

	for k, v in pairs(self.racetrack.checkpoint_holder) do
		self.world:add(v, v.x, v.y, v.w, v.h)
	end

	self.world:add(self.racetrack.start_line, self.racetrack.start_line.x, self.racetrack.start_line.y, self.racetrack.start_line.w, self.racetrack.start_line.h)

	self.phase = "intro"

	--TIMERS
	self.intro_timer = 0
	self.intro_timer_max = 5

	self.active_timer = 0
	self.active_timer_max = 5

	self.outro_timer = 0
	self.outro_timer_max = 5

	self.global_timer = 0


	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

	--WIN LOSE
	self.winner = nil
	self.counted_score = {p1 = false, p2 = false}


end

function minigame_11:update(dt)

	--PHASES

	--INTRO
	if self.phase == "intro" then
		 self.intro_timer = self.intro_timer + dt
		 self.horn_timer = self.horn_timer + dt
		if self.horn_timer >= 0 then
			self.low_horn:play()
		end
		if self.intro_timer >= self.intro_timer_max  then
			self.phase = "active"
			self.high_horn:play()
		end

		if self.intro_timer >= 1.69 then self.bg_music:play() end
	end
	--ACTIVE PHASE
	if self.phase == "active" then
		self.active_timer = self.active_timer + dt

		self.player_1:update(dt)
		self.player_2:update(dt)
		self.racetrack:update(dt)

		--WORLD BUMP HANDLING
		--PLAYER 1
		self.player_1.actualX, self.player_1.actualY, p1_cols, self.player_1.lenght_collisions  = self.world:move(self.player_1, self.player_1.x, self.player_1.y, self.player_Filter)
		self.player_1.y = self.player_1.actualY
		self.player_1.x = self.player_1.actualX

		self.player_2.actualX, self.player_2.actualY, p2_cols, self.player_2.lenght_collisions  = self.world:move(self.player_2, self.player_2.x, self.player_2.y, self.player_Filter)
		self.player_2.y = self.player_2.actualY
		self.player_2.x = self.player_2.actualX

		--COLISION resolution
		self.player_1:handle_collisions(p1_cols)
		self.player_2:handle_collisions(p2_cols)

		--WIN LOSE
		if self.player_1.current_lap > self.number_of_laps then
			self.winner = "player_1"
			self.phase = "outro"
			self.win_string = "Player 1 left Player 2 in the DUST"
			if self.counted_score.p1 == false then
				global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
				self.counted_score.p1 = true
			end
		elseif self.player_2.current_lap > self.number_of_laps then
			self.winner = "player_2"
			self.phase = "outro"
			self.win_string = "Player 2 left Player 1 in the DUST"
			if self.counted_score.p1 == false then
				global_score_counter.p2 = global_score_counter.p2 + 1 -- SCORE POINT
				self.counted_score.p1 = true
			end
		end

	end -- END ACTIVE

	--outro
	if self.phase == "outro" then
		self.outro_timer = self.outro_timer + dt
		if self.outro_timer >= self.outro_timer_max then gamestate.switch(scoreboard) end
	end

end

function minigame_11:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.background, 0,0)
		self.racetrack:draw()

		self.player_1:draw()
		self.player_2:draw()

		--Start line
		love.graphics.draw(self.racetrack.start_flag, 0, 0)

		--draaw UI
		self:draw_ui()

		--INTRO
		if self.phase == "intro" then
			love.graphics.setFont(self.font)
			love.graphics.setColor(0,0,0, 1)
			love.graphics.printf("Finish First", 0 + 3, global_height/2 - self.font:getHeight()/2 + 3, global_width, "center")
			love.graphics.setColor(1, 0.5, 0.1, 1)
			love.graphics.printf("Finish First", 0, global_height/2 - self.font:getHeight()/2, global_width, "center")

			--PLAYER NUMBERS
			love.graphics.setColor(0,1,0, math.cos(self.intro_timer * 10) + 1.2)
			love.graphics.print("1", self.player_1.x - self.player_1.w/2, self.player_1.y - self.player_1.h/2)
			love.graphics.setColor(1,0,0, math.cos(self.intro_timer * 10) + 1.2)
			love.graphics.print("2", self.player_2.x - self.player_2.w/2, self.player_2.y - self.player_2.h/2)

		end

		--OUTRO
		if self.phase == "outro" then
			love.graphics.setColor(0.5,0.5, 0.5)
			love.graphics.setFont(self.font)
			love.graphics.printf(self.win_string, 5, global_height/2 - self.font:getHeight()/2 + 5, global_width, "center")
			love.graphics.setColor(1,0.2,0.5)
			love.graphics.setFont(self.font)
			love.graphics.printf(self.win_string, 0, global_height/2 - self.font:getHeight()/2, global_width, "center")
			--FADE TO BLACK
				if self.outro_timer_max - self.outro_timer <=1 then
					time_left = 1 - (self.outro_timer_max - self.outro_timer)
					self.bg_music:setVolume(self.bg_volume * (self.outro_timer_max - self.outro_timer)) --fade music away
					love.graphics.setColor(0,0,0, time_left)
					love.graphics.rectangle("fill", 0, 0 , global_width, global_height)
					love.graphics.setColor(1,1,1)
				end
		end

		----- FINISH DRAWING ----
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.canvas, self.aspect_ratio.x, self.aspect_ratio.y, 0, self.aspect_ratio.scale, self.aspect_ratio.scale)

	draw_debug()
	--Additional debug
	if global_debug then
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("Lap player 1 "..tostring(self.player_1.current_lap), 10, 175)
		love.graphics.print("Lap player 2 "..tostring(self.player_2.current_lap), 10, 190)

		love.graphics.print("Checkpoints player 1 "..tostring(self.player_1.chekpoint_number), 10, 205)
		love.graphics.print("Checkpoints player 2 "..tostring(self.player_2.chekpoint_number), 10, 220)

		love.graphics.print(" player 1 x"..tostring(self.player_1.vector.x).." y "..tostring(self.player_1.vector.y), 10, 235)
		love.graphics.print(" player 2 x"..tostring(self.player_2.vector.x).." y "..tostring(self.player_2.vector.y), 10, 250)
	end
end

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_11:keypressed(key)

end

function minigame_11:keyreleased(key)

end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_11:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_11:enter(previous)
	self:init()
end

function minigame_11:leave()
	--REMOVE ALL FROM WORLD
	local items, len = self.world:getItems()
	for k, v in pairs(items) do
		self.world:remove(v)
		print("removed item "..tostring(v.tag).." from world")
	end
	local items, len = self.world:getItems()
	print(len.." items in self.world")
	self.world = nil

	love.audio.stop()
	deep_release(self)
end

function minigame_11.player_Filter(item, other)
  	if other.tag == "barrier"   then
		return "touch"
  	elseif other.tag == "track" or other.tag == "checkpoint" or other.tag == "start" then
		return "cross"
	elseif other.tag == "car" then
		return "bounce"
  	end
end

function minigame_11:draw_ui()
	--Print Timer Total
	love.graphics.setFont(self.ui_font)
	love.graphics.setColor(0,0,0)

	local display_timer = math.ceil(self.active_timer)
	local minute_timer = math.floor(display_timer/60)
	local second_timer = math.floor(display_timer%60)
	local ms_timer = math.fmod(self.active_timer,1) * 100

	self.final_timer = string.format("%02d:%02d:%02d", minute_timer, second_timer, ms_timer)
	love.graphics.print(self.final_timer, global_width/2 -50, 0)

	love.graphics.setColor(0,0,0)
	love.graphics.print("P1:", 12, 52)
	love.graphics.setColor(1,1,1)
	love.graphics.print("P1:", 10, 50)
	for k, v in pairs(self.time_lap_holder.p1) do

		if v == "--:--:--" then
			love.graphics.setColor(0,0,0)
			love.graphics.print(v, 50 + 2, 0 + 50 *k + 2)
			love.graphics.setColor(1,1,1)
			love.graphics.print(v, 50, 0 + 50 *k)
		else
			local display_timer = v
			local minute_timer = math.floor(display_timer/60)
			local second_timer = math.floor(display_timer%60)
			local ms_timer = math.fmod(v,1) * 100
			love.graphics.setColor(0,0,0)
			love.graphics.print(string.format("%02d:%02d:%02d", minute_timer, second_timer, ms_timer),  50 + 2, 0 + 50 *k + 2)
			love.graphics.setColor(1,1,1)
			love.graphics.print(string.format("%02d:%02d:%02d", minute_timer, second_timer, ms_timer),  50, 0 + 50 *k)
		end
	end
	love.graphics.setColor(0,0,0)
	love.graphics.print("P2:", global_width - 250 + 2, 50 + 2)
	love.graphics.setColor(1,1,1)
	love.graphics.print("P2:", global_width - 250, 50)
	for k, v in pairs(self.time_lap_holder.p2) do
		if v == "--:--:--" then
			love.graphics.setColor(0,0,0)
			love.graphics.print(v, global_width - 200 + 2, 0 + 50 *k + 2)
			love.graphics.setColor(1,1,1)
			love.graphics.print(v, global_width - 200 , 0 + 50 *k)
		else
			local display_timer = v
			local minute_timer = math.floor(display_timer/60)
			local second_timer = math.floor(display_timer%60)
			local ms_timer = math.fmod(v,1) * 100
			love.graphics.setColor(0,0,0)
			love.graphics.print(string.format("%02d:%02d:%02d", minute_timer, second_timer, ms_timer), global_width - 200 + 2, 0 + 50 *k + 2)
			love.graphics.setColor(1,1,1)
			love.graphics.print(string.format("%02d:%02d:%02d", minute_timer, second_timer, ms_timer), global_width - 200, 0 + 50 *k)
		end
	end


end

-- NEEDS TO BE AT THE VERY END
return minigame_11
