minigame_1 = {}
local tween  = require "libs.tween"


function minigame_1:init()

-- TAGS
self.scene_type = "game"
self.scene_name = "Tower Building"

--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
	
	-- FONTS 
	
	self.font_main = love.graphics.newFont("fonts/coolvetica/coolvetica condensed rg.otf", 100)
	self.font_small = love.graphics.newFont("fonts/coolvetica/coolvetica condensed rg.otf", 50)
	
	-- MINIGAME INTRO COUNTDOWN
	self.intro_time_max = 4
	self.intro_timer = 4
	
	
	--MINIGAME PHASES either intro active reveal or outro phase
	self.phase = "intro"
	
	-- PLAYERS
	
	--PLAYER 1
	
	self.player_1 = {}
	self.player_1.click_count = 0
	
	
	--PLAYER 2
	
	self.player_2 = {}
	self.player_2.click_count = 0
	
	-- GAME TIMER 
	self.game_timer = 10
	
	--REVEAL TIMER 
	
	self.reveal_timer = 0
	self.reveal_timer_max = 5
	
	-- OUTRO TIMER 
	self.outro_timer = 0
	self.outro_timer_max = 3
	self.outro_started = false
	
	--FLOOR LEVEL Y
	self.floor_level = 900

	--LOGS
	self.log_h = {}
	self.log_h.img = love.graphics.newImage( "scenes/minigame_1/img/log_horizontal.png")
	self.log_h.w = 300
	self.log_h.h = 50
	
	self.log_v = {}
	self.log_v.img = love.graphics.newImage( "scenes/minigame_1/img/log_vertical.png")
	self.log_v.w = 50
	self.log_v.h = 300
	
	--Hit sounds
	
	self.hit_sounds = { love.audio.newSource( "scenes/minigame_1/sound/wood_hit_1.ogg", "static" ),
						love.audio.newSource( "scenes/minigame_1/sound/wood_hit_2.ogg", "static" ),
						love.audio.newSource( "scenes/minigame_1/sound/wood_hit_3.ogg", "static" ),
						love.audio.newSource( "scenes/minigame_1/sound/wood_hit_4.ogg", "static" )}
						
	--Player animations 
	self.p1_anim = {}
	self.p1_anim.spritesheet = love.graphics.newImage( "scenes/minigame_1/img/p1_builder.png")
	self.p1_anim.quads = {love.graphics.newQuad( 0, 0, 300, 300, 600, 300 ),
							  love.graphics.newQuad( 300, 0, 300, 300, 600, 300 )}
	self.p1_anim.current_quad = 1
	self.p1_anim.w = 300
	self.p1_anim.h = 300
	self.p1_anim.x = 300 + self.log_h.w
	self.p1_anim.y = self.floor_level - self.p1_anim.h
	
	self.p2_anim = {}
	self.p2_anim.spritesheet = love.graphics.newImage( "scenes/minigame_1/img/p2_builder.png")
	self.p2_anim.quads = {love.graphics.newQuad( 0, 0, 300, 300, 600, 300 ),
							  love.graphics.newQuad( 300, 0, 300, 300, 600, 300 )}
	self.p2_anim.current_quad = 1
	self.p2_anim.w = 300
	self.p2_anim.h = 300
	self.p2_anim.x = global_width - 300 - self.log_h.w - self.p2_anim.w
	self.p2_anim.y = self.floor_level - self.p1_anim.h
	
	
	-- GAME OUTCOME
	self.winner = nil
	
	self.counted_score = {p1 = false, p2 = false}
	
end

