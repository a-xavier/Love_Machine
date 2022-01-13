minigame_6 = {}
local Runner = require "scenes.minigame_6.entities.runner"


function minigame_6:init()
	self.scene_type = "game"
	self.scene_name = "Runaway"
	
	self.font = love.graphics.newFont("fonts/runner/Runner.ttf", 65)
	
	self.phase = "intro"
	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
	
	--Music
	self.active_music = love.audio.newSource( "scenes/minigame_6/sound/run_bg_music.ogg", "static")
	self.active_music:setLooping(true)
	self.active_music:setVolume(0.15)

	--TIMERS 
	--TIMERS 
	self.intro_timer = 0
	self.intro_timer_max = 3

	self.active_timer = 0
	self.active_timer_max = 15

	self.outro_timer = 0
	self.outro_timer_max = 5
	
		--global timer 
	self.global_timer = 0
	
	--Import both runner minigames
	--padding of 100
	self.runner_1 = Runner(100, 100, global_width - 200, global_height/2 - 100, 1)
	self.runner_2 = Runner(self.runner_1.area.x, global_height - self.runner_1.area.h - 50 , self.runner_1.area.w, self.runner_1.area.h, 2)
	
	--WINNERS OVERALL
	 self.counted_score = {p1 = false, p2 = false}
	 
	 self.winner = nil
	
	
end

function minigame_6:update(dt)
--GLOBAL TIMER 
	self.global_timer =  self.global_timer + dt
	--intro 
	if self.phase == "intro" then 
		self.intro_timer = self.intro_timer + dt 
		if self.intro_timer >= self.intro_timer_max then self.phase = "active" end
	end
	
	--Active
	if self.phase == "active" then 
		self.runner_1:update(dt)
		self.runner_2:update(dt)
		--Music
		self.active_music:play()
		
		if ((self.runner_1.player.stopped == true) and (self.runner_2.player.stopped == true)) or  ((self.runner_1.player.finished == true) and (self.runner_2.player.finished == true)) or ((self.runner_1.player.finished == true) and (self.runner_2.player.stopped == true)) or ((self.runner_1.player.stopped == true) and (self.runner_2.player.finished == true)) then 
			self.phase = "outro"
			self.active_music:play()
			print(self.runner_1.player.obstacle_jumped)
			print(self.runner_2.player.obstacle_jumped)
			
			--check winner
			if ((self.runner_1.player.finished == true) and (self.runner_2.player.finished == true)) then --if both finish
				self.winner = "draw"
			elseif ((self.runner_1.player.stopped == true) and (self.runner_2.player.stopped == true))  then --if both stop check count 
				if self.runner_1.player.obstacle_jumped > self.runner_2.player.obstacle_jumped then 
					self.winner = "player_1"
				elseif self.runner_1.player.obstacle_jumped < self.runner_2.player.obstacle_jumped then 
					self.winner = "player_2"
				else
					self.winner = "draw"
				end
			elseif ((self.runner_1.player.finished == true) and (self.runner_2.player.stopped == true)) then -- if one stop and the other finishes
				self.winner = "player_1"
			elseif ((self.runner_2.player.finished == true) and (self.runner_1.player.stopped == true)) then 
				self.winner = "player_2"
			end 
			
			--GIVE POINTS 
			if self.winner == "player_1" then 
				if self.counted_score.p1 == false then 
					global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
					self.counted_score.p1 = true
				end
			
			elseif self.winner == "player_2" then 
				if self.counted_score.p2 == false then 
					global_score_counter.p2 = global_score_counter.p2 + 1 -- SCORE POINT
					self.counted_score.p2 = true
				end
			
			elseif self.winner == "draw" then 
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
	
	-- OUTRO
	if self.phase == "outro" then 
	self.outro_timer = self.outro_timer + dt 
	if self.outro_timer >= self.outro_timer_max then gamestate.switch(scoreboard) end
	end


	
end

function minigame_6:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
		--ALWAYS DRAW RUNNER GAME
		self.runner_1:draw()
		self.runner_2:draw()
		
		--INTRO 
		if self.phase == "intro" then 
			love.graphics.setColor(1,1,1)
			love.graphics.setFont(self.font)
			local time_left =  math.ceil(self.intro_timer_max - self.intro_timer)
			local string_to_show = "Run and Jump in "..tostring(time_left)
			love.graphics.print(string_to_show, self.runner_1.area.x, 0)
		end
		
		--SWITCH
			--outro and fade to black
		if self.outro_timer_max - self.outro_timer <=1 then
			time_left = 1 - (self.outro_timer_max - self.outro_timer)
			self.active_music:setVolume(0.35 * (self.outro_timer_max - self.outro_timer)) --fade music away
			love.graphics.setColor(0,0,0, time_left)
			love.graphics.rectangle("fill", 0, 0 , global_width, global_height)
			love.graphics.setColor(1,1,1)
		end
		
		if self.phase == "outro" then 
			if self.winner == "player_1" then 
				self.string_to_display = "Player 1 Wins"
			elseif self.winner == "player_2" then 
				 self.string_to_display = "Player 2 Wins"
			elseif self.winner == "draw" then 
				 self.string_to_display = "DRAW"
			end 
			love.graphics.setColor(1, 0, 0)
			love.graphics.setFont(self.font)
			love.graphics.printf(self.string_to_display, 0,0, global_width, "center")
			
		end
		
		

		----- FINISH DRAWING ----
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.canvas, self.aspect_ratio.x, self.aspect_ratio.y, 0, self.aspect_ratio.scale, self.aspect_ratio.scale)
	
	draw_debug()
end

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_6:keypressed(key)
	if key == "d" then 
		self.runner_1.jump.release = false
		if self.runner_1.sound_jump_played == false and self.phase == "active" then
			local pitch = math.random(80, 120)/100
			self.runner_1.sound_jump:setPitch(pitch)
			self.runner_1.sound_jump:play()
			self.runner_1.sound_jump_played = true
			self.runner_1.sound_land_played = false
		end
	end
	if key == "k" then 
		self.runner_2.jump.release = false
		if self.runner_2.sound_jump_played == false and self.phase == "active" then
			local pitch = math.random(80, 120)/100
			self.runner_2.sound_jump:setPitch(pitch)
			self.runner_2.sound_jump:play()
			self.runner_2.sound_jump_played = true
			self.runner_2.sound_land_played = false
		end
	end
	
end

function minigame_6:keyreleased(key)
	if key == "d" then 
		self.runner_1.jump.release = true
	end
	
	if key == "k" then 
		self.runner_2.jump.release = true
	end
end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_6:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_6:enter(previous)

end

function minigame_6:leave()
	love.audio.stop() -- stop all audio
end

-- NEEDS TO BE AT THE VERY END
return minigame_6


