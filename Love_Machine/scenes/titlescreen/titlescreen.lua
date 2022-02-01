titlescreen = {}

function titlescreen:init()
	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

	--libs
	local tween  = require "libs.tween"

	local Profiler = require "entities.profiler"
	self.profiler = Profiler()

	self.bgm = love.audio.newSource( "scenes/splashscreen/sound/loop_intro_lofi.ogg", 'stream' )
	self.bgm:setLooping(true)
	self.bgm:setVolume(0.5)


		-- TITLESCREEN INTRO
	self.intro_timer = 0
	self.intro_time_max = 2

	self.sound = {}
	self.sound.boom1 = love.audio.newSource( "scenes/titlescreen/sound/intro_boom_1.ogg", "static" )
	self.sound.boom1:setLooping(false)
	self.sound.boom15 = love.audio.newSource( "scenes/titlescreen/sound/intro_boom_1.ogg", "static" )
	self.sound.boom15:setLooping(false)
	self.sound.boom15:setPitch(1.3)
	self.sound.boom2  = love.audio.newSource( "scenes/titlescreen/sound/intro_boom_2.ogg", "static" )
	self.sound.boom2:setLooping(false)

	-- FONT TITLE
	self.title_font_big = love.graphics.newFont("fonts/Molot.otf", 450)
	self.title_font_small = love.graphics.newFont("fonts/Molot.otf", 200)

	self.title_font_start_prompt = love.graphics.newFont("fonts/Molot.otf", 90)

	self.title_string = "The"
	self.title_alpha = 0
	self.title_tween = tween.new(self.intro_time_max + 1, self, {title_alpha=1}, 'inQuad')
	--TITLESCREEN PHASES either intro or active phase
	self.phase = "intro"

	-- Prompt to start

	self.green_button = {}
	self.green_button.img = love.graphics.newImage( "img/green_button.png")
	self.green_button.x = 900 - 250
	self.green_button.y = 540 - 150
	self.green_button.w = 500
	self.green_button.h = 500
	self.green_button.alpha = 0
	self.green_button.tween = tween.new(self.intro_time_max + 1, self.green_button, {alpha=1}, 'inQuad')

	-- Progress bar to start

	self.progress_bar = {}
	self.progress_bar.length = 0
	self.progress_bar.h = 25
	self.progress_bar.w = 0
	self.progress_bar.max_w = self.green_button.w
	self.progress_bar.hold_seconds = 1 -- in seconds
	self.progress_bar.timer = 0
	self.progress_bar.x = self.green_button.x
	self.progress_bar.y = self.green_button.y + self.green_button.h + 25 -- 25 is padding

	-- Prompt to QUIT

	self.red_button = {}
	self.red_button.img = love.graphics.newImage( "img/red_button.png")
	self.red_button.x = 250
	self.red_button.y = 540
	self.red_button.w = 100
	self.red_button.h = 100
	self.red_button.alpha = 0
	self.red_button.tween = tween.new(self.intro_time_max + 1, self.red_button, {alpha=1}, 'inQuad')

	-- Progress bar to QUIT

	self.quit_bar = {}
	self.quit_bar.length = 0
	self.quit_bar.h = 15
	self.quit_bar.w = 0
	self.quit_bar.max_w = self.red_button.w
	self.quit_bar.hold_seconds = 1 -- in seconds
	self.quit_bar.timer = 0
	self.quit_bar.x = self.red_button.x
	self.quit_bar.y = self.red_button.y + self.red_button.h + 25 -- 25 is padding

	-- Prompt to Single game
	self.blue_button = {}
	self.blue_button.img = love.graphics.newImage( "img/blue_button.png")
	self.blue_button.x = self.green_button.x + self.green_button.w + 100
	self.blue_button.y = self.green_button.y
	self.blue_button.w = 500
	self.blue_button.h = 500
	self.blue_button.alpha = 0
	self.blue_button.tween = tween.new(self.intro_time_max + 1, self.blue_button, {alpha=1}, 'inQuad')

	-- Progress single_start

	self.single_bar = {}
	self.single_bar.length = 0
	self.single_bar.h = 15
	self.single_bar.w = 0
	self.single_bar.max_w = self.blue_button.w
	self.single_bar.hold_seconds = 1 -- in seconds
	self.single_bar.timer = 0
	self.single_bar.x = self.blue_button.x
	self.single_bar.y = self.blue_button.y + self.blue_button.h + 25 -- 25 is padding

	self.outro = {}
	self.outro.started = false
	self.outro.timer = 0
	self.outro.time_max = 1
	self.outro.alpha = 0
