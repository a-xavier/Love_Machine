minigame_4 = {}
local Plate = require "scenes.minigame_4.entities.Plate"
local Hand = require "scenes.minigame_4.entities.Hand"
local tween  = require "libs.tween"

function minigame_4:init()
	self.scene_type = "game"
	self.scene_name = "Don't grab the last bite"
	
	self.phase = "intro"
	
	self.intro_timer = 0
	self.intro_timer_max = 3
	self.font = love.graphics.newFont("fonts/hiro_misake/HIROMISAKE.ttf", 90)
	
	self.phase = "intro"
	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
	
	
	--Plate
	--, 
	self.plate = Plate(global_width/2 - 100, global_height/2 , 450)
	
	--Buttons to explain what to do
	self.buttons = {}
	local target_width = 200
	local x_padding = 10
	self.buttons.green = ButtonIcon(self.plate.area.x + self.plate.area.r, global_height - target_width - 100, target_width , target_width,  "green", "GRAB 1")
	self.buttons.red = ButtonIcon( self.buttons.green.x + target_width + x_padding, global_height - target_width - 100 , target_width , target_width,  "red", "GRAB 2")
	self.buttons.blue = ButtonIcon(self.buttons.green.x + 2*target_width + 2*x_padding, global_height - target_width - 100 , target_width , target_width,  "blue", "GRAB 3")
	
	
	self.tween_holder = {}
	
	--Tweens to make food and plate appear
	for k, v in pairs(self.plate.food_holder) do
		local r = (self.plate.area.r - 100) * math.sqrt(math.random())
		local theta = math.random() * 2 * math.pi
		local new_y =  self.plate.area.y + r * math.sin(theta)
		new_tween = tween.new(self.intro_timer_max/2, v, {y= new_y, rot = math.rad(math.random(0,360)), sy = 1}, 'outBounce')
		table.insert(self.tween_holder, new_tween)
	end

	-- Taking turns
	self.turn = "player_1"
	
	--Hand
	self.hand_1 = Hand(self.plate.area.x, -200, "top")
	self.hand_2 = Hand(-200, self.plate.area.y, "left")
	self.hand_3 = Hand(self.plate.area.x, global_height + 200, "bottom")
	self.all_hands = {self.hand_1, self.hand_2, self.hand_3}
	
	self.animation_playing = false
	
		--WINNER
	
	self.winner = nil
	self.counted_score = {p1 = false, p2 = false}
	
	self.outro_timer = 0 
	self.outro_timer_max  = 5
end

function minigame_4:update(dt)
	if self.phase == "intro" then 
		self.intro_timer = self.intro_timer + dt
		
		--after 1 second
		if self.intro_timer >= 1 then 
			for k, v in pairs(self.tween_holder) do
				v:update(dt)
			end
		end
		
		if self.intro_timer >=  self.intro_timer_max then self.phase = "active" end
	end
	
	self.plate.food_left = #self.plate.food_holder
	--ACTIVE PHASE 
	if self.phase == "active" then 
		--Check if any animation is already playing
		if (self.hand_1.grab_finished == false) or (self.hand_2.grab_finished == false) or(self.hand_2.grab_finished == false) then
			self.animation_playing = true
		else
			self.animation_playing = false
		end
		
		for k, v in pairs(self.all_hands) do
			v:update(dt)
			v:grab_food(self.plate.food_holder, dt)
		end
		
		--VICTORY CONDITIONS 
		
		if (self.plate.food_left == 1) then 
			self.hand_1.grab_finished = false -- grabs last piece of food 
			if self.turn == "player_1" then 
				self.winner = "player_2"
				if self.counted_score.p2 == false then
					global_score_counter.p2 = global_score_counter.p2 + 100
					self.counted_score.p2 = true
				end
			elseif self.turn == "player_2" then 
				self.winner = "player_1"
				if self.counted_score.p1 == false then
					global_score_counter.p1 = global_score_counter.p1 + 100
					self.counted_score.p1 = true
				end
			end
			self.phase = "outro"
		end
	end
	
	if self.phase == "outro" then 
		self.outro_timer = self.outro_timer + dt 
		for k, v in pairs(self.all_hands) do
			v:update(dt)
			v:grab_food(self.plate.food_holder, dt)
		end
		if self.outro_timer >= self.outro_timer_max then gamestate.switch(scoreboard) end
	end
	
