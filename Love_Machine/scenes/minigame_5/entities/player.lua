Player = Class{}
function Player:init(x, y, player)
	local ButtonIcon = require "entities.button_icon"
	self.tween  = require "libs.tween"
	self.area = {}
	self.area.x = x
	self.area.y = y
	self.area.w = (global_width/2) - 200
	self.area.h = global_height - self.area.y - 200
	self.player_number = player

	if self.player_number == 1 then
		self.flip = 1
	elseif self.player_number == 2 then
		self.flip = -1
	end

	self.img = {}
	self.img.spritesheet = love.graphics.newImage( "scenes/minigame_5/img/player.png")
	self.img.quads = {love.graphics.newQuad(0, 0, self.area.w, self.area.h, 2280, 627 ),
				 love.graphics.newQuad(self.area.w, 0, self.area.w, self.area.h,  2280, 627 ),
				 love.graphics.newQuad(2*self.area.w, 0, self.area.w, self.area.h,  2280, 627 )}
	self.img.current_quad = 1
	self.img.timer = self.player_number * 2
	 if self.player_number == 1 then self.img.speed = 1 else self.img.speed = 1.05 end


	--Game tags
	self.choice = nil
	self.choice_animations_done = true
	self.buttons_hidden = false
	self.choice_animations_tweens_generated = false
	self.choice_animations_tweens = {}
	self.choice_animations_timer_max = 0.75

	self:initialise_buttons()

	--IMAGE R P S
	self.hands = {}
	self.hands["rock"] = love.graphics.newImage( "scenes/minigame_5/img/rock.png")
	self.hands["paper"] = love.graphics.newImage( "scenes/minigame_5/img/paper.png")
	self.hands["scissors"] = love.graphics.newImage( "scenes/minigame_5/img/scissors.png")

	--STAR TO SHOW SCORE
	self.star_img = love.graphics.newImage("scenes/minigame_5/img/star.png")

end

function Player:initialise_buttons()
--button showing
	self.buttons = {}
	collectgarbage("collect")
	local target_width = global_height - self.area.y - self.area.h - 10
	local x_padding = (self.area.w - 3*target_width)/2
	self.buttons.green = ButtonIcon(self.area.x, self.area.y + self.area.h + 10, target_width , target_width,  "green", "ROCK")
	self.buttons.red = ButtonIcon(self.area.x + x_padding + target_width, self.area.y + self.area.h + 10, target_width , target_width,  "red", "PAPER")
	self.buttons.blue = ButtonIcon(self.area.x + target_width + x_padding + target_width + x_padding, self.area.y + self.area.h + 10, target_width , target_width,  "blue", "SCISSORS")
	self.buttons_hidden = false

end

function Player:hide_buttons(dt)
	if self.choice_animations_done == false then
		if self.choice_animations_tweens_generated == false then
			table.insert(self.choice_animations_tweens, self.tween.new(self.choice_animations_timer_max, self.buttons.green, {x = self.buttons.red.x, alpha = 0}, "inBack"))
			table.insert(self.choice_animations_tweens, self.tween.new(self.choice_animations_timer_max, self.buttons.blue, {x = self.buttons.red.x, alpha = 0}, "inBack"))
			table.insert(self.choice_animations_tweens, self.tween.new(self.choice_animations_timer_max+0.5, self.buttons.red, {alpha = 0}))
			self.choice_animations_tweens_generated = true
		end

		if self.choice_animations_tweens_generated == true then
			if (self.choice_animations_tweens[1]:update(dt) == false ) and (self.choice_animations_tweens[2]:update(dt) == false) and (self.choice_animations_tweens[3]:update(dt) == false) then
				self.choice_animations_tweens[1]:update(dt)
				self.choice_animations_tweens[2]:update(dt)
				self.choice_animations_tweens[3]:update(dt)
			end

			if (self.choice_animations_tweens[1]:update(dt) == true ) and (self.choice_animations_tweens[2]:update(dt) == true) and (self.choice_animations_tweens[3]:update(dt) == true) then
				--reset everything
				self.choice_animations_done = true
				self.choice_animations_tweens_generated = false
				self.choice_animations_tweens = {}
				self.buttons_hidden = true

			end

		end


	end

end


function Player:update(dt, phase)
	--PLAYER ANIMATION
	self.img.timer = self.img.timer + 6 * dt * self.img.speed  --stagger?
	--update current quad 1 - 2 - 3 - 2 - 1
	if math.floor(self.img.timer%5) == 0 then
		self.img.current_quad = 1
	elseif  math.floor(self.img.timer%5) == 1 then
		self.img.current_quad = 2
	elseif  math.floor(self.img.timer%5) == 2 then
		self.img.current_quad = 3
	elseif  math.floor(self.img.timer%5) == 3 then
		self.img.current_quad = 2
	else
		self.img.current_quad = 1
	end

	--overwrite if reveal
	if (minigame_5.phase == "reveal") and (minigame_5.reveal_timer > minigame_5.reveal_timer_mid) then
		self.img.current_quad = 3
	end


	--update buttons
	for k, v  in pairs(self.buttons) do
		v:update(dt)
	end


end

function Player:draw()

	--Temp draw area of player
	love.graphics.setColor(1, 1, 1)
	--love.graphics.rectangle("fill", self.area.x, self.area.y, self.area.w, self.area.h)

	--DRAW PLAYER
	if self.player_number == 1 then
		love.graphics.setColor(0.5, 1, 0.5)
		love.graphics.draw(self.img.spritesheet, self.img.quads[self.img.current_quad], self.area.x, self.area.y)
	elseif self.player_number == 2 then
		love.graphics.setColor(1, 0.5, 0.5)
		love.graphics.draw(self.img.spritesheet, self.img.quads[self.img.current_quad], self.area.x + self.area.w, self.area.y, 0, -1, 1)
	end

	--SHOW Buttons
	for k, v  in pairs(self.buttons) do
		v:draw()
	end
	if self.buttons_hidden == true then
		love.graphics.setFont(minigame_5.font)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("READY", self.area.x, self.area.y + self.area.h, self.area.w, "center")
	end

	--SHOW WIN STARS
	if self.player_number == 1 then
		love.graphics.setColor(0.5, 1, 0.5)
		for i=1, minigame_5.number_of_wins.p1, 1 do
			love.graphics.draw(self.star_img, self.area.x + (50 + 10) * (i-1), self.area.y -50, 0,0.5, 0.5)
		end
	elseif self.player_number == 2 then
		love.graphics.setColor(1, 0.5, 0.5)
		for i=1, minigame_5.number_of_wins.p2, 1 do
			love.graphics.draw(self.star_img, self.area.x + (50 + 10) * (i-1), self.area.y - 50, 0,0.5, 0.5)
		end

	end

	if (minigame_5.phase == "reveal") and (minigame_5.reveal_timer > minigame_5.reveal_timer_mid) and (self.choice ~= nil)then
		if self.player_number == 1 then
			love.graphics.setColor(0.5, 1, 0.5, 1)
			love.graphics.draw(self.hands[self.choice], self.area.x, self.area.y)
		elseif self.player_number == 2 then
			love.graphics.setColor(1, 0.5, 0.5, 1)
			love.graphics.draw(self.hands[self.choice], self.area.x + self.area.w, self.area.y, 0, -1, 1)
		end
	end


end

return Player