end

function titlescreen:update(dt)
	--Profiler
	self.profiler:update(dt)

	--sound
	self.bgm:play()

	--Tweens
	self.title_tween:update(dt)
	self.green_button.tween:update(dt)
	self.red_button.tween:update(dt)
	self.blue_button.tween:update(dt)

	-- INTRO TO TITLESCREEN
	if self.phase == "intro" then
		if self.intro_timer <= self.intro_time_max then self.intro_timer = self.intro_timer + dt end

		if self.intro_timer <= self.intro_time_max/3 then
			self.title_string = "The"
			self.sound.boom15:play() -- Boom
		elseif self.intro_timer <= 2*self.intro_time_max/3 then
			self.title_string = "Love"
			self.sound.boom1:play() -- BOOM
		elseif self.intro_timer <= self.intro_time_max then
			self.title_string = "Machine"
			self.sound.boom2:play() --BAM
		else
			self.phase = "active"
		end
	end

	if self.phase == "active" then
		--START BAR TIMER
		if love.keyboard.isDown( "d" ) then
			self.progress_bar.timer = self.progress_bar.timer + dt
		else
			self.progress_bar.timer = 0
		end
		self.progress_bar.w = math.min( self.progress_bar.max_w * (self.progress_bar.timer/self.progress_bar.hold_seconds),  self.progress_bar.max_w)
		if self.progress_bar.timer >= self.progress_bar.hold_seconds then
			self.outro.started = true
			global_game_mode = "normal"
		end -- MOVES TO FIRST GAMES

		--START QUIT TIMER
		if love.keyboard.isDown( "s" ) then
			self.quit_bar.timer = self.quit_bar.timer + dt
		else
			self.quit_bar.timer = 0
		end
		self.quit_bar.w = math.min( self.quit_bar.max_w * (self.quit_bar.timer/self.quit_bar.hold_seconds),  self.quit_bar.max_w)
		if self.quit_bar.timer >= self.quit_bar.hold_seconds then love.event.quit() end -- QUIT

		--START SINGLE MODE
		if love.keyboard.isDown( "f" ) then
			self.single_bar.timer = self.single_bar.timer + dt
		else
			self.single_bar.timer = 0
		end
		self.single_bar.w = math.min( self.single_bar.max_w * (self.single_bar.timer/self.single_bar.hold_seconds),  self.single_bar.max_w)
		if self.single_bar.timer >= self.single_bar.hold_seconds then
			global_game_mode = "single"
			self.outro.started = true
		end
	end
	-- FADE TO BLACK BEFORE CHANGING TO MINIGAME 1
	if self.outro.started == true then
		self.outro.timer = self.outro.timer + dt
		self.outro.alpha = 1 * (self.outro.timer/self.outro.time_max)
		if self.outro.timer >= self.outro.time_max then
			if global_game_mode == "normal" then
				--Randomise order of the games
				global_reference_table = shuffle(global_reference_table)
				gamestate.switch(scoreboard)
			elseif global_game_mode == "single" then
				gamestate.switch(choose_game)
			end
		end
	end

end

