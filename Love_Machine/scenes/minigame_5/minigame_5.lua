minigame_5 = {}


function minigame_5:init()
	local Player = require "scenes.minigame_5.entities.player"

	self.scene_type = "game"
	self.scene_name = "Chi Fu Mi"

	self.font = love.graphics.newFont("fonts/gang_of_three/go3v2.ttf", 90)

	--Can be intro, choose, reveal or outro
	self.phase = "intro"

	--PROFILER
	local Profiler = require "entities.profiler"
	self.profiler = Profiler()

	--TITLE
	self.title = {}
	self.title.display_test = ""
	self.title.y = 50

	--Timers
	self.intro_timer = 0
	self.intro_timer_max = 3
	self.intro_sounds = { love.audio.newSource( "scenes/minigame_5/sound/intro_1.ogg", "stream"),
						  love.audio.newSource( "scenes/minigame_5/sound/intro_2.ogg", "stream"),
						  love.audio.newSource( "scenes/minigame_5/sound/intro_3.ogg", "stream"),
						  love.audio.newSource( "scenes/minigame_5/sound/intro_4.ogg", "stream")}


	self.choose_timer = 0
	self.choose_timer_max = 5
	self.choose_music =  love.audio.newSource( "scenes/minigame_5/sound/bg_sound_minigame_5.ogg", "stream")

	self.reveal_music = love.audio.newSource( "scenes/minigame_5/sound/riser.ogg", "stream")
	self.reveal_timer = 0
	self.reveal_timer_max = self.reveal_music:getDuration( unit )
	self.reveal_timer_mid = 1.71


	self.outro_timer = 0
	self.outro_timer_max = 1

	-- FIRST TO 3?
	self.round = 1
	self.number_of_wins = {p1 = 0, p2 = 0}
	self.first_to = 3
	self.round_result = nil


	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

	 -- PLAYERS ZONES
	 self.player_1 = Player( 100 ,self.font:getHeight() + self.title.y + 100, 1)
	 self.player_2 = Player( global_width - self.player_1.area.w - 100  ,self.font:getHeight() + self.title.y + 100, 2)
	 print(self.player_1.area.w)
	 print(self.player_1.area.h)

	 --WINNERS OVERALL
	 self.counted_score = {p1 = false, p2 = false}

end

function minigame_5:update(dt)

--PROFILER
self.profiler:update(dt)

--INTRO
if self.phase == "intro" then
	self.intro_timer = self.intro_timer + dt
	if self.intro_timer >= self.intro_timer_max then
		self.phase = "choose"
		love.audio.stop()
		self.intro_sounds[4]:play()
	end

	if self.intro_timer <= self.intro_timer_max/3 then self.intro_sounds[1]:play()
		elseif self.intro_timer <=  2 * self.intro_timer_max/3 then self.intro_sounds[2]:play()
		elseif self.intro_timer <=  self.intro_timer_max then self.intro_sounds[3]:play() end
end

--CHOOSE PHASE

if self.phase == "choose" then
	self.choose_music:play() --player choose music
	self.player_1:update(dt, self.phase)
	self.player_1:hide_buttons(dt)
	self.player_2:update(dt, self.phase)
	self.player_2:hide_buttons(dt)
end

--CHange to Reveal after both players have chosen
if (self.player_1.choice ~= nil) and (self.player_2.choice ~= nil) and (self.player_1.choice_animations_done == true) and (self.player_2.choice_animations_done == true) then
	self.phase = "reveal"
	self.choose_music:stop()
	self.reveal_music:play()
	--get winner
end

--Player reveal music
if self.phase == "reveal" then
	self.reveal_timer = self.reveal_timer + dt
	self.player_1:update(dt, self.phase)
	self.player_2:update(dt, self.phase)
	minigame_5:decide_winner()
	--choose winner
	--move to next round OR switch to scoreboard
	if self.reveal_timer >= self.reveal_timer_max then
		self.reveal_music:stop()
		if (self.number_of_wins.p1 <self.first_to) and(self.number_of_wins.p2 <self.first_to) then
			--reset -timers buttons and everything
			self.phase = "choose"
			self.player_1:initialise_buttons()
			self.player_2:initialise_buttons()
			self.choose_timer = 0
			self.player_1.choice = nil
			self.player_2.choice = nil
			self.round_result = nil
			self.reveal_timer = 0
		else
			if self.number_of_wins.p1  == self.first_to then
				if self.counted_score.p1 == false then
					global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
				self.counted_score.p1 = true
				end
			elseif self.number_of_wins.p2  == self.first_to then
				if self.counted_score.p2 == false then
					global_score_counter.p2 = global_score_counter.p2 + 1 -- SCORE POINT
				self.counted_score.p2 = true
				end
			end
			self.player_2.choice = nil
			self.player_1.choice = nil-- hack to stop musci from starting
			self.outro_timer = self.outro_timer + dt

		end
	end

