minigame_10 = {}
function minigame_10:init()
	local Platforms = require "scenes.minigame_10.entities.platforms"
	local Player = require "scenes.minigame_10.entities.player"
	local bump = require 'libs.bump'
	local Camera = require "libs.hump.camera"
	--love.graphics.setBackgroundColor(0.5, 0.5, 0.8 )
	self.scene_type = "game"
	self.scene_name = "Go Up"

	self.font = love.graphics.newFont("fonts/pulang/Pulang.ttf", 115)

	self.phase = "intro"

	--TIMERS
	self.intro_timer = 0
	self.intro_timer_max = 5

	self.active_timer = 0
	self.active_timer_max = 5

	self.outro_timer = 0
	self.outro_timer_max = 5

	self.global_timer = 0

	--MUSIC
	self.bg_music = love.audio.newSource( "scenes/minigame_10/sound/platform_minigame.ogg", "stream")
	self.music_volume = 0.35
	self.bg_music:setVolume(self.music_volume)

	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

	--CAMERA
	self.camera = Camera(global_width/2, global_height/2, self.aspect_ratio.scale)

	--Plaftorms init
	self.platforms = Platforms()
	self.speed = 35

	--BUMP WORLD
	self.world = bump.newWorld(50)

	--Insert platforms in world
	for k, v in pairs(self.platforms.platform_holder) do
		self.world:add(v.left, v.left.x, v.left.y, v.left.w, v.left.h)
		self.world:add(v.right, v.right.x, v.right.y, v.right.w, v.right.h)
	end

	--Players
	local player_heights = 50
	local player_width = 10
	self.player_1 = Player(100, self.platforms.platform_holder[1].left.y - player_heights, 1, player_width, player_heights) --100 is player height
	self.player_2 = Player(global_width - 100 - player_width, self.player_1.y, 2, player_width, player_heights) -- 50 is player width

	self.world:add(self.player_1, self.player_1.x, self.player_1.y, self.player_1.w, self.player_1.h)
	self.world:add(self.player_2, self.player_2.x, self.player_2.y, self.player_2.w, self.player_2.h)

	--WIN LOSE
	self.winner = nil
	self.counted_score = {p1 = false, p2 = false}

end

function minigame_10:update(dt)
	--MUSIC
	self.bg_music:play()
	--INTRO TIMRS
	if self.phase == "intro" then
		self.intro_timer = 	self.intro_timer + dt
		if 	self.intro_timer >= self.intro_timer_max then self.phase = "active" end
	end

	if self.phase == "active" then
		self.active_timer = self.active_timer + dt
	end

	self.global_timer = self.global_timer + dt

	self.platforms:update(dt)
	self.player_1:update(dt)
	self.player_2:update(dt)

	--update_current platform
	--MOVE CAMERA
	if self.phase == "active" and self.active_timer > 2 then
		self.speed = self.speed + 5 *dt
		self.camera:move(0, -self.speed * dt)
	end


	--WORLD BUMP HANDLING
	--PLAYER 1
	self.player_1.actualX, self.player_1.actualY,  p1_cols, self.player_1.lenght_collisions  = self.world:move(self.player_1, self.player_1.x, self.player_1.y, self.player_1_Filter)
	self.player_1.y = self.player_1.actualY
	self.player_1.x = self.player_1.actualX

	self.player_2.actualX, self.player_2.actualY,  p2_cols, self.player_2.lenght_collisions  = self.world:move(self.player_2, self.player_2.x, self.player_2.y, self.player_1_Filter)
	self.player_2.y = self.player_2.actualY
	self.player_2.x =  self.player_2.actualX

	--COLISION resolution
	self.player_1:handle_collisions(p1_cols)
	self.player_2:handle_collisions(p2_cols)


	--WIN LOSE
	if self.phase == "active" then
		if self.player_1.y > self.camera.y + global_height/2 + 50 then
			self.winner = "player_2"
			self.win_string = "Player 1 is WEAK"
			if self.counted_score.p2 == false then
				global_score_counter.p2 = global_score_counter.p2 + 1 -- SCORE POINT
				self.counted_score.p2 = true
			end
			self.phase = "outro"
		elseif self.player_2.y > self.camera.y + global_height/2 + 50 then
			self.winner = "player_1"
			self.win_string = "Player 2 is WEAK"
			if self.counted_score.p1 == false then
				global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
				self.counted_score.p1 = true
			end
			self.phase = "outro"
		end
	end

	--outro
	if self.phase == "outro" then
		self.outro_timer = self.outro_timer + dt
		if self.outro_timer >= self.outro_timer_max then gamestate.switch(scoreboard) end
	end


