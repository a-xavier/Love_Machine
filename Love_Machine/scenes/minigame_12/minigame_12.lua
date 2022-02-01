minigame_12 = {}

function minigame_12:init()
	local Paddle = require "scenes.minigame_12.entities.paddle"
	self.scene_type = "game"
	self.scene_name = "Definitely not Pong"

	self.font = love.graphics.newFont("fonts/roboto/Roboto-Light.ttf", 250)
	self.font_small = love.graphics.newFont("fonts/roboto/Roboto-Light.ttf", 50)
	self.font_medium = love.graphics.newFont("fonts/roboto/Roboto-Light.ttf", 150)

	self.phase = "intro"
	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

	--PLAY AREA
	self.play_area = {}
	self.play_area.w = global_width / 2
	self.play_area.h = global_height - 25
	self.play_area.x = global_width / 4
	self.play_area.y = 12.5

	--Physics world
	love.physics.setMeter(64)
	self.world = love.physics.newWorld(0, 0, true)
	self.world:setCallbacks( beginContact, endContact, preSolve, postSolve )

	--WALLS
	self.walls = {}
	self.walls.left = {}
	self.walls.left.body = love.physics.newBody( self.world, self.play_area.x, self.play_area.y, "static" )
	self.walls.left.shape = love.physics.newEdgeShape( 0,0, 0, self.play_area.h )
	self.walls.left.fixture =  love.physics.newFixture(self.walls.left.body , self.walls.left.shape )
	self.walls.left.fixture:setRestitution( 1 )
	self.walls.left.fixture:setUserData({"wall", "left"})

	self.walls.right = {}
	self.walls.right.body = love.physics.newBody( self.world, self.play_area.x + self.play_area.w , self.play_area.y, "static" )
	self.walls.right.shape = love.physics.newEdgeShape( 0,0, 0, self.play_area.h )
	self.walls.right.fixture =  love.physics.newFixture(self.walls.right.body , self.walls.right.shape )
	self.walls.right.fixture:setRestitution( 1 )
	self.walls.right.fixture:setUserData({"wall", "right"})

	-- Paddles
	self.player_1 = Paddle(global_width/2, 50, 1)
	self.player_2 = Paddle(global_width/2, global_height - self.player_1.h - 30, 2)

	--ball
	self.ball = {}
	self.ball.r = 25
	self.ball.initial_x = global_width/2
	self.ball.initial_y = global_height/2
	self.ball.body = love.physics.newBody( self.world, global_width/2, global_height/2, "dynamic" )
	self.ball.shape = love.physics.newCircleShape( self.ball.r )
	self.ball.fixture = love.physics.newFixture(self.ball.body, self.ball.shape)
	self.ball.fixture:setRestitution( 1 )
	self.ball.fixture:setUserData( "ball" )
	self.ball.body:setMass(0.01)
	self.ball.timer = 0
	self.ball.timer_max = 2
	self.ball.original_speed = 750
	self.ball.speed = 750

	--ARROW
	--arrow when pressing stuff
	self.arrow = {}
	self.arrow.x1 = self.ball.initial_x
	self.arrow.y1 = self.ball.initial_y
	self.arrow.x2 = 0
	self.arrow.y2 = 0
	self.arrow.force = 10
	self.arrow.angle = 0
	self.arrow.outer_radius_default= 50
	self.arrow.outer_radius = 100
	self.tween_arrow = nil
	self:reset_ball()

	--Scores

	self.scores = {p1 = 0, p2 = 0}

	--Sounds
	self.wall_sound = love.audio.newSource( "scenes/minigame_12/sound/wall_hihat.ogg", "static" )
	self.wall_sound:setVolume(0.5)
	self.p1_sound = love.audio.newSource( "scenes/minigame_12/sound/p1_kick.ogg", "static" )
	self.p1_sound:setVolume(0.5)
	self.p2_sound = love.audio.newSource( "scenes/minigame_12/sound/p2_snare.ogg", "static" )
	self.p2_sound:setVolume(0.5)
	self.crash = love.audio.newSource( "scenes/minigame_12/sound/crash.ogg", "static" )
	self.intro_sound = love.audio.newSource( "scenes/minigame_12/sound/intro_sound.ogg", "static" )
	self.intro_sound:setLooping(false)
	self.intro_sound:setVolume(0.5)
	self.sound_layer = {love.audio.newSource( "scenes/minigame_12/sound/part_1.ogg", "static" ),
						love.audio.newSource( "scenes/minigame_12/sound/part_2.ogg", "static" ),
						love.audio.newSource( "scenes/minigame_12/sound/part_3.ogg", "static" ),
						love.audio.newSource( "scenes/minigame_12/sound/part_4.ogg", "static" )}
	self.current_sound = 1
	for _, v in pairs(self.sound_layer) do
		v:setVolume(0.6)
	end

	--TIMERS
	self.intro_timer = 0
	self.intro_timer_max = 3

	self.active_timer = 0
	self.active_timer_max = 5

	self.outro_timer = 0
	self.outro_timer_max = 5

	self.global_timer = 0


	--WINNING
	self.max_score = 5
	self.winner = nil
	self.counted_score = {p1 = false, p2 = false}