end


end

function minigame_5:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
	--INTRO
	if self.phase == "intro" then
		if self.intro_timer <= self.intro_timer_max/3 then display_text = "Rock"
		elseif self.intro_timer <=  2 * self.intro_timer_max/3 then display_text = "Rock Paper"
		else display_text = "Rock Paper Scissors" end
		love.graphics.setFont(self.font)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(display_text, 0, self.title.y, global_width, "center")
	end

	--CHOSE PHASE
	if (self.phase == "choose") or (self.phase == "reveal") then
		display_text = "Rock Paper Scissors"
		love.graphics.setFont(self.font)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(display_text, 0, self.title.y, global_width, "center")

		for i=0, 10, 1 do
			love.graphics.setColor(1, 0.1, 0.1)
			love.graphics.rectangle("line", (global_width - self.font:getWidth( display_text))/2 - i, 5 - i + self.title.y, self.font:getWidth( display_text) + 2*i , self.font:getHeight() + 2* i , 10)
		end

		--DRAW PLAYERS
		self.player_1:draw()
		self.player_2:draw()

	--SWITCH
			--outro and fade to black
		if self.outro_timer_max - self.outro_timer <=1 then
			time_left = 1 - (self.outro_timer_max - self.outro_timer)
			love.graphics.setColor(0,0,0, time_left)
			love.graphics.rectangle("fill", 0, 0 , global_width, global_height)
			love.graphics.setColor(1,1,1)
		end
		if self.outro_timer >= self.outro_timer_max then
			gamestate.switch(scoreboard)
		end

	end

	--REVEAL PHASE
	--DRAW PLAYERS AND TITLE

		----- FINISH DRAWING ----
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.canvas, self.aspect_ratio.x, self.aspect_ratio.y, 0, self.aspect_ratio.scale, self.aspect_ratio.scale)

	draw_debug()
	--PROFILER
	self.profiler:draw()
end

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_5:keypressed(key)

end

function minigame_5:keyreleased(key)
	if self.phase == "choose" then
		--player 1
		if self.player_1.choice == nil and key == "s" then
			self.player_1.choice_animations_done = false
			self.player_1.choice = "rock"
		end
		if self.player_1.choice == nil and key == "d" then
			self.player_1.choice_animations_done = false
			self.player_1.choice = "paper"
		end
		if self.player_1.choice == nil and key == "f" then
			self.player_1.choice_animations_done = false
			self.player_1.choice = "scissors"
		end
		--player 2
		if self.player_2.choice == nil and key == "j" then
			self.player_2.choice_animations_done = false
			self.player_2.choice = "rock"
		end
		if self.player_2.choice == nil and key == "k" then
			self.player_2.choice_animations_done = false
			self.player_2.choice = "paper"
		end
		if self.player_2.choice == nil and key == "l" then
			self.player_2.choice_animations_done = false
			self.player_2.choice = "scissors"
		end
	end
end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_5:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_5:enter(previous)
	self:init()
end

function minigame_5:leave()
	love.audio.stop()
	deep_release(self)
end

function minigame_5:decide_winner()
	if (self.player_1.choice ~= nil) and (self.player_1.choice ~= nil) and (self.player_1.choice_animations_done == true) and (self.player_2.choice_animations_done == true) and (self.reveal_timer > self.reveal_timer_mid) and (self.round_result == nil) then
		--if same choice
		if self.player_1.choice == self.player_2.choice then
			self.round_result = "draw"
			--dont change results
		end

		--if different choices
		if self.player_1.choice ~= self.player_2.choice then
			--P1
			--if rock
			if self.player_1.choice == "rock" then
				if self.player_2.choice == "scissors" then
					self.round_result = "player_1"
					self.number_of_wins.p1 = self.number_of_wins.p1 + 1
				elseif
					self.player_2.choice == "paper" then
					self.round_result = "player_2"
					self.number_of_wins.p2 = self.number_of_wins.p2 + 1
				end
			end

			--if paper
			if self.player_1.choice == "paper" then
				if self.player_2.choice == "rock" then
					self.round_result = "player_1"
					self.number_of_wins.p1 = self.number_of_wins.p1 + 1
				elseif
					self.player_2.choice == "scissors" then
					self.round_result = "player_2"
					self.number_of_wins.p2 = self.number_of_wins.p2 + 1
				end
			end

			--if scissors
			if self.player_1.choice == "scissors" then
				if self.player_2.choice == "paper" then
					self.round_result = "player_1"
					self.number_of_wins.p1 = self.number_of_wins.p1 + 1
				elseif
					self.player_2.choice == "rock" then
					self.round_result = "player_2"
					self.number_of_wins.p2 = self.number_of_wins.p2 + 1
				end
			end

		end

		return self.round_result
	else
		return nil
	end
end

-- NEEDS TO BE AT THE VERY END
return minigame_5
