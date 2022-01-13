Class = require "libs.hump.class"
Generator = require "scenes.minigame_6.entities.generator"

Runner = Class{}
local bump = require 'libs.bump'

function Runner:init(x, y, w, h, number)
	self.area = {}
	self.area.x = x
	self.area.y = y
	self.area.w = w
	self.area.width = w
	self.area.height = h
	self.area.h = h 
	
	self.world = bump.newWorld(50)
	

	
	self.player = {}
	self.player.w = 100
	self.player.h = 150
	self.player.x = self.area.x + 250
	self.player.y = self.area.y + self.area.height - self.player.h
	self.player.mass = 750
	self.player.vely = 0
	self.gravity = 9.81
	self.player.on_ground = true
	self.player.number = number
	if self.player.number == 1 then 
		self.player.key = "d"
	elseif self.player.number == 2 then 
		self.player.key = "k"
	end
	--count number of obstacle jumped
	self.player.obstacle_jumped = 0
	
	self.player.stopped = false --tag if bumped into something
	self.player.finished = false
	
	--sounds 
	self.sound = {}
	self.sound_jump = love.audio.newSource( "scenes/minigame_6/sound/jump_start.ogg", "static")
	self.sound_land = love.audio.newSource( "scenes/minigame_6/sound/jump_land.ogg", "static")
	self.sound_crash = love.audio.newSource( "scenes/minigame_6/sound/crash.ogg", "static")
	self.sound_crash:setVolume(2)
	self.sound_jump_played = false
	self.sound_land_played = true
	self.sound_crash_played = false
	
	
	--tags for jump
	self.jump = {}
	self.jump.has_jump = true
	self.jump.jump_signal = false
	self.jump.jump_started = false 
	self.jump.jump_finished = true
	self.jump.release = true
	self.jump.timer = 0
	self.jump.timer_max = 0.1
	self.jump.force = -16750
	
	--floor for bump
	self.floor = {}
	self.floor.x = self.area.x
	self.floor.y = self.area.y + self.area.h
	self.floor.w = self.area.w
	self.floor.h = 10
	self.floor.tag = "floor"
	
	--tags for difficulty
	self.number_of_obstacles = 15
	self.speed = 1000
	self.delay = 0
	
	-- hider (to hide the edges of the box and diseapearing obstacles)
	self.hiders = {}
	self.hiders.left = {}
	self.hiders.left.x = 0
	self.hiders.left.y = self.area.y
	self.hiders.left.w = self.area.x
	self.hiders.left.h = self.area.h
	
	self.hiders.right = {}
	self.hiders.right.x = self.area.x + self.area.w
	self.hiders.right.y = self.area.y
	self.hiders.right.w = self.area.x
	self.hiders.right.h = self.area.h
	
	--Generators 
	math.randomseed(os.time() * self.player.number)
	self.generator = Generator(self.area, self.number_of_obstacles, self.speed, self.delay)
	
	--Insert in world
	self.world:add(self.player,self.player.x,self.player.y,self.player.w,self.player.h)
	self.world:add(self.floor, self.floor.x,self.floor.y,self.floor.w,self.floor.h)
	--[[for k, v in pairs(self.generator.obstacle_holder) do--insert obastacles in world
		self.world:add(v, v.x, v.y, v.w, v.h)
	end]]
end