end

function minigame_12:update(dt)

	--INTRO
	if self.phase == "intro" then
		self.intro_sound:play()
		self.intro_timer = self.intro_timer + dt
		if self.intro_timer >= self.intro_timer_max then self.phase = "active" end
	end

	--ACTIVE
	if self.phase == "active" then
		--Paddles
		self.player_1:update(dt)
		self.player_2:update(dt)

		--WORLD UPDATE
		self.world:update(dt)

		--Launch ball when at the center
		self:launch_ball(dt)

		--More speed with time
		self.ball.speed = self.ball.speed + dt * 35

		--Scoring
		if self.ball.body:getY() <= -50 then
			self.scores.p2 = self.scores.p2 + 1
			self.crash:play()
			self:reset_ball()
			for _, v in pairs(self.sound_layer) do
				v:stop()
			end
		elseif self.ball.body:getY() >= global_height + 50 then
			self.scores.p1 = self.scores.p1 + 1
			self.crash:play()
			self:reset_ball()
			for _, v in pairs(self.sound_layer) do
				v:stop()
			end
		end

		--WINNING
		if (self.scores.p1 == self.max_score) then
			self.winner = "player_1"
			self.phase = "outro"
			self.win_string = "Player 1 is rather good."
			if self.counted_score.p1 == false then
				global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
				self.counted_score.p1 = true
			end
		elseif (self.scores.p2 == self.max_score) then
			self.winner = "player_2"
			self.phase = "outro"
			self.win_string = "Player 2 excelled at winning."
			if self.counted_score.p1 == false then
				global_score_counter.p2 = global_score_counter.p2 + 1 -- SCORE POINT
				self.counted_score.p1 = true
			end
		end
	end --END ACTIVE

	--outro
	if self.phase == "outro" then
		self.outro_timer = self.outro_timer + dt
		if self.outro_timer >= self.outro_timer_max then gamestate.switch(scoreboard) end
	end
end

function minigame_12:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
		--play area
		love.graphics.setColor(0.5, 0.5, 0.5)
		love.graphics.rectangle("fill", self.play_area.x, self.play_area.y, self.play_area.w, self.play_area.h)

		--WALLS
		love.graphics.setColor(1,0,0)
		love.graphics.line(self.walls.left.body:getWorldPoints(self.walls.left.shape:getPoints()))
		love.graphics.line(self.walls.right.body:getWorldPoints(self.walls.right.shape:getPoints()))

		--ball
		love.graphics.setColor(0,1,0)
		love.graphics.circle("fill", self.ball.body:getX(), self.ball.body:getY(), self.ball.r)

		-- Paddles
		self.player_1:draw()
		self.player_2:draw()

		if self.ball.timer ~= 0 then
			love.graphics.setColor(0,0,0)
			love.graphics.arrow(self.arrow.x1, self.arrow.y1, self.arrow.x2, self.arrow.y2, 15, 0.35)
		end

		-- SCORES
		if self.phase == "active" then
			love.graphics.setColor(1, 1, 1)
			love.graphics.setFont(self.font)
			love.graphics.printf("P1", 0, 0, self.play_area.x, "center")
			love.graphics.printf(self.scores.p1, 0, self.font:getHeight(), self.play_area.x, "center")
			love.graphics.printf("P2", self.play_area.x + self.play_area.w, 0, self.play_area.x , "center")
			love.graphics.printf(self.scores.p2, self.play_area.x + self.play_area.w, self.font:getHeight(), self.play_area.x , "center")
		end
		--INTRO
		if self.phase == "intro" then
			love.graphics.setFont(self.font)
			love.graphics.setColor(0, 0, 0)
			love.graphics.printf("This is not a Pong", 2, global_height/2 - 2* self.font:getHeight()/2+2, global_width, "center")
			love.graphics.setColor(1, 1, 1)
			love.graphics.printf("This is not a Pong", 0, global_height/2 - 2* self.font:getHeight()/2, global_width, "center")

			love.graphics.setFont(self.font_small)
			love.graphics.setColor(0, 0, 0)
			love.graphics.printf("P1", 2, self.player_1.y + 50 + 2, global_width, "center")
			love.graphics.printf("P2", 2, self.player_2.y - self.font_small:getHeight() - 50 + 2, global_width, "center")
			love.graphics.setColor(1, 0.5, 0)
			love.graphics.printf("P1", 0, self.player_1.y + 50, global_width, "center")
			love.graphics.printf("P2", 0, self.player_2.y - self.font_small:getHeight() - 50, global_width, "center")
		end
		--OUTRO
		if self.phase == "outro" then
			love.graphics.setColor(0.5,0.5, 0.5)
			love.graphics.setFont(self.font_medium)
			love.graphics.printf(self.win_string, 5, global_height/2 - self.font_small:getHeight()/2 + 5, global_width, "center")
			love.graphics.setColor(1,0.2,0.5)
			love.graphics.printf(self.win_string, 0, global_height/2 - self.font_small:getHeight()/2, global_width, "center")
			--FADE TO BLACK
				if self.outro_timer_max - self.outro_timer <=1 then
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
	--ADDITIONAL DEBUG
	if global_debug then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(default_font)
		love.graphics.print("P1 x = "..tostring(self.player_1.body:getX()), 10, 150)
		love.graphics.print("Ball Speed = "..tostring(self.ball.speed), 10, 165)
	end
