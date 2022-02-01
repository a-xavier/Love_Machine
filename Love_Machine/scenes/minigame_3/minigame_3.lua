minigame_3 = {}

function minigame_3:init()
	local Player = require "scenes.minigame_3.entities.player_1"

	self.scene_type = "game"
	self.scene_name = "Basketball"

	self.font = love.graphics.newFont("fonts/basketball/Basketball.otf", 90)

	self.phase = "intro"

	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

	self.bg_music = love.audio.newSource( "scenes/minigame_3/sound/bbasetball.ogg", "stream")
	self.music_volume = 0.35
	self.bg_music:setVolume(self.music_volume)

	--player 1 area/world everything

	--PUT THAT IN OWN FILE LATER
	--padding 50 on each sides

	self.player_1 = Player(50, 200)
	self.player_1.world:setCallbacks( p1beginContact, p1endContact, p1preSolve, p1postSolve )

	self.player_2 = Player(global_width - self.player_1.area.w - 50, 200)
	self.player_2.world:setCallbacks( p2beginContact, p2endContact, p2preSolve, p2postSolve )

	-- All sounds
	self.sounds = {}
	self.sounds.horn = love.audio.newSource( "scenes/minigame_3/sound/horn.ogg", "static" )
	self.sounds.horn:setVolume(0.25)
	self.sounds.bounce = {love.audio.newSource( "scenes/minigame_3/sound/bounce_1.ogg", "static") ,
						love.audio.newSource( "scenes/minigame_3/sound/bounce_2.ogg", "static") ,
						love.audio.newSource( "scenes/minigame_3/sound/bounce_3.ogg", "static") ,
						love.audio.newSource( "scenes/minigame_3/sound/bounce_4.ogg", "static") ,
						love.audio.newSource( "scenes/minigame_3/sound/bounce_5.ogg", "static") }
	-- TIMERS
	self.intro_timer = 0
	self.intro_timer_max  = 3

	self.active_timer = 0
	self.active_timer_max  = 45

	self.outro_timer = 0
	self.outro_timer_max  = 3

	--WINNER

	self.winner = nil
	self.counted_score = {p1 = false, p2 = false}

end

function minigame_3:update(dt)

self.bg_music:play()

-- UPDATE TIMERS
if self.phase == "intro" then
	self.intro_timer = self.intro_timer + dt
	if self.intro_timer >= self.intro_timer_max then self.phase = "active" end

end
if self.phase == "active" then
	self.active_timer = self.active_timer + dt
	if self.active_timer >= self.active_timer_max then
		self.phase = "outro"
		--decide winner
		if self.player_1.score > self.player_2.score then
			self.winner = "player_1"
		elseif self.player_1.score < self.player_2.score then
			self.winner = "player_2"
		elseif self.player_1.score == self.player_2.score then
			self.winner = "draw"
		end

	end
end

if self.phase == "outro" then
	self.outro_timer = self.outro_timer + dt
	if self.outro_timer >= self.outro_timer_max then gamestate.switch(scoreboard) end
end



-- ACTIVE PHASE
	if self.phase == "active" then
		--update active timer

		--Player 1 game
		self.player_1:update(dt)
		--Player 1 controls
		if love.keyboard.isDown("s") then self.player_1.arrow.angle = self.player_1.arrow.angle - 2 * dt  end
		if love.keyboard.isDown("f") then self.player_1.arrow.angle = self.player_1.arrow.angle + 2 * dt  end
		if love.keyboard.isDown("d") then self.player_1.arrow.outer_radius = self.player_1.arrow.outer_radius + 50 * dt end

		--Player 2 game
		self.player_2:update(dt)
		--Player 2 controls
		if love.keyboard.isDown("j") then self.player_2.arrow.angle = self.player_2.arrow.angle - 2 * dt  end
		if love.keyboard.isDown("l") then self.player_2.arrow.angle = self.player_2.arrow.angle + 2 * dt  end
		if love.keyboard.isDown("k") then self.player_2.arrow.outer_radius = self.player_2.arrow.outer_radius + 50 * dt end
	end


end

