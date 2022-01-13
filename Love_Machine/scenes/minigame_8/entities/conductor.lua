Class = require "libs.hump.class"

Conductor = Class{}

function Conductor:init(x, y, number) -- delay in seconds
	--All have a timer 
	self.timer = 0
	--position size
	self.x = x
	self.y = y
	self.w = 200
	self.h = 400
	
	self.options = {"left", "up", "right"}
	self.initial_seq_length = 4
	self.current_cycle = 0
	self.sequence_started = false 
	self.sequence_finished = false
	self.sequence_num = 1
	self:generate_sequence()
	self.current_movement = nil
	self.current_movement_index = 1
	
	self.sounds = {}
	self.sounds.right = love.audio.newSource( "scenes/minigame_8/sound/right.ogg", "static")
	self.sounds.up = love.audio.newSource( "scenes/minigame_8/sound/up.ogg", "static")
	self.sounds.left = love.audio.newSource( "scenes/minigame_8/sound/left.ogg", "static")
	
	--IMG AND ANIMS
	self.img = {}
	self.img.spritesheet = love.graphics.newImage( "scenes/minigame_8/img/conductor.png")
	self.img.quads = {love.graphics.newQuad( 0, 0, self.w, self.h, 600, 800 ), -- First row is up left right 
				  love.graphics.newQuad( self.w, 0, self.w, self.h, 600, 800 ), -- Next row is idle 123
				  love.graphics.newQuad( 2*self.w, 0, self.w, self.h, 600, 800 ),
				  love.graphics.newQuad( 0, self.h, self.w, self.h, 600, 800 ),
				  love.graphics.newQuad( self.w, self.h, self.w, self.h, 600, 800 ),
				  love.graphics.newQuad(2*self.w, self.h, self.w, self.h, 600, 800 )}
	self.img.current_quad = 1
	
	
end


function Conductor:update(dt)
	--Update timer
	self.timer = self.timer + dt*10
	
	--update idle animation
	if minigame_8.phase ~= "show" then 
		if math.ceil(self.timer%8) == 0 then 
			self.img.current_quad = 4
		elseif math.ceil(self.timer%8) == 1 then 
			self.img.current_quad = 5
		elseif math.ceil(self.timer%8) == 2 then 
			self.img.current_quad = 6
		elseif math.ceil(self.timer%8) == 3 then 
			self.img.current_quad = 5
		elseif math.ceil(self.timer%8) == 4 then 
			self.img.current_quad = 4
		else 
			self.img.current_quad = 4
		end
	end
	
	--Sequence finished if nothing left in holder
	--if next(self.sequence) == nil then self.sequence_finished = true end
	

	--SHOW PHASE
	if minigame_8.phase == "show" then
		if minigame_8.music.beat_num == 1 then self.sequence_started = true end -- start at beginning of the bar
		
		if self.sequence_started == true then --iterate over all 
			if (minigame_8.music.beat_signal == true) and (self.current_movement_index <= #self.sequence) then 
			 --self.current_movement = self.sequence[1]
			 --table.remove(self.sequence, 1)
			 --Player sound
			 if self.sequence[self.current_movement_index] == "left" then 
				self.sounds.left:stop()
				self.sounds.left:play()
				self.img.current_quad = 2
			 elseif  self.sequence[self.current_movement_index] == "right" then 
				self.sounds.right:stop()
				self.sounds.right:play()
				self.img.current_quad = 3
			 elseif self.sequence[self.current_movement_index] == "up" then 
				self.sounds.up:stop()
				self.sounds.up:play()
				self.img.current_quad = 1
			 end
			 
			self.current_movement = self.sequence[self.current_movement_index]
			
			print(self.current_movement_index)
			print(self.current_movement)
			
			self.current_movement_index = self.current_movement_index + 1
			table.remove(self.sequence_copy, 1)
			end
			
			if (minigame_8.music.beat_timer - minigame_8.music.alpha_timer <= 0.1) then 
				self.img.current_quad = 4
			end
			
			if (self.current_movement_index > #self.sequence) and (minigame_8.music.alpha_timer > (minigame_8.music.beat_timer - 0.1)) then
				self.sequence_finished = true
				--print("FINISHED frame "..minigame_8.frame)
			end
		end
	end
	
end

function Conductor:draw()
	love.graphics.setColor(1,1,1)
	--love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	love.graphics.draw(self.img.spritesheet, self.img.quads[self.img.current_quad], self.x, self.y)
	if (self.sequence_started == true) and (self.sequence_finished == false) and (minigame_8.music.beat_timer - minigame_8.music.alpha_timer >= 0.1) then
		love.graphics.setColor(0,0,0)
		love.graphics.setFont(minigame_8.font_small)
		love.graphics.printf(self.current_movement, self.x, self.y + self.h/2, self.w, "center")
		--print(("STIL SHOWING AT frame "..minigame_8.frame..self.current_movement))
	end

end

function Conductor:generate_sequence()
	math.randomseed(os.time())
	self.sequence = {}
	self.sequence_copy = {}
	self.sequence_num = self.sequence_num + 1
	
	--[[if self.current_cycle <= 8 then 
		length_of_seq = 4
	elseif self.current_cycle <= 10 then 
		length_of_seq = 6
	elseif self.current_cycle <= 12 then 
		length_of_seq = 8
	else
		length_of_seq = 12
	end]]
	length_of_seq = 4
	
	for i = 1, length_of_seq , 1 do
		local movement = self.options[math.random(1,3)]
		table.insert(self.sequence, movement)
		table.insert(self.sequence_copy, movement)
		print(movement)
	end
	print(#self.sequence)
	
	self.current_cycle = self.current_cycle + 1
	
	--also reset other things
	self.current_movement = nil
	self.current_movement_index = 1
	self.sequence_started = false 
	self.sequence_finished = false
	

end

return Conductor