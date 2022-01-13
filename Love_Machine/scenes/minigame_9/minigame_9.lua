minigame_9 = {}
local Player = require "scenes.minigame_9.entities.player"
local tween = require "libs.tween"

function minigame_9:init()
	self.scene_type = "game"
	self.scene_name = "Trhead the Needle"

	self.font = love.graphics.newFont("fonts/oldstyle/OLDSH___.TTF", 100)

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
	self.wind.sound = love.audio.newSource( "scenes/minigame_9/sound/wind.ogg", "static")
	self.wind.sound:setVolume(0.15)

	--Players
	--Buffer of 15 pixels at edge of the screen
	self.padding = 15
	self.player_1 = Player(self.padding, self.padding, global_width/2 - 3*self.padding, global_height - 2* self.padding, 1)
	self.player_2 = Player(self.player_1.area.x + self.player_1.area.w + self.padding, self.player_1.area.y, self.player_1.area.w, self.player_1.area.h , 2)
end

function minigame_9:update(dt)

	--GLOBAL TIMER
	self.global_timer = self.global_timer + dt

	--Sound
	self.wind.sound:play()

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
		self.player_1.hand.physics.palm.body:applyForce(self.wind.direction * self.wind.speed, 0)
		self.player_2.hand.physics.palm.body:applyForce(self.wind.direction * self.wind.speed, 0)
	end


end

function minigame_9:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----

		--PLAYERS ALL THE TIME
		self.player_2:draw()
		self.player_1:draw()
		

		--INTRO
		if self.phase == "intro" then
		love.graphics.setColor(0.5,0.5,0.5)
		love.graphics.setFont(self.font)
		love.graphics.printf("Thread the Needle in the Wind", 0 + 3, global_height/2 - self.font:getHeight()/2 + 3, global_width, "center")

		love.graphics.setColor(1,0.1,0.5)
		love.graphics.setFont(self.font)
		love.graphics.printf("Thread the Needle in the Wind", 0, global_height/2 - self.font:getHeight()/2, global_width, "center")
		end

		--Wind

		for k, v in pairs(self.wind.speck_holder) do
			love.graphics.setColor(1,1,1, v.alpha)
			love.graphics.draw(self.wind.img, v.x, v.y, 0, 5/v.time_to_get_there, 0.5+ 0.5/v.time_to_get_there)
		end

		----- FINISH DRAWING ----
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.canvas, self.aspect_ratio.x, self.aspect_ratio.y, 0, self.aspect_ratio.scale, self.aspect_ratio.scale)

	draw_debug()
	--additional debug
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(self.wind.speed, 10, 175)
	love.graphics.print(self.phase, 10, 190)
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

end

-- NEEDS TO BE AT THE VERY END
return minigame_9
