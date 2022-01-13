minigame_8 = {}
local Player = require "scenes.minigame_8.entities.player"
local Conductor = require "scenes.minigame_8.entities.conductor"

function minigame_8:init()
	self.scene_type = "game"
	self.scene_name = "Dancefloor"

	self.frame = 1

	self.font = love.graphics.newFont("fonts/dance/dance.ttf", 150)
	self.font_small = love.graphics.newFont("fonts/dance/dance.ttf", 50)

	-- Here phases are intro then loop of show reproduce the outro if there is a mistake
	self.phase = "intro"

	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

	--Music
	self.music = {}
	self.music.bg_music = love.audio.newSource( "scenes/minigame_8/sound/minigame_dance_final.ogg", "static")
	--Volume a bit down
	self.music.volume = 0.75
	self.music.bg_music:setVolume(self.music.volume)
	self.music.bpm = 120
	self.music.bar_timer = self.music.bpm/60
	self.music.beat_timer = self.music.bpm/60/4
	self.music.bar_num = 1
	self.music.beat_num = 1
	self.music.beat_signal = false
	self.music.pos = nil -- position of the song in seconds
	self.music.alpha = 0 -- for blinking stuff
	self.music.alpha_timer = 0
	self.music.color = {r=1,g = 1, b = 1}
	self.music.outro = love.audio.newSource( "scenes/minigame_8/sound/outro_clap.ogg", "static")

	--COnductor
	self.conductor = Conductor(global_width/2 - 100, 50)

	--players
	self.player_1 = Player(250, global_height - 300 - 100, 1)
	self.player_2 = Player(global_width - self.player_1.w - 250, global_height - 300 - 100, 2)

	--TIMERS
	self.intro_max_bar = 3

		--global timer
	self.global_timer = 0

	self.outro_timer = 0
	self.outro_timer_max = 7
	--Win-lose
	self.target_points = 46 --should be divisible by 4/8

	self.winner = nil
	self.counted_score = {p1 = false, p2 = false}
end