function minigame_3:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----

	--Draw player 1 area --put in player 1 file later
	self.player_1:draw()
	self.player_2:draw()

	--INTRO DRAWING
	if self.phase == "intro" then
		local time_left = math.ceil(self.intro_timer_max - self.intro_timer)
		love.graphics.printf("Shoot the Hoops in: "..tostring(time_left), 0,0, global_width, "center")
	end

	--ACTIVE
	if self.phase == "active" then
		local time_left = math.ceil(self.active_timer_max - self.active_timer)
		love.graphics.printf(tostring(time_left), 0,0, global_width, "center")
	end

	-- OUTRO
	if self.phase == "outro" then
		--outro and fade to black
		if self.outro_timer_max - self.outro_timer <=1 then
			local time_left = 1 - (self.outro_timer_max - self.outro_timer)
			self.bg_music:setVolume(self.music_volume * (self.outro_timer_max - self.outro_timer)) --fade music away
			love.graphics.setColor(0,0,0, time_left)
			love.graphics.rectangle("fill", 0, 0 , global_width, global_height)
			love.graphics.setColor(1,1,1)
		end
		love.graphics.setColor(1,1,1)
		if self.winner == "player_1" then
			love.graphics.printf("Player 1 WINS", 0,0, global_width, "center")
			if self.counted_score.p1 == false then
				global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
				self.counted_score.p1 = true
			end
		elseif self.winner == "player_2" then
			love.graphics.printf("Player 2 WINS", 0,0, global_width, "center")
			if self.counted_score.p2 == false then
				global_score_counter.p2 = global_score_counter.p2 + 1 -- SCORE POINT
				self.counted_score.p2 = true
			end
		elseif self.winner == "draw" then
			love.graphics.printf("DRAW", 0,0, global_width, "center")
			if (self.counted_score.p1 == false) and (self.counted_score.p2 == false) then
				global_score_counter.p1 = global_score_counter.p1  + 1
				global_score_counter.p2 = global_score_counter.p2  + 1
				self.counted_score.p1 = true
				self.counted_score.p2 = true
			end
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

function minigame_3:keypressed(key)
	if key == "space" then
		self.player_1:reset_ball()
		self.player_2:reset_ball()
	end

end

function minigame_3:keyreleased(key)
	if (key == "d") and (self.player_1.ball.is_at_starting_position == true) then
		self.player_1.world:setGravity(0, self.player_1.ball.normal_gravity)
		self.player_1.ball.body:setLinearVelocity((self.player_1.arrow.x2 - self.player_1.arrow.x1) * self.player_1.arrow.force, (self.player_1.arrow.y2 - self.player_1.arrow.y1) * self.player_1.arrow.force)
		self.player_1.arrow.outer_radius = self.player_1.arrow.outer_radius_default
		self.player_1.ball.is_at_starting_position = false
	end

	if (key == "k") and (self.player_2.ball.is_at_starting_position == true) then
		self.player_2.world:setGravity(0, self.player_2.ball.normal_gravity)
		self.player_2.ball.body:setLinearVelocity((self.player_2.arrow.x2 - self.player_2.arrow.x1) * self.player_2.arrow.force, (self.player_2.arrow.y2 - self.player_2.arrow.y1) * self.player_2.arrow.force)
		self.player_2.arrow.outer_radius = self.player_2.arrow.outer_radius_default
		self.player_2.ball.is_at_starting_position = false
	end

end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_3:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_3:enter(previous)
	self:init()
end

function minigame_3:leave()
	love.audio.stop()
	deep_release(self)
end

function p1endContact(a, b, contact)
	if (a:getUserData() == "ground") or (b:getUserData() == "ground") then
		minigame_3.player_1.ball.ground_bounce = minigame_3.player_1.ball.ground_bounce + 1
	end

	if a and b then
	local sound_index = math.random(1, 5)
		minigame_3.sounds.bounce[sound_index]:play()
	end
end

function p2endContact(a, b, contact)
	if (a:getUserData() == "ground") or (b:getUserData() == "ground") then
		minigame_3.player_2.ball.ground_bounce = minigame_3.player_2.ball.ground_bounce + 1
	end
	if a and b then
	local sound_index = math.random(1, 5)
	local sound_pitch = math.random(80, 120)/100
		minigame_3.sounds.bounce[sound_index]:setPitch(sound_pitch)
		minigame_3.sounds.bounce[sound_index]:play()
	end
end

-- NEEDS TO BE AT THE VERY END
return minigame_3