end

function minigame_4:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
		
		--DRAW Plate
		self.plate:draw()
		
		--ACTIVE PHASE 
		 
		 if self.phase == "active" or self.phase == "outro" then 
			if self.phase == "active" then -- Only print info in active phase
			--Draw number of food left 
				love.graphics.setColor(1,1,1)
				love.graphics.setFont(self.font)
				love.graphics.print("Left\nin\nplate\n"..tostring(self.plate.food_left), self.plate.area.x + self.plate.area.r, self.plate.area.y - self.plate.area.r)
				--Draw number of food left 
				love.graphics.setColor(1,1,1)
				love.graphics.setFont(self.font)
				if self.turn == "player_1" then 
					text_player = "Player 1"
				elseif self.turn == "player_2" then 
					text_player = "Player 2"
				end
				love.graphics.printf(text_player.." Turn", 0,0,global_width, "center")
			end
			
			--draw buttons
			for k, v in pairs(self.buttons) do
				v:draw()
			end
			
			--Draw hand 
			for k, v in pairs(self.all_hands) do
				v:draw()
			end
			
			-- outro in active
			-- OUTRO 
			if self.phase == "outro" then 
		--outro and fade to black
				if self.outro_timer_max - self.outro_timer <=1 then
					local time_left = 1 - (self.outro_timer_max - self.outro_timer)
					love.graphics.setColor(0,0,0, time_left)
					love.graphics.rectangle("fill", 0, 0 , global_width, global_height)
					love.graphics.setColor(1,1,1)
				end
				love.graphics.setColor(0.8, 0.4, 0.3)
				if self.winner == "player_1" then 
					love.graphics.setFont(self.font)
					love.graphics.printf("Player 1 WINS", 0, global_height/2 - self.font:getHeight()/2, global_width, "center")
					love.graphics.printf("Player 2 is so F**king rude!", 0, global_height/2 - self.font:getHeight()/2 + self.font:getHeight(), global_width, "center")
				elseif self.winner == "player_2" then 
					love.graphics.setFont(self.font)
					love.graphics.printf("Player 2 WINS", 0,global_height/2 - self.font:getHeight()/2, global_width, "center")
					love.graphics.printf("Player 1 is so F**king rude!", 0, global_height/2 - self.font:getHeight()/2 + self.font:getHeight(), global_width, "center")
				end
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

function minigame_4:keypressed(key)
	
end

function minigame_4:keyreleased(key)
	--active state
	if (self.phase == "active") and (self.animation_playing == false) and (self.turn == "player_1")then 
		if key == "s" and self.plate.food_left > 1 then
			number_to_get = 1
		elseif key == "d" and self.plate.food_left > 2 then
			number_to_get = 2
		elseif key == "f" and self.plate.food_left > 3 then
			number_to_get = 3
		else 
			number_to_get = 0
		end
		
		if (key == "s") or (key == "d") or (key == "f") then 
			for i = 1, number_to_get, 1 do
				self.all_hands[i].grab_finished = false
			end
		end
	end
	
	if (self.phase == "active") and (self.animation_playing == false) and (self.turn == "player_2")then 
		if key == "j" and self.plate.food_left > 1 then
			number_to_get = 1
		elseif key == "k"and self.plate.food_left > 2 then
			number_to_get = 2
		elseif key == "l" and self.plate.food_left > 3 then
			number_to_get = 3
		else 
			number_to_get = 0
		end
		
		if (key == "j") or (key == "k") or (key == "l") then 
			for i = 1, number_to_get, 1 do
				self.all_hands[i].grab_finished = false
			end
		end
	end
end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_4:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_4:switch_turns()
	if 	self.turn == "player_1" then 
		self.turn =  "player_2"
	elseif	self.turn == "player_2" then 
		self.turn =  "player_1"
	end
end

function minigame_4:enter(previous)

end

-- NEEDS TO BE AT THE VERY END
return minigame_4