function minigame_8:update(dt)
	--FRAME COUNTER
	self.frame = self.frame + 1

	-- Play music all the timer
	self.music.bg_music:play()
	self.music.pos = self.music.bg_music:tell( "seconds" )
	--Loop for flash
	if self.music.bg_music:isPlaying() then
		self.music.alpha_timer = self.music.alpha_timer + dt
	end
	if (self.music.alpha_timer >= self.music.beat_timer) then --good enough no sync with actual music timer
		--update timer based on precise position?
		self.music.alpha_timer = 0 --self.music.pos%self.music.beat_timer -- zero on precise remainder instead of  zero
		self.music.beat_num = self.music.beat_num + 1
		self.music.beat_signal = true
		if self.music.beat_num > 4 then
			self.music.beat_num = 1
			self.music.bar_num = self.music.bar_num + 1
		end
		self.music.color = {r = math.random(), g = math.random(), b = math.random()}
	else
		self.music.beat_signal = false
	end
	self.music.alpha = 0.8 - (self.music.alpha_timer/self.music.beat_timer) -- 1 is too bright

		--Change phases based on the music beats
	--INTRO TO FIRST SHOW
	if (self.phase == "intro") and (self.music.bar_num == self.intro_max_bar) then
		self.phase = "show"
	end

	-- SHOW TO REPRODUCE

	if (self.phase == "show") and (self.conductor.sequence_started == true) and (self.conductor.sequence_finished == true) and (next(self.conductor.sequence_copy) == nil) and (self.music.beat_num == 4) and (self.music.alpha_timer > (self.music.beat_timer - 0.5))then
		self.phase = "reproduce"
		self.player_1.beat_counter = 0
		self.player_2.beat_counter = 0
	end

	--UPDATE
	self.conductor:update(dt)
	self.player_1:update(dt)
	self.player_2:update(dt)

	--SHOW PHASE
	if self.phase == "reproduce" then
		self.player_1.sequence_length = #self.conductor.sequence
		self.player_2.sequence_length = #self.conductor.sequence

		--TRANSITION to another show
		if (self.player_1.beat_counter == #self.conductor.sequence) and (self.player_2.beat_counter == #self.conductor.sequence) and (self.music.alpha_timer > (self.music.beat_timer - 0.1)) then
		self.conductor:generate_sequence()
		self.phase = "show"
		self.player_1:reset()
		self.player_2:reset()
		end
	end

	-- TRANSITION TO OUTRO

	--TMP

	if (self.phase == "show") and (self.player_1.score >= minigame_8.target_points) then
		self.phase = "outro"
		self.music.outro:play()
		print("SWITCH TO OUTRO")
	elseif (self.phase == "show") and (self.player_2.score >= minigame_8.target_points) then
		self.phase = "outro"
		self.music.outro:play()
		print("SWITCH TO OUTRO")
	end


	if self.phase == "outro" then
		self.outro_timer = self.outro_timer + dt
		if self.outro_timer >= self.outro_timer_max then gamestate.switch(scoreboard) end
		--score
		if self.player_1.score > self.player_2.score then
			self.winner = "player_1"
			self.win_string = "Player 1 is awesome"
			if self.counted_score.p1 == false then
					global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
					self.counted_score.p1 = true
			end
		elseif  self.player_1.score < self.player_2.score then
			self.winner = "player_2"
			self.win_string = "Player 2 is awesome"
			if self.counted_score.p2 == false then
					global_score_counter.p2 = global_score_counter.p2 + 1 -- SCORE POINT
					self.counted_score.p2 = true
			end
		elseif self.player_1.score == self.player_2.score then
			self.winner = "draw"
			self.win_string = "Both players are awesome"
			if self.counted_score.p1 == false then
					global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
					self.counted_score.p1 = true
			end
			if self.counted_score.p2 == false then
					global_score_counter.p2 = global_score_counter.p2 + 1 -- SCORE POINT
					self.counted_score.p2 = true
			end
		end
	end
end

function minigame_8:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
		--Background flash with music?
		love.graphics.setColor(self.music.color.r, self.music.color.g, self.music.color.b,  self.music.alpha)
		love.graphics.rectangle("fill", 0,0, global_width, global_height)


		--COnductor
		self.conductor:draw()
		--Players
		self.player_1:draw()
		self.player_2:draw()

		--INTRO
		if self.phase == "intro" then
			love.graphics.setColor(0.5,0.5, 0.5, 1 - (self.music.alpha))
			love.graphics.setFont(self.font)
			love.graphics.printf("Repeat that sequence!", 5, global_height/2 - self.font:getHeight()/2 + 5, global_width, "center")
			love.graphics.setColor(1,1,1, 1 - (self.music.alpha))
			love.graphics.setFont(self.font)
			love.graphics.printf("Repeat that sequence!", 0, global_height/2 - self.font:getHeight()/2, global_width, "center")
		end

		--OUTRO
		if self.phase == "outro" then
			love.graphics.setColor(0.5,0.5, 0.5, 1 - (self.music.alpha))
			love.graphics.setFont(self.font)
			love.graphics.printf(self.win_string, 5, global_height/2 - self.font:getHeight()/2 + 5, global_width, "center")
			love.graphics.setColor(1,1,1, 1 - (self.music.alpha))
			love.graphics.setFont(self.font)
			love.graphics.printf(self.win_string, 0, global_height/2 - self.font:getHeight()/2, global_width, "center")
			--FADE TO BLACK
				if self.outro_timer_max - self.outro_timer <=1 then
					time_left = 1 - (self.outro_timer_max - self.outro_timer)
					self.music.bg_music:setVolume(self.music.volume * (self.outro_timer_max - self.outro_timer)) --fade music away
					self.music.outro:setVolume((self.outro_timer_max - self.outro_timer)) --fade music away
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
	self:debug()
end -- END DRAW

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_8:keypressed(key)
	--Reproduce phase
	if self.phase == "reproduce" then
		if key == "s" or key == "d" or key == "f" then
			self.player_1:handle_keypress(key)
		end
		if key == "j" or key == "k" or key == "l" then
			self.player_2:handle_keypress(key)
		end
	end

end

function minigame_8:debug()

-- additional debug
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(default_font)
	love.graphics.print(tostring(self.music.bar_num)..":"..tostring(self.music.beat_num), 10, 100)
	love.graphics.print(self.phase, 10, 115)
	love.graphics.print(tostring(self.player_2.current_input), 10, 130)
	love.graphics.print(tostring(self.player_2.key_registered), 10, 145)
	--self.no_input_timer
	love.graphics.print(tostring(minigame_8.player_2.no_input_timer), 10, 160)
	love.graphics.print(tostring(minigame_8.player_2.current_input_index), 10, 175)
	love.graphics.print(tostring(self.music.pos%self.music.beat_timer), 10, 190)

end

function minigame_8:keyreleased(key)

--Reproduce phase
	if self.phase == "reproduce" then
		if key == "s" or key == "d" or key == "f" then
			self.player_1:handle_keyrelease(key)
		end
		if key == "j" or key == "k" or key == "l" then
			self.player_2:handle_keyrelease(key)
		end
	end

end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_8:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_8:enter(previous)

end

function minigame_8:leave()
	love.audio.stop()
end

-- NEEDS TO BE AT THE VERY END
return minigame_8