function Runner:update(dt)

	--FIND THE LAST OBSTABLE 
	for k, v in pairs(self.generator.obstacle_holder_moving) do
		if v.id == self.number_of_obstacles then 
			if v.x <= self.area.x then self.player.finished = true end
		end
	end

	
	--[[if #self.generator.obstacle_holder_left == 1 then
		self.player.finished = true
	end]]
	
	
	print(self.player.finished)
	if self.player.stopped == false then
		--press
		if love.keyboard.isDown(self.player.key) and (self.jump.has_jump == true) and (self.player.stopped == false) then 
			self.jump.jump_signal = true
			self.jump.timer = self.jump.timer + dt 
			self.player.on_ground = false
			if (self.jump.timer <= self.jump.timer_max ) and (self.jump.has_jump == true) then 
				self.player.vely = self.player.vely + self.jump.force * dt * (-math.log10(self.jump.timer))
			end
		else 
			self.jump.jump_signal = false
		end

		--physics
		if self.player.on_ground == true then 
			self.player.vely  = 1 --low gravity 
		else
			self.player.vely = self.player.vely + (self.gravity * self.player.mass * dt)
		end
		
		self.player.y = self.player.y + self.player.vely * dt
		
		--update moving
		self.player.actualX, self.player.actualY, self.cols, self.lenght_collisions  = self.world:move(self.player, self.player.x, self.player.y, self.playerFilter)
		self.player.y = self.player.actualY
		self.player.x =  self.player.actualX
		
		for k, v in pairs(self.cols) do --resolve collisions
			if v.other.tag == "floor" and (self.jump.release == true)  then
				self.jump.has_jump = true
				self.jump.timer = 0
				self.player.on_ground = true
				if self.sound_land_played == false then 
					self.sound_land_played = true
					self.sound_jump_played = false
					local pitch = math.random(80, 120)/100
					self.sound_land:setPitch(pitch)
					self.sound_land:play()
				end
			elseif v.other.tag == "floor" then 
				if self.sound_land_played == false then 
					self.sound_land_played = true
					self.sound_jump_played = false
					local pitch = math.random(80, 120)/100
					self.sound_land:setPitch(pitch)
					self.sound_land:play()
				end
			elseif v.other.tag == "obstacle" then 
				if self.sound_crash_played == false then 
					self.sound_crash:play()
					self.sound_crash_played = true
				end
				self.player.stopped = true
				self.player.obstacle_jumped = v.other.id -1 --id is number in the obstacle holder
			end
		end
		
		--update obstacles
			self.generator:update(dt)
			
			--update world 
			for k, v in pairs(self.generator.obstacle_holder_moving) do 
				self.world:update(v, v.x, v.y)
			end
			
			--every time timer crosses multiple of delay add obastacle to mos=ving obstacle 
			--if (self.generator.timer == dt) or (self.generator.timer%self.generator.delay <= dt) and (#self.generator.obstacle_holder_left > 1) then
			if (next(self.generator.time_holder) ~= nil) and (self.generator.timer >= self.generator.time_holder[1] ) and (next(self.generator.obstacle_holder_left) ~= nil)then
				table.insert(self.generator.obstacle_holder_moving, self.generator.obstacle_holder_left[1]) -- from the beginning insert in the end
				table.remove(self.generator.obstacle_holder_left, 1) --remove the beginning
				table.remove(self.generator.time_holder, 1) -- remove timer
				self.world:add(self.generator.obstacle_holder_moving[#self.generator.obstacle_holder_moving], --add to physics world
							   self.generator.obstacle_holder_moving[#self.generator.obstacle_holder_moving].x, 
							   self.generator.obstacle_holder_moving[#self.generator.obstacle_holder_moving].y, 
							   self.generator.obstacle_holder_moving[#self.generator.obstacle_holder_moving].w, 
							   self.generator.obstacle_holder_moving[#self.generator.obstacle_holder_moving].h)
				self.generator.obstacle_holder_moving[#self.generator.obstacle_holder_moving].start_moving = true
			end
	end
	
end

function Runner:draw()
	--Draw area
	if self.player.stopped == true then 
		love.graphics.setColor(1,0.8,0.8)
	elseif self.player.finished == true then 
		love.graphics.setColor(0.8,1,0.8)
	else
		love.graphics.setColor(1,1,1)
	end
	love.graphics.rectangle("fill", self.area.x, self.area.y, self.area.w, self.area.h)
	
	--Draw player 
	love.graphics.setColor(1, 0.5, 0.5)
	love.graphics.rectangle("fill", self.player.x, self.player.y, self.player.w, self.player.h)
	
	--draw obstacles 
		--update obstacles
	self.generator:draw()
	
	--HIDERS
	for k, v in pairs(self.hiders) do
		love.graphics.setColor(0,0,0) 
		love.graphics.rectangle("fill", v.x,v.y,v.w,v.h)
	end
	
	--Player number print
	love.graphics.setColor(0.5,0.5,0.5)
	love.graphics.setFont(minigame_6.font)
	love.graphics.print("Player "..tostring(self.player.number), self.area.x + 10 + 2, self.area.y + math.sin(minigame_6.global_timer * 5) * 5  +  5)
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(minigame_6.font)
	love.graphics.print("Player "..tostring(self.player.number), self.area.x + 10, self.area.y + math.sin(minigame_6.global_timer * 5) * 5 )
	

end

 function Runner.playerFilter(item, other)
  if other.tag == "floor"   then
	return 'slide'
  elseif other.tag == "obstacle" then
	return "cross"
  else
	return nil
  end
end

return Runner