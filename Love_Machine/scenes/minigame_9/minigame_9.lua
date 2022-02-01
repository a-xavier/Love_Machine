minigame_9 = {}


function minigame_9:init()
	local Player = require "scenes.minigame_9.entities.player"
	local WindHandle = require "scenes.minigame_9.entities.wind_handle"
	local tween = require "libs.tween"

	self.scene_type = "game"
	self.scene_name = "Trhead the Needle"

	self.font = love.graphics.newFont("fonts/oldstyle/OLDSH___.TTF", 100)

	--music
	self.bg_music = love.audio.newSource( "scenes/minigame_9/sound/cheapos.ogg", "stream")
	self.bg_music:setLooping(true)
	self.bg_volume = 0.45
	self.bg_music:setVolume(self.bg_volume)

	self.phase = "intro"
	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

	--TIMERS
	self.intro_timer = 0
	self.intro_timer_max = 1

	self.active_timer = 0
	self.active_timer_max = 5

	self.outro_timer = 0
	self.outro_timer_max = 5

	self.global_timer = 0

	self.wind = require "scenes.minigame_9.entities.wind"
	self.wind.sound = love.audio.newSource( "scenes/minigame_9/sound/wind.ogg", "stream")
	self.wind.sound:setVolume(0.35)

	--Players
	--Buffer of 15 pixels at edge of the screen
	self.padding = 15
	self.player_1 = Player(self.padding, self.padding, global_width/2 - 3*self.padding, global_height - 2* self.padding, 1)
	self.player_2 = Player(self.player_1.area.x + self.player_1.area.w + self.padding, self.player_1.area.y, self.player_1.area.w, self.player_1.area.h , 2)

	self.auto_advance_force = -50

		--handle Wind change
	self.wind.timer = 0
	self.wind.timer_change = 5

	--Wind HANDLE
	self.wind_handle = WindHandle(self.player_2.area.x - self.padding/2 , global_height/2, self.wind, self.wind.timer)

	--WIN
	self.winner = nil
	self.counted_score = {p1 = false, p2 = false}

end

function minigame_9:update(dt)

	--GLOBAL TIMER
	self.global_timer = self.global_timer + dt

	--Sound
	self.wind.sound:play()
	self.bg_music:play()

	-- INTRO
	if self.phase == "intro" then
		self.intro_timer = self.intro_timer + dt
		if self.intro_timer >= self.intro_timer_max then self.phase = "active" end
	end

	--Wind
	for k, v in pairs(self.wind.tween_holder) do
		if v:update(dt) == false then
			v:update(dt)
		else
			v:reset()
			v.subject.y = math.random(0, global_height)
		end
	end

	--ACTIVE
	if self.phase == "active" then
		self.player_1:update(dt)
		self.player_2:update(dt)
		--WIND PUSH
		self.player_1.hand.physics.palm.body:applyForce(self.wind.direction * self.wind.speed, self.auto_advance_force)
		self.player_2.hand.physics.palm.body:applyForce(self.wind.direction * self.wind.speed, self.auto_advance_force)

		--handle wind change
		self.wind.timer = self.wind.timer + dt
		if self.wind.timer >= self.wind.timer_change then
			self.wind.timer = 0
			self.wind:reset()
		end

		--WInd handle
		self.wind_handle:update(dt)

		--Move to outro
		if self.player_1.winner == true or self.player_2.winner == true then
			self.phase = "outro"
			if self.player_1.winner == true then
				self.winner = "player_1"
				self.win_string = "Player 1 is unshakeable"
				if self.counted_score.p1 == false then
						global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
						self.counted_score.p1 = true
				end
			elseif self.player_2.winner == true then
				self.winner = "player_2"
				self.win_string = "Player 2 is unshakeable"
				if self.counted_score.p2 == false then
						global_score_counter.p2 = global_score_counter.p2 + 1 -- SCORE POINT
						self.counted_score.p2 = true
				end
			end
		end
	end

	--outro
	if self.phase == "outro" then
		self.outro_timer = self.outro_timer + dt
		if self.outro_timer >= self.outro_timer_max then gamestate.switch(scoreboard) end
	end


end

function minigame_9:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----

		--PLAYERS ALL THE TIME
		self.player_2:draw()
		self.player_1:draw()

		--Wind

		for k, v in pairs(self.wind.speck_holder) do
			love.graphics.setColor(1,1,1, v.alpha)
			love.graphics.draw(self.wind.img, v.x, v.y, 0, 5/v.time_to_get_there, 0.5+ 0.5/v.time_to_get_there)
		end

		--WInd handle
		self.wind_handle:draw()

		--INTRO
		if self.phase == "intro" then
			love.graphics.setColor(0.5,0.5,0.5)
			love.graphics.setFont(self.font)
			love.graphics.printf("Thread the Needle in the Wind", 0 + 3, global_height/2 - self.font:getHeight()/2 + 3, global_width, "center")

			love.graphics.setColor(1,0.1,0.5)
			love.graphics.setFont(self.font)
			love.graphics.printf("Thread the Needle in the Wind", 0, global_height/2 - self.font:getHeight()/2, global_width, "center")
		end

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
					--self.music.bg_music:setVolume(self.music.volume * (self.outro_timer_max - self.outro_timer)) --fade music away
					--self.music.outro:setVolume((self.outro_timer_max - self.outro_timer)) --fade music away
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
	--additional debug
	if global_debug then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(default_font)
		love.graphics.print(self.wind.speed, 10, 175)
		love.graphics.print(self.phase, 10, 190)
	end
end

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_9:keypressed(key)

end

function minigame_9:keyreleased(key)
	if key == "space" then
		self.wind:reset()
	end
end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_9:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_9:enter(previous)
	self:init()
end

function minigame_9:leave()
	love.audio.stop()
	deep_release(self)
end

-- NEEDS TO BE AT THE VERY END
return minigame_9
