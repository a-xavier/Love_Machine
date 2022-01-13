minigame_7 = {}
local Player = require "scenes.minigame_7.entities.player"
local Button = require "entities.button_icon"


function minigame_7:init()
	self.scene_type = "game"
	self.scene_name = "Cowboy Shit"
	
	self.font = love.graphics.newFont("fonts/western/western.ttf", 100)
	
	self.phase = "intro"
	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
	
	--no entities?
	self.bg_music = love.audio.newSource( "scenes/minigame_7/sound/cowboy_bg_music.ogg", "static")
	self.bg_music:setVolume(0.35)
	
	--randomly generate parameters 
	math.randomseed(os.time())
	self.bell_rings = math.random(2,6) -- number of ring of the bell
	self.bell_dict = {"First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth", "Ninth", "Tenth", "Eleventh", "Twelfth"}
	self.bell_sound = love.audio.newSource( "scenes/minigame_7/sound/bell.ogg", "static")
	self.bell_duration = self.bell_sound:getDuration()
	self.bell_timer_holder = {0} -- timer that trigger the bell ringing
	for i=2, self.bell_rings, 1 do
		local new_timer = (math.random(150, 400)/100)
		print(new_timer + self.bell_timer_holder[i-1])
		table.insert(self.bell_timer_holder, new_timer + self.bell_timer_holder[i-1])
	end
	print(self.bell_rings)
	print(#self.bell_timer_holder)
	
	self.allowed_to_shoot = false
	
	--Players
	self.player_1 = Player(300, global_height/2, 1)
	self.player_2 = Player(global_width - self.player_1.w - 300, global_height/2, 2)
	
	
	--TIMERS 
	self.intro_timer = 0
	self.intro_timer_max = 5

	self.active_timer = 0
	self.active_timer_max = 15

	self.outro_timer = 0
	self.outro_timer_max = 6
	
		--global timer 
	self.global_timer = 0
	
	--Button prompt
	self.shoot_button = Button(global_width/2 - 100, global_height - 500, 200, 200, "green", "Press to shoot")
	
	--Winner 
	self.winner = nil
	self.counted_score = {p1 = false, p2 = false}
	
	--TODO MAKE WINNER AND COUNT GLOBAL POINTS
	
end

function minigame_7:update(dt)
	--always on 
	self.global_timer = self.global_timer + dt
	self.bg_music:play()
	
	--Update players
		self.player_1:update(dt)
		self.player_2:update(dt)
	
	--INTRO
	if self.phase == "intro" then 
		self.intro_timer = self.intro_timer + dt 
		if self.intro_timer >= self.intro_timer_max then
			self.phase = 'active'
			--allow illegal shooting
			self.player_1.can_shoot = true
			self.player_2.can_shoot = true
		end
	end
	
		--ACTIVE
	if self.phase == "active" then 
		self.active_timer = self.active_timer + dt 
		
		--handle bell 
		if (next(self.bell_timer_holder) ~=nil) and (self.active_timer >= self.bell_timer_holder[1]) then -- if timer reaches the first time in time holder
			self.bell_sound:stop()
			table.remove(self.bell_timer_holder, 1) -- remove the time to ring the bell 
			self.bell_sound:play()
		end
		-- resolve shooting
		--TRIGGER ALLOWING TO SHOOT 
		if (next(self.bell_timer_holder) == nil) then self.allowed_to_shoot = true end
	end
	
	if self.phase == "outro" then 
		self.outro_timer = self.outro_timer + dt
		if (self.player_1.killer == true) or (self.player_2.killer == true) then 
			if self.player_1.killer == true then 
				self.player_2.killed = true
			elseif self.player_2.killer == true then 
				self.player_1.killed = true
			end
		end
		--points
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
		end
		
		--Switch to scoreboard
		if self.outro_timer >= self.outro_timer_max then gamestate.switch(scoreboard) end
		
	end


	
end

function minigame_7:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
			if self.phase == "intro" then
				love.graphics.setColor(1,1,1)
				love.graphics.setFont(self.font)
				local width_text = self.font:getWidth( "Shoot after the" )
				local heigh_text =  self.font:getHeight()
				love.graphics.printf("Shoot after the" ,0, global_height/2 - (3*heigh_text), global_width, "center")
				love.graphics.printf(self.bell_dict[self.bell_rings], 0, global_height/2 - (2*heigh_text), global_width, "center")
				love.graphics.printf("bell", 0, global_height/2 - (heigh_text), global_width, "center")
				self.shoot_button:draw()
			end
			
			--Draw players
			self.player_1:draw()
			self.player_2:draw()
			
			-- OUTRO PRINT RESULTS 
			if self.phase == "outro" then 
				--premature ending
				if (self.player_1.premature_shooter == true) or (self.player_2.premature_shooter == true) then 
					if self.player_1.premature_shooter == true then 
						 string_to_display = "Player 1"
					elseif self.player_2.premature_shooter == true then 
						 string_to_display = "Player 2"
					end
					love.graphics.setColor(1, 0.4, 0.4)
					love.graphics.setFont(self.font)
					love.graphics.printf(string_to_display.." is a premature shooter and a loser", 0, global_height/2 - self.font:getHeight()/2, global_width, "center")
				end
				--Killer ending
				if (self.player_1.killer == true) or (self.player_2.killer == true) then 
					if self.player_1.killer == true then 
						 string_to_display = "Player 1"
						 deadname = "Player 2"
					elseif self.player_2.killer == true then 
						 string_to_display = "Player 2"
						 deadname = "Player 1"
					end
					
					love.graphics.setFont(self.font)
					love.graphics.setColor(0.5, 0.5, 0.5)
					love.graphics.printf(string_to_display.." is a sharpshooter and a winner...", 0, global_height/2 - self.font:getHeight()/2 + 5, global_width, "center")
					love.graphics.printf("...also "..deadname.." is dead.", 0, global_height/2  - self.font:getHeight()/2 + self.font:getHeight() + 5, global_width, "center")
					love.graphics.setColor(0.4, 1, 0.4)
					
					love.graphics.printf(string_to_display.." is a sharpshooter and a winner...", 0, global_height/2 - self.font:getHeight()/2, global_width, "center")
					love.graphics.printf("...also "..deadname.." is dead.", 0, global_height/2  - self.font:getHeight()/2 + self.font:getHeight(), global_width, "center")
					
				end
				
				--FADE TO BLACK 
				if self.outro_timer_max - self.outro_timer <=1 then
					time_left = 1 - (self.outro_timer_max - self.outro_timer)
					self.bg_music:setVolume(0.35 * (self.outro_timer_max - self.outro_timer)) --fade music away
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
end

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_7:keypressed(key)
	if self.phase == "active" then
		if key == "d" then 
			self.player_1.shoot_triggered = true
		end
		
		if key == "k" then 
			self.player_2.shoot_triggered = true
		end
	end
	
end

function minigame_7:keyreleased(key)
	
end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_7:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_7:enter(previous)

end

-- NEEDS TO BE AT THE VERY END
return minigame_7