function minigame_1:update(dt)

	-- INTRO COUNTDOWN
	if self.phase == "intro" then
		self.intro_timer = self.intro_timer - dt
		if self.intro_timer <= 0 then self.phase = "active" end
	end
	
	if self.phase == "active" then 
		if self.game_timer >= 0 then 
			self.game_timer = self.game_timer - dt
		else
		--Lots of things happenn here
			self.phase = "reveal"
			-- Get the maximum height of the highest tower
			--Careful if table is empty 
			if #player_1_logs > 0 then 
				max_player_1 =  player_1_logs[#player_1_logs].y
			else
				max_player_1 = self.floor_level
			end 
			
			if #player_2_logs > 0 then 
				max_player_2 =  player_2_logs[#player_2_logs].y
			else
				max_player_2 = self.floor_level
			end 

			max_tower = math.min(max_player_1, max_player_2) -- min because going up
			
			--designate winner 
			
			if self.player_1.click_count > self.player_2.click_count then 
				self.winner = "player_1"
			elseif self.player_1.click_count < self.player_2.click_count then 
				self.winner = "player_2"
			elseif self.player_1.click_count == self.player_2.click_count then
				self.winner = "draw"
			end
			
			--create tweens for sliding
			self.reveal_tweens = {}
			for k, v in pairs(player_1_logs) do
				table.insert(self.reveal_tweens, tween.new(self.reveal_timer_max, v, {y= v.y - max_tower + self.log_v.h}, 'inOutExpo'))
			end
			
			for k, v in pairs(player_2_logs) do
				table.insert(self.reveal_tweens, tween.new(self.reveal_timer_max, v, {y= v.y - max_tower +  self.log_v.h }, 'inOutExpo'))
			end
			
			--ADD PLAYER INTO TWEEN TABLE
			table.insert(self.reveal_tweens, tween.new(self.reveal_timer_max, self.p1_anim, {y= self.p1_anim.y - max_tower +  self.log_v.h }, 'inOutExpo'))
			table.insert(self.reveal_tweens, tween.new(self.reveal_timer_max, self.p2_anim, {y= self.p2_anim.y - max_tower +  self.log_v.h }, 'inOutExpo'))
		end
	end
	
	if self.phase == "reveal" then 
		if self.reveal_timer <= self.reveal_timer_max then self.reveal_timer = self.reveal_timer + dt else self.outro_started = true end
		--update tweens
		for k, v in pairs(self.reveal_tweens) do
			v:update(dt)
		end
		
		if self.outro_started == true then 
			self.outro_timer = self.outro_timer + dt
		end
			
	end
end

function minigame_1:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
		--ALL TIME SHOW PLAYERS BUILDER 
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.p1_anim.spritesheet, self.p1_anim.quads[self.p1_anim.current_quad], self.p1_anim.x, self.p1_anim.y)
		love.graphics.draw(self.p2_anim.spritesheet, self.p2_anim.quads[self.p2_anim.current_quad], self.p2_anim.x, self.p2_anim.y)
		
		--INTRO COUNTDOWN
		if self.phase == "intro" then
			local timer_int = math.floor(self.intro_timer)
			local timer_dec = math.fmod(self.intro_timer,1) * 100
			love.graphics.setFont(self.font_main)
			love.graphics.setColor(1,1,1)
			love.graphics.print(tostring(timer_int), global_width/2, global_height/2)
			love.graphics.setFont(self.font_small)
			love.graphics.setColor(1,1,1)
			love.graphics.print(string.format(".%02d", timer_dec), global_width/2 + self.font_main:getWidth( tostring(timer_int) ), global_height/2)
		end
		
		--ACTIVE GAME
		if self.phase == "active" then
			love.graphics.setFont(self.font_small)
			love.graphics.printf("PLAYER 1: "..tostring(self.player_1.click_count), 0, 0, global_width, "left")
			love.graphics.printf("PLAYER 2: "..tostring(self.player_2.click_count), 0, 0, global_width, "right")
			love.graphics.printf(tostring(self.game_timer), 0, 0, global_width, "center")
			
			
			--DRAW LOGS 
			
			player_1_logs = self:build_tower(self.player_1.click_count, 1)
			player_2_logs = self:build_tower(self.player_2.click_count, 2)
			
			for k, v in pairs(player_1_logs) do
				love.graphics.draw(v.img, v.x, v.y)
			end
			
			for k, v in pairs(player_2_logs) do
				love.graphics.draw(v.img, v.x, v.y)
			end
		end
		
		-- REVEAL
		if  self.phase == "reveal" then
			-- STILL DRAW TOWER
			for k, v in pairs(player_1_logs) do
				love.graphics.draw(v.img, v.x, v.y)
			end
			
			for k, v in pairs(player_2_logs) do
				love.graphics.draw(v.img, v.x, v.y)
			end
			
			--PRINT WINNER 
			if self.outro_started == true then 
				love.graphics.setColor(1,1,1)
				love.graphics.setFont(self.font_main)
				if self.winner == "player_1" then 
					love.graphics.printf("Player 1 Wins", 300 , 75, self.log_h.w, "center")
					if self.counted_score.p1 == false then 
						global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE + 1
						self.counted_score.p1 = true
					end
				elseif self.winner == "player_2" then 
					love.graphics.printf("Player 2 Wins", global_width - 300 - self.log_h.w , 75,  self.log_h.w, "center")
					if self.counted_score.p2 == false then 
						global_score_counter.p2 = global_score_counter.p2 + 1
						self.counted_score.p2 = true
					end
				elseif self.winner == "draw" then 
					love.graphics.printf("DRAW", 0, 75 , global_width, "center")
					if (self.counted_score.p2 == false) and (self.counted_score.p1 == false) then 
						global_score_counter.p2 = global_score_counter.p2 + 1
						global_score_counter.p1 = global_score_counter.p1 + 1
						self.counted_score.p2 = true
						self.counted_score.p1 = true
					end
				end
				
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
			
		end
		
		
		----- FINISH DRAWING ----

love.graphics.setCanvas()
love.graphics.setColor(1, 1, 1)
love.graphics.draw(self.canvas, self.aspect_ratio.x, self.aspect_ratio.y, 0, self.aspect_ratio.scale, self.aspect_ratio.scale)
draw_debug()

	
end


function minigame_1:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_1:enter(previous)

end

-- CONTROLS

function minigame_1:keypressed(key)
	if self.phase == "active" then
		if key == "d" then 
			local random_int_1_1 = math.random(1,4)
			self.hit_sounds[random_int_1_1]:setPitch( math.random(80, 120)/100 )
			self.hit_sounds[random_int_1_1]:play()
			self.p1_anim.current_quad = 2
		end
		
		if key == "k" then 
			local random_int_2_2 = math.random(1,4)
			self.hit_sounds[random_int_2_2]:setPitch( math.random(80, 120)/100 )
			self.hit_sounds[random_int_2_2]:play()
			self.p2_anim.current_quad = 2
		end
	end
end


function minigame_1:keyreleased(key)
	if self.phase == "active" then
		if key == "d" then 
			self.player_1.click_count = self.player_1.click_count + 1
			self.p1_anim.current_quad = 1
		end
		
		if key == "k" then 
			self.player_2.click_count = self.player_2.click_count + 1
			self.p2_anim.current_quad = 1
		end
	end
end

function minigame_1:build_tower(count, player_number)
	local count = count + 2
	local level = 0
	
	local log_table = {}
	
	if player_number == 1 then 
		base_x = 300
	elseif player_number == 2 then
		base_x = global_width - 300 - self.log_h.w
	end

	if count >= 3 then 
		for i = 3, count, 1 do 
			if i%3 == 0 then --horizontal
				current_log = {x = base_x, y = self.floor_level - level * self.log_v.h, img = self.log_h.img}
			elseif i%3 == 1 then --vertical left
				current_log = {x = base_x, y = self.floor_level - level * self.log_v.h - self.log_v.h + self.log_h.h , img = self.log_v.img}
			elseif i%3 == 2 then --vertical right
				current_log = {x = base_x + self.log_h.w - self.log_v.w, y = self.floor_level - level * self.log_v.h - self.log_v.h + self.log_h.h , img = self.log_v.img}
			level = level + 1
			end
		table.insert(log_table, current_log)
		end
	end
	return log_table
end

-- NEEDS TO BE AT THE VERY END
return minigame_1

