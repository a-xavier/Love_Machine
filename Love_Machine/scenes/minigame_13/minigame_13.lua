minigame_13 = {}

function minigame_13:init()
	self.scene_type = "game"
	self.scene_name = "Et Tron"

	local Bike = require "scenes.minigame_13.entities.bike"
	local bump = require 'libs.bump'

	self.world = bump.newWorld(25)

	self.font = love.graphics.newFont("fonts/cybrpnuk/Cybrpnuk2.ttf", 100)

	self.bg_music = love.audio.newSource( "scenes/minigame_13/sound/chansondereserve.ogg", "stream")
	self.bg_volume = 0.25
	self.bg_music:setVolume(self.bg_volume)

	self.crash_sound = love.audio.newSource( "scenes/minigame_13/sound/troncrash.ogg", "static")
	self.crash_sound:setVolume(0.5)

	self.phase = "intro"
	--TIMERS
	self.intro_timer = 0
	self.intro_timer_max = 3

	self.active_timer = 0
	self.active_timer_max = 5

	self.outro_timer = 0
	self.outro_timer_max = 5

	self.global_timer = 0
	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

	--play area
	self.play_area = {}
	self.play_area.x = 50
	self.play_area.y = 50
	self.play_area.w = global_width - 100
	self.play_area.h = global_height - 100

	--PLAYERS
	local player_width = 50
	local player_height = 25
	self.player_1 = Bike(self.play_area.x + 100, self.play_area.y + 75, 1, player_width, player_height)
	self.player_2 = Bike(self.play_area.x + self.play_area.w - 100, self.play_area.y + self.play_area.h - 75, 2, player_width, player_height)

	--WALLS OUTSIDE
	self.walls = {}
	self.walls.left = {}
	self.walls.left.x = self.play_area.x
	self.walls.left.y = self.play_area.y
	self.walls.left.w = 1
	self.walls.left.tag = "wall"
	self.walls.left.h = self.play_area.h
	self.walls.right = {}
	self.walls.right.x = self.play_area.x + self.play_area.w
	self.walls.right.y = self.play_area.y
	self.walls.right.w = 1
	self.walls.right.h = self.play_area.h
	self.walls.right.tag = "wall"
	self.walls.top = {}
	self.walls.top.x = self.play_area.x
	self.walls.top.y = self.play_area.y
	self.walls.top.w = self.play_area.w
	self.walls.top.h = 1
	self.walls.top.tag = "wall"
	self.walls.bottom = {}
	self.walls.bottom.x = self.play_area.x
	self.walls.bottom.y = self.play_area.y + self.play_area.h
	self.walls.bottom.w = self.play_area.w
	self.walls.bottom.h = 1
	self.walls.bottom.tag = "wall"

	for k, v in pairs(self.walls) do
		self.world:add(v, v.x, v.y, v.w, v.h)
	end

	--add everything to bump
	self.world:add(self.player_1.pos, self.player_1.pos.x, self.player_1.pos.y, 5, 5)
	self.world:add(self.player_2.pos, self.player_2.pos.x, self.player_2.pos.y, 5, 5)

	-- WIN LOSE
	self.winner = nil
	self.counted_score = {p1 = false, p2 = false}

	--EXPLOSION  PARTICLE SYSTEM
	self.smoke = love.graphics.newImage("scenes/minigame_13/img/smoke.png")
	self.psystem =  love.graphics.newParticleSystem(self.smoke, 1000)
	self.psystem:setLinearAcceleration( -100, -100, 100, 100 )
	self.psystem:setSpin(-math.pi, math.pi)
	self.psystem:setSizes(1, 2, 0 )
	self.psystem:setParticleLifetime(1 )
	--self.psystem:setLinearDamping( 0, 1 )
	self.psystem:setEmissionRate(10)
	self.psystem:setInsertMode( "bottom" )
end

function minigame_13:update(dt)
	--INTRO
	if self.phase == "intro" then
		self.intro_timer = self.intro_timer + dt
		if self.intro_timer >= self.intro_timer_max then self.phase = "active" end
	end
	--music
	if self.player_1.pos.crashed == false and self.player_2.pos.crashed == false then
		self.bg_music:play()
	end
	--ACTIVE
	if self.phase == "active" then
		--PLAYERS
		if self.player_1.pos.crashed == false and self.player_2.pos.crashed == false then
			self.player_1:update(dt)
			self.player_2:update(dt)
		end


		--PLAYER 1
		self.player_1.actualX, self.player_1.actualY, p1_cols, self.player_1.lenght_collisions  = self.world:move(self.player_1.pos, self.player_1.pos.x, self.player_1.pos.y, self.player_Filter)
		self.player_1.y = self.player_1.actualY
		self.player_1.x = self.player_1.actualX


		self.player_2.actualX, self.player_2.actualY, p2_cols, self.player_2.lenght_collisions  = self.world:move(self.player_2.pos, self.player_2.pos.x, self.player_2.pos.y, self.player_Filter)
		self.player_2.y = self.player_2.actualY
		self.player_2.x = self.player_2.actualX

		--WINNING
		if (self.player_2.pos.crashed == true) then
			self.winner = "player_1"
			self.phase = "outro"
			self.win_string = "Player 2 CRASHED and Failed"
			if self.counted_score.p1 == false then
				global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
				self.counted_score.p1 = true
			end
		elseif (self.player_1.pos.crashed == true) then
			self.winner = "player_2"
			self.phase = "outro"
			self.win_string = "Player 2 Bested Their Opponent"
			if self.counted_score.p1 == false then
				global_score_counter.p2 = global_score_counter.p2 + 1 -- SCORE POINT
				self.counted_score.p1 = true
			end
		end
	end

	--outro
	if self.phase == "outro" then
		self.psystem:start()
		self.psystem:update(dt)
		self.outro_timer = self.outro_timer + dt
		if self.outro_timer >= self.outro_timer_max then gamestate.switch(scoreboard) end
	end

