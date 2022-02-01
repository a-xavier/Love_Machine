choose_game = {}

function choose_game:init()
	self.scene_type = "Game Chooser"
	self.scene_name = "Game Chooser"

	local Button = require "entities.button_icon"

	self.bgm = love.audio.newSource( "scenes/minigame_9/sound/cheapos.ogg", 'stream' )
	self.bgm:setLooping(true)
	self.bgm:setVolume(0.5)

	self.swish_left = love.audio.newSource( "scenes/choose_game/sound/swish_left.ogg", 'stream' )
	self.swish_left:setVolume(0.25)
	self.swish_right = love.audio.newSource( "scenes/choose_game/sound/swish_right.ogg", 'stream' )
	self.swish_right:setVolume(0.25)

	self.font_title = love.graphics.newFont("fonts/roboto/Roboto-Bold.ttf", 150)
	self.font_text = love.graphics.newFont("fonts/roboto/Roboto-Light.ttf", 50)
	local GameDescription =  require "scenes.choose_game.entities.game_description"
	self.game_descriptions = GameDescription()

	self.phase = "intro"
	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

	self.current_game_index = 1
	--Tween holder
	self.tween_holder = {}	--

	--game cards
	self.game_card_holder = {}
	for i = 0, #self.game_descriptions.games-1, 1 do
		local card = {}
		card.img = {}
		card.img.x = i * global_width + 15
		card.img.y = 15
		card.img.h = global_height - 30
		card.img.w = card.img.h

		card.text_x = card.img.x + card.img.w + 15
		card.text_w = global_width - card.img.w - 30

		table.insert(self.game_card_holder, card)
	end

	local button_width = self.game_card_holder[1].text_w/3 - 30

	--BUTTONS
	self.red_button = Button(self.game_card_holder[1].img.x + self.game_card_holder[1].img.w + 10, global_height - button_width - 15, button_width, button_width, "red",
							self.game_descriptions.games[1].left)
	self.green_button = Button(self.game_card_holder[1].img.x + self.game_card_holder[1].img.w + button_width + 20 , global_height - button_width - 15, button_width, button_width, "green",
							self.game_descriptions.games[1].up)
	self.blue_button = Button(self.game_card_holder[1].img.x + self.game_card_holder[1].img.w  + 2* button_width + 30 , global_height - button_width - 15, button_width, button_width, "blue",
							self.game_descriptions.games[1].right)

	local button_width = 100

	--BUTTONS
	self.red_button_command = Button(10, global_height - button_width - 10, button_width, button_width, "red", "HOLD TO")
	self.red_button_command.original_x = self.red_button_command.x
	self.red_button_command.original_y = self.red_button_command.y
	self.blue_button_command = Button(100, global_height - button_width - 10, button_width, button_width, "blue", "GO BACK")
	self.blue_button_command.original_x = self.blue_button_command.x
	self.blue_button_command.original_y = self.blue_button_command.y
	self.green_button_command = Button(230, global_height - button_width - 10, button_width, button_width, "green", "START")
	self.green_button_command.original_x = self.green_button_command.x
	self.green_button_command.original_y = self.green_button_command.y

	self.back_timer = 0
	self.back_timer_max = 2
	self.start_timer = 0
	self.start_timer_max = 2
end


function choose_game:update(dt)

	--SOUND
	self.bgm:play()

	self.red_button_command:update(dt)
	self.blue_button_command:update(dt)
	self.green_button_command:update(dt)

	for k, v in pairs(self.tween_holder) do
		v:update(dt)
		if v:update(dt) == true then table.remove(self.tween_holder, k) end

		if k == 1 then --FADE TRANSPARENT
			if v.clock < 0.49 then
				self.red_button.alpha = 1 - (v.clock/0.25)
				self.blue_button.alpha = 1 - (v.clock/0.25)
				self.green_button.alpha = 1 - (v.clock/0.25)
			else
				self.red_button.label = self.game_descriptions.games[self.current_game_index].left
				self.green_button.label = self.game_descriptions.games[self.current_game_index].up
				self.blue_button.label = self.game_descriptions.games[self.current_game_index].right

			end
		end
	end

	if next(self.tween_holder) == nil then
		self.red_button.alpha = 1
		self.blue_button.alpha = 1
		self.green_button.alpha = 1

		self.swish_right:stop()
		self.swish_left:stop()
	end

	--GO BACK
	if love.keyboard.isDown("s") and love.keyboard.isDown("f") then
		self.back_timer = self.back_timer + dt
		self.red_button_command.x = self.red_button_command.x + math.random(-1, 1)
		self.red_button_command.y = self.red_button_command.y + math.random(-1, 1)
		self.blue_button_command.x = self.blue_button_command.x + math.random(-1, 1)
		self.blue_button_command.y = self.blue_button_command.y + math.random(-1, 1)
		if self.back_timer >= self.back_timer_max then gamestate.switch(titlescreen) end
	else
		self.back_timer = 0
		self.red_button_command.x = self.red_button_command.original_x
		self.red_button_command.y = self.red_button_command.original_y
		self.blue_button_command.x = self.blue_button_command.original_x
		self.blue_button_command.y = self.blue_button_command.original_y
	end
	--start
	if love.keyboard.isDown("d") then
		self.start_timer = self.start_timer + dt
		self.green_button_command.x = self.green_button_command.x + math.random(-2, 2)
		self.green_button_command.y = self.green_button_command.y + math.random(-2, 2)
		global_current_game_index = self.current_game_index
		if self.start_timer >= self.start_timer_max then gamestate.switch(scoreboard) end
	else
		self.start_timer = 0
		self.green_button_command.x = self.green_button_command.original_x
		self.green_button_command.y = self.green_button_command.original_y
	end