end

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_12:keypressed(key)

end

function minigame_12:keyreleased(key)
	if key == "space" then
		self:reset_ball()
	end
end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function minigame_12:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function minigame_12:enter(previous)
	self:init()
end

function minigame_12:leave()
	--Stop audio
	love.audio.stop()
	-- Release love2d objects
	deep_release(self)
end

function minigame_12:launch_ball(dt)
	if (self.ball.body:getX() == self.ball.initial_x) and (self.ball.body:getY() == self.ball.initial_y) then
		self.ball.timer = self.ball.timer + dt
		--outer point
		self.arrow.x2 = self.ball.initial_x + math.cos(self.arrow.angle) * (self.ball.r + self.arrow.outer_radius)
		self.arrow.y2 = self.ball.initial_y + math.sin(self.arrow.angle) * (self.ball.r + self.arrow.outer_radius)
		self.arrow.length = distance_2_points(self.arrow.x1, self.arrow.y1, self.arrow.x2, self.arrow.y2)

		if self.tween_arrow  ~= nil then
			self.tween_arrow:update(dt)
			if self.tween_arrow:update(dt) == true then
				self.tween_arrow = nil
			end
		end

		-- ARROW SPINNING
		if self.ball.timer >=  self.ball.timer_max then
			self.ball.timer = 0
			self.ball.body:setLinearVelocity((self.arrow.x2 - self.arrow.x1) * 7.5 , (self.arrow.y2 - self.arrow.y1) * 7.5)
		end
	end

end

function minigame_12:reset_ball()
	self.ball.body:setX(self.ball.initial_x)
	self.ball.body:setY(self.ball.initial_y)
	self.ball.body:setLinearVelocity(0,0)
	self.ball.body:setAngularVelocity(0)
	self.ball.speed = self.ball.original_speed
	math.randomseed(os.time())
	local new_angle =  math.random(-3*math.pi, 3*math.pi)
	while new_angle%math.pi == 0 do
		new_angle =  math.random(-3*math.pi, 3*math.pi)
		print("NEW ANGLE : "..tostring(new_angle).." modulo 0: "..tostring(new_angle%math.pi))
	end

	self.tween_arrow = tween.new(self.ball.timer_max-0.5, self.arrow, {angle = new_angle}, "inOutBack")

end

function beginContact(a, b, coll)
	if a:getUserData()[1] == "paddle" and b:getUserData() == "ball" then
		local vx, vy = b:getBody():getLinearVelocity( )
		a:getBody():setLinearVelocity(0, - vy/1.95)

		-- CHANGE LAYER SOUND
		if a:getUserData()[2] == 1 then
			for _, v in pairs(minigame_12.sound_layer) do
				v:stop()
			end
			--not random notes but one after the other
			minigame_12.sound_layer[minigame_12.current_sound]:play()
			minigame_12.current_sound = minigame_12.current_sound + 1
			if minigame_12.current_sound > #minigame_12.sound_layer then
				minigame_12.current_sound = 1
			end
		end

		if vy < 0 then
			minigame_12.p1_sound:play()
		else
			minigame_12.p2_sound:play()
		end
	end

	if a:getUserData()[1] == "wall" and b:getUserData() == "ball" then
		local vx, vy = b:getBody():getLinearVelocity( )
		b:getBody():setLinearVelocity(-vx, vy)
		minigame_12.wall_sound:play()
	end
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
	if a:getUserData()[1] == "paddle" and b:getUserData() == "ball" then
		local vx, vy = b:getBody():getLinearVelocity( )
		if vy > 0 then
			speed = minigame_12.ball.speed
		else
			speed = -minigame_12.ball.speed
		end
		b:getBody():setLinearVelocity(vx, speed)
	end
end

function love.graphics.arrow(x1, y1, x2, y2, arrlen, angle)
	love.graphics.line(x1, y1, x2, y2)
	local a = math.atan2(y1 - y2, x1 - x2)
	love.graphics.line(x2, y2, x2 + arrlen * math.cos(a + angle), y2 + arrlen * math.sin(a + angle))
	love.graphics.line(x2, y2, x2 + arrlen * math.cos(a - angle), y2 + arrlen * math.sin(a - angle))
end

-- NEEDS TO BE AT THE VERY END
return minigame_12