end -- END UPDATE

function minigame_13:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----

		--DRAW PLAY AREA
		love.graphics.setColor(0.7, 0.7, 0.7)
		love.graphics.rectangle("fill", self.play_area.x , self.play_area.y, self.play_area.w , self.play_area.h)
		love.graphics.setColor(0.5, 0.5, 0.5)
		--horizontal
		for x = self.play_area.x, self.play_area.x+self.play_area.w, 75 do
			love.graphics.line(x, self.play_area.y, x, self.play_area.y + self.play_area.h)
		end
		--vertical
		for y = self.play_area.x, self.play_area.y+self.play_area.h, 75 do
			love.graphics.line(self.play_area.x , y, self.play_area.x + self.play_area.w, y)
		end

		--PLAYER
		self.player_1:draw()
		self.player_2:draw()

		--INTRO
		if self.phase == "intro" then
			love.graphics.setFont(self.font)
			love.graphics.setColor(0,0,0)
			love.graphics.printf("Don't Touch ANYTHING or You'll Die", self.play_area.x + 2, global_height/2 - self.font:getHeight()/2 + 2, self.play_area.w, "center")
			love.graphics.setColor(1,0.1,0.3)
			love.graphics.printf("Don't Touch ANYTHING or You'll Die", self.play_area.x, global_height/2 - self.font:getHeight()/2, self.play_area.w, "center")
		end

		--OUTRO
		if self.phase == "outro" then
			--end explosion
			if self.winner == "player_1" then
				love.graphics.setColor(self.player_2.color)
				love.graphics.draw(self.psystem, self.player_2.x, self.player_2.y)
			elseif self.winner == "player_2" then
				love.graphics.setColor(self.player_1.color)
				love.graphics.draw(self.psystem, self.player_1.x, self.player_1.y)
			end

			love.graphics.setColor(0.5,0.5, 0.5)
			love.graphics.setFont(self.font)
			love.graphics.printf(self.win_string, 5, global_height/2 - self.font:getHeight()/2 + 5, global_width, "center")
			love.graphics.setColor(1,0.2,0.5)
			love.graphics.printf(self.win_string, 0, global_height/2 - self.font:getHeight()/2, global_width, "center")
			--FADE TO BLACK
				if self.outro_timer_max - self.outro_timer <=1 then
					self.psystem:stop()
					time_left = 1 - (self.outro_timer_max - self.outro_timer)
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

function minigame_13:keypressed(key)
	self.player_1:handle_press(key)
	self.player_2:handle_press(key)
end

function minigame_13:keyreleased(key)
	self.player_1:handle_release(key)
	self.player_2:handle_release(key)
end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_13:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_13:enter(previous)
	self:init()
end

function minigame_13:leave()
	--Clean Bump
	local items, len = self.world:getItems()
	for k, v in pairs(items) do
		self.world:remove(v)
		print("removed item "..tostring(v.tag).." from world")
	end
	local items, len = self.world:getItems()
	print(len.." items in self.world")
	self.world = nil

	--Stop audio
	love.audio.stop()
	-- Release love2d objects
	deep_release(self)
	collectgarbage("collect")
end

function minigame_13.player_Filter(item, other)
	if string.find(other.tag, "wall") ~= nil then -- if touched a wall
		minigame_13.bg_music:stop()
		minigame_13.crash_sound:play()
		item.crashed = true
		return "touch"

	-- if touched an obstacle wall from yourself
	elseif string.find(other.tag, "rectangle") ~= nil and (string.find(other.tag, item.player_number) ~= nil) then

		if item.player_number == 1 then --if player 1 then
			--if rectangle is very close don't collide
			if minigame_13.player_1.rectangle_holder[#minigame_13.player_1.rectangle_holder].index - other.index < 5 then
				return "cross"
			else
				item.crashed = true
				minigame_13.bg_music:stop()
				minigame_13.crash_sound:play()
				return "touch"
			end

		elseif item.player_number == 2 then --if player 2 then
			if minigame_13.player_2.rectangle_holder[#minigame_13.player_2.rectangle_holder].index - other.index < 5 then
				return "cross"
			else
				item.crashed = true
				minigame_13.bg_music:stop()
				minigame_13.crash_sound:play()
				return "touch"
			end
		end
	--if collide with other player obstacle
	elseif string.find(other.tag, "rectangle") ~= nil and (string.find(other.tag, item.player_number) == nil) then
		minigame_13.bg_music:stop()
		minigame_13.crash_sound:play()
		item.crashed = true
		return "touch"
	else
		return "cross"
	end
end
-- NEEDS TO BE AT THE VERY END
return minigame_13