end

function choose_game:draw(dt)
love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
		for k, v in pairs(self.game_card_holder) do
			local current_game = self.game_descriptions.games[k]
			--placeholder image
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("fill", v.img.x, v.img.y, v.img.w, v.img.h)

			--title
			love.graphics.setFont(self.font_title)
			love.graphics.setColor(1,1,1)
			love.graphics.printf(tostring(current_game.name), v.text_x + 3, 0 + 3, v.text_w, "center")
			love.graphics.setColor(1, 0.5, 0.5, 1)
			love.graphics.printf(tostring(current_game.name), v.text_x, 0, v.text_w, "center")
			love.graphics.setColor(1, 0.5, 0.5, 1)
			love.graphics.rectangle("fill", v.text_x, 15, 10,10)
			local width, wrappedtext = self.font_title:getWrap( current_game.name, v.text_w )
			local y_description = #wrappedtext * self.font_title:getHeight()
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.setFont(self.font_text)
			love.graphics.printf(current_game.description, v.text_x, y_description, v.text_w, "center")
			local width, wrappedtext = self.font_text:getWrap( current_game.name, v.text_w )
			local y_text = #wrappedtext * self.font_text:getHeight()
		end

		--Buttons
		self.red_button:draw()
		self.green_button:draw()
		self.blue_button:draw()
		if next(self.tween_holder) == nil then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.setFont(self.font_text)
			love.graphics.print("Game Controls", self.red_button.x, self.red_button.y - self.font_text:getHeight() - 10)
		end

		--COmmands
		self.red_button_command:draw()
		self.green_button_command:draw()
		self.blue_button_command:draw()

		----- FINISH DRAWING ----
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.canvas, self.aspect_ratio.x, self.aspect_ratio.y, 0, self.aspect_ratio.scale, self.aspect_ratio.scale)

	draw_debug()
	if global_debug then
		love.graphics.setColor(0.5, 0.5, 0.5)
		love.graphics.setFont(default_font)
		love.graphics.print(self.current_game_index,10, 150)
	end
end

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------

function choose_game:keypressed(key)

end

function choose_game:keyreleased(key)
	if key == "f"  and next(self.tween_holder) == nil and self.current_game_index < #self.game_card_holder then --move right
		for k, v in pairs(self.game_card_holder) do
			table.insert(self.tween_holder,	tween.new(1, v.img, {x = v.img.x - global_width}, "inOutQuart"))
			table.insert(self.tween_holder,	tween.new(1, v, {text_x = v.text_x - global_width}, "inOutQuart"))
		end
		self.current_game_index = self.current_game_index + 1
		self.swish_right:play()
	end

	if key == "s" and next(self.tween_holder) == nil and self.current_game_index > 1 then --move left
		for k, v in pairs(self.game_card_holder) do
			table.insert(self.tween_holder,	tween.new(1, v.img, {x = v.img.x + global_width}, "inOutQuart"))
			table.insert(self.tween_holder,	tween.new(1, v, {text_x = v.text_x + global_width}, "inOutQuart"))
		end
		self.current_game_index = self.current_game_index - 1
		self.swish_left:play()
	end


end

-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function choose_game:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function choose_game:enter(previous)
	global_game_mode = "single" --set to single just for test purpose
	print(global_game_mode)
end

function choose_game:leave()
	--Stop audio
	love.audio.stop()
	-- Release love2d objects
	--deep_release(self)
end

-- NEEDS TO BE AT THE VERY END
return choose_game