function titlescreen:draw(dt)
	love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
		--INTRO PHASE
		if self.phase == "intro" then
			love.graphics.setColor(1, 1, 1)
			love.graphics.setFont(self.title_font_big)
			love.graphics.printf(self.title_string, 0, global_height/2 - (self.title_font_big:getHeight( )/2), global_width, 'center')
		--ACTIVE PHASE
		elseif self.phase == "active" then
			love.graphics.setFont(self.title_font_small)
			love.graphics.setColor( 1,1,1, self.title_alpha )
			love.graphics.printf("The Love Machine", 0, 0, global_width, 'center')

			-- DRAW GREEN BUTTON
			love.graphics.setColor( 1,1,1, self.green_button.alpha )
			love.graphics.draw(self.green_button.img, self.green_button.x, self.green_button.y)
			love.graphics.setFont(self.title_font_start_prompt)
			love.graphics.setColor( 0,0,0, self.green_button.alpha )
			love.graphics.printf("Party Game MODE", self.green_button.x + 97 , self.green_button.y + 77 , 340, 'center')
			love.graphics.setColor( 1,1,1, self.green_button.alpha )
			love.graphics.printf("Party Game MODE", self.green_button.x + 93, self.green_button.y + 73 , 340, 'center')

			--draw progress bar
			love.graphics.setColor( 1,1,1)
			love.graphics.rectangle( "fill", self.progress_bar.x, self.progress_bar.y, self.progress_bar.w, self.progress_bar.h, 0, 0, 20 )
			love.graphics.setColor( 0.2,1,0.2)
			love.graphics.rectangle( "fill", self.progress_bar.x, self.progress_bar.y - 2, self.progress_bar.w, self.progress_bar.h, 0, 0, 20 )

			-- DRAW RED BUTTON
			love.graphics.setColor( 1,1,1, self.red_button.alpha )
			love.graphics.draw(self.red_button.img, self.red_button.x, self.red_button.y, 0 , 0.2, 0.2)
			love.graphics.setFont(default_font)
			love.graphics.setColor( 0,0,0, self.red_button.alpha )
			love.graphics.printf("QUIT", self.red_button.x + 97/5 , self.red_button.y + self.red_button.h/3 + 5  , 340/5, 'center')
			love.graphics.setColor( 1,1,1, self.red_button.alpha )
			love.graphics.printf("QUIT", self.red_button.x + 93/5, self.red_button.y + self.red_button.h/3 , 340/5, 'center')

			-- DRAW BLUE BUTTON
			love.graphics.setColor( 1,1,1, self.blue_button.alpha )
			love.graphics.draw(self.blue_button.img, self.blue_button.x, self.blue_button.y, 0)
			love.graphics.setFont(self.title_font_start_prompt)
			love.graphics.setColor( 0,0,0, self.blue_button.alpha )
			love.graphics.printf("Single game MODE", self.blue_button.x + 97 , self.blue_button.y + 77 , 340, 'center')
			love.graphics.setColor( 1,1,1, self.blue_button.alpha )
			love.graphics.printf("Single Game MODE", self.blue_button.x + 93, self.blue_button.y + 73 , 340, 'center')

			--draw CHOOSE SINGLE GAME MODE bar
			love.graphics.setColor( 1,1,1)
			love.graphics.rectangle( "fill", self.single_bar.x, self.single_bar.y, self.single_bar.w, self.single_bar.h, 0, 0, 20 )
			love.graphics.setColor( 0.2,1,0.2)
			love.graphics.rectangle( "fill", self.single_bar.x, self.single_bar.y - 2, self.single_bar.w, self.single_bar.h, 0, 0, 20 )

			--draw QUIT bar
			love.graphics.setColor( 1,1,1)
			love.graphics.rectangle( "fill", self.quit_bar.x, self.quit_bar.y, self.quit_bar.w, self.quit_bar.h, 0, 0, 20 )
			love.graphics.setColor( 0.2,1,0.2)
			love.graphics.rectangle( "fill", self.quit_bar.x, self.quit_bar.y - 2, self.quit_bar.w, self.quit_bar.h, 0, 0, 20 )
		end

			--DRAW OUTRO
		if self.outro.started == true then
			love.graphics.setColor( 0,0,0, self.outro.alpha)
			love.graphics.rectangle( "fill",0,0,global_width, global_height)
		end


		----- FINISH DRAWING ----

	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.canvas, self.aspect_ratio.x, self.aspect_ratio.y, 0, self.aspect_ratio.scale, self.aspect_ratio.scale)

	draw_debug()
	self.profiler:draw()

end

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------


-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function titlescreen:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function titlescreen:leave()
	love.audio.stop( )
end

function titlescreen:enter(previous)
	--[[
	if previous == scoreboard or previous == choose_game then
		--reset all
		self.intro_timer = 0
		self.progress_bar.timer = 0

		scoreboard:init()
		global_current_game_index = 0
		global_difficulty = 1
		global_game_finished = 0
		global_score_counter = {p1 = 0, p2 = 0}
	end]]
	titlescreen:init()

end

-- NEEDS TO BE AT THE VERY END
return titlescreen