end-- UPDATE END

function minigame_10:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		self.camera:attach()

		----- DRAW HERE ----

		--DRAW Platforms
		self.platforms:draw()

		--DRAW Players
		self.player_1:draw()
		self.player_2:draw()

		--INTRO
			if self.phase == "intro" then
				love.graphics.setFont(self.font)
				love.graphics.setColor(0.3,0.3,0.3)
				love.graphics.printf("Don't Fall to the bottom", 0+3, global_height/2 - self.font:getHeight()/2 + 3, global_width, "center")
				love.graphics.setColor(1, 0.5, 0.1, 1)
				love.graphics.printf("Don't Fall to the bottom", 0, global_height/2 - self.font:getHeight()/2, global_width, "center")
			end

		--OUTRO
		if self.phase == "outro" then
			love.graphics.setColor(0.5,0.5, 0.5)
			love.graphics.setFont(self.font)
			love.graphics.printf(self.win_string, 5,self.camera.y - self.font:getHeight()/2 + 5, global_width, "center")
			love.graphics.setColor(1,0.2,0.5)
			love.graphics.setFont(self.font)
			love.graphics.printf(self.win_string, 0,self.camera.y - self.font:getHeight()/2, global_width, "center")
			--FADE TO BLACK
				if self.outro_timer_max - self.outro_timer <=1 then
					time_left = 1 - (self.outro_timer_max - self.outro_timer)
					self.bg_music:setVolume(self.music_volume * (self.outro_timer_max - self.outro_timer)) --fade music away
					love.graphics.setColor(0,0,0, time_left)
					love.graphics.rectangle("fill", 0, 0 , global_width, global_height)
					love.graphics.setColor(1,1,1)
				end
		end

		----- FINISH DRAWING ----
	self.camera:detach()
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.canvas, self.aspect_ratio.x, self.aspect_ratio.y, 0)

	draw_debug()
	--additional Debug
	if global_debug then
		love.graphics.setFont(default_font)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(self.speed, 10, 190)
		love.graphics.print(self.camera.x, 10, 205)
		love.graphics.print(self.camera.y, 10, 220)
		love.graphics.print(self.phase, 10, 235)
	end
end

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_10:keypressed(key)
	if key == "d" then
		self.player_1.jump.release = false
		if self.player_1.sound_jump_played == false then
			local pitch = math.random(80, 120)/100
			self.player_1.sound_jump:setPitch(pitch)
			self.player_1.sound_jump:play()
			self.player_1.sound_jump_played = true
			self.player_1.sound_land_played = false
			--self.player_1.platform_that_started_the_jump_y =  self.platforms.platform_holder[self.player_1.last_platform].left.y
		end
	end
	if key == "k" then
		self.player_2.jump.release = false
		if self.player_2.sound_jump_played == false then
			local pitch = math.random(80, 120)/100
			self.player_2.sound_jump:setPitch(pitch)
			self.player_2.sound_jump:play()
			self.player_2.sound_jump_played = true
			self.player_2.sound_land_played = false
			--self.player_2.platform_that_started_the_jump_y =  self.platforms.platform_holder[self.player_2.last_platform].left.y
		end
	end

end

function minigame_10:keyreleased(key)
	if key == "d" then
		self.player_1.jump.release = true
	end

	if key == "k" then
		self.player_2.jump.release = true
	end
end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_10:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
	self.camera.scale = self.aspect_ratio.scale
end

function minigame_10:enter(previous)
	self:init()
end

function minigame_10:leave()
	--REMOVE ALL FROM WORLD
	local items, len = self.world:getItems()
	for k, v in pairs(items) do
		self.world:remove(v)
		print("removed item "..tostring(v.tag).." from world")
	end
	local items, len = self.world:getItems()
	print(len.." items in self.world")
	self.world = nil

	--STOP AUDIO
	love.audio.stop()
	--Deep Clean
	deep_release(self)
end

function minigame_10.player_1_Filter(item, other)
  	if other.tag == "floor"   then
				if other.physics == "solid" then
					return 'slide'
				else
					return "bounce"
				end
  	elseif other.tag == "player" then
			return "slide"
  	else
			return nil
  	end
end

-- NEEDS TO BE AT THE VERY END
return minigame_10
