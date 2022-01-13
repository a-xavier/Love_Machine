Class = require "libs.hump.class"
local tween  = require "libs.tween"

Hand = Class{
	init = function(self, x, y, location)

	--defines playable area
	self.x = x
	self.y = y 
	self.original_x = x
	self.original_y = y 
	self.rot = 0
	
	self.location = location
	self.img = love.graphics.newImage( "scenes/minigame_4/img/hand_"..self.location..".png")
	if self.location == "top" then 
		self.index = 0
		self.palmx = 110
		self.palmy = 900
	elseif self.location == "left" then 
		self.index = 1
		self.palmx = 900
		self.palmy = 120
	elseif self.location == "bottom" then 
		self.index = 2
		self.palmx = 120
		self.palmy = 150
	end
	
	self.w = self.img:getWidth( )
	self.h = self.img:getHeight( )
	
	self.grab = "idle"
	self.grab_start_signal = false
	self.grab_started = false
	self.grab_finished = true
	self.grab_food_chosen = false
	
	self.reach = {}
	self.reach.timer_max = 0.5
	self.reach.tween_generated = false
	self.reach.tween  = nil

	
	self.retract = {}
	self.retract.timer_max = 1
	self.retract.tween_generated = false
	self.retract.tween = nil
	
	end
	}

function Hand:update(dt)
	--HANDLE ANIMATION
	
end

function Hand:grab_food(food_holder, dt)
	-- if not empty
	if #food_holder > 0 then
		if self.grab_finished == false then
			--First select the food to grab and its unique index
			if self.grab_food_chosen == false then
				self.food = food_holder[(#food_holder-self.index)] --get last minus index so last for top second to last for left etc
				 self.index_to_remove = self.food.number --get individual index of food to remove
				 target_x = self.food.x
				 target_y = self.food.y 
				self.grab_food_chosen = true
				print(index_to_remove)
			end
			
			--If tween for grab not generated
			if (self.reach.tween_generated == false) then -- at start generate tween for reach
				self.reach.tween = tween.new(self.reach.timer_max + (3 - self.index) * 0.25, self, {x = target_x, y = target_y})
				self.reach.tween_generated = true
				print("reach generate")
			end
			--If tween for grab generated
			if (self.reach.tween_generated == true) and (self.reach.tween:update(dt) == false) then
				self.reach.tween:update(dt)
				print("reach updating")
			end
			--WHen  tween for grab ends
			if (self.reach.tween_generated == true) and (self.reach.tween:update(dt) == true) and (self.retract.tween_generated == false)then
				self.retract.tween = tween.new(self.retract.timer_max + (3 - self.index) * 0.25, self, {x = self.original_x, y = self.original_y})
				self.retract.tween_generated = true
			end
			
			--Update tween for rtracts
			if (self.retract.tween_generated == true) and (self.retract.tween:update(dt) == false) then
				self.retract.tween:update(dt)
				--Move food too and remove it from the 
				self.food.x = self.x
				self.food.y = self.y
				print("MOVE FOOD")
			end
			
			--finish animation
			if (self.retract.tween_generated == true) and (self.retract.tween:update(dt) == true) then
				--Find index of food to remove
				for i=1, #food_holder, 1 do 
					if (food_holder[i] ~= nil) and (food_holder[i].number == self.index_to_remove) then 
						table.remove(food_holder, i)
						break
					end
				end
				self.grab_finished = true
				--reset all 
				self.reach.tween_generated = false
				self.reach.tween  = nil
				self.retract.tween_generated = false
				self.retract.tween = nil
				self.grab_food_chosen = false
				if self.index == 0 then minigame_4:switch_turns() end
			end
		end
	end
end

function Hand:draw()
	--draw Hand
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.img, self.x, self.y, 0, 1, 1, self.palmx, self.palmy ) -- use palm center as reference for drawing
end


return Hand