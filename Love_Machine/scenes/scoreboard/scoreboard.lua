scoreboard = {}
function scoreboard:init()

	self.scene_type = "transition"

	self.timer = 0
	self.timer_max = 3

	self.font = love.graphics.newFont("fonts/kg_happy/KGHAPPY.ttf", 110)

	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function scoreboard:update(dt)
	self.timer = self.timer + dt

	if self.timer >= self.timer_max then
		--NORMAL PARTY GAME
		if global_game_mode == "normal" then
			global_current_game_index = global_current_game_index + 1
			if global_current_game_index <= #global_reference_table then
				--LOAD THE MINIGAME IN QUESTION
				print(global_reference_table[global_current_game_index])
				collectgarbage("collect")
				gamestate.switch(require(global_reference_table[global_current_game_index]))

			else
				--Reinitialise all
				print("GOING BACK TO TITLESCREEN")
				love.event.quit("restart")
			end
		end --NORMAL GAME

		--SINGLE GAME
		if global_game_mode == "single" then
			collectgarbage("collect")
			gamestate.switch(require(global_reference_table[global_current_game_index]))
		end
	end
end

function scoreboard:draw(dt)

love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		----- DRAW HERE ----
		love.graphics.setFont(self.font)
		love.graphics.setColor(1,1,1)
		love.graphics.printf("SCORE", 0, 0, global_width, "center")

		love.graphics.printf("Player 1 : "..tostring(global_score_counter.p1), 0, global_height/2, global_width/2, "center")
		love.graphics.printf("Player 2 : "..tostring(global_score_counter.p2), global_width/2, global_height/2, global_width/2, "center")


		----- FINISH DRAWING ----
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.canvas, self.aspect_ratio.x, self.aspect_ratio.y, 0, self.aspect_ratio.scale, self.aspect_ratio.scale)

	draw_debug()
end

-----------------------------------------------------------------------
-------------------------- CONTROLS -----------------------------------
-----------------------------------------------------------------------



-----------------------------------------------------------------------
-------------------------- END CONTROLS -----------------------------------
-----------------------------------------------------------------------

function scoreboard:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function scoreboard:enter(previous)
	--DELETE PREVIOUS GAMESTATE
	previous = {}
	collectgarbage("collect")
	gamestate.show_stack()
	self.timer = 0
end

function scoreboard:leave()

end



-- NEEDS TO BE AT THE VERY END
return scoreboard
